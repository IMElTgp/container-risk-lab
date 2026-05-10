//go:build labhelpers

package main

import (
	"bufio"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"runtime"
	"strings"
	"syscall"
	"time"

	"golang.org/x/sys/unix"
)

const (
	privateRoot   = "/tmp/chroot-private-root"
	workerMarker  = "worker-private-root"
	readyFileName = "ready.status"
	afterFileName = "afteraction.status"
)

type workerReady struct {
	Tid       int
	MountNS   string
	CapEff    string
	CapPrm    string
	CapBnd    string
	LogFile   *os.File
	ReadyErr  error
}

func main() {
	runtime.LockOSThread()

	stateDir := os.Getenv("STATE_DIR")
	if stateDir == "" {
		stateDir = "/tmp/chroot-dev-state"
	}
	must(os.MkdirAll(stateDir, 0o755))

	actionCh := make(chan struct{})
	readyCh := make(chan workerReady, 1)

	go worker(stateDir, readyCh, actionCh)
	ready := <-readyCh
	must(ready.ReadyErr)

	mainTid := unix.Gettid()
	mainMountNS := mustThreadNS(mainTid, "mnt")
	must(dropCapabilityFamily(unix.CAP_SYS_ADMIN, unix.CAP_SETPCAP))
	mainStatusPath := fmt.Sprintf("/proc/self/task/%d/status", mainTid)
	mainCapEff := mustStatusValue(mainStatusPath, "CapEff")
	mainCapPrm := mustStatusValue(mainStatusPath, "CapPrm")
	mainCapBnd := mustStatusValue(mainStatusPath, "CapBnd")

	readyLines := []string{
		fmt.Sprintf("main_tid=%d", mainTid),
		fmt.Sprintf("main_mntns=%s", mainMountNS),
		fmt.Sprintf("main_CapEff=%s", mainCapEff),
		fmt.Sprintf("main_CapPrm=%s", mainCapPrm),
		fmt.Sprintf("main_CapBnd=%s", mainCapBnd),
		fmt.Sprintf("worker_tid=%d", ready.Tid),
		fmt.Sprintf("worker_mntns=%s", ready.MountNS),
		fmt.Sprintf("worker_CapEff=%s", ready.CapEff),
		fmt.Sprintf("worker_CapPrm=%s", ready.CapPrm),
		fmt.Sprintf("worker_CapBnd=%s", ready.CapBnd),
	}
	must(os.WriteFile(filepath.Join(stateDir, readyFileName), []byte(strings.Join(readyLines, "\n")+"\n"), 0o644))

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGUSR1)
	<-sigCh
	actionCh <- struct{}{}
	sleepForever()
}

func worker(stateDir string, readyCh chan<- workerReady, actionCh <-chan struct{}) {
	runtime.LockOSThread()

	logFile, err := os.OpenFile(filepath.Join(stateDir, afterFileName), os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0o644)
	if err != nil {
		readyCh <- workerReady{ReadyErr: err}
		return
	}

	if err := unix.Unshare(unix.CLONE_NEWNS | unix.CLONE_FS); err != nil {
		readyCh <- workerReady{ReadyErr: fmt.Errorf("unshare failed: %w", err)}
		return
	}

	if err := os.MkdirAll(privateRoot, 0o755); err != nil {
		readyCh <- workerReady{ReadyErr: err}
		return
	}
	if err := unix.Mount("tmpfs", privateRoot, "tmpfs", 0, ""); err != nil {
		readyCh <- workerReady{ReadyErr: fmt.Errorf("mount tmpfs failed: %w", err)}
		return
	}
	if err := os.WriteFile(filepath.Join(privateRoot, "root-marker.txt"), []byte(workerMarker+"\n"), 0o644); err != nil {
		readyCh <- workerReady{ReadyErr: err}
		return
	}

	if err := dropCapabilityFamily(unix.CAP_SYS_ADMIN, unix.CAP_SETPCAP); err != nil {
		readyCh <- workerReady{ReadyErr: err}
		return
	}

	tid := unix.Gettid()
	workerMountNS := mustThreadNS(tid, "mnt")
	readyCh <- workerReady{
		Tid:      tid,
		MountNS:  workerMountNS,
		CapEff:   mustStatusValue(fmt.Sprintf("/proc/self/task/%d/status", tid), "CapEff"),
		CapPrm:   mustStatusValue(fmt.Sprintf("/proc/self/task/%d/status", tid), "CapPrm"),
		CapBnd:   mustStatusValue(fmt.Sprintf("/proc/self/task/%d/status", tid), "CapBnd"),
		LogFile:  logFile,
		ReadyErr: nil,
	}

	<-actionCh

	must(unix.Chroot(privateRoot))
	must(os.Chdir("/"))
	marker, err := os.ReadFile("/root-marker.txt")
	must(err)

	lines := []string{
		fmt.Sprintf("worker_tid=%d", tid),
		fmt.Sprintf("mntns=%s", workerMountNS),
		fmt.Sprintf("marker=%s", strings.TrimSpace(string(marker))),
		fmt.Sprintf("cwd=%s", mustGetwd()),
	}
	_, err = logFile.WriteString(strings.Join(lines, "\n") + "\n")
	must(err)
	must(logFile.Sync())
	sleepForever()
}

func dropCapabilityFamily(dropCaps ...int) error {
	for _, capID := range dropCaps {
		if err := unix.Prctl(unix.PR_CAPBSET_DROP, uintptr(capID), 0, 0, 0); err != nil {
			return fmt.Errorf("bounding drop for cap %d failed: %w", capID, err)
		}
	}

	data, err := getCaps()
	if err != nil {
		return err
	}
	for _, capID := range dropCaps {
		clearBit(&data, capID, fieldEffective)
		clearBit(&data, capID, fieldPermitted)
		clearBit(&data, capID, fieldInheritable)
	}
	return setCaps(data)
}

type capField int

const (
	fieldEffective capField = iota
	fieldPermitted
	fieldInheritable
)

func getCaps() ([2]unix.CapUserData, error) {
	hdr := unix.CapUserHeader{Version: unix.LINUX_CAPABILITY_VERSION_3}
	data := [2]unix.CapUserData{}
	if err := unix.Capget(&hdr, &data[0]); err != nil {
		return data, err
	}
	return data, nil
}

func setCaps(data [2]unix.CapUserData) error {
	hdr := unix.CapUserHeader{Version: unix.LINUX_CAPABILITY_VERSION_3}
	return unix.Capset(&hdr, &data[0])
}

func clearBit(data *[2]unix.CapUserData, capID int, field capField) {
	idx := capID / 32
	bit := ^(uint32(1) << uint(capID%32))

	switch field {
	case fieldEffective:
		data[idx].Effective &= bit
	case fieldPermitted:
		data[idx].Permitted &= bit
	case fieldInheritable:
		data[idx].Inheritable &= bit
	}
}

func mustStatusValue(path, key string) string {
	value, err := statusValue(path, key)
	must(err)
	return value
}

func statusValue(path, key string) (string, error) {
	file, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		k, v, found := strings.Cut(line, ":")
		if found && k == key {
			return strings.TrimSpace(v), nil
		}
	}
	if err := scanner.Err(); err != nil {
		return "", err
	}
	return "", fmt.Errorf("key %s not found in %s", key, path)
}

func mustReadlink(path string) string {
	value, err := os.Readlink(path)
	must(err)
	return value
}

func mustThreadNS(tid int, nsType string) string {
	return mustReadlink(fmt.Sprintf("/proc/self/task/%d/ns/%s", tid, nsType))
}

func mustGetwd() string {
	wd, err := os.Getwd()
	must(err)
	return wd
}

func must(err error) {
	if err == nil {
		return
	}
	fmt.Fprintln(os.Stderr, err)
	os.Exit(1)
}

func sleepForever() {
	for {
		time.Sleep(time.Hour)
	}
}

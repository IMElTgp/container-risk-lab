//go:build labhelpers

package main

import (
	"bufio"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"time"

	"golang.org/x/sys/unix"
)

const (
	modeAfterExec = "afterexec"
)

var trackedKeys = []string{
	"CapInh",
	"CapPrm",
	"CapEff",
	"CapBnd",
	"CapAmb",
	"NoNewPrivs",
}

func main() {
	stateDir := os.Getenv("STATE_DIR")
	if stateDir == "" {
		stateDir = "/lab/state"
	}

	if len(os.Args) > 1 && os.Args[1] == modeAfterExec {
		must(writeStatusFile(filepath.Join(stateDir, "afterexec.status")))
		sleepForever()
	}

	must(os.MkdirAll(stateDir, 0o755))
	must(armDelayedCapability())
	must(writeStatusFile(filepath.Join(stateDir, "armed.status")))

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGUSR1)
	<-sigCh

	exe, err := os.Executable()
	must(err)
	must(syscall.Exec(exe, []string{exe, modeAfterExec}, os.Environ()))
}

func armDelayedCapability() error {
	data, err := getCaps()
	if err != nil {
		return err
	}

	for _, capID := range []int{unix.CAP_SETUID, unix.CAP_SETPCAP} {
		setBit(&data, capID, fieldPermitted)
		setBit(&data, capID, fieldInheritable)
		setBit(&data, capID, fieldEffective)
	}

	if err := setCaps(data); err != nil {
		return err
	}

	if err := unix.Prctl(unix.PR_CAP_AMBIENT, unix.PR_CAP_AMBIENT_RAISE, uintptr(unix.CAP_SETUID), 0, 0); err != nil {
		return fmt.Errorf("raise ambient CAP_SETUID failed: %w", err)
	}

	data, err = getCaps()
	if err != nil {
		return err
	}

	clearBit(&data, unix.CAP_SETUID, fieldEffective)
	clearBit(&data, unix.CAP_SETPCAP, fieldEffective)

	if err := setCaps(data); err != nil {
		return err
	}

	return nil
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

func setBit(data *[2]unix.CapUserData, capID int, field capField) {
	idx := capID / 32
	bit := uint32(1) << uint(capID%32)

	switch field {
	case fieldEffective:
		data[idx].Effective |= bit
	case fieldPermitted:
		data[idx].Permitted |= bit
	case fieldInheritable:
		data[idx].Inheritable |= bit
	}
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

func writeStatusFile(path string) error {
	lines, err := readTrackedStatus()
	if err != nil {
		return err
	}

	content := []string{
		fmt.Sprintf("pid=%d", os.Getpid()),
		fmt.Sprintf("tid=%d", unix.Gettid()),
		fmt.Sprintf("uid=%d", os.Getuid()),
	}
	content = append(content, lines...)
	content = append(content, fmt.Sprintf("timestamp=%d", time.Now().Unix()))

	return os.WriteFile(path, []byte(strings.Join(content, "\n")+"\n"), 0o644)
}

func readTrackedStatus() ([]string, error) {
	file, err := os.Open("/proc/self/status")
	if err != nil {
		return nil, err
	}
	defer file.Close()

	want := make(map[string]struct{}, len(trackedKeys))
	for _, key := range trackedKeys {
		want[key] = struct{}{}
	}

	lines := make([]string, 0, len(trackedKeys))
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		key, _, found := strings.Cut(line, ":")
		if !found {
			continue
		}
		if _, ok := want[key]; ok {
			lines = append(lines, strings.ReplaceAll(line, "\t", ""))
		}
	}
	if err := scanner.Err(); err != nil {
		return nil, err
	}

	return lines, nil
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

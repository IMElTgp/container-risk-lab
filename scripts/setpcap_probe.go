//go:build labhelpers

package main

import (
	"fmt"
	"os"
	"syscall"

	"golang.org/x/sys/unix"
)

func main() {
	data, err := getCaps()
	must(err)

	clearEff(&data, unix.CAP_NET_RAW)
	must(setCaps(data))

	data, err = getCaps()
	must(err)
	setEff(&data, unix.CAP_NET_RAW)
	must(setCaps(data))

	fd, err := syscall.Socket(syscall.AF_PACKET, syscall.SOCK_RAW, int(htons(0x0003)))
	if err != nil {
		fmt.Fprintf(os.Stderr, "raw socket creation after capset failed: %v\n", err)
		os.Exit(1)
	}
	_ = syscall.Close(fd)
	fmt.Println("capset restored CAP_NET_RAW into CapEff and raw socket creation succeeded")
}

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

func clearEff(data *[2]unix.CapUserData, capID int) {
	idx := capID / 32
	bit := ^(uint32(1) << uint(capID%32))
	data[idx].Effective &= bit
}

func setEff(data *[2]unix.CapUserData, capID int) {
	idx := capID / 32
	bit := uint32(1) << uint(capID%32)
	data[idx].Effective |= bit
}

func must(err error) {
	if err == nil {
		return
	}
	fmt.Fprintln(os.Stderr, err)
	os.Exit(1)
}

func htons(v uint16) uint16 {
	return (v<<8)&0xff00 | v>>8
}

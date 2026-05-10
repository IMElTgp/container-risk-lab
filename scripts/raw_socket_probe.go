//go:build labhelpers

package main

import (
	"fmt"
	"os"
	"syscall"
)

func main() {
	fd, err := syscall.Socket(syscall.AF_PACKET, syscall.SOCK_RAW, int(htons(0x0003)))
	if err != nil {
		fmt.Fprintf(os.Stderr, "raw socket creation failed: %v\n", err)
		os.Exit(1)
	}
	_ = syscall.Close(fd)
	fmt.Println("raw socket creation succeeded")
}

func htons(v uint16) uint16 {
	return (v<<8)&0xff00 | v>>8
}

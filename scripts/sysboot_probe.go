//go:build labhelpers

package main

import (
	"errors"
	"fmt"
	"os"

	"golang.org/x/sys/unix"
)

const invalidRebootCmd = 0x0badf00d

func main() {
	_, _, errno := unix.Syscall6(
		unix.SYS_REBOOT,
		uintptr(unix.LINUX_REBOOT_MAGIC1),
		uintptr(unix.LINUX_REBOOT_MAGIC2),
		uintptr(invalidRebootCmd),
		0,
		0,
		0,
	)
	if errno == 0 {
		fmt.Fprintln(os.Stderr, "unexpected reboot success with invalid command")
		os.Exit(1)
	}
	if errors.Is(errno, unix.EPERM) {
		fmt.Fprintf(os.Stderr, "reboot stopped at permission gate: %v\n", errno)
		os.Exit(1)
	}
	if !errors.Is(errno, unix.EINVAL) {
		fmt.Fprintf(os.Stderr, "unexpected reboot error: %v\n", errno)
		os.Exit(1)
	}

	fmt.Printf("reboot syscall passed capability gate and failed safely with invalid command: %v\n", errno)
}

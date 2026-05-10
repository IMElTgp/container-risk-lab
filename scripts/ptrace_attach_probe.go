//go:build labhelpers

package main

import (
	"fmt"
	"os"
	"strconv"
	"syscall"

	"golang.org/x/sys/unix"
)

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintln(os.Stderr, "usage: ptrace_attach_probe <pid>")
		os.Exit(2)
	}

	pid, err := strconv.Atoi(os.Args[1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "invalid pid: %v\n", err)
		os.Exit(2)
	}

	if err := unix.PtraceAttach(pid); err != nil {
		fmt.Fprintf(os.Stderr, "attach failed: %v\n", err)
		os.Exit(1)
	}

	var status syscall.WaitStatus
	if _, err := syscall.Wait4(pid, &status, 0, nil); err != nil {
		fmt.Fprintf(os.Stderr, "wait failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("attached wait_status=%#x\n", int(status))

	if err := unix.PtraceDetach(pid); err != nil {
		fmt.Fprintf(os.Stderr, "detach failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("detached")
}

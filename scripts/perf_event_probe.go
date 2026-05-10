//go:build labhelpers

package main

import (
	"fmt"
	"os"
	"unsafe"

	"golang.org/x/sys/unix"
)

func main() {
	attr := unix.PerfEventAttr{
		Type:   unix.PERF_TYPE_SOFTWARE,
		Config: unix.PERF_COUNT_SW_CPU_CLOCK,
		Size:   uint32(unsafe.Sizeof(unix.PerfEventAttr{})),
	}
	fd, err := unix.PerfEventOpen(&attr, 0, -1, -1, 0)
	if err != nil {
		fmt.Fprintf(os.Stderr, "perf_event_open failed: %v\n", err)
		os.Exit(1)
	}
	_ = unix.Close(fd)
	fmt.Println("perf_event_open succeeded")
}

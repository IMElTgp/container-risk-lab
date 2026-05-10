//go:build labhelpers

package main

import (
	"fmt"
	"os"

	"golang.org/x/sys/unix"
)

func main() {
	if err := unix.Ioperm(0x80, 1, 1); err != nil {
		fmt.Fprintf(os.Stderr, "ioperm grant failed: %v\n", err)
		os.Exit(1)
	}
	defer unix.Ioperm(0x80, 1, 0)

	fmt.Println("ioperm grant succeeded for port 0x80")
}

//go:build labhelpers

package main

import (
	"errors"
	"fmt"
	"os"

	"golang.org/x/sys/unix"
)

func main() {
	err := unix.DeleteModule("runtia_nonexistent_module", 0)
	switch {
	case err == nil:
		fmt.Fprintln(os.Stderr, "unexpectedly deleted a non-existent module")
		os.Exit(1)
	case errors.Is(err, unix.EPERM):
		fmt.Fprintf(os.Stderr, "delete_module stopped at permission gate: %v\n", err)
		os.Exit(1)
	case !errors.Is(err, unix.ENOENT):
		fmt.Fprintf(os.Stderr, "unexpected delete_module error: %v\n", err)
		os.Exit(1)
	default:
		fmt.Printf("delete_module passed the capability gate and failed safely with: %v\n", err)
	}
}

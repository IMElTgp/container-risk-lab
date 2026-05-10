//go:build labhelpers

package main

import (
	"fmt"
	"os"
	"unsafe"

	"golang.org/x/sys/unix"
)

type bpfInsn struct {
	Code   uint8
	Regs   uint8
	Off    int16
	Imm    int32
}

type bpfProgLoadAttr struct {
	ProgType           uint32
	InsnCnt            uint32
	Insns              uint64
	License            uint64
	LogLevel           uint32
	LogSize            uint32
	LogBuf             uint64
	KernVersion        uint32
	ProgFlags          uint32
	ProgName           [16]byte
	ProgIfindex        uint32
	ExpectedAttachType uint32
}

type bpfProgTestRunAttr struct {
	ProgFD      uint32
	Retval      uint32
	DataSizeIn  uint32
	DataSizeOut uint32
	DataIn      uint64
	DataOut     uint64
	Repeat      uint32
	Duration    uint32
	CtxSizeIn   uint32
	CtxSizeOut  uint32
	CtxIn       uint64
	CtxOut      uint64
	Flags       uint32
	Cpu         uint32
	BatchSize   uint32
}

func ptrToU64[T any](p *T) uint64 {
	return uint64(uintptr(unsafe.Pointer(p)))
}

func bpf(cmd uintptr, attr unsafe.Pointer, size uintptr) (uintptr, error) {
	r1, _, errno := unix.Syscall(unix.SYS_BPF, cmd, uintptr(attr), size)
	if errno != 0 {
		return 0, errno
	}
	return r1, nil
}

func main() {
	license := append([]byte("GPL"), 0)
	logBuf := make([]byte, 64*1024)
	dataIn := []byte("runtia-bpf-proof")
	dataOut := make([]byte, len(dataIn))

	insns := []bpfInsn{
		{
			Code: unix.BPF_ALU64 | unix.BPF_MOV | unix.BPF_K,
			Imm:  7,
		},
		{
			Code: unix.BPF_JMP | unix.BPF_EXIT,
		},
	}

	var loadAttr bpfProgLoadAttr
	loadAttr.ProgType = unix.BPF_PROG_TYPE_SOCKET_FILTER
	loadAttr.InsnCnt = uint32(len(insns))
	loadAttr.Insns = ptrToU64(&insns[0])
	loadAttr.License = ptrToU64(&license[0])
	loadAttr.LogLevel = 1
	loadAttr.LogSize = uint32(len(logBuf))
	loadAttr.LogBuf = ptrToU64(&logBuf[0])
	copy(loadAttr.ProgName[:], []byte("runtiabpf"))

	fdRaw, err := bpf(uintptr(unix.BPF_PROG_LOAD), unsafe.Pointer(&loadAttr), unsafe.Sizeof(loadAttr))
	if err != nil {
		fmt.Fprintf(os.Stderr, "bpf prog load failed: %v\n", err)
		if n := bytesUntilNUL(logBuf); n > 0 {
			fmt.Fprintf(os.Stderr, "verifier log:\n%s\n", string(logBuf[:n]))
		}
		os.Exit(1)
	}
	fd := int(fdRaw)
	defer unix.Close(fd)

	testAttr := bpfProgTestRunAttr{
		ProgFD:      uint32(fd),
		DataSizeIn:  uint32(len(dataIn)),
		DataSizeOut: uint32(len(dataOut)),
		DataIn:      ptrToU64(&dataIn[0]),
		DataOut:     ptrToU64(&dataOut[0]),
		Repeat:      1,
	}

	if _, err := bpf(uintptr(unix.BPF_PROG_TEST_RUN), unsafe.Pointer(&testAttr), unsafe.Sizeof(testAttr)); err != nil {
		fmt.Fprintf(os.Stderr, "bpf prog test run failed: %v\n", err)
		os.Exit(1)
	}

	if testAttr.Retval != 7 {
		fmt.Fprintf(os.Stderr, "unexpected bpf retval: got %d want 7\n", testAttr.Retval)
		os.Exit(1)
	}

	fmt.Printf("bpf prog load and test run succeeded (retval=%d, duration=%d)\n", testAttr.Retval, testAttr.Duration)
}

func bytesUntilNUL(buf []byte) int {
	for i, b := range buf {
		if b == 0 {
			return i
		}
	}
	return len(buf)
}

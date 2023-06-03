package main

import (
	"fmt"
	"runtime"
	"time"
)

func cpuBound() {
	//goland:noinspection GoInfiniteFor
	for {
	}
}

func ioBound() {
	for {
		time.Sleep(100 * time.Millisecond)
		fmt.Printf("[%s] i'm not blocked by cpu bound goroutine\n", time.Now())
	}
}

// CheckAsyncPreemption
// From Go 1.14, CPU-bound goroutines (e.g. those having an infinite loop) don't block other goroutines, even with GOMAXPROCS=1.
// Setting GODEBUG=asyncpreemptoff=1 disables this, letting a CPU-bound goroutine monopolize the CPU.
func CheckAsyncPreemption() {
	maxProcs := runtime.GOMAXPROCS(1)
	fmt.Printf("GOMAXPROCS was = %d\n", maxProcs)
	go cpuBound()
	go ioBound()
	time.Sleep(250 * time.Millisecond)
}

package main

import (
	"fmt"
	"io"
	"net"
	"net/http"
)

func pingIPHandler(w http.ResponseWriter, _ *http.Request) {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		fmt.Println(err)
		return
	}

	for _, addr := range addrs {
		if ipnet, ok := addr.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
			if ipnet.IP.To4() != nil {
				_, err = io.WriteString(w, ipnet.IP.String())
			} else {
				_, err = io.WriteString(w, ipnet.IP.String())
			}
		}
	}
	_, err = io.WriteString(w, " hello world")
	if err != nil {
		panic(err)
	}
}

func main() {
	http.HandleFunc("/ping", pingIPHandler)
	err := http.ListenAndServe(":8081", nil)
	if err != nil {
		panic(err)
	}
}

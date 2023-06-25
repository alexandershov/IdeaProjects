package main

import (
	"io"
	"net/http"
)

func pingHandler(w http.ResponseWriter, _ *http.Request) {
	_, err := io.WriteString(w, "hello world")
	if err != nil {
		panic(err)
	}
}

func main() {
	http.HandleFunc("/ping", pingHandler)
	err := http.ListenAndServe(":8081", nil)
	if err != nil {
		panic(err)
	}
}

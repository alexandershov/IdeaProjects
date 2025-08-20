package main

import "core:fmt"

Person :: struct {
  name: string,
  age: int,
}


main :: proc() {
    fmt.println("hello!")
    // slices, similar to Zig
    some_slice := []int{1, 4, 9}

    // defer
    defer fmt.println("exit")

    // Unions - tagged unions
    Int_or_bool :: union {int, bool}
    f: Int_or_bool = 23
    switch _ in f {
      case int: fmt.println("int!")
      case bool: fmt.println("bool!")
    }

    // for loop
    for item in some_slice {
        fmt.println(item)
    }

    me := Person {
      name = "sasa",
      age = 40,
    }
    future_me := Person {
      name = "sasa",
      age = 41,
    }
    // convert to structure of arrays
    mes : #soa[2]Person
    mes[0] = me
    mes[1] = future_me
    fmt.println(me.name)
    fmt.println(mes[1].age)

}
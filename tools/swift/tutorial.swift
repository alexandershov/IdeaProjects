// Swift is a replacement for Objective-C
// and uses the same runtime under the hood (reference counting, NSString etc)

// run this tutorial with `swift tutorial.swift` in command line


// protocols are like interfaces
protocol IntLike {
    func toInt() -> Int
}


// we can extend built-in types
extension String: IntLike {
    func toInt() -> Int {
       // ! unwraps an optional
        return Int(self)!
    }
}

func tutorial(name: String) {
    // let defines a constant
    let uppercasedName = name.uppercased()
    var mutableUppercasedName = name.uppercased()
    mutableUppercasedName += "abc"
    // string interpolation is done with \(...)
    print("hello \(mutableUppercasedName)")

    // arrays
    let names = ["john", "george"]
    print("names.count = \(names.count)")

    // dictionaries
    let ageByName = [
        "john": 31,
        "george": 99
    ]
    let johnAge = ageByName["john"]
    // johnAge is Optional(Int)
    print("john age = \(johnAge)")

    let name: String? = "optional string"
    // nameLength is also an optional, because we used ?. on another Optional
    let nameLength = name?.count
    print("name = \(name), nameLength = \(nameLength)")
    let number = "32".toInt()
    print("number = \(number)")
}

tutorial(name: "me")
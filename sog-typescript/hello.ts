// typescript is a strongly typed subset of javascript

// typescript has generics, which are similar to Java/C# generics
function identity<Type>(value: Type): Type {
    return value
}

// typescript has interfaces
interface WithLength {
    length: number
}

// interfaces can be used in generics
// this is similar to Java
function getLength<Type extends WithLength>(value: Type): number {
    return value.length
}

function checkTypescript() {
    let n = 32  // n has an inferred type number
    let x: number = 89  // explicit typing
    let y = identity(99)  // y has an inferred type number
    // let y: string = identity(99)  // doesn't typecheck, string is not a number
    let person = {name: "sasa", age: 38}
    // person.ag  // doesn't typecheck, person has no property .ag
    console.log(person.age)  // typechecks

    // typescript supports async/await
    // this is a classic async/await like in Python/C#
    // it colors functions
    const asyncFunc = async () => "test"
    const asyncWrapper = async () => {
        // you can do await only inside the async function
        let value = await asyncFunc() // value has inferred type string
    }
    let promise = asyncFunc()  // promise has an inferred type Promise<string>

}
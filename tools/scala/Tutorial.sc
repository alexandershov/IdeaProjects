// scala has enum classes
enum Color:
  case Red, Green, Blue

object Tutorial {
  def main(args: Array[String]) = {
    println("hello")
    // Scala has significant indentation in some places since Scala 3
    // you can have ifs with significant indentations but you can't have
    // classes/functions with significant indentations
    if true then
      println("first in if")
      println("second in if")
    else
      print("first in else")

    // `color` can't reassigned, because we used val
    val color = Color.Red

    // pattern matching with exhaustion checks during compilation
    color match
      case Color.Red => println("red")
      case Color.Green => println("green")
      case Color.Blue => println("blue")

    // keyword arguments
    println(add(x=9, y=11))

    // lambdas
    val double = ((x: Int) => x + x)
    println(double(9))
    val ages = Map("me" -> 38)
    // maps/array items can be accessed via (...)
    println(ages("me"))

    val numbers = List(8, 9, 10)
    // map & friends, (_ + 1) is the same as (x => x + 1)
    println(numbers map (_ + 1))
  }

  def add(x: Int, y: Int): Int = {
    // return value is the value of last expression
    x + y
  }
}
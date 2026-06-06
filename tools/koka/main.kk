// user-defined effect `yield` supports one method `yield`
effect yield
  ctl yield( i : int ) : bool


// function traverse performs yield effect
fun traverse( xs : list<int> ) : yield ()
  match xs
    // here we perform effect
    Cons(x,xx) -> if yield(x) then traverse(xx) else ()
    Nil        -> ()

fun print-elems() : console ()
  // here we set set a handler for yield effect
  // essentially code calling yield will jump here
  with ctl yield(i)
    println("yielded " ++ i.show)
    // resume will jump back where effect will be performed
    resume(i<=2)
  traverse([1,2,3,4])

fun main()
    print-elems()
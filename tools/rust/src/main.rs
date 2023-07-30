use std::fs::File;
use std::io;
use std::io::Read;
use crate::Token::Comma;

fn my_print(s: String) {
    println!("s = {}", s);
}

fn first_two_bytes(s: &str) -> &str {
    // first_two_bytes returns a slice: basically a reference to some
    // part of the string
    return &s[0..2];
}

// we can annotate function with lifetimes
// here 'a is a intersection of lifetimes of first and second
// without lifetime annotations we'll get a compile time error
// because rust can't automatically figure out the lifetime of result
// after all the lifetime of result is dynamic
fn one_of<'a>(first: &'a str, second: &'a str) -> &'a str {
    if first.len() > second.len() {
        return first;
    }
    return second;
}

fn explicit_errors(path: &str) {
    // if a function can fail, then it should return Result
    // Result is enum with two member Ok and Err
    // we can pattern match on it
    // this is basically like go
    let open_result = File::open(path);
    match open_result {
        Ok(file) => { println!("opened a file {:?}", file) }
        Err(err) => { println!("got an error {}", err) }
    }
    // btw file will be closed when open_result will go out of the scope RAII
}

fn implicit_errors(path: &str) -> Result<String, io::Error> {
    // ? operator allows us to propagate errors automatically
    // if result is Ok, then it's used
    // if result is Err, then it's returned
    // here open_result is a File,
    // not a Result,                           V (notice the ? here)
    let mut open_result = File::open(path)?;
    let mut content = String::new();
    open_result.read_to_string(&mut content)?;
    // btw returning owned type from the function transfers ownership
    // btw #2 rust is an expression-oriented language, so we can skip
    // the return in the last line of the function
    Ok(content)
}

// enums are ADT
enum Token {
    Number(i64),
    Keyword(String),
    Comma,
}

fn main() {
    let x = 9;
    // let is immutable by default, reassigning x won't work

    let mut y = 10;
    println!("y = {}", y);
    y = 11;  // this works because of `let mut`

    // println! is a macro, that allows printing with type-safe format strings
    // macros are tough to write in Rust, so I'll skip it
    println!("x = {}, y = {}", x, y);
    let name = String::from("sasa");
    let other_name = name;
    // String is an owned type
    // after `other_name = name`, name is moved into other_name
    // and name itself becomes invalid
    // so you can't use `name` after move
    // use after move is a compile error in rust
    // that's why next line is commented out
    // println!("hello {}", name)

    println!("hello {}", other_name);
    // here other_name is moved into function argument
    my_print(other_name);
    // next line is commented out, because it's use after move
    // my_print(other_name);
    let mut language = String::from("rust");
    let two_bytes = first_two_bytes(&language);
    // we can have many immutable borrows
    // immutable borrow is basically when we use a reference to something
    // mutable borrow is the same as immutable, only we can change the object
    // next line will fail to compile, we can't mutate something that has active immutable references
    // language.push_str("abc");

    println!("{}", two_bytes);

    let token = Comma;
    let n = match token {
        // match should be exhaustive, if we comment any clause
        // we'll get a compile time error
        Comma => 1,
        Token::Number(b) => b,
        Token::Keyword(_) => 3  // _ as a wildcard match
    };
    println!("n = {}", n);
    explicit_errors("rust.md");
    let t: &str;
    // if we put first & second inside of the block, then we'll get a
    // compile time error, because lifetime of t don't match the lifetimes
    // of first and second
    // {
    let first = String::from("first");
    let second: String = String::from("second");
    t = one_of(&first, &second);
    // }
    println!("t = {}", t);
    let v = vec![1, 2, 3, 4, 5];
    // rust has closures
    let added_one: Vec<i32> = v.iter().map(|x| x + 1).collect();
    println!("added_one = {:?}", added_one);
    // panic is for unrecoverable errors
    // panic will stop executing the program and print stacktrace
    // panic!("nice seeing you");
}

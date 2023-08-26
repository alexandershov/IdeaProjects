(* module is like an interface *)
module type X_int = sig val x : int end

(* create a module that matches a signature *)
module Three : X_int = struct let x = 3 end

(* three is a first-class module, that you can use as a value *)
let three = (module Three : X_int)


(* with first-class modules we can create new modules without functors *)
let next_fn delta (module M : X_int) =
  (module struct
    let x = M.x + delta
  end : X_int);

(* in theory first-class modules are more powerful than interfaces,
   but nobody can tell why.
   I need to look at https://hirrolot.github.io/posts/compiler-development-rust-or-ocaml.html#type-flexibility-first-class-modules
   more carefully
*)

(* Functors have different meaning in OCaml.
   Functor is basically a function that converts module to another module.
   It's similar to C++ templates.
   The difference is that we can write wrong C++ template that will be checked
   during the instantiation time.

   With functors we are getting typechecking during the functor definition.
   Also OCaml uses structural subtyping. Result of Next is not a subtype of any module,
   but since its structure satisfies Int_x it can be used as X_int.
 *)
module Next (X : X_int) = struct let x = X.x + 1 end;;

(* we can apply functions several times on first-class modules *)
let four_fn = next_fn 1 (module Three : X_int);;
let five_fn = next_fn 1 (next_fn 1 (module Three : X_int));;

(*
  We apply functors using () syntax
  We can apply functors several times
*)
module Four = Next(Three);;
module Five = Next(Next(Three));;

print_int Four.x;
print_endline "";
print_int Five.x;
print_endline "";

(* we need to unpack first-class modules, to access .x *)

module Four_fn = (val four_fn : X_int);;
module Five_fn = (val five_fn : X_int);;
print_int Four_fn.x;
print_endline "";
print_int Five_fn.x;
print_endline "";

(* Basically functors or functions on first-class modules are more generic
   than e.g. "extend" keyword, you can describe any relationship between two
   modules. But all in all, OCaml modules provide basically the same functionality
   as generics/templates in other languages. Differences are miniscule and
   expressiveness is the same
*)


(* Modules combine functions + types, here's a stack module that hides
   how stack is implemented (that's the type `t` job) and works for any type a
*)

module type Stack = sig
  type 'a t

  val empty : 'a t
  val push : 'a -> 'a t -> 'a t
  val pop : 'a t -> 'a * 'a t
end;;

module List_Stack: Stack = struct
  type 'a t = 'a list

  let empty = []

  let push h s = h::s

  let pop s = match s with
  | [] -> raise (Invalid_argument "empty stack")
  | (x::xs) -> (x, xs)
end

let check_stack =
  let s = List_Stack.empty in
    (* here we can't use List_Stack.t as a list, it's an implementation detail
       invisible to the users of the List_Stack
    *)
    (List_Stack.push 8 (List_Stack.push 3 s))


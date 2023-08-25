(* module is like an interface *)
module type X_int = sig val x : int end;;

(* create a module that matches a signature *)
module Three : X_int = struct let x = 3 end;;

(* three is a first-class module, that you can use as a value *)
let three = (module Three : X_int);

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
 *)
module Next (X : X_int) = struct let x = X.x + 1 end;;

(*
  We apply functors using () syntax
  We can apply functors several times
*)
module Four = Next(Three);;
module Five = Next(Next(Three));;

print_int Four.x;
print_endline "";
print_int Five.x;
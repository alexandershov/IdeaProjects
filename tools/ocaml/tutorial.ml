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
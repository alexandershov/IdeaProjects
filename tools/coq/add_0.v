(* Theorem states that 0 + n = n for each natural number n *)
Theorem add_0_l : forall n : nat, 0 + n = n.
Proof.
  (* this is a proof *)
  intros n. simpl. reflexivity.
  (* `intros n` considers all natural numbers *)
  (* `simpl` simplifies the left part of equation `0 + n` to `n` *)
  (* reflexivity is a fancy word for "x is equal x, duh" *)
Qed.

(* Theorem states that 0 + n = n for each natural number n *)
Theorem add_0_l : forall n : nat, 0 + n = n.
Proof.
  (* this is a proof *)
  intros n. simpl. reflexivity.
  (* `intros n` considers all natural numbers *)
  (* `simpl` simplifies the left part of equation `0 + n` to `n` *)
  (* reflexivity is a fancy word for "x is equal x, duh" *)
Qed.

Theorem tuple_equality : forall (n m o p : nat),
     n = m -> (n, o) = (n, p) -> (n, o) = (m, p).
Proof.
  (* eq1 is (n = m), eq2 is the second equation *)
  intros n m o p eq1 eq2.

  (* replace m with n in goal *)
  rewrite <- eq1.

  (* apply tactic `apply`, it's unclear what apply tactic does *)
  apply eq2.
Qed.

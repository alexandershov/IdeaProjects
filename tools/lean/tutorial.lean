-- proof that N + 0 == N
theorem add_zero_nat (N : Nat) : N + 0 = N := by
-- this is class induction proof: we prove for 0, and then we prove for n + 1 considering that it holds for n
  induction N with
  | zero =>
  -- rfl stands for reflexivity, essentially we do 0 + 0 == 0 and ask lean to simplify it
  -- and check that it simplifies to equal lhs == rhs, it is indeed simplifies to 0 == 0
      rfl
  -- ih is Induction Hypothesis (it holds for n), meaning n + 0 == n
  | succ n ih =>
      -- calc blocks containing of two statements
      -- A = B := proof
      -- _ = C := proof
      -- means
      -- A = B := proof
      -- B = C := proof
      -- hence A == C
      -- here A == C is exactly what we need to proof
      calc
        -- this holds by reflexivity, because of addition definition
        (Nat.succ n) + 0 = Nat.succ (n + 0) := rfl
        -- n + 0 == n by induction, hence Nat.succ (n + 0) == Nat.succ n
        -- rw rewrites `n + 0` to `n` using induction hypothesis
        _                = Nat.succ n       := by rw [ih]


def main : IO Unit := do
  IO.println "all done"
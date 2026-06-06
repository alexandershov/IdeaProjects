----------------------------- MODULE main -----------------------------
EXTENDS Integers

VARIABLES A, B

Init ==
\* /\ means "AND"
    /\ A = 100
    /\ B = 100

\* A', B' are values of A, B after this action is applied
\* it's still boolean formula which is true (if A = 100, B = 50), when A' == 50, B' == 100
Transfer ==
    /\ A' = A - 50
    /\ B' = B + 50

Next ==
    Transfer

\* since we don't have overdraft protection TLA+ will eventually do bunch of transfers that will
\* violate overdraft invariant
\* this invariant prevents bad things from happening - this is called "safety" in TLA+.
\* "liveness" is "good things eventually happen", like system goes to expected state eventually
\* I ignore liveness in this file
NoOverdraft ==
    /\ A >= 0
    /\ B >= 0

Spec ==
\* this describes valid state transitions, this is logical formula
\* that is true when Init is true and we either do nothing or apply Next action
\* [][Next]_<<A, B>> means "next action is either nothing or applying Next"
\* "nothing" is to allow "stuttering" when nothing changes, because in a real world system can chill for some time
     Init /\ [][Next]_<<A, B>>

=============================================================================
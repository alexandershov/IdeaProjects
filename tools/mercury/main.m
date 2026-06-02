:- module main.
:- interface.
:- import_module io.

% di is Destructive Input
% uo is Unique Output
% det means that this predicate is deterministic
:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module int, list, string.

:- pred double(int, int).

% double(x, Y) is deterministic, because each in has exactly one output
:- mode double(in, out) is det.
% double(X, y) can find either zero (y is odd) or one (y is even) solution to X
:- mode double(out, in) is semidet.

% modes allow mercury compiler to have better optimization than prolog, because search scope is limited

:- pragma promise_equivalent_clauses(double/2).

double(X::in, Y::out) :-
    Y = X * 2.

double(X::out, Y::in) :-
    Y mod 2 = 0,
    X = Y / 2.

% !IO expands into two variables that hold the state of the world: input & output
main(!IO) :-
    double(21, A),
    io.format("double(21) = %d\n", [i(A)], !IO),

    ( if double(B, 42) then
        io.format("half(42) = %d\n", [i(B)], !IO)
    else
        io.write_string("42 has no integer half\n", !IO)
    ).
% so constraints over integers (like #=, #>) work
:- use_module(library(clpz)).

% for maplist
:- use_module(library(lists)).

% for if_
:- use_module(library(reif)).

% for *
:- use_module(library(debug)).

% for dif
:- use_module(library(dif)).

% these are simple facts
% atoms start with the lowercase
father(nikolai, sasha).
father(nikolai, andrei).
father(aleksandr, nikolai).

% this is a predicate of the form Head :- Body.
% If Body holds, then Head holds. Think of :- as an arrow from Body to Head.
% variables start with the uppercase
grandfather(F, C) :-
    father(F, X), % comma is AND
    father(X, C).

% you can ask prolog the most general query grandfather(X, Y) and it will find all solutions
% so Prolog predicates are functions that can work in all directions
% e.g. grandfather(aleksandr, X) finds all grandchildren

% prolog program consists of terms
% term is either variable (X), atom (y), or a compound term f(X, y).
% term is ground when it contains no variables

% the way to read this definition is by declarative style:
% empty list has length zero - holds always
% list with [H|Tail] is having Length, when list Tail is having Length - 1
list_length([], 0).
list_length([_|Ls], Length) :-
    % #= is an integer equality constraint, there are also #>, #<
    % scientific term for this is CLP(FD) - constraint logic programming over finite domain
    % for integers it's CLP(Z)
    Length #= Length0 + 1,
    list_length(Ls, Length0).

% what's cool about CLP(Z) is that these constraint work in two directions as usual in Prolog
% indomain finds matches
% this will find all cubes from 0 to 1000
% SomeX #= SomeY * SomeY * SomeY, SomeX #> 0, SomeX in 0..1000, indomain(SomeX).

% we can add extra constraints, e.g. cubes that are also squares. pretty cool! and totally declarative!
% it even finds negative SomeZ which I totally forgot about!
% label is multivariable version of indomain
% SomeX #= SomeY * SomeY * SomeY, SomeX #> 0, SomeX in 0..1000000, SomeX #= SomeZ * SomeZ, label([SomeX, SomeY, SomeZ]).

% There also higher-order predicate
% maplist(#>, [3, 2, 1], [2, 1, 0]).
% what's cool is that we can have variables:
% maplist(#>, [3, X, 1], [X, 1, 0]).
% and prolog is able to figure out that X must be equal to 2! (3 > X and X > 1) Awesome!

broken_list_length([], 0).
broken_list_length([_|T], N) :-
    N #= N0 + 2,
    broken_list_length(T, N0).

% broken_list_length is, ahem, broken
% with prolog we can find a counterexample
% broken_list_length(Ls, N), broken_list_length([_|Ls], N1), N1 #\= N + 1.
% here are the counterexamples, that prolog finds:
% Ls = [], N = 0, N1 = 2
%  ;  Ls = [_A], N = 2, N1 = 4

% you can have two types of problems in your prolog programs:
% 1. your program are too generic - they find extra solutions
% 2. your program are too specific - they don't find all solutions
% problem 1. is fixed by adding more goals
% problem 2. is fixed by adding more rules
% adding just more rules will not solve problem 1 - you'll just get more solutions, still too generic

another_broken_list_length([], 0).
another_broken_list_length([_|T], N) :-
    N #= N0 + 1,
    % * is not exactly a comment, it makes a goal to disappear
    % it's kinda like comment, even better, because it works on a last goal (comment will also remove trailing .)
    % with * we can exclude goals from search, thus making our program more general and find a problematic goal
    * N0 #= X * 2,
    * X in 1..N,
    another_broken_list_length(T, N0).

% prolog has pairs, - constructs a pair
number_number_pair_and_sum(X, Y, X-Y, S) :-
    S #= X + Y.

% ?- number_number_pair_and_sum(3, 2, P, S).
%   P = 3-2, S = 5.
% it works in all directions!
% ?- number_number_pair_and_sum(X, Y, P, 9), X in 0..100, Y in 0..100, indomain(X).
% X = 0, Y = 9, P = 0-9
% X = 1, Y = 8, P = 1-8


% all_distinct is true when all elements are all_distinct
% ins is a list version of in
% this finds all distinct triplets of numbers between 0 and 2
% all_distinct([X, Y, Z]), [X, Y, Z] ins 0..2, label([X, Y, Z]).
%   X = 0, Y = 1, Z = 2
% ;  X = 0, Y = 2, Z = 1
% ;  X = 1, Y = 0, Z = 2
% etc

% you should think declaratively when writing prolog
% think in terms of relations, not in terms of what's getting calculated
% remember, prolog predicate work in all directions
% here's "remove element from a list" (why in quotes) will be clear a bit alter
list_element_filtered_list([], _, []).

list_element_filtered_list([H|Ls], E, [H|F]) :-
    % dif means 'different'
    dif(E, H),
    list_element_filtered_list(Ls, E, F).

list_element_filtered_list([E|Ls], E, F) :-
    list_element_filtered_list(Ls, E, F).

% let's "remove" element from a list
% ?- list_element_filtered_list([a, b, c, a], a, F).
%   F = "bc"
% it works as expected, but actually it's not remove!
% it's a relation between 3 things!
% we can find "what element was removed" between 2 lists!
% ?- list_element_filtered_list([a, b, c, a], X, [b, c]).
%   X = a
% wow!
% we can find "from what list we can remove a and get [b, c]"
% ?- list_element_filtered_list(Ls, a, [b, c]).
%    Ls = "bc"
% ;  Ls = "bca"
% ;  Ls = "bcaa"
% so this predicate works in all directions!
% granted direction to find Ls is not very interesting, but "which element was removed" is super nice!

% prolog is actually quite lispy, you can get canonical/lispy form of the expression with write_canonical
% ?- write_canonical( (my_sum(X, Y, Z) :- Z #= X + Y) ).
% :-(my_sum(_612322,_612323,_612324),#=(_612324,+(_612322,_612323)))   true.
% note that there's no infix notation in canonical form

int_int_sum(X, Y, Z) :- Z #= X + Y.

% now prolog will rewrite terms that look like term_expansion first argument into second
% this is prolog answer to lisp macros
user:term_expansion(
    (wrong_int_int_sum(X, Y, Z) :- X #= Y + Z),
    (wrong_int_int_sum(X, Y, Z) :- int_int_sum(X, Y, Z))
).

% this definition will rewritten using user:term_expansion
wrong_int_int_sum(X, Y, Z) :- X #= Y + Z.


% cuts (!) allow you to skip backtracking.
% but cuts are not-declarative and harmful!
% let's take this example
% the idea is to have a predicate for a list construction
broken_list([]) :- !.  % it looks like this cut will save us backtracking
broken_list([_|Ls]) :- broken_list(Ls).

% but this cut actually harms generality
% ?- broken_list(Ls).
%    Ls = [].
% it generates just one example!
% this cut only works when list is instantiated.
% But prolog predicates are more general - they should generate solution
correct_list([]).
correct_list([_|Ls]) :- correct_list(Ls).
% ?- correct_list(Ls).
%    Ls = []
% ;  Ls = [_A]
% ;  Ls = [_A,_B]
% ;  Ls = [_A,_B,_C]
% etc

% so constraints over integers (like #=, #>) work
:- use_module(library(clpz)).

% for maplist
:- use_module(library(lists)).

% for if_
:- use_module(library(reif)).

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

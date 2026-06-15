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
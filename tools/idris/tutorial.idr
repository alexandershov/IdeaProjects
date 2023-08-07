module Main

import Data.Nat

-- Idris is a functional programming language similar to Haskell.

-- Nat is a type of natural numbers
myPlus : Nat -> Nat -> Nat
-- Z is zero
myPlus x Z = x
-- S is successor
myPlus x (S y) = S (myPlus x y)

-- types are first-class in idris
-- isSingleton returns a computed type
isSingleton : Bool -> Type
isSingleton True = Nat
isSingleton False = List Nat

-- Now (isSingleton True|False) is a normal type

-- we can construct instances of this type ...
mkSingle : (x: Bool) -> isSingleton x
mkSingle True = 0
mkSingle False = [1]

-- and use it in functions
sum : (single: Bool) -> isSingleton single -> Nat
sum True x = x
sum False [] = 0
sum False (x::xs) = x + (sum False xs)

-- having a List with the length as part of its type is a classic example of dependent types
data MyVect : Nat -> Type -> Type where
    Nil : MyVect Z a
    (::) : a -> MyVect k a -> MyVect (S k) a


-- Fin n represents a set of numbers from 0 to n - 1 inclusive
data Fin : Nat -> Type where
    -- FZ represents zeroth element of Fin (S k)
    -- We can't construct FZ for Fin 0, because of (S k)
    -- We can construct FZs for Fin 1, Fin 2, Fin 3, ...
    -- And these FZs will be different values
    FZ : Fin (S k)

    -- FS data constructor takes a Fin k which represents a number m
    -- 0 <= m < k
    -- and returns a Fin (k + 1) that represents a number == m + 1
    -- 0 <= m + 1 < k + 1
    -- since the root way to create a Fin is using FZ and FZ creates at least Fin 1
    -- it's impossible to create Fin 0
    FS : Fin k -> Fin (S k)


-- built-in Data.Fin can construct Fin directly from Nats, but that's just
-- convenience


myPlusSuccRightSucc : (n : Nat) -> (x : Nat) -> plus n (S x) = S (plus n x)
myPlusSuccRightSucc Z x = Refl
myPlusSuccRightSucc (S n) x = rewrite plusSuccRightSucc n x in Refl

-- idris needs some help with types, to understand that (n + (S x)) == S (n + x)
-- hence usage of rewrite
applyFS : (x: Nat) -> Fin n -> Fin (n + x)
applyFS Z f = rewrite plusZeroRightNeutral n in f
applyFS (S x) f = rewrite myPlusSuccRightSucc n x in applyFS x (FS f)


-- idris supports how many times a variable can be used (0, 1, or unrestricted)
-- here we saying that x will be used exactly one
-- if we remove usage of x (e.g. myId = 0), then we'll have a type error
myId : (1 x: Nat) -> Nat
myId x = x


makeFin : (n: Nat) -> Fin (S n)
makeFin n = let zero = (the (Fin 1) FZ) in
    applyFS n zero


Show (Fin n) where
    show FZ = "FZ"
    show (FS p) = "(FS " ++ (show p) ++ ")"


main : IO ()
main = do
    putStrLn (show (myPlus 3 9))
    putStrLn (show (sum (mkSingle False)))
    putStrLn (show (the (Fin 2) (FS FZ)))
    putStrLn (show (makeFin 3))

module Main

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

main : IO ()
main = do
    putStrLn (show (myPlus 3 9))
    putStrLn (show (sum (mkSingle False)))
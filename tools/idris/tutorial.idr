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


-- Fin n represents a set of numbers from 0 to n - 1 inclusive
data Fin : Nat -> Type where
    -- FZ represents zeroth element of Fin (S k)
    -- We can't construct FZ for Fin 0, because of (S k)
    FZ : Fin (S k)

    FS : Fin k -> Fin (S k)


Show (Fin n) where
    show FZ = "FZ"
    show (FS p) = "(FS " ++ (show p) ++ ")"


main : IO ()
main = do
    putStrLn (show (myPlus 3 9))
    putStrLn (show (sum (mkSingle False)))
    putStrLn (show (the (Fin 2) (FS FZ)))

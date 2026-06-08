{-# LANGUAGE GADTs #-}
import Data.List

-- ADTs (Algebraic Data Types) are basically enums on steroids
data ADTExpr =
 ADTIntLiteral Int |
 ADTStringLiteral String |
 ADTFuncall String ([ADTExpr] -> ADTExpr) [ADTExpr]


adtSum :: [ADTExpr] -> ADTExpr
adtSum [] = ADTIntLiteral 0
adtSum ((ADTIntLiteral x):xs) = let (ADTIntLiteral xsSum) = adtSum xs in
 ADTIntLiteral (x + xsSum)
-- we can't add strings, hence undefined
adtSum _ = undefined

adtEval :: ADTExpr -> ADTExpr
adtEval (ADTFuncall _ f args) = f $ map adtEval args
adtEval x = x

-- we can pattern match on ADTs (with exhaustive checks)
-- if we comment out any of the show clauses, then we'll get
-- a compile-time error "Non-exhaustive patterns in function show"
instance Show ADTExpr where
 show (ADTIntLiteral n) = show n
 show (ADTStringLiteral s) = show s
 show (ADTFuncall op _ args) = op ++ "(" ++ (intercalate ", " (map show args)) ++ ")"

-- GADTs (Generalized Abstract Data Types) are enums on NZT.
data Expr a where
    IntLiteral :: Int -> Expr Int
    StringLiteral :: String -> Expr String
    -- GADTs allow us to encode some behaviour into constructors
    -- and this behaviour can be checked at compile-time
    Funcall :: String -> ([a] -> b) -> [Expr a] -> Expr b

-- GADTs allow us to write type-safe eval
-- we can't construct an invalid expression, we'll get a compile-time error
-- e.g we can't have a list consisting of IntLiterals and StringLiterals
-- contrary to simple ADTs it doesn't typecheck
-- e.g. with simple ADTs we can have a list of Expr where
-- ADTStringLiterals & ADTIntLiterals are mixed
eval :: Expr a -> a
eval (IntLiteral x) = x
eval (StringLiteral s) = s
eval (Funcall _ f args) = f $ map eval args

-- GADTs can be used to have compiletime-checked fsm
data Requested
data Riding
data Completed


data Trip a where
   -- RequestedTrip, RidingTrip, CompletedTrip are data constructors and can be used in pattern matching
   -- Each trip will carry a String at runtime and will have a different type
   RequestedTrip :: String -> Trip Requested
   RidingTrip :: String -> Trip Riding
   CompletedTrip :: String -> Trip Completed

requestTrip :: String -> Trip Requested
requestTrip s = RequestedTrip s

startRiding :: Trip Requested -> Trip Riding
startRiding (RequestedTrip s) = RidingTrip s

completeTrip :: Trip Riding -> Trip Completed
completeTrip (RidingTrip s) = CompletedTrip s
-- if we'll try to use ADT for a fsm, then to have type-safety we would need to have different types
-- for different states (like RequestedTrip|RidingTrip|CompletedTrip) and it would be hard to implement
-- generic function on all trips (let's say extract String)

instance Show (Trip a) where
 show (RequestedTrip x) = show x
 show (RidingTrip x) = show x
 show (CompletedTrip x) = show x


instance Show (Expr a) where
 show (IntLiteral x) = show x
 show (StringLiteral s) = show s
 show (Funcall op _ args) = op ++ "(" ++ (intercalate ", " (map show args)) ++ ")"

main = do
    putStrLn (show $ ADTIntLiteral 8)
    putStrLn (show $ ADTStringLiteral "nice")
    putStrLn (show $ ADTFuncall "+" adtSum [ADTIntLiteral 8, ADTIntLiteral 9])
    putStrLn (show (adtEval $ ADTFuncall "+" adtSum [ADTIntLiteral 8, ADTIntLiteral 9]))
    -- next line typechecks but fails at runtime, because of undefined
    -- putStrLn (show (adtEval $ ADTFuncall "+" adtSum [ADTStringLiteral "try this", ADTIntLiteral 9]))

    putStrLn (show $ IntLiteral 8)
    putStrLn (show $ StringLiteral "nice")
    putStrLn (show $ Funcall "+" sum [IntLiteral 8, IntLiteral 9])
    putStrLn (show (eval $ Funcall "+" sum [IntLiteral 8, IntLiteral 9]))
    -- next line will fail at compile-time, that's the power the GADTs give us
    --  putStrLn (show (eval $ Funcall "+" sum [StringLiteral "try this", IntLiteral 9]))
    putStrLn (show $ requestTrip "my trip")
    putStrLn (show $ startRiding $ requestTrip "my trip")
    -- next line fails to compile, because completeTrip expects RidingTrip
    -- putStrLn (show $ completeTrip $ requestTrip "my trip")

    putStrLn "done!"
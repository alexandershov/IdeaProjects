-- this is the walkthrough of https://blog.sigfpe.com/2006/08/you-could-have-invented-monads-and.html

import Text.Printf

-- let's say we have a function that operates on floats
double :: Float -> Float
double x = 2 * x

-- now let's say that we want to show some debug information alongside with computation
-- this needs to be reflected in a function signature - haskell is pure
-- let's return debugging information alongside with the
debuggingDouble :: Float -> (Float, String)
debuggingDouble x = ((double x), (printf "called `double %.2f`" x))


debuggingTriple :: Float -> (Float, String)
debuggingTriple x = ((3 * x), (printf "called `triple %.2f`" x))

-- now let's say we want to compose two debugging functions
-- `debuggingDouble . debuggingTriple` won't work, because type don't match
-- let's write a function bind to help with composition
-- it takes a function and a result of some other function
-- and applies function to the result of some other function
-- while concatenating debug information
bind :: ((Float) -> (Float, String)) -> (Float, String) -> (Float, String)
bind f (resG, outG) =
    let (resF, outF) = f resG in
        (resF, outG ++ outF)

-- now we can compose two debugging functions with
-- (bind f) . g == this function takes a Float, applies g to it and then applies (bind f) to it

-- our composition is f * g == (bind f) . g
-- Ordinary composition has id with the following laws: id . f = f and f . id = f
-- let's define our id and call it unit:
unit :: Float -> (Float, String)
unit x = (x, "")

-- lift makes a debuggable function out of ordinary functions
-- lift :: (Float -> Float) -> Float -> (Float, String)
-- lift f x = ((f x), "")
-- or:
lift f = unit . f

-- let's prove that
-- lift f * lift g = lift (f . g)
-- (lift f * lift g) x = (bind(lift f) . lift g) x =
-- = bind(lift f) (g x, "") = f (g x), ""
-- (unit . f . g) x = (unit (f g x)) = (f (g x)), ""
-- QED
-- bind & unit allow us to compose debuggable functions

-- multivalued functions
-- bind :: (Complex Float -> [Complex Float]) -> [Complex Float] -> [Complex Float]
-- bind f resG = apply f to each resG and concatenate
-- unit x = [x]

-- so monad is a triple of (m, bind, unit) and this triple must obey laws
-- bind f x is written as x >>= f (we pass monad into a function that works on ordinary values)
--
-- do notation is a syntax sugar over bind and composition
-- do
--   x <- debuggingDouble 4
--   debuggingTriple x
-- is the same as
-- (debuggingDouble 4) >>= debuggingTriple
-- or the same as
-- (debuggingDouble 4) ==> (\x -> code after the <- statement)
-- it's just using >>= internally to have a nicer syntax
-- cool stuff with >>= is that we can chain it
-- x >>= f >>= g >>= h >>= ..
-- essentially monads give you a way to compose different computations and (sometimes) pass some context around
-- think of them "as programmable semicolons (end of statements)": with do notations and monads you get to decide
-- and implement what you need to do with the result of the action
-- Now: why there's no function extract :: m a -> a?
-- because monad contains more information that just an `a` (e.g. Maybe contains None)

-- why there's no function bind :: m a -> (m a -> m b) -> m b?
-- because it would be useless! it's just a function application!
-- In that case every function would still need to extract value from monad.


main = do
    let (dd_result_1, dd_msg_1) = (debuggingDouble 8)
    putStrLn dd_msg_1
    putStrLn "done!"
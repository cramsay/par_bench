{{#ghc}}
module Main where

import Control.Parallel.Strategies

main :: IO ()
main = print $ main'
main' :: Int

transcl_nested :: (Eq a) => (a -> [a]) -> [a] -> [[a]]
-- build_nested :: Int -> [[a]] -> [[a]]
nfib :: Int -> Int
bool :: Bool -> Int
{{/ghc}}

{{#heron}}
main = main'
{{/heron}}


-- main parallel version:
-- producing a list-of-list improves parallelism, since the position of an element
-- does not depend on all the previous elements
transcl_nested r xs =
  let zss = cons_nested xs r zss
  in zss
cons_nested xs r a = id $ xs : [] ++ build_nested r a 1 a

build_nested r zss j []       = []
build_nested r zss j (xs:xss) =
  let zss' = map (filter (not . (flip elem (concat (take j zss)))) . r) xs
  in zss' ++ build_nested r zss (j+length zss') xss

-- Example relations
-- r1 b n = if b>=n then [n+1] else []
-- r2 b n = if b>=n then filter (even) (reverse $ enumFromTo 1 (n-1)) else []
rlist d n = nfib ((d-1) `min` (n `max` d)) `seq` enumFromTo (n+1) (n+11)

nfib n =
  if n <= 1
    then 1
    else nfib (n-1) + nfib (n-2)

bool True = 1
bool False = 0

main' =
  let seeds   = enumFromTo 1 10
      bufSize = 16 -- parBuffer size
      m       = 1234 -- Dummy value to search for
      delay   = 22 -- Delay of `nfib` when applying the relation
      zs = transcl_nested (rlist delay) seeds
      strat = parBuffer bufSize (evalList rseq)
  in bool $ m `elem` (concat (zs {{^seq}}`using` strat{{/seq}}))

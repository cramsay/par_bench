{{#ghc}}
module Main where

{{^seq}}import Control.Parallel.Strategies{{/seq}}

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
-- r2 b n = if b>=n then filter (even) (reverse [1 .. (n-1)]) else []
rlist d n = nfib ((d-1) `min` (n `max` d)) `seq` [(n+1) .. (n+11)]

nfib n =
  if n <= 1
    then 1
    else nfib (n-1) + nfib (n-2)

bool True = 1
bool False = 0

main' =
  let seeds   = [1 .. 10]
      {{#big}}
      m       = 1534 -- Dummy value to search for
      delay   = 19 -- Delay of `nfib` when applying the relation
      {{/big}}
      {{^big}}
      m       = 27 -- Dummy value to search for
      delay   = 12 -- Delay of `nfib` when applying the relation
      {{/big}}
      zs = transcl_nested (rlist delay) seeds
{{^seq}}
      bufSize = 50 -- parBuffer size
      strat = parBuffer bufSize (evalList rseq)
  in bool $ m `elem` (concat (zs `using` strat))
{{/seq}}
{{#seq}}
  in bool $ m `elem` (concat zs)
{{/seq}}

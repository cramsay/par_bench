{{#ghc}}
module Main where

import Control.Parallel.Strategies

main :: IO ()
main = print $ main'

nqueens :: Int -> Int
nqueensPar :: Int -> Int -> Int
toOne :: Int -> [Int]
safe :: Int -> Int -> [Int] -> Bool
whenSafe :: [Int] -> Int -> [[Int]]
gen :: Int -> [[Int]] -> [[Int]]
genInner :: Int -> [Int] -> [[Int]]
main' :: Int
{{/ghc}}

{{#heron}}
main = main'
iterate f x = x : iterate f (f x)
{{/heron}}

nqueensPar threshold nq = length (pargen threshold nq 0 [])
nqueens nq = length (iterate (gen nq) [[]] !! nq)

toOne n = if n == 1
  then [1]
  else n : toOne (n - 1)

safe x d []    = True
safe x d (q:l) = (x /= q) && (x /= q+d) && (x /= q-d) && safe x (d+1) l

whenSafe b q = if safe q 1 b
                 then [q : b]
                 else []

gen nq bs = concatMap (genInner nq) bs

genInner nq b = concatMap (whenSafe b) (toOne nq)


pargen threshold nq n b =
 if threshold <= n
   then iterate (gen nq) [b] !! (nq - n)
   else let bs = map (pargen threshold nq (n+1)) (gen nq [b]) `using` parList (evalList (evalList rseq))
        in concat bs

main' =
  {{^seq}}nqueensPar 2 12{{/seq}}
  {{#seq}}nqueens      12{{/seq}}

{{#ghc}}
module Main where

import Control.Parallel.Strategies

main :: IO ()
main = print $ main'
main' :: Int

totients :: Int -> Int -> [Int]
{{/ghc}}

{{#heron}}
main = main'

rem x y = if y > x
            then x
            else rem (x-y) y
{{/heron}}

totients lower upper = map euler $ enumToFrom upper lower

-- Generating the list in reverse will schedule the biggest task first
enumToFrom u l
  = if u <= l
      then []
      else u : enumToFrom (pred u) l

euler n = length (filter (relprime n) (enumFromTo 1 n))

relprime x y = hcf x y == 1

hcf x y = if y == 0
            then x
            else hcf y (rem x y)

main' =
  let ts = totients 0 5000 {{^seq}}`using` parList rseq{{/seq}}
  in sum ts

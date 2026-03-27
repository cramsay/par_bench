{{#ghc}}
module Main where

import Prelude hiding(rem)

{{^seq}}import Control.Parallel.Strategies{{/seq}}

main :: IO ()
main = print $ main'
main' :: Int

totients :: Int -> Int -> [Int]
{{/ghc}}

{{#heron}}
main = main'
{{/heron}}

totients lower upper = map euler [upper,upper-1..lower]

euler n = length (filter (relprime n) [1..n])

relprime x y = hcf x y == 1

hcf x y = if y == 0
            then x
            else hcf y (rem x y)

rem x y = if y > x
            then x
            else rem (x-y) y

main' =
  let {{^big}}n = 70{{/big}}
      {{#big}}n = 1500{{/big}}
      ts = totients 0 n {{^seq}}`using` parList rseq{{/seq}}
  in maximum ts -- should be sum, but we have limited Ints

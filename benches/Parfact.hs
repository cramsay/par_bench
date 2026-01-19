{{#ghc}}
module Main where

import Control.Parallel
import Prelude hiding (div, divMod)

main :: IO ()
main = print $ main'
main' :: Int

div :: Int -> Int -> Int
div x y = case divMod x y of (d, m) -> d

divMod :: Int -> Int -> (Int,Int)
divMod x y = let  y2 = y + y in
             if y2 <= x
               then case divMod x y2 of
                      (d2, m2) ->
                        let d2x2 = d2 + d2
                        in if y <= m2
                             then (d2x2 + 1, m2 - y)
                             else (d2x2, m2)
               else if y <= x
                      then (1, x - y)
                      else (0, x    )
{{/ghc}}

{{#heron}}
main = main'
{{/heron}}

-- This one is a bit iffy. We actually compute the `sum [1..n]`, not `n!`, just
-- to keep the result managable with fixed width integers. Even then, this is
-- probably too large to fit in Heron's primitive integers...

-- concise version:
-- parfact_seq m n = product [m..n]
fact m n = fact' 1 m n
fact' acc m n =
  if (m>n)
    then acc
    else let acc' = acc + m -- acc * m
         in acc' `seq` fact' acc' (m + 1) n
         -- TODO Maybe we want the strictness in GHC only. Heron's PRS should do
         -- the trick faster

-- parallel worker function, with thresholding
parfact m n t =
  if (n-m) <= t
    -- seq version if interval size <= t
    then fact m n -- seq version if interval size <= t
    -- par version with d&c
    else let mid = (m+n) `div` 2
             left = parfact m mid t
             right = parfact (mid+1) n t
         in left `par` right `seq` left + right -- left * right

main' =
  {{^big}}let n = 1000{{/big}}
  {{#big}}let n = 16000{{/big}}
  in {{^seq}}parfact 1 n 1000{{/seq}}
     {{#seq}}fact 1 n{{/seq}}

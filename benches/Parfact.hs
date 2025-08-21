{{#ghc}}
module Main where

import Control.Parallel

main :: IO ()
main = print $ main'
main' :: Int
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
  let n = 50000000
  in {{^seq}}parfact 1 n 100000{{/seq}}
     {{#seq}}fact 1 n{{/seq}}

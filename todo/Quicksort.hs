{{#ghc}}
module Main where

import Control.Parallel
import Control.Parallel.Strategies

main :: IO ()
main = print $ main'
main' :: Int

threshold :: Int
{{/ghc}}

{{#heron}}
main = main'
{{/heron}}

lte x y = x <= y
gt x y = not (x <= y)

quicksortPar n xs =
  if n == 0
    then quicksort xs `using` evalList r0
    else case xs of
      [] -> []
      (pivot:rest) ->
        let low  = quicksortPar (n-1) (filter (gt  pivot) rest) `using` evalList r0
            high = quicksortPar (n-1) (filter (lte pivot) rest) `using` evalList r0
        in high `par` low ++ [pivot] ++ high

quicksort [] = []
quicksort (pivot:rest) = case rest of
  [] -> [pivot]
  (y:ys) -> let low  = quicksort $ filter (gt pivot) rest
                high = quicksort $ filter (lte pivot) rest
            in low ++ [pivot] ++ high

-- Version with ideal input
-- Each sublist should be equal size

interleave xs ys =
  if null xs
    then ys
    else if null ys
            then xs
            else head xs : interleave ys (tail xs)

inps l u =
  let mid = (((u-l)+1) `div` 2) + l
      ls  = inps l (mid-1)
      us  = inps (mid+1) u
  in mid : interleave ls us
genInps n = take n $ inps 0 n

threshold = 5
main' =
  let
      largeInp = genInps 150000
      sorted = {{^seq}}quicksortPar threshold largeInp{{/seq}}
               {{#seq}}quicksort largeInp{{/seq}}
  in maximum sorted

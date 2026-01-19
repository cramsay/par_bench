{{#ghc}}
module Main where

{{^seq}}import Control.Parallel.Strategies{{/seq}}

main :: IO ()
main = print $ main'

maximumGo :: Int -> [Int] -> Int
maximumGo n [] = n
maximumGo n xs = maximum xs
{{/ghc}}

{{#heron}}
main = main'
minBound = 0-16383
{{/heron}}

inits xs =
  case xs of
    []       -> [[]]
    (y : ys) -> xs : inits (init xs)

tails ys =
  case ys of
    [] -> []
    (x : xs) -> ys : tails xs

segments xs = map inits (tails xs)

maxSum xs =
  let segSums = map sum xs
  in maximumGo minBound segSums

mss xs =
  let xss = segments xs -- `using` evalList r0
      sums = map maxSum xss {{^seq}} `using` parList rseq {{/seq}}
  in maximum sums

main' =
  let 
      {{^big}}n = 20{{/big}}
      {{#big}}n = 300{{/big}}
      xs = enumFromTo (0-n) n -- `using` evalList rseq
  in mss xs

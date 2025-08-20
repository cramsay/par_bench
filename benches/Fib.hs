{{#ghc}}
module Main where

import Control.Parallel

main :: IO ()
main = print $ main'

pfib :: Int -> Int
fib :: Int -> Int
threshold :: Int
main' :: Int
{{/ghc}}

{{#heron}}
main = main'
{{/heron}}

pfib n =
  if n <= 1
    then 1
    else if n <= threshold
           then fib n
           else let x = pfib (n - 2)
                    y = pfib (n - 1)
                in x `par` y + x

fib n =
  if n <= 1
    then 1
    else fib (n-2) + fib (n-1)

threshold = 27
main' =
  let n = 34
  in {{^seq}}
     pfib n
     {{/seq}}
     {{#seq}}
     fib n
     {{/seq}}

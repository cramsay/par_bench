{{#ghc}}
module Main where

import Control.Parallel

main :: IO ()
main = print $ main'
main' :: Int

threshold :: Int
tak :: Int -> Int -> Int -> Int
ptak :: Int -> Int -> Int -> Int -> Int
{{/ghc}}

{{#heron}}
main = main'
{{/heron}}

ptak n x y z = case x <= y of
  True -> z
  False -> let n' = n - 1
               a = ptak n' (x - 1) y z
               b = ptak n' (y - 1) z x
               c = ptak n' (z - 1) x y
           in if n == 0
                then tak x y z
                else b `par` c `par` ptak n' a b c

tak x y z = case x <= y of
  True -> z
  False -> let a = tak (x - 1) y z
               b = tak (y - 1) z x
               c = tak (z - 1) x y
           in tak a b c

threshold = 8
main' =
  let
    {{^big}}
    x = 16
    y = 14
    z = 6
    {{/big}}
    {{#big}}
    x = 22
    y = 19
    z = 7
    {{/big}}
  in {{^seq}}ptak threshold x y z{{/seq}}
     {{#seq}}tak            x y z{{/seq}}

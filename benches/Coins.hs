{{#ghc}}
module Main where

import Control.Parallel.Strategies
import Control.Parallel

main :: IO ()
main = print $ main'

liftEval2 :: (a -> b -> c) -> Eval a -> Eval b -> Eval c
liftEval2 f x y = f <$> x <*> y 

lenA :: AList [Int] -> Int
lenAPar :: Int -> AList [Int] -> Int
nilA :: AList a -> Bool
append :: AList a -> AList a -> AList a
pay :: Int -> [(Int,Int)] -> [Int] -> AList [Int]
payPar :: Int -> Int -> [(Int,Int)] -> [Int] -> AList [Int]
parDepth :: Int
parLenDepth :: Int
main' :: Int
{{/ghc}}

{{#heron}}
liftEval2 f (Done x) sy = case sy of
  Done y -> Done (f x y)

main = main'
{{/heron}}

data AList a = ANil | ASing a | Append (AList a) (AList a)

lenA ANil          = 0
lenA (ASing a)     = length a `seq` 1
lenA (Append l r)  = lenA l + lenA r

lenAPar depth ANil = 0
lenAPar depth (ASing a) = length a `seq` 1
lenAPar depth (Append l r)  =
  if depth == 0
    then lenA l + lenA r
    else let depth' = depth-1
             llen = lenAPar depth' l
             rlen = lenAPar depth' r
         in rlen `par` llen + rlen

nilA ANil = True
nilA (ASing a) = False
nilA (Append l r) = False

append l r =
  if nilA l
    then r
    else if nilA r
           then l
           else Append l r

pay val coins0 acc =
  if val == 0
    then ASing acc
    else case coins0 of
      [] -> ANil
      (x:coins) -> case x of
        (c,q) -> if c > val
                   then pay val coins acc
                   else let left = pay (val-c) coins' (c:acc)
                            right = pay val coins acc
                            coins' = if q == 1 then coins
                                               else (c,q-1) : coins
                        in append left right

payPar depth val coins0 acc =
  if depth == 0
    then pay val coins0 acc
    else if val == 0
      then ASing acc
      else case coins0 of
        [] -> ANil
        (x:coins) -> case x of
          (c,q) -> if c > val
                     then payPar depth val coins acc
                     else let left = payPar (if q==1 then depth-1 else depth) (val-c) coins' (c:acc)
                              right = payPar (depth-1) val coins acc
                              coins' = if q == 1 then coins
                                                 else (c,q-1) : coins
                          in runEval $ liftEval2 append (rpar left) (rseq right)

parDepth = 3
parLenDepth = 3

main' =
  let coins = zip vals quants
      {{#big}}
      arg = 3841
      vals = [250, 100, 25, 10, 5, 1]
      quants = [9, 10, 15, 15, 15, 15]
      {{/big}}
      {{^big}}
      arg = 413
      vals = [250, 100, 25, 10, 5, 1]
      quants = [5,5,5,5,5,5]
      {{/big}}
  in {{^seq}}
     lenAPar parLenDepth $ payPar parDepth arg coins []
     {{/seq}}
     {{#seq}}
     lenA $ pay arg coins []
     {{/seq}}

module Main where

import Prelude hiding (splitAt)
import Control.Parallel.Strategies
import Control.Parallel

-- This is a bad implementation of half. The first list is reversed, but that's OK here.
half xs = half' (length xs) [] xs

half' n acc [] = (acc,[])
half' n acc (x:xs) =
  if n <= 0
    then (acc, x:xs)
    else half' (n-2) (x : acc) xs

merge [] ys = ys
merge (x:xs) ys = case ys of
  [] -> x:xs
  (z:zs) -> if x <= z
              then x : merge xs ys
              else z : merge (x:xs) zs

mergeSort xs = case xs of
  [] -> []
  (y:ys) -> case ys of
    [] -> [y]
    (z:zs) -> case half xs of
                (a,b) -> let a' = mergeSort a
                             b' = mergeSort b
                         in merge a' b'

mergeSortPar t xs =
  if t == 0
    then mergeSort xs
    else case xs of
      [] -> []
      (y:ys) -> case ys of
        [] -> [y]
        (z:zs) -> case half xs of
                    (a,b) -> let t' = t - 1
                                 a' = mergeSortPar t' a `using` evalList rseq
                                 b' = mergeSortPar t' b `using` evalList rseq
                             in b' `par` merge a' b'

main = let inp = enumFromTo 0 10000000
           threshold = 5
       in print (maximum $ mergeSortPar threshold inp)

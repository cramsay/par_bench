module Main where

import Prelude hiding (splitAt)
import Control.Parallel.Strategies
import Control.Parallel

mul x y = if x == 0
            then 0
            else (mul (x-1) y + y)

square x = mul x x

reduce acc x = acc + mul coeff x

coeff = 5000

main = let ops = map square (replicate 4000 coeff) `using` parBuffer 4 rseq
       in print $ foldl reduce 0 ops

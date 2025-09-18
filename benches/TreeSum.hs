{{#ghc}}
module Main where

import Control.Parallel

main :: IO ()
main = print $ main'
main' :: Int

mktree :: Int -> Int -> Tree Int
ptreesum :: Int -> Tree Int -> Int
treesum :: Tree Int -> Int
{{/ghc}}

{{#heron}}
main = main'
{{/heron}}

data Tree a = Leaf | Node a (Tree a) (Tree a)

mktree x n = if n==0 then Leaf
                     else let m = n-1
                          in Node x (mktree 0 m) (mktree 0 m)

ptreesum t Leaf = 0
ptreesum t (Node n l r) =
  if 0 > t
    then treesum (Node n l r)
    else let t' = t - 1
             l' = ptreesum t' l
             r' = ptreesum t' r
         in r' `par` l' + n + r'

treesum Leaf = 0
treesum (Node n l r) = treesum l + n + treesum r

main' =
  let x = mktree 42 23
  in {{^seq}}ptreesum 5 x{{/seq}}
     {{#seq}}treesum    x{{/seq}}

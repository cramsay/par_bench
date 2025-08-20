{{#ghc}}
module Main where

import Control.Parallel

main :: IO ()
main = print $ main'
main' :: Int

mktree :: Int -> Tree Int
ptreesum :: Int -> Tree a -> Int
treesum :: Tree a -> Int
{{/ghc}}

{{#heron}}
main = main'
{{/heron}}

data Tree a = Leaf | Node a (Tree a) (Tree a)

mktree n = if n==0 then Leaf
                   else let m = n-1
                        in Node n (mktree m) (mktree m)

ptreesum t Leaf = 1
ptreesum t (Node n l r) =
  if 0 > t
    then treesum (Node n l r)
    else let t' = t - 1
             l' = ptreesum t' l
             r' = ptreesum t' r
         in r' `par` 1 + l' + r'

treesum Leaf = 1
treesum (Node n l r) = treesum l + treesum r + 1

main' =
  let x = mktree 24
  in {{^seq}}ptreesum 5 x{{/seq}}
     {{#seq}}treesum    x{{/seq}}

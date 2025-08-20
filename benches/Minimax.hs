{{#ghc}}
{-# OPTIONS_GHC -Wno-incomplete-patterns #-}

module Main where

import Data.List (transpose)
import Control.Parallel.Strategies

main :: IO ()
main = print $ main'

data Piece = X | O | Empty
 deriving (Show)
type Row = [Piece]
type Board = [Row]
type Player = Evaluation -> Evaluation -> Evaluation
type Move = (Board, Evaluation)
data Evaluation = OWin | Score Int | XWin
  deriving (Show)
  -- Higher scores denote a board in X's favour
type Win = [[Int]]
data Tree a = Branch a [Tree a]
  deriving Show

boardDim :: Int
intEval :: Evaluation -> Int
cons :: a -> [a] -> [a]
isWin :: Evaluation -> Bool
alternate :: Int -> Piece -> Player -> Player -> Board -> [Move]
minE :: Evaluation -> Evaluation -> Evaluation
initialBoard :: Board
maxE :: Evaluation -> Evaluation -> Evaluation
static :: Board -> Evaluation
interpret :: Int -> [Evaluation] -> Evaluation
solve :: Int -> Board -> [Move]
score :: Board -> [Evaluation]
repTree :: (a->[a]) -> (a->[a])-> a -> (Tree a)
mapTree :: (a -> b) -> (Tree a) -> (Tree b)
prune :: Int -> (Tree a) -> (Tree a)
parMise
  :: Int
  -> (Evaluation -> Evaluation -> Evaluation)
  -> (Evaluation -> Evaluation -> Evaluation)
  -> Tree Evaluation
  -> Evaluation
main' :: Int
{{/ghc}}

{{#heron}}
main = main'

enumFrom m = m : enumFrom (succ m)

reverse = reverseOnto []
reverseOnto acc [] = acc
reverseOnto acc (x:xs) = reverseOnto (x:acc) xs

transpose [] = []
transpose (xs0 : xss) = case xs0 of
  [] -> transpose xss
  (x:xs) -> let rest = unzip (map transposeSplit xss)
            in (x : fst rest) : transpose (xs : snd rest)
transposeSplit (hd:tl) = (hd,tl)
{{/heron}}


-- TODO make seq version
main' =
  let depth = 5
  in intEval . snd . head $ solve depth testBoard

{{#big}}
testBoard =
  [[  O  ,Empty,Empty,Empty]
  ,[Empty,Empty,Empty,Empty]
  ,[Empty,Empty,Empty,Empty]
  ,[Empty,Empty,Empty,  X  ]
  ]
{{/big}}
{{^big}}
testBoard =
  [[Empty,Empty,Empty]
  ,[Empty,Empty,Empty]
  ,[Empty,Empty,Empty]
  ]
{{/big}}

--------------------------------------------------------------------------------
-- Game

boardDim = length $ head testBoard

intEval OWin = 99
intEval XWin = 101
intEval (Score x) = x

eqEval OWin e = case e of
  OWin -> True
  XWin -> False
  (Score x) -> False
eqEval XWin e = case e of
  XWin -> True
  OWin -> False
  (Score x) -> False
eqEval (Score x) e = case e of
  XWin -> False
  OWin -> False
  (Score y) -> x==y

cons x xs = x : xs

isWin XWin = True
isWin OWin = True
isWin (Score n) = False

alternate depth player f g board
  = if fullBoard board
      then []
      else if isWin (static board)
             then []
             else let opponent = opposite player
                      possibles = newPositions player board
                      scores = map (bestMove depth opponent g f) possibles {{^seq}} `using` parList rseq {{/seq}}
                      move = best f possibles scores
                      board' = fst move
                  in move : alternate depth opponent g f board'

opposite X = O
opposite O = X
opposite Empty = Empty

best f (b:bs) ss0 = case ss0 of
  (s:ss) -> best' f b s bs ss

best' f b s [] ss0 = (b,s)
best' f b s (b':bs) ss0 = case ss0 of
  (s':ss) -> if eqEval s (f s s')
               then best' f b  s  bs ss
               else best' f b' s' bs ss

bestMove depth p f g
{{^seq}}
  = parMise 2 f g
{{/seq}}
{{#seq}}
  = mise f g
{{/seq}}
  . cropTree
  . mapTree static
  . prune depth
  . searchTree p

cropTree (Branch x l) = case l of
  [] -> Branch x []
  (c:cs) -> case x of
    XWin -> Branch x []
    OWin -> Branch x []
    (Score a) -> Branch (Score a) (map cropTree l)

searchTree p board = repTree (newPositions p) (newPositions (opposite p)) board

mise f g (Branch a l) = case l of
  [] -> a
  (x:xs) -> foldr f (g OWin XWin) (map (mise g f) l)

parMise n f g t =
  if (n == 0)
    then mise f g t
    else case t of
      (Branch a l) -> case l of
         [] -> a
         (x:xs) -> foldr f (g OWin XWin) (map (parMise (n-1) g f) l `using` parList rseq)

--------------------------------------------------------------------------------
-- Board

isEmpty Empty = True
isEmpty X     = False
isEmpty O     = False

placePiece new board pos
  = zipWith (placePieceRow new pos) (enumFrom 1) board
placePieceRow new pos y row = zipWith (placePieceCol new pos y) (enumFrom 1) row
placePieceCol new (px,py) y x old =
  if ((px == x) && (py == y))
    then new
    else old

empty (x,y) board = isEmpty ((board !! (y-1)) !! (x-1))

fullBoard b = all (not . isEmpty) (concat b)

newPositions piece board = goRows piece id board

goRows p rowsL [] = []
goRows p rowsL (row:rowsR)
  = goRow p rowsL id row rowsR ++ goRows p (rowsL . (cons row)) rowsR


goRow p rowsL psL [] rowsR = []
goRow p rowsL psL (p':psR) rowsR = case p' of
  Empty -> (rowsL $ (psL $ (p:psR)) : rowsR) : goRow p rowsL (psL . (cons Empty)) psR rowsR
  X     -> goRow p rowsL (psL . (cons X)) psR rowsR
  O     -> goRow p rowsL (psL . (cons O)) psR rowsR

empties board = zipWith emptiesRow (enumFrom 1) board
emptiesRow y row = concat (zipWith (emptiesCell y) (enumFrom 1) row)
emptiesCell y x Empty = [(x,y)]
emptiesCell y x X = []
emptiesCell y x O = []

initialBoard = replicate boardDim (replicate boardDim Empty)

maxE XWin b = XWin
maxE OWin b = b
maxE (Score x) b = case b of
  XWin -> XWin
  OWin -> Score x
  (Score y) -> if x>y then Score x else Score y

minE OWin b = OWin
minE XWin b = b
minE (Score x) b = case b of
  OWin    -> OWin
  XWin    -> Score x
  (Score y) -> if (x<=y) then (Score x) else (Score y)

eval n =
  if n == boardDim
    then XWin
    else if (0-n) == boardDim
           then OWin
           else Score n

static board = interpret 0 (score board)

interpret x [] = (Score x)
interpret x (e:l) = case e of
  (Score y) -> interpret (x+y) l
  XWin -> XWin
  OWin -> OWin

scorePiece X     = 1
scorePiece O     = 0-1
scorePiece Empty = 0

scoreString n [] = n
scoreString n (X:ps)     = scoreString (n+1) ps
scoreString n (O:ps)     = scoreString (n-1) ps
scoreString n (Empty:ps) = scoreString n ps

score board =
  let r = map (eval . scoreString 0) board
      c = map (eval . scoreString 0) (transpose board)
      d1 = eval (scoreString 0 (zipWith (!!) board (enumFrom 0)))
      d2 = eval (scoreString 0 (zipWith (!!) board (reverse $ enumFromTo 0 (boardDim-1))))
  in r ++ c ++ [d1,d2]

--------------------------------------------------------------------------------
-- Prog

-- X to play: find the best move
solve depth board
  = take 1
  . alternate depth X maxE minE $ board

--------------------------------------------------------------------------------
-- Tree

repTree f g a = Branch a (map (repTree g f) (f a))

mapTree f (Branch a l) = Branch (f a) (map (mapTree f) l)
-- mapTree :: (a -> b) -> Tree a -> Tree b
-- mapTree f (Branch a l)
--    = fa `par` Branch fa (map (mapTree f) l `using` parList rseq)
--    where fa = f a

prune n (Branch a l) =
  if (n == 0) then Branch a []
              else Branch a (map (prune (n-1)) l)

module CfnFlip.Conduit
  ( takeBalancedC
  , module Conduit
  , module Data.Conduit.List
  ) where

import RIO

import Conduit
import Data.Conduit.List (sourceList)

-- | Take until an ending element, including any reopened-ended in between
--
-- >>> :{
-- runIdentity
--   $ runConduit
--   $ yieldMany "this is (a thing) here) and more"
--   .| takeBalancedC (== '(') (==')')
--   .| sinkList
-- :}
-- "this is (a thing) here)"
--
-- Note that imbalance will terminate early,
--
-- >>> :{
-- runIdentity
--   $ runConduit
--   $ yieldMany "this is, a) unexpected but b) the best we can do)"
--   .| takeBalancedC (== '(') (==')')
--   .| sinkList
-- :}
-- "this is, a)"
--
-- Or just run to the end
--
-- >>> :{
-- runIdentity
--   $ runConduit
--   $ yieldMany "this is (pretty unlikely"
--   .| takeBalancedC (== '(') (==')')
--   .| sinkList
-- :}
-- "this is (pretty unlikely"
--
takeBalancedC :: Monad m => (a -> Bool) -> (a -> Bool) -> ConduitT a a m ()
takeBalancedC reopens closes = go (0 :: Int)
 where
  go balance = do
    me <- await

    for_ me $ \a -> do
      let
        loop
          | closes a = unless (balance <= 0) $ go $ balance - 1
          | reopens a = go $ balance + 1
          | otherwise = go balance

      yield a >> loop

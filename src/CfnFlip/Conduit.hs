module CfnFlip.Conduit
  ( takeBalancedC
  , module Conduit
  ) where

import RIO

import Conduit

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
takeBalancedC :: Monad m => (a -> Bool) -> (a -> Bool) -> ConduitT a a m ()
takeBalancedC reopens closes = go (0 :: Int)
 where
  go balance = do
    me <- await

    for_ me $ \case
      a | closes a -> do
        yield a
        unless (balance <= 0) $ go $ balance - 1
      a | reopens a -> do
        yield a
        go $ balance + 1
      a -> do
        yield a
        go balance

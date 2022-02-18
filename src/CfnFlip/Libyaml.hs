module CfnFlip.Libyaml
  ( InvalidYamlEvent(..)
  , makeMapping
  , makeSequence
  , startsMapOrSequence
  , isSameStart
  , isStartsEnd
  , takeMapOrSequenceC
  , module Text.Libyaml
  ) where

import RIO

import CfnFlip.Conduit
import Text.Libyaml
  (Event(..), MappingStyle(..), SequenceStyle(..), Style(..), Tag(..))

data InvalidYamlEvent = InvalidYamlEvent Event String
  deriving stock Show
  deriving anyclass Exception

makeMapping
  :: Monad m => ByteString -> ConduitT i Event m () -> ConduitT i Event m ()
makeMapping tag inner = do
  yield $ EventMappingStart NoTag BlockMapping Nothing
  yield $ EventScalar tag NoTag Plain Nothing
  inner
  yield EventMappingEnd

makeSequence :: Monad m => ConduitT i Event m () -> ConduitT i Event m ()
makeSequence inner = do
  yield $ EventSequenceStart NoTag BlockSequence Nothing
  inner
  yield EventSequenceEnd

startsMapOrSequence :: Event -> Bool
startsMapOrSequence = \case
  EventMappingStart{} -> True
  EventSequenceStart{} -> True
  _ -> False

isSameStart :: Event -> Event -> Bool
x `isSameStart` y = case (x, y) of
  (EventMappingStart{}, EventMappingStart{}) -> True
  (EventSequenceStart{}, EventSequenceStart{}) -> True
  _ -> False

isStartsEnd :: Event -> Event -> Bool
x `isStartsEnd` y = case (x, y) of
  (EventMappingStart{}, EventMappingEnd{}) -> True
  (EventSequenceStart{}, EventSequenceEnd{}) -> True
  _ -> False

takeMapOrSequenceC :: Monad m => Event -> ConduitT Event Event m ()
takeMapOrSequenceC e = takeBalancedC (isSameStart e) (isStartsEnd e)

module CfnFlip.YamlToJson
  ( InvalidYamlEvent(..)
  , translate
  ) where

import CfnFlip.Prelude

import CfnFlip.Conduit
import CfnFlip.IntrinsicFunction
import CfnFlip.Libyaml
import qualified Data.ByteString as BS
import qualified Prelude as Unsafe (toEnum)

translate :: MonadIO m => ConduitT Event Event m ()
translate = awaitForever $ \case
  e@(EventScalar x (UriTag "!GetAtt") _ _) -> do
    (resource, attribute) <- maybe (throwInvalidGetAtt e x) pure $ parseGetAtt x

    makeMapping "Fn::GetAtt" $ makeSequence $ yieldMany
      [ EventScalar resource NoTag Plain Nothing
      , EventScalar attribute NoTag Plain Nothing
      ]

  e | Just tag <- getIntrinsicFunction e -> do
    makeMapping tag $ do
      yield e
      when (startsMapOrSequence e) $ takeMapOrSequenceC e .| translate

  e -> yield e

parseGetAtt :: ByteString -> Maybe (ByteString, ByteString)
parseGetAtt x = case BS.split (charToWord8 '.') x of
  [resource, attribute] -> Just (resource, attribute)
  _ -> Nothing

throwInvalidGetAtt :: MonadIO m => Event -> ByteString -> m a
throwInvalidGetAtt e x =
  throwIO
    $ InvalidYamlEvent e
    $ "!GetAtt shoule be \"Resource.Attribute\", saw "
    <> show x

charToWord8 :: Char -> Word8
charToWord8 = Unsafe.toEnum . fromEnum

{-# OPTIONS_GHC -Wno-missing-signatures #-}
{-# OPTIONS_GHC -Wno-missing-local-signatures #-}

module CfnFlip.Yaml
  ( encode
  , decode
  ) where

import CfnFlip.Prelude

import CfnFlip.Aeson (ToJSON(..))
import CfnFlip.Conduit
import CfnFlip.IntrinsicFunction
import CfnFlip.Libyaml
import qualified Data.Yaml as Yaml
import qualified Data.Yaml.Internal as Yaml
import qualified Text.Libyaml as Libyaml

newtype FromJSONError = FromJSONError String
  deriving stock Show
  deriving anyclass Exception

encode
  :: (MonadUnliftIO m, ToJSON a)
  => ConduitT Event Event (ResourceT m) ()
  -> a
  -> m ByteString
encode c a =
  runConduitRes
    $ sourceList (Yaml.objToStream stringStyle $ toJSON a)
    .| c
    .| fixQuoting
    .| Libyaml.encodeWith formatOptions
 where
  stringStyle = Yaml.defaultStringStyle

  formatOptions =
    Libyaml.setTagRendering Libyaml.renderUriTags Libyaml.defaultFormatOptions

fixQuoting :: Monad m => ConduitT Event Event m ()
fixQuoting = awaitForever $ yield . \case
  e@(EventScalar x t _ z) | Just _ <- getIntrinsicFunction e ->
    EventScalar x t SingleQuoted z
  e -> e

-- We can't type this because Parse (nor ParserState) is exported
--
-- TODO: File a bug
--
-- decode
--   :: (MonadIO m, FromJSON a)
--   => ConduitT Event Event Yaml.Parse ()
--   -> ByteString
--   -> m a
decode c bs = liftIO $ do
  result <- Yaml.decodeHelper $ Libyaml.decode bs .| c

  case result of
    Left a -> throwIO a
    Right (_, b) -> either (throwIO . FromJSONError) pure b

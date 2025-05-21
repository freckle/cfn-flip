module CfnFlip.Prelude
  ( module X
  , readFileBinary
  , writeFileBinary
  ) where

import Prelude as X

import Control.Monad as X (unless, when, (<=<))
import Control.Monad.IO.Class as X (MonadIO (..))
import Control.Monad.IO.Unlift as X (MonadUnliftIO)
import Data.ByteString as X (ByteString)
import Data.Foldable as X (for_, traverse_)
import Data.Maybe as X (fromMaybe)
import Data.Text as X (Text, pack, unpack)
import Data.Text.Encoding as X (encodeUtf8)
import Data.Word as X (Word8)
import UnliftIO.Exception as X (Exception, throwIO, throwString)

{- FOURMOLU_DISABLE -}

import qualified Data.ByteString as BS

{- FOURMOLU_ENABLE -}

{-# ANN module ("HLint: ignore Avoid restricted alias" :: String) #-}
{-# ANN module ("HLint: ignore Avoid restricted qualification" :: String) #-}

readFileBinary :: MonadIO m => FilePath -> m ByteString
readFileBinary = liftIO . BS.readFile

writeFileBinary :: MonadIO m => FilePath -> ByteString -> m ()
writeFileBinary p = liftIO . BS.writeFile p

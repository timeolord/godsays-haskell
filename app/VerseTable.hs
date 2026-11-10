{-# LANGUAGE TemplateHaskell #-}

module VerseTable (VerseTable, embed_verses, lookup_verse) where

import Bible (godphrases)
import Data.Bits (shiftR)
import qualified Data.ByteString as BS
import qualified Data.ByteString.UTF8 as BSU
import Data.FileEmbed (bsToExp)
import Data.Word (Word8)
import Language.Haskell.TH (Exp, Q, runIO)
import Language.Haskell.TH.Syntax (addDependentFile, lift)

data VerseTable = VerseTable BS.ByteString BS.ByteString Int

embed_verses :: FilePath -> Q Exp
embed_verses path = do
  addDependentFile path
  verses <- runIO $ map BSU.fromString . godphrases <$> BS.readFile path
  let offsets = scanl (\offset verse -> offset + toInteger (BS.length verse)) 0 verses
  if null verses || last offsets > 4294967295
    then fail "verse table must be nonempty and smaller than 4 GiB"
    else [| VerseTable $(bsToExp $ BS.concat verses)
              $(bsToExp $ BS.pack $ concatMap encode_offset offsets)
              $(lift $ length verses) |]

encode_offset :: Integer -> [Word8]
encode_offset offset = [fromInteger $ offset `shiftR` bits | bits <- [0, 8, 16, 24]]

lookup_verse :: VerseTable -> Integer -> BS.ByteString
lookup_verse (VerseTable verses offsets count) seed =
  let index = fromInteger (seed `mod` toInteger count)
      start = read_offset offsets index
      end = read_offset offsets (index + 1)
   in BS.take (end - start) $ BS.drop start verses

read_offset :: BS.ByteString -> Int -> Int
read_offset offsets index = sum [fromIntegral (BS.index offsets (index * 4 + byte)) * 256 ^ byte | byte <- [0 .. 3]]

{-# LANGUAGE TemplateHaskell #-}

module Main where

import qualified Data.ByteString as BS
import qualified Data.ByteString.UTF8 as BSU
import qualified Data.ByteString.Char8 as C
import qualified Data.Char8 as CH
import Data.FileEmbed (embedFileRelative)
import Data.List
import Data.Time.Clock
import GHC.Num

main :: IO ()
main = do
  currentTime <- getCurrentTime
  let bibles = godphrases bibleText
  let num = integerToInt $ diffTimeToPicoseconds $ utctDayTime currentTime
  let result = bibles !! mod num (length bibles)
  putStrLn result

bibleText :: BS.ByteString
bibleText = $(embedFileRelative "./app/bible.txt")

godphrases :: BS.ByteString -> [String]
godphrases bible =
  let bibles = concat $ map (BS.split 32) $ BS.split 10 $ bible
   in let indices = findIndices (BS.all (\x -> (x >= 48) && (x <= 58))) $ bibles
       in let bibleLength = length bibles
           in let indicesPair = zip indices (drop 1 indices ++ [bibleLength])
               in map (\(a, b) -> unwords $ map BSU.toString $ take (b - a) $ drop a $ bibles) indicesPair

godwords :: BS.ByteString -> [String]
godwords bible = [BSU.toString bible]

-- (take 20 . filter (all (map CH.isAlpha)) . concatMap C.words . C.lines) bibleText



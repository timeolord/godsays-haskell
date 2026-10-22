{-# LANGUAGE TemplateHaskell #-}

module Main where

import Bible (godphrases)
import qualified Data.ByteString as BS
import Data.FileEmbed (embedFileRelative)
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


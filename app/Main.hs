{-# LANGUAGE TemplateHaskell #-}
module Main where
import qualified Data.ByteString as BS
import Data.FileEmbed (embedFileRelative)
import Data.Char
import Data.List
import Data.Time.Clock
import GHC.Num
import Data.String
import qualified Data.ByteString.UTF8 as BSU

main :: IO ()
main = do
  currentTime <- getCurrentTime
  let bibles = godphrases bibleText
  let num = integerToInt $ diffTimeToPicoseconds $ utctDayTime currentTime
  let result = bibles !! mod num (length bibles)
  putStrLn $ "God says...\n" ++ result

bibleText :: BS.ByteString
bibleText = $(embedFileRelative "./app/bible.txt")

godphrases :: BS.ByteString -> [String]
godphrases bible = let bibles = concat $ map (BS.split 32) $ BS.split 10 $ bible in
  let indices = findIndices (BS.all (\x -> (x >= 48) && (x <= 58))) $ bibles in
    let bibleLength = length bibles in
      let indicesPair = zip indices (drop 1 indices ++ [bibleLength]) in
        map (\(a, b) -> unwords $ map BSU.toString $ take (b - a) $ drop a $ bibles) indicesPair   

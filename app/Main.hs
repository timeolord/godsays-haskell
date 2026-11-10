module Main where

import qualified Data.ByteString.Char8 as BS
import Data.Time.Clock (diffTimeToPicoseconds, getCurrentTime, utctDayTime)
import EmbeddedBible (bible_table)
import VerseTable (lookup_verse)

main :: IO ()
main = do
  current_time <- getCurrentTime
  BS.putStrLn $ lookup_verse bible_table (diffTimeToPicoseconds $ utctDayTime current_time)


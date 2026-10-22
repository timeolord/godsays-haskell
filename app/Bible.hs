module Bible (godphrases) where

import qualified Data.ByteString as BS
import qualified Data.ByteString.UTF8 as BSU

godphrases :: BS.ByteString -> [String]
godphrases = name_verses book_names . split_verses . words . BSU.toString

is_reference :: String -> Bool
is_reference token = case break (== ':') token of
  (chapter, ':' : verse) -> digits chapter && digits verse
  _ -> False
  where
    digits xs = not (null xs) && all (\c -> c >= '0' && c <= '9') xs

split_verses :: [String] -> [[String]]
split_verses [] = []
split_verses (reference : tokens) =
  let (verse, remaining) = break is_reference tokens
   in (reference : verse) : split_verses remaining

name_verses :: [String] -> [[String]] -> [String]
name_verses _ [] = []
name_verses [] _ = []
name_verses (book : books) (verse : verses) =
  let (current, remaining) = break ((== "1:1") . head) verses
   in map (unwords . (book :)) (verse : current) ++ name_verses books remaining

book_names :: [String]
book_names =
  [ "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy"
  , "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel", "1 Kings", "2 Kings"
  , "1 Chronicles", "2 Chronicles", "Ezra", "Nehemiah", "Esther", "Job"
  , "Psalms", "Proverbs", "Ecclesiastes", "Song of Solomon", "Isaiah"
  , "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos"
  , "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai"
  , "Zechariah", "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans"
  , "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians"
  , "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy"
  , "Titus", "Philemon", "Hebrews", "James", "1 Peter", "2 Peter", "1 John"
  , "2 John", "3 John", "Jude", "Revelation"
  ]

module Main where

import Bible (godphrases)
import Control.Monad (unless)
import qualified Data.ByteString as BS
import qualified Data.ByteString.UTF8 as BSU
import Data.List (isInfixOf, isPrefixOf)

assert_equal :: (Eq a, Show a) => String -> a -> a -> IO ()
assert_equal label expected actual = unless (expected == actual) $
  error (label ++ ": expected " ++ show expected ++ ", got " ++ show actual)

main :: IO ()
main = do
  assert_equal "empty input" [] (godphrases BS.empty)
  assert_equal "whitespace" [] (godphrases $ BSU.fromString " \n\t ")
  assert_equal "wrapped and inline verses"
    [ "Genesis 1:1 In the beginning."
    , "Genesis 1:2 Wrapped text with 123 and a colon: here."
    , "Genesis 2:1 Next chapter."
    , "Exodus 1:1 Next book’s opening."
    ]
    (godphrases $ BSU.fromString "1:1 In the\nbeginning.\n\n1:2 Wrapped text with 123 and a colon: here. 2:1 Next chapter.\n\n1:1 Next book’s opening.")
  verses <- godphrases <$> BS.readFile "app/bible.txt"
  let openings = filter (isInfixOf " 1:1 ") verses
  assert_equal "verse count" 31102 (length verses)
  assert_equal "book count" 66 (length openings)
  assert_equal "first verse"
    "Genesis 1:1 In the beginning God created the heaven and the earth."
    (head verses)
  assert_equal "last verse"
    "Revelation 22:21 The grace of our Lord Jesus Christ be with you all. Amen."
    (last verses)
  assert_equal "numbered book" True ("1 Samuel 1:1 " `isPrefixOf` (openings !! 8))
  assert_equal "multiword book" True ("Song of Solomon 1:1 " `isPrefixOf` (openings !! 21))
  assert_equal "new testament boundary" True ("Matthew 1:1 " `isPrefixOf` (openings !! 39))
  assert_equal "final book" True ("Revelation 1:1 " `isPrefixOf` last openings)
  putStrLn "all bible tests passed"

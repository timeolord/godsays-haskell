{-# LANGUAGE TemplateHaskell #-}

module EmbeddedBible (bible_table) where

import VerseTable (VerseTable, embed_verses)

bible_table :: VerseTable
bible_table = $(embed_verses "app/bible.txt")

# godsays

![gif of godsays running in the terminal](./gifs/godsays.gif)
An homage to Terry A. Davis and TempleOS. Displays a random bible verse from the 1611 King James Bible based on the current time.

Each verse includes the book name and chapter and verse numbers, for example:

```text
Genesis 1:2 And the earth was without forme, and voyd; and darkeneſſe was vpon the face of the deepe: and the Spirit of God mooued vpon the face of the waters.
```

The bundled text uses Wikisource's 1611 transcription wherever text is available, preserving its long s (`ſ`) and round s placement. Use a terminal font with support for `ſ`. Book labels retain modern spelling.

## Bible text sources

The app retains its 66 books and 31,102 verses. [Wikisource's 1611 edition](https://en.wikisource.org/wiki/Bible_(King_James_Version,_1611)) is incomplete, so the bundled text combines these sources:

| Source | Verses |
| --- | ---: |
| Wikisource transcription | 1,442 |
| Wikisource with a missing fragment filled | 4 |
| 1611 spelling with reconstructed long s | 29,656 |

[app/bible-sources.tsv](app/bible-sources.tsv) records every verse range, its source, and links to the exact Wikisource scan page revisions. `wikisource` preserves the transcribed letters without substitution. `mixed` contains a transcribed passage plus a restored fragment. `reconstructed` uses the fallback text and reconstructed typography. There is no runtime letter conversion.

The import uses the available book pages and the separate `Page:BibleKJV1611` scan transcriptions, checked on 1 November 2026. The scan pages supply additional passages from 1 Thessalonians, 1 Timothy, Titus, Hebrews, and Revelation. Revelation 21:22 joins text from two adjoining scan pages. Unnumbered headings, summaries, marginal notes, note markers, and separate epistle subscriptions are removed; decorative initials are read from image alt text and superscripts are flattened. Whitespace is normalized. The transcription's spellings, punctuation, and typographical errors are otherwise retained.

Two incorrect verse labels are repaired: Esther 5:1 was labeled 4:1 on scan `BibleKJV1611-010.pdf/15`, and Proverbs 3:1–2 were labeled 1:1–2 on `BibleKJV1611-011.pdf/60`. Empty markers in Psalms 9:6–20 are treated as gaps. The unreadable OCR on `BibleKJV1611-002.pdf/21` is excluded. Genesis 21:26, Genesis 44:20, and Matthew 6:22 preserve their available Wikisource prefixes and fill their missing endings from the fallback. The missing decorative `I` in 1 Timothy 2:1 is also restored from the fallback. These four verses are marked `mixed`.

The gap search also checked [Lou Burnard's TEI transcription](https://github.com/lb42/KJV_1611) and [clove3am's terminal edition](https://github.com/clove3am/kjv1611---bible). These normalize long s rather than preserving it throughout, so they do not supply a verified long s transcription for the remaining gaps. Scans exist for the original printing, but most remaining verses have no usable long s text transcription in the sources checked. The fallback is [aruljohn/Bible-kjv-1611](https://github.com/aruljohn/Bible-kjv-1611/tree/8ef066868ad1b7204d7be48658ea3bd1783d409b), revision `8ef066868ad1b7204d7be48658ea3bd1783d409b`, using its first 66 books, decoding HTML entities, and normalizing whitespace.

Only fallback text receives reconstruction: lowercase `s` followed by a letter becomes `ſ`, except beside lowercase `f`. Word endings, apostrophes, capital `S`, and existing `ſ` are preserved. This is an approximation, not a verification of every printed glyph. Original typefaces, ligatures, page layout, and the Apocrypha are not reproduced. See [Andrew West's study of long s](https://www.babelstone.co.uk/Blog/2006/06/rules-for-long-s.html) for historical conventions and their variation.

Attribution: Wikisource contributors, linked by revision in the source manifest. Wikisource makes its text available under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/); the underlying 1611 Bible is public domain in the United States. The software license remains in `LICENSE`.

The SHA256 of `app/bible.txt` is `d05377f3f4ea5ac069960274679a157bcabed29cedf52d986e62ae0bcf44fc57`.

## Usage

Run with:

```
nix run
```

## Development

Template Haskell parses the Bible, adds book names, and embeds the finished UTF-8 text and a packed byte-offset table during compilation. At runtime, the program reads the current time, selects a verse with a constant-time lookup, and writes its bytes. No Bible parsing or list traversal happens at startup. Changes to `app/bible.txt` trigger recompilation of the embedded table.

This project uses Nix flakes. Enter the dev shell with:

```
direnv allow
```

Then build or run with cabal:

```
cabal build
cabal run
cabal test
```

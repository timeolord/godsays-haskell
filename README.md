# godsays

![gif of godsays running in the terminal](./gifs/godsays.gif)
An homage to Terry A. Davis and TempleOS. Displays a random bible verse from the King James Bible based on the current time. 

Each verse includes the book name and chapter and verse numbers, for example:

```text
Genesis 1:1 In the beginning God created the heaven and the earth.
```

## Usage

Run with:

```
nix run
```

## Development

This project uses Nix flakes. Enter the dev shell with:

```
direnv allow
```

Then build or run with cabal:

```
cabal build
cabal run
```

[![cd](https://github.com/humbertodias/fpg-editor/actions/workflows/cd.yml/badge.svg)](https://github.com/humbertodias/fpg-editor/actions/workflows/cd.yml)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/humbertodias/fpg-editor)
![GitHub all downloads](https://img.shields.io/github/downloads/humbertodias/fpg-editor/total)

# FPG Editor

**FPG Editor** is a desktop application for editing **FPG**, **FNT**, and **PRG** files.  
It supports Linux, macOS, and Windows.

[Download the latest release](https://github.com/humbertodias/fpg-editor/releases).

## Build

To build the application for Linux:

```bash
make build/lin
````

For macOS:

```bash
make build/mac
```

For Windows:

```bash
make build/win
```



## Run

Run the application on Linux:

```bash
make run/lin
```

On macOS:

```bash
make run/mac
```

On Windows:

```bash
make run/win
```


## Package / Release

Create a distributable archive for Linux:

```bash
make release/lin
```

For macOS:

```bash
make release/mac
```

For Windows:

```bash
make release/win
```

The generated `.tar.gz` files will contain the application binary and the `languages/` folder.


## Notes

* Linux requires GTK2 libraries.
* macOS uses the Cocoa widget set.
* Windows uses the Win32 widget set.
* Ensure `lazbuild` and Lazarus are installed and in your `PATH`.


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
<img width="538" height="372" alt="Screenshot From 2025-10-26 16-55-37" src="https://github.com/user-attachments/assets/4d9c36d4-b7ac-4b4d-9964-ed372f6929bd" />

On macOS:

```bash
make run/mac
```
<img width="528" height="325" alt="Screenshot 2025-10-26 at 4 47 54 PM" src="https://github.com/user-attachments/assets/46c77c75-335a-4321-b7d7-f172ca7c3e97" />


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


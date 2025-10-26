[![cd](https://github.com/humbertodias/fpg-editor/actions/workflows/cd.yml/badge.svg)](https://github.com/humbertodias/fpg-editor/actions/workflows/cd.yml)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/humbertodias/fpg-editor)
![GitHub all downloads](https://img.shields.io/github/downloads/humbertodias/fpg-editor/total)

# FPG Editor

**FPG Editor** is a cross-platform desktop application for editing **FPG**, **FNT**, and **PRG** files used in **BennuGD**, **Fenix**, and related game engines.
It runs on **Linux**, **macOS**, and **Windows**, built with [Lazarus](https://www.lazarus-ide.org/index.php?page=downloads).

👉 [Download the latest release](https://github.com/humbertodias/fpg-editor/releases)

Forked from the [original FPG Editor](https://code.google.com/archive/p/fpg-editor/downloads) and updated for **modern 64-bit systems**.

## 🚀 Run Instructions

### Linux

```bash
make run/lin
```

<p align="center">
  <img width="538" height="372" alt="Screenshot Linux" src="https://github.com/user-attachments/assets/4d9c36d4-b7ac-4b4d-9964-ed372f6929bd" />
</p>

### macOS

```bash
make run/mac
```

<p align="center">
  <img width="528" height="325" alt="Screenshot macOS" src="https://github.com/user-attachments/assets/46c77c75-335a-4321-b7d7-f172ca7c3e97" />
</p>

### Windows

```bash
make run/win
```

<p align="center">
  <img width="418" height="237" alt="Screenshot Windows" src="https://github.com/user-attachments/assets/7f95de45-0495-4a1a-b434-5bd5abab590e" />
</p>

## ⚙️ Requirements

* **Linux**: GTK2 libraries
* **macOS**: Cocoa widget set
* **Windows**: Win32 widget set
* **All platforms**: `lazbuild` available in your system `PATH`

## 📦 Supported BennuGD File Types

| Extension | Meaning             | Function                                            |
| --------- | ------------------- | --------------------------------------------------- |
| **.PRG**  | Program             | Main game or program code (source or compiled)      |
| **.INC**  | Include             | Auxiliary file with functions or shared data        |
| **.DCL**  | Declare             | Declarations of variables, processes, and constants |
| **.FPG**  | Fenix Picture Group | Image group (sprites, tiles, etc.)                  |
| **.FNT**  | Font                | Bitmap font used for displaying text                |
| **.MAP**  | Map                 | Single image file (often part of an FPG)            |
| **.PAL**  | Palette             | Color palette file                                  |


### 🖼️ File Type Previews

#### **FPG – Fenix Picture Group**

A collection of images (sprites, tiles, backgrounds) stored together in a single package.

<p align="center">
  <img width="820" height="532" alt="FPG Example" src="https://github.com/user-attachments/assets/6cf9247d-5a3b-48b0-8068-719a35fa0473" />
</p>

#### **FNT – Font**

A bitmap-based font definition for displaying text in BennuGD or Fenix.

<p align="center">
  <img width="820" height="670" alt="FNT Example" src="https://github.com/user-attachments/assets/b20ba081-4a78-4ff4-8195-ac1c4b55a48e" />
</p>

#### **PRG – Program**

The main program file containing the game logic, processes, and code.

<p align="center">
  <img width="831" height="711" alt="PRG Example" src="https://github.com/user-attachments/assets/1390da96-4c8b-45b1-992c-ac6c4f3081c6" />
</p>

#!/usr/bin/env bash
# Bundle fpg-editor with Qt6Pas + required Qt6 libraries into a portable tree.
# Usage: scripts/bundle-qt.sh [linux|mac|win]
# Env: ARCH (default x86_64), APP (default fpg-editor), DIST (default dist)
set -euo pipefail

APP="${APP:-fpg-editor}"
ARCH="${ARCH:-x86_64}"
DIST="${DIST:-dist}"
LANG_DIR="${LANG_DIR:-languages}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  case "$(uname -s)" in
    Linux*) TARGET=linux ;;
    Darwin*) TARGET=mac ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT) TARGET=win ;;
    *) echo "Unknown OS; pass linux|mac|win" >&2; exit 1 ;;
  esac
fi

die() { echo "ERROR: $*" >&2; exit 1; }

find_qt_bin() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    command -v "$tool"
    return
  fi
  # Homebrew / common prefixes
  local p
  for p in \
    "$(brew --prefix qt 2>/dev/null || true)/bin" \
    /usr/lib/qt6/bin \
    /usr/lib/x86_64-linux-gnu/qt6/bin \
    /mingw64/bin \
    /c/Qt/*/mingw_64/bin \
    "$HOME/Qt"/*/mingw_64/bin
  do
    [[ -x "$p/$tool" ]] && { echo "$p/$tool"; return; }
  done
  return 1
}

qt_query() {
  local key="$1"
  if command -v qmake6 >/dev/null 2>&1; then
    qmake6 -query "$key"
  elif command -v qmake >/dev/null 2>&1; then
    qmake -query "$key"
  else
    die "qmake6/qmake not found (needed to locate Qt libraries)"
  fi
}

copy_resolved() {
  # copy_resolved <src> <dest-dir> — follows one level of symlink, keeps basename
  local src="$1" dest="$2" real base
  [[ -e "$src" ]] || return 0
  real="$(readlink -f "$src" 2>/dev/null || realpath "$src" 2>/dev/null || echo "$src")"
  base="$(basename "$src")"
  mkdir -p "$dest"
  if [[ -f "$real" ]]; then
    cp -a "$real" "$dest/$base"
    # Also copy versioned soname siblings next to the real file when useful
    if [[ "$(uname -s)" == Linux ]]; then
      local dir sibling
      dir="$(dirname "$real")"
      for sibling in "$dir"/$(basename "$real").*; do
        [[ -e "$sibling" ]] || continue
        cp -a "$sibling" "$dest/" 2>/dev/null || true
      done
    fi
  elif [[ -d "$src" ]]; then
    cp -a "$src" "$dest/"
  fi
}

bundle_linux() {
  local bin="$ROOT/$APP"
  [[ -f "$bin" ]] || die "missing binary: $bin (build first)"

  local stage="$DIST/$APP-lin-$ARCH"
  rm -rf "$stage"
  mkdir -p "$stage/lib" "$stage/plugins"

  cp -a "$bin" "$stage/${APP}.bin"
  [[ -d "$LANG_DIR" ]] && cp -a "$LANG_DIR" "$stage/"

  local qt_libs qt_plugins
  qt_libs="$(qt_query QT_INSTALL_LIBS)"
  qt_plugins="$(qt_query QT_INSTALL_PLUGINS)"

  # Qt6Pas
  local pas
  pas="$(ldd "$bin" | awk '/Qt6Pas/ {print $3; exit}')"
  if [[ -z "$pas" || "$pas" == "not" ]]; then
    pas="$(find /usr/lib /usr/local/lib /lib -name 'libQt6Pas.so*' 2>/dev/null | head -n1 || true)"
  fi
  [[ -n "$pas" && -e "$pas" ]] || die "libQt6Pas.so not found"
  # Copy all sonames for Qt6Pas
  local pas_dir pas_base
  pas_dir="$(dirname "$(readlink -f "$pas")")"
  pas_base="$(basename "$(readlink -f "$pas")")"
  cp -a "$pas_dir"/libQt6Pas.so* "$stage/lib/" 2>/dev/null || cp -a "$pas" "$stage/lib/"

  # Direct + recursive Qt deps of the binary and of Qt6Pas
  local needed
  needed="$( (
    ldd "$bin"
    ldd "$pas"
  ) | awk '/=>/ {print $3}' | sort -u )"

  local lib
  while IFS= read -r lib; do
    [[ -z "$lib" || ! -e "$lib" ]] && continue
    case "$lib" in
      *libQt6*|*libicu*|*libpcre2-16*|*libdouble-conversion*|*libzstd*|*libbrotli*|*libxcb-cursor*)
        cp -a "$lib" "$stage/lib/" 2>/dev/null || true
        # soname companions
        cp -a "$(dirname "$lib")"/$(basename "$lib").* "$stage/lib/" 2>/dev/null || true
        ;;
    esac
  done <<< "$needed"

  # Essential Qt plugins for a GUI app
  local plug
  for plug in \
    platforms/libqxcb.so \
    platforms/libqwayland.so \
    xcbglintegrations/libqxcb-glx-integration.so \
    xcbglintegrations/libqxcb-egl-integration.so \
    platformthemes/libqgtk3.so \
    platformthemes/libqxdgdesktopportal.so \
    imageformats/libqjpeg.so \
    imageformats/libqico.so \
    imageformats/libqgif.so \
    imageformats/libqsvg.so \
    iconengines/libqsvgicon.so \
    styles/libqstylesheetstyle.so
  do
    if [[ -f "$qt_plugins/$plug" ]]; then
      mkdir -p "$stage/plugins/$(dirname "$plug")"
      cp -a "$qt_plugins/$plug" "$stage/plugins/$plug"
      # Pull plugin deps that are Qt-related
      ldd "$qt_plugins/$plug" 2>/dev/null | awk '/=>/ {print $3}' | while read -r d; do
        [[ -e "$d" ]] || continue
        case "$d" in
          *libQt6*|*libicu*) cp -a "$d" "$stage/lib/" 2>/dev/null || true ;;
        esac
      done
    fi
  done

  # libQt6XcbQpa lives in libs, often needed by libqxcb.so
  cp -a "$qt_libs"/libQt6XcbQpa.so* "$stage/lib/" 2>/dev/null || true
  cp -a "$qt_libs"/libQt6WaylandClient.so* "$stage/lib/" 2>/dev/null || true

  cat > "$stage/qt.conf" <<'EOF'
[Paths]
Prefix = .
Libraries = lib
Plugins = plugins
EOF

  cat > "$stage/$APP" <<EOF
#!/bin/sh
DIR=\$(CDPATH= cd -- "\$(dirname "\$0")" && pwd)
export LD_LIBRARY_PATH="\$DIR/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="\$DIR/plugins"
exec "\$DIR/${APP}.bin" "\$@"
EOF
  chmod +x "$stage/$APP" "$stage/${APP}.bin"

  tar -C "$DIST" -czf "${APP}-lin-${ARCH}.tar.gz" "$(basename "$stage")"
  echo "Created ${APP}-lin-${ARCH}.tar.gz"
}

bundle_mac() {
  local bin="$ROOT/$APP"
  [[ -f "$bin" ]] || die "missing binary: $bin (build first)"

  local stage="$DIST/$APP-mac-$ARCH"
  local bundle="$stage/${APP}.app"
  rm -rf "$stage"
  mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Frameworks" "$bundle/Contents/Resources"

  cp -a "$bin" "$bundle/Contents/MacOS/$APP"
  [[ -d "$LANG_DIR" ]] && cp -a "$LANG_DIR" "$bundle/Contents/Resources/"

  cat > "$bundle/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>${APP}</string>
  <key>CFBundleIdentifier</key><string>org.fpg-editor.app</string>
  <key>CFBundleName</key><string>FPG Editor</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
EOF

  # Embed Qt6Pas.framework
  local fw=""
  for fw in \
    /Library/Frameworks/Qt6Pas.framework \
    "$(brew --prefix qt 2>/dev/null || true)/lib/Qt6Pas.framework" \
    "$HOME/lazarus/lcl/interfaces/qt6/cbindings/lib/Qt6Pas.framework" \
    "$HOME/lazarus/lcl/interfaces/qt6/cbindings/Qt6Pas.framework"
  do
    [[ -d "$fw" ]] && break
    fw=""
  done
  if [[ -z "$fw" ]]; then
    fw="$(find /Library/Frameworks "$HOME" /opt/homebrew /usr/local -type d -name 'Qt6Pas.framework' 2>/dev/null | head -n1 || true)"
  fi
  [[ -n "$fw" && -d "$fw" ]] || die "Qt6Pas.framework not found"
  cp -a "$fw" "$bundle/Contents/Frameworks/"

  # Normalize Qt6Pas install name so the embedded copy is used
  local pas_bin="$bundle/Contents/Frameworks/Qt6Pas.framework/Versions/6/Qt6Pas"
  if [[ -f "$pas_bin" ]]; then
    install_name_tool -id @rpath/Qt6Pas.framework/Versions/6/Qt6Pas "$pas_bin" 2>/dev/null || true
  fi

  # Make the binary look for frameworks next to itself
  install_name_tool -add_rpath @executable_path/../Frameworks "$bundle/Contents/MacOS/$APP" 2>/dev/null || true

  # Prefer @rpath for Qt6Pas if linked with absolute / empty path
  local old
  while IFS= read -r old; do
    case "$old" in
      *Qt6Pas*)
        install_name_tool -change "$old" \
          @rpath/Qt6Pas.framework/Versions/6/Qt6Pas \
          "$bundle/Contents/MacOS/$APP" 2>/dev/null || true
        ;;
    esac
  done < <(otool -L "$bundle/Contents/MacOS/$APP" | awk 'NR>1 {print $1}')

  local macdeployqt
  macdeployqt="$(find_qt_bin macdeployqt || true)"
  if [[ -n "$macdeployqt" ]]; then
    # Pull Qt frameworks referenced by Qt6Pas into the bundle
    "$macdeployqt" "$bundle" -verbose=1 || true
    # Ensure Qt6Pas itself is still present (macdeployqt can be picky)
    [[ -d "$bundle/Contents/Frameworks/Qt6Pas.framework" ]] || \
      cp -a "$fw" "$bundle/Contents/Frameworks/"
  else
    echo "WARN: macdeployqt not found; copying Qt frameworks from Homebrew/Qt prefix"
    local qt_prefix qt_lib
    qt_prefix="$(qt_query QT_INSTALL_PREFIX)"
    qt_lib="$(qt_query QT_INSTALL_LIBS)"
    local dep
    for dep in QtCore QtGui QtWidgets QtPrintSupport QtDBus QtOpenGL; do
      if [[ -d "$qt_lib/${dep}.framework" ]]; then
        cp -a "$qt_lib/${dep}.framework" "$bundle/Contents/Frameworks/"
      elif [[ -d "$qt_prefix/lib/${dep}.framework" ]]; then
        cp -a "$qt_prefix/lib/${dep}.framework" "$bundle/Contents/Frameworks/"
      fi
    done
  fi

  # Launcher note at stage root
  cat > "$stage/README.txt" <<EOF
FPG Editor (Qt6)
Open ${APP}.app — Qt6Pas and Qt6 frameworks are embedded in Contents/Frameworks.
EOF

  tar -C "$DIST" -czf "${APP}-mac-${ARCH}.tar.gz" "$(basename "$stage")"
  echo "Created ${APP}-mac-${ARCH}.tar.gz"
}

bundle_win() {
  local bin="$ROOT/${APP}.exe"
  [[ -f "$bin" ]] || die "missing binary: $bin (build first)"

  local stage="$DIST/$APP-win-$ARCH"
  rm -rf "$stage"
  mkdir -p "$stage"
  cp -a "$bin" "$stage/"
  [[ -d "$LANG_DIR" ]] && cp -a "$LANG_DIR" "$stage/"

  # Locate Qt6Pas6.dll (Lazarus qt62.pas: Qt6PasLib = 'Qt6Pas6.dll')
  local pas=""
  for pas in \
    "$ROOT/Qt6Pas6.dll" \
    "$ROOT/Qt6Pas.dll" \
    /mingw64/bin/Qt6Pas6.dll \
    /mingw64/bin/Qt6Pas.dll \
    "$HOME/lazarus/lcl/interfaces/qt6/cbindings"/Qt6Pas6.dll \
    "$HOME/lazarus/lcl/interfaces/qt6/cbindings"/Qt6Pas.dll \
    "$HOME/lazarus/lcl/interfaces/qt6/cbindings"/lib/Qt6Pas6.dll \
    "$HOME/lazarus/lcl/interfaces/qt6/cbindings"/lib/Qt6Pas.dll
  do
    [[ -f "$pas" ]] && break
    pas=""
  done
  if [[ -z "$pas" ]]; then
    pas="$(find "$HOME" /mingw64 /c/Qt "$ROOT" \( -name 'Qt6Pas6.dll' -o -name 'Qt6Pas.dll' \) 2>/dev/null | head -n1 || true)"
  fi
  [[ -n "$pas" && -f "$pas" ]] || die "Qt6Pas6.dll not found"
  cp -a "$pas" "$stage/"

  local windeployqt
  windeployqt="$(find_qt_bin windeployqt || true)"
  if [[ -n "$windeployqt" ]]; then
    "$windeployqt" --release --no-translations --compiler-runtime "$stage/${APP}.exe" || \
      "$windeployqt" --release --no-translations "$stage/${APP}.exe"
  else
    echo "WARN: windeployqt not found; copying core Qt6 DLLs from PATH/Qt prefix"
    local qt_bins
    qt_bins="$(qt_query QT_INSTALL_BINS 2>/dev/null || true)"
    local dll
    for dll in Qt6Core.dll Qt6Gui.dll Qt6Widgets.dll Qt6PrintSupport.dll Qt6Svg.dll; do
      if [[ -n "$qt_bins" && -f "$qt_bins/$dll" ]]; then
        cp -a "$qt_bins/$dll" "$stage/"
      elif command -v "$dll" >/dev/null 2>&1; then
        cp -a "$(command -v "$dll")" "$stage/"
      fi
    done
    local plugins
    plugins="$(qt_query QT_INSTALL_PLUGINS 2>/dev/null || true)"
    if [[ -n "$plugins" && -d "$plugins/platforms" ]]; then
      mkdir -p "$stage/platforms"
      cp -a "$plugins/platforms"/*.dll "$stage/platforms/" 2>/dev/null || true
    fi
  fi

  # Always ensure Qt6Pas6.dll sits beside the exe (name expected by LCL)
  cp -a "$pas" "$stage/Qt6Pas6.dll"
  cp -a "$pas" "$stage/Qt6Pas.dll"

  # Windows users expect .zip (not .tar.gz nested inside Actions artifact zips)
  local out="$ROOT/${APP}-win-${ARCH}"
  python - "$stage" "$out" <<'PY'
import shutil, sys
from pathlib import Path
stage = Path(sys.argv[1])
out = Path(sys.argv[2])
shutil.make_archive(str(out), "zip", root_dir=stage.parent, base_dir=stage.name)
print(f"Created {out}.zip")
PY
}

case "$TARGET" in
  linux|lin) bundle_linux ;;
  mac|macos|darwin) bundle_mac ;;
  win|windows) bundle_win ;;
  *) die "unknown target: $TARGET (use linux|mac|win)" ;;
esac

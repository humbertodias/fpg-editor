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

# Copy a dylib by value (dereference Homebrew symlinks into Cellar).
# Relative symlinks break when placed in Contents/Frameworks/.
copy_real_file() {
  local src="$1" dest="$2" real
  real="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$src")"
  [[ -f "$real" ]] || die "cannot resolve real file for $src"
  cp -p "$real" "$dest"
  chmod u+w "$dest" 2>/dev/null || true
}

# Strip code signature so install_name_tool can rewrite load commands.
strip_macho_signature() {
  local macho="$1"
  [[ -f "$macho" ]] || return 0
  chmod u+w "$macho" 2>/dev/null || true
  codesign --remove-signature "$macho" 2>/dev/null || true
}

# Rewrite absolute / Homebrew / Cellar dylib refs in a Mach-O binary to @rpath.
# Args: <mach-o-file> <frameworks-dir>
fix_macho_deps() {
  local macho="$1" fwdir="$2"
  local dep new fwname inner base resolved err
  [[ -f "$macho" ]] || return 0
  chmod -R u+w "$(dirname "$macho")" 2>/dev/null || chmod u+w "$macho" 2>/dev/null || true
  strip_macho_signature "$macho"
  err="$(mktemp)"

  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    case "$dep" in
      /System/*|/usr/lib/*|@rpath/*|@executable_path/*|@loader_path/*) continue ;;
    esac
    if [[ "$dep" == *'.framework/'* ]]; then
      fwname="$(echo "$dep" | sed -E 's|.*/([^/]+)\.framework/.*|\1|')"
      if [[ -d "$fwdir/${fwname}.framework" ]]; then
        inner="$(echo "$dep" | sed -E "s|.*/${fwname}\\.framework/|${fwname}.framework/|")"
        new="@rpath/${inner}"
        if ! install_name_tool -change "$dep" "$new" "$macho" 2>"$err"; then
          echo "WARN: install_name_tool -change failed for $macho:" >&2
          cat "$err" >&2 || true
        fi
      fi
      continue
    fi
    base="$(basename "$dep")"
    # Ensure the dylib is present in Frameworks before rewriting
    if [[ -L "$fwdir/$base" && ! -f "$fwdir/$base" ]]; then
      rm -f "$fwdir/$base"
    fi
    if [[ ! -f "$fwdir/$base" ]]; then
      resolved="$dep"
      [[ -e "$resolved" ]] || resolved="$(resolve_brew_dylib "$base" || true)"
      if [[ -n "$resolved" && -e "$resolved" ]]; then
        echo "Bundling dylib $base from $resolved (during fix)"
        copy_real_file "$resolved" "$fwdir/$base"
        strip_macho_signature "$fwdir/$base"
      fi
    fi
    if [[ -f "$fwdir/$base" ]]; then
      if ! install_name_tool -change "$dep" "@rpath/$base" "$macho" 2>"$err"; then
        echo "WARN: install_name_tool -change $dep -> @rpath/$base failed on $macho:" >&2
        cat "$err" >&2 || true
        # Retry after stripping again
        strip_macho_signature "$macho"
        install_name_tool -change "$dep" "@rpath/$base" "$macho" 2>"$err" || \
          echo "WARN: retry also failed: $(cat "$err")" >&2
      fi
    else
      echo "WARN: $base not in Frameworks; cannot rewrite $dep in $macho" >&2
    fi
  done < <(otool -L "$macho" 2>/dev/null | awk 'NR>1 {print $1}')
  rm -f "$err"
}

# Resolve @loader_path / relative refs against a Mach-O's directory.
resolve_loader_path() {
  local dep="$1" macho="$2" base
  base="$(cd "$(dirname "$macho")" && pwd)"
  case "$dep" in
    @loader_path/*)
      echo "$base/${dep#@loader_path/}"
      return 0
      ;;
  esac
  return 1
}

# List LC_RPATH entries for a Mach-O (resolved @loader_path where possible).
macho_rpaths() {
  local macho="$1" base rpath
  base="$(cd "$(dirname "$macho")" && pwd)"
  otool -l "$macho" 2>/dev/null | awk '/cmd LC_RPATH/{getline; getline; if ($1=="path") print $2}' | while IFS= read -r rpath; do
    case "$rpath" in
      @loader_path/*) echo "${base}/${rpath#@loader_path/}" ;;
      @executable_path/*) continue ;; # need exe path; skip here
      *) echo "$rpath" ;;
    esac
  done
}

# Resolve @rpath/... using the binary's rpaths + known Qt/Homebrew lib dirs.
# Args: <dep> <macho> [frameworks-dir]
resolve_rpath_dep() {
  local dep="$1" macho="$2" fwdir="${3:-}"
  local suffix try rpath fwname
  case "$dep" in
    @rpath/*) suffix="${dep#@rpath/}" ;;
    *) return 1 ;;
  esac

  # Already bundled?
  if [[ -n "$fwdir" && -e "$fwdir/$suffix" ]]; then
    echo "$fwdir/$suffix"
    return 0
  fi

  while IFS= read -r rpath; do
    [[ -z "$rpath" ]] && continue
    try="$rpath/$suffix"
    if [[ -e "$try" ]]; then
      echo "$try"
      return 0
    fi
  done < <(macho_rpaths "$macho")

  # Known Qt framework locations
  if [[ "$suffix" == *.framework/* ]]; then
    fwname="$(echo "$suffix" | sed -E 's|^([^/]+)\.framework/.*|\1|')"
    for try in \
      "$(brew --prefix qtbase 2>/dev/null)/lib/${fwname}.framework" \
      "$(brew --prefix qt 2>/dev/null)/lib/${fwname}.framework" \
      "$(brew --prefix qtdeclarative 2>/dev/null)/lib/${fwname}.framework" \
      "/usr/local/opt/qtbase/lib/${fwname}.framework" \
      "/usr/local/opt/qt/lib/${fwname}.framework" \
      "/opt/homebrew/opt/qtbase/lib/${fwname}.framework" \
      "/opt/homebrew/opt/qt/lib/${fwname}.framework" \
      "/usr/local/lib/${fwname}.framework" \
      "/opt/homebrew/lib/${fwname}.framework"
    do
      [[ -z "$try" || "$try" == "/lib/${fwname}.framework" ]] && continue
      if [[ -d "$try" ]]; then
        echo "$try/$(echo "$suffix" | sed -E "s|^${fwname}\\.framework/||")"
        return 0
      fi
    done
  else
    # Plain dylib via @rpath
    try="$(resolve_brew_dylib "$(basename "$suffix")" || true)"
    [[ -n "$try" && -e "$try" ]] && { echo "$try"; return 0; }
  fi
  return 1
}

# Ensure common Qt frameworks referenced via @rpath are present.
# Args: <frameworks-dir>
ensure_qt_frameworks() {
  local fwdir="$1"
  local name src
  for name in QtCore QtGui QtWidgets QtPrintSupport QtDBus QtOpenGL QtNetwork QtSvg; do
    [[ -d "$fwdir/${name}.framework" ]] && continue
    src="$(resolve_fw_dep "${name}.framework/Versions/A/${name}" || true)"
    if [[ -z "$src" || ! -e "$src" ]]; then
      continue
    fi
    local fwsrc
    fwsrc="$(echo "$src" | sed -E 's|(.*/[^/]+\.framework)/.*|\1|')"
    fwsrc="$(cd "$fwsrc" && pwd)"
    echo "Ensuring framework $name from $fwsrc"
    cp -a "$fwsrc" "$fwdir/"
    chmod -R u+w "$fwdir/${name}.framework" 2>/dev/null || true
  done
}

# Find a Homebrew dylib by basename (icu4c, etc.).
resolve_brew_dylib() {
  local base="$1" try prefix
  for prefix in \
    "$(brew --prefix icu4c@78 2>/dev/null)" \
    "$(brew --prefix icu4c 2>/dev/null)" \
    "$(brew --prefix pcre2 2>/dev/null)" \
    "$(brew --prefix zstd 2>/dev/null)" \
    "$(brew --prefix libpng 2>/dev/null)" \
    "$(brew --prefix jpeg-turbo 2>/dev/null)" \
    "$(brew --prefix jpeg 2>/dev/null)" \
    "$(brew --prefix libb2 2>/dev/null)" \
    "$(brew --prefix double-conversion 2>/dev/null)" \
    "$(brew --prefix md4c 2>/dev/null)" \
    "$(brew --prefix harfbuzz 2>/dev/null)" \
    "$(brew --prefix freetype 2>/dev/null)" \
    "$(brew --prefix glib 2>/dev/null)" \
    "/usr/local/opt/icu4c@78" \
    "/usr/local/opt/icu4c" \
    "/usr/local/opt/md4c" \
    "/usr/local/opt/double-conversion" \
    "/opt/homebrew/opt/icu4c@78" \
    "/opt/homebrew/opt/icu4c" \
    "/opt/homebrew/opt/md4c" \
    "/opt/homebrew/opt/double-conversion"
  do
    [[ -z "$prefix" || "$prefix" == "null" ]] && continue
    try="$prefix/lib/$base"
    [[ -f "$try" ]] && { echo "$try"; return 0; }
  done
  # Last resort: locate under Homebrew Cellar / opt
  try="$(find /usr/local/opt /opt/homebrew/opt /usr/local/Cellar /opt/homebrew/Cellar \
    -name "$base" 2>/dev/null | head -n1 || true)"
  [[ -n "$try" && -f "$try" ]] && { echo "$try"; return 0; }
  return 1
}

# Resolve a missing framework path via Homebrew prefixes.
# Accepts absolute, @rpath/, or bare "Name.framework/..." forms.
resolve_fw_dep() {
  local dep="$1" fwname rest try
  # Strip optional @rpath/ prefix
  rest="${dep#@rpath/}"
  # Extract framework name
  case "$rest" in
    *.framework/*)
      fwname="${rest%%.framework/*}"
      fwname="${fwname##*/}"
      ;;
    *)
      return 1
      ;;
  esac
  [[ -n "$fwname" ]] || return 1
  for try in \
    "$(brew --prefix qtbase 2>/dev/null)/lib/${fwname}.framework" \
    "$(brew --prefix qt 2>/dev/null)/lib/${fwname}.framework" \
    "/usr/local/opt/qtbase/lib/${fwname}.framework" \
    "/usr/local/opt/qt/lib/${fwname}.framework" \
    "/opt/homebrew/opt/qtbase/lib/${fwname}.framework" \
    "/opt/homebrew/opt/qt/lib/${fwname}.framework" \
    "/usr/local/lib/${fwname}.framework" \
    "/opt/homebrew/lib/${fwname}.framework"
  do
    [[ -z "$try" || "$try" == "/lib/${fwname}.framework" ]] && continue
    if [[ -d "$try" ]]; then
      echo "$try/Versions/A/${fwname}"
      return 0
    fi
  done
  return 1
}

# Recursively collect and copy non-system Mach-O deps into Frameworks/.
# Bash 3.2 compatible (no associative arrays).
# Args: <start-binary> <frameworks-dir>
collect_macos_deps() {
  local start="$1" fwdir="$2"
  local queue_file seen_file
  queue_file="$(mktemp)"
  seen_file="$(mktemp)"
  echo "$start" > "$queue_file"

  while [[ -s "$queue_file" ]]; do
    local cur dep fwname fwsrc dest fwbin resolved base
    cur="$(head -n1 "$queue_file")"
    tail -n +2 "$queue_file" > "${queue_file}.rest" && mv "${queue_file}.rest" "$queue_file"
    grep -Fxq -- "$cur" "$seen_file" 2>/dev/null && continue
    echo "$cur" >> "$seen_file"
    [[ -f "$cur" ]] || continue

    while IFS= read -r dep; do
      [[ -z "$dep" ]] && continue
      case "$dep" in
        /System/*|/usr/lib/*) continue ;;
        @executable_path/*) continue ;;
        @rpath/*)
          resolved="$(resolve_rpath_dep "$dep" "$cur" "$fwdir" || true)"
          if [[ -n "$resolved" && -e "$resolved" ]]; then
            dep="$resolved"
          else
            # Fall back to framework name lookup (e.g. QtDBus)
            if [[ "$dep" == *'.framework/'* ]]; then
              resolved="$(resolve_fw_dep "$dep" || true)"
              if [[ -n "$resolved" && -e "$resolved" ]]; then
                dep="$resolved"
              else
                echo "WARN: unresolved @rpath dep $dep from $cur" >&2
                continue
              fi
            else
              echo "WARN: unresolved @rpath dep $dep from $cur" >&2
              continue
            fi
          fi
          ;;
        @loader_path/*)
          resolved="$(resolve_loader_path "$dep" "$cur" || true)"
          if [[ -n "$resolved" && -e "$resolved" ]]; then
            dep="$resolved"
          else
            continue
          fi
          ;;
        @*) continue ;;
      esac

      if [[ ! -e "$dep" ]]; then
        if [[ "$dep" == *'.framework/'* ]]; then
          dep="$(resolve_fw_dep "$dep" || true)"
        else
          base="$(basename "$dep")"
          dep="$(resolve_brew_dylib "$base" || true)"
        fi
        [[ -n "$dep" && -e "$dep" ]] || continue
      fi

      if [[ "$dep" == *'.framework/'* ]]; then
        fwname="$(echo "$dep" | sed -E 's|.*/([^/]+)\.framework/.*|\1|')"
        fwsrc="$(echo "$dep" | sed -E 's|(.*/[^/]+\.framework)/.*|\1|')"
        # Prefer real path (Homebrew frameworks are often symlinks into Cellar)
        fwsrc="$(cd "$fwsrc" && pwd)"
        dest="$fwdir/${fwname}.framework"
        if [[ ! -d "$dest" ]]; then
          echo "Bundling framework $fwname from $fwsrc"
          cp -a "$fwsrc" "$fwdir/"
          chmod -R u+w "$dest" 2>/dev/null || true
        fi
        fwbin="$(find "$dest" -type f -path "*/Versions/*/${fwname}" 2>/dev/null | head -n1 || true)"
        [[ -z "$fwbin" ]] && fwbin="$dest/$fwname"
        [[ -f "$fwbin" ]] && strip_macho_signature "$fwbin"
        if [[ -f "$fwbin" ]] && ! grep -Fxq -- "$fwbin" "$seen_file" 2>/dev/null; then
          echo "$fwbin" >> "$queue_file"
        fi
      else
        base="$(basename "$dep")"
        dest="$fwdir/$base"
        if [[ -L "$dest" && ! -f "$dest" ]]; then
          rm -f "$dest"
        fi
        if [[ ! -f "$dest" ]]; then
          echo "Bundling dylib $base from $dep"
          copy_real_file "$dep" "$dest"
          strip_macho_signature "$dest"
        fi
        if ! grep -Fxq -- "$dest" "$seen_file" 2>/dev/null; then
          echo "$dest" >> "$queue_file"
        fi
      fi
    done < <(otool -L "$cur" 2>/dev/null | awk 'NR>1 {print $1}')
  done

  rm -f "$queue_file" "$seen_file" "${queue_file}.rest"
}

# Scan Frameworks for leftover absolute Homebrew refs, copy missing dylibs, rewrite again.
# Args: <frameworks-dir> <app-exe>
relink_macos_bundle() {
  local fwdir="$1" exe="$2"
  local f dep base resolved pass fwname inner fwsrc

  # Make everything writable and drop signatures first (install_name_tool needs this)
  chmod -R u+w "$fwdir" 2>/dev/null || true
  while IFS= read -r -d '' f; do
    file "$f" 2>/dev/null | grep -q 'Mach-O' || continue
    strip_macho_signature "$f"
  done < <(find "$fwdir" -type f -print0 2>/dev/null)
  strip_macho_signature "$exe"

  for pass in 1 2 3 4; do
    echo "macOS relink pass $pass..."
    ensure_qt_frameworks "$fwdir"
    # Copy any remaining absolute / unresolved @rpath third-party deps
    while IFS= read -r -d '' f; do
      file "$f" 2>/dev/null | grep -q 'Mach-O' || continue
      while IFS= read -r dep; do
        [[ -z "$dep" ]] && continue
        case "$dep" in
          /System/*|/usr/lib/*) continue ;;
          @rpath/*)
            # Missing bundled framework referenced via @rpath (e.g. QtDBus)
            if [[ "$dep" == *'.framework/'* ]]; then
              fwname="$(echo "$dep" | sed -E 's|@rpath/([^/]+)\.framework/.*|\1|')"
              if [[ ! -d "$fwdir/${fwname}.framework" ]]; then
                resolved="$(resolve_rpath_dep "$dep" "$f" "$fwdir" || resolve_fw_dep "$dep" || true)"
                if [[ -n "$resolved" && -e "$resolved" ]]; then
                  fwsrc="$(echo "$resolved" | sed -E 's|(.*/[^/]+\.framework)/.*|\1|')"
                  fwsrc="$(cd "$fwsrc" && pwd)"
                  if [[ ! -d "$fwdir/${fwname}.framework" ]]; then
                    echo "Bundling @rpath framework $fwname from $fwsrc"
                    cp -a "$fwsrc" "$fwdir/"
                    chmod -R u+w "$fwdir/${fwname}.framework" 2>/dev/null || true
                  fi
                  collect_macos_deps "$f" "$fwdir"
                fi
              fi
            fi
            ;;
          @*) continue ;;
          /usr/local/*|/opt/homebrew/*)
            if [[ "$dep" == *'.framework/'* ]]; then
              collect_macos_deps "$f" "$fwdir"
            else
              base="$(basename "$dep")"
              # Replace broken Homebrew symlinks from earlier cp -a attempts
              if [[ -L "$fwdir/$base" && ! -f "$fwdir/$base" ]]; then
                rm -f "$fwdir/$base"
              fi
              resolved="$dep"
              [[ -e "$resolved" ]] || resolved="$(resolve_brew_dylib "$base" || true)"
              if [[ -n "$resolved" && -e "$resolved" && ! -f "$fwdir/$base" ]]; then
                echo "Bundling leftover dylib $base from $resolved"
                copy_real_file "$resolved" "$fwdir/$base"
                strip_macho_signature "$fwdir/$base"
                collect_macos_deps "$fwdir/$base" "$fwdir"
              fi
              # Rewrite this specific reference immediately
              if [[ -f "$fwdir/$base" ]]; then
                strip_macho_signature "$f"
                if ! install_name_tool -change "$dep" "@rpath/$base" "$f" 2>/tmp/fpg-int2.err; then
                  echo "WARN: immediate -change failed for $dep in $f:" >&2
                  cat /tmp/fpg-int2.err >&2 || true
                fi
                rm -f /tmp/fpg-int2.err
              else
                echo "WARN: failed to materialize $base into Frameworks" >&2
              fi
            fi
            ;;
        esac
      done < <(otool -L "$f" 2>/dev/null | awk 'NR>1 {print $1}')
    done < <(find "$fwdir" -type f -print0 2>/dev/null)

    # Full rewrite pass on every Mach-O
    while IFS= read -r -d '' f; do
      file "$f" 2>/dev/null | grep -q 'Mach-O' || continue
      strip_macho_signature "$f"
      if [[ "$f" == *'.framework/'* ]]; then
        fwname="$(echo "$f" | sed -E 's|.*/([^/]+)\.framework/.*|\1|')"
        inner="$(echo "$f" | sed -E "s|.*/${fwname}\\.framework/|${fwname}.framework/|")"
        install_name_tool -id "@rpath/${inner}" "$f" 2>/dev/null || true
      else
        install_name_tool -id "@rpath/$(basename "$f")" "$f" 2>/dev/null || true
      fi
      install_name_tool -add_rpath @executable_path/../Frameworks "$f" 2>/dev/null || true
      fix_macho_deps "$f" "$fwdir"
    done < <(find "$fwdir" -type f -print0 2>/dev/null)

    strip_macho_signature "$exe"
    install_name_tool -add_rpath @executable_path/../Frameworks "$exe" 2>/dev/null || true
    fix_macho_deps "$exe" "$fwdir"
  done
}

# Fail if any bundled Mach-O still references Homebrew/Cellar paths,
# or @rpath frameworks that were not copied into the bundle.
assert_macos_relocatable() {
  local fwdir="$1"
  local f bad=0 tmp dep fwname
  tmp="$(mktemp)"
  while IFS= read -r -d '' f; do
    file "$f" 2>/dev/null | grep -q 'Mach-O' || continue
    if otool -L "$f" 2>/dev/null | grep -E '/usr/local/opt/|/opt/homebrew/|/Cellar/' >"$tmp" 2>/dev/null; then
      if [[ -s "$tmp" ]]; then
        echo "ERROR: absolute Homebrew refs remain in $f:" >&2
        cat "$tmp" >&2
        bad=1
      fi
    fi
    while IFS= read -r dep; do
      case "$dep" in
        @rpath/*.framework/*)
          fwname="$(echo "$dep" | sed -E 's|@rpath/([^/]+)\.framework/.*|\1|')"
          if [[ ! -d "$fwdir/${fwname}.framework" ]]; then
            echo "ERROR: missing bundled framework $fwname (needed by $f via $dep)" >&2
            bad=1
          fi
          ;;
      esac
    done < <(otool -L "$f" 2>/dev/null | awk 'NR>1 {print $1}')
  done < <(find "$fwdir" -type f -print0 2>/dev/null)
  rm -f "$tmp"
  [[ "$bad" -eq 0 ]] || die "macOS bundle is not relocatable — Homebrew library refs remain"
}

# Locate Qt's plugins directory (Homebrew layout varies by formula/version).
find_macos_qt_plugins() {
  local try
  if command -v qmake6 >/dev/null 2>&1 || command -v qmake >/dev/null 2>&1; then
    try="$(qt_query QT_INSTALL_PLUGINS 2>/dev/null || true)"
    if [[ -n "$try" && -f "$try/platforms/libqcocoa.dylib" ]]; then
      echo "$try"
      return 0
    fi
  fi
  for try in \
    "$(brew --prefix qtbase 2>/dev/null)/share/qt/plugins" \
    "$(brew --prefix qt 2>/dev/null)/share/qt/plugins" \
    "$(brew --prefix qtbase 2>/dev/null)/plugins" \
    "$(brew --prefix qt 2>/dev/null)/plugins" \
    "/usr/local/opt/qtbase/share/qt/plugins" \
    "/usr/local/opt/qt/share/qt/plugins" \
    "/opt/homebrew/opt/qtbase/share/qt/plugins" \
    "/opt/homebrew/opt/qt/share/qt/plugins" \
    "/usr/local/share/qt/plugins" \
    "/opt/homebrew/share/qt/plugins"
  do
    [[ -z "$try" || "$try" == "/share/qt/plugins" || "$try" == "/plugins" ]] && continue
    if [[ -f "$try/platforms/libqcocoa.dylib" ]]; then
      echo "$try"
      return 0
    fi
  done
  try="$(find /usr/local/opt /opt/homebrew/opt /usr/local/Cellar /opt/homebrew/Cellar \
    -path '*/plugins/platforms/libqcocoa.dylib' 2>/dev/null | head -n1 || true)"
  if [[ -n "$try" && -f "$try" ]]; then
    echo "$(cd "$(dirname "$try")/.." && pwd)"
    return 0
  fi
  return 1
}

# Copy essential Qt plugins into Contents/PlugIns (cocoa is mandatory).
# Args: <app-bundle> <frameworks-dir>
bundle_macos_qt_plugins() {
  local bundle="$1" fwdir="$2"
  local qt_plugins plugdir name src dest
  qt_plugins="$(find_macos_qt_plugins)" \
    || die "Qt plugins dir with platforms/libqcocoa.dylib not found"

  echo "Bundling Qt plugins from $qt_plugins"
  mkdir -p "$bundle/Contents/PlugIns"

  # platforms/ is required; others improve UX and are small
  for plugdir in platforms styles imageformats iconengines; do
    [[ -d "$qt_plugins/$plugdir" ]] || continue
    mkdir -p "$bundle/Contents/PlugIns/$plugdir"
    for src in "$qt_plugins/$plugdir"/*.dylib; do
      [[ -e "$src" ]] || continue
      name="$(basename "$src")"
      dest="$bundle/Contents/PlugIns/$plugdir/$name"
      # Replace any dangling Homebrew symlink left by macdeployqt
      rm -f "$dest"
      copy_real_file "$src" "$dest"
      strip_macho_signature "$dest"
    done
  done

  [[ -f "$bundle/Contents/PlugIns/platforms/libqcocoa.dylib" ]] \
    || die "failed to bundle platforms/libqcocoa.dylib from $qt_plugins"

  # Pull transitive deps of every bundled plugin into Frameworks/
  local plug
  while IFS= read -r -d '' plug; do
    file "$plug" 2>/dev/null | grep -q 'Mach-O' || continue
    collect_macos_deps "$plug" "$fwdir"
  done < <(find "$bundle/Contents/PlugIns" -type f -name '*.dylib' -print0 2>/dev/null)
}

bundle_mac() {
  local bin="$ROOT/$APP"
  [[ -f "$bin" ]] || die "missing binary: $bin (build first)"

  local stage="$DIST/$APP-mac-$ARCH"
  local bundle="$stage/${APP}.app"
  local fwdir="$bundle/Contents/Frameworks"
  rm -rf "$stage"
  mkdir -p "$bundle/Contents/MacOS" "$fwdir" "$bundle/Contents/Resources"

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
    fw="$(find /Library/Frameworks "$HOME/lazarus" -type d -name 'Qt6Pas.framework' 2>/dev/null | head -n1 || true)"
  fi
  [[ -n "$fw" && -d "$fw" ]] || die "Qt6Pas.framework not found"
  cp -a "$fw" "$fwdir/"

  local pas_bin exe
  pas_bin="$fwdir/Qt6Pas.framework/Versions/6/Qt6Pas"
  [[ -f "$pas_bin" ]] || pas_bin="$(find "$fwdir/Qt6Pas.framework" -type f -name Qt6Pas | head -n1)"
  [[ -f "$pas_bin" ]] || die "Qt6Pas binary not found inside framework"
  exe="$bundle/Contents/MacOS/$APP"

  # Pull Qt frameworks / dylibs referenced by Qt6Pas (and recursively)
  collect_macos_deps "$pas_bin" "$fwdir"
  collect_macos_deps "$exe" "$fwdir"
  ensure_qt_frameworks "$fwdir"
  # Re-walk after ensuring core Qt frameworks (picks up QtDBus etc.)
  for f in "$fwdir"/Qt*.framework/Versions/*/Qt*; do
    [[ -f "$f" ]] || continue
    file "$f" 2>/dev/null | grep -q 'Mach-O' || continue
    collect_macos_deps "$f" "$fwdir"
  done

  # Also try macdeployqt for plugins. The main binary only links Qt6Pas (not
  # QtGui), so point -executable at Qt6Pas or macdeployqt skips platforms/.
  local macdeployqt
  macdeployqt="$(find_qt_bin macdeployqt || true)"
  if [[ -n "$macdeployqt" ]]; then
    "$macdeployqt" "$bundle" -verbose=1 \
      "-executable=$pas_bin" \
      2>&1 | tail -n 80 || true
    [[ -d "$fwdir/Qt6Pas.framework" ]] || cp -a "$fw" "$fwdir/"
    # macdeployqt may refresh frameworks with absolute Homebrew paths — re-collect
    collect_macos_deps "$pas_bin" "$fwdir"
  fi

  # Always install platform (and related) plugins ourselves — required for GUI.
  bundle_macos_qt_plugins "$bundle" "$fwdir"

  # qt.conf in Resources (macOS app-bundle convention) + beside the exe.
  # Prefix is relative to Contents/ for Resources/qt.conf.
  cat > "$bundle/Contents/Resources/qt.conf" <<'EOF'
[Paths]
Prefix = .
Plugins = PlugIns
Libraries = Frameworks
EOF
  cat > "$bundle/Contents/MacOS/qt.conf" <<'EOF'
[Paths]
Prefix = ..
Plugins = PlugIns
Libraries = Frameworks
EOF

  # Bundle leftover ICU/Homebrew dylibs and rewrite all absolute refs to @rpath
  relink_macos_bundle "$fwdir" "$exe"

  # Ensure main binary references Qt6Pas via @rpath
  local old
  while IFS= read -r old; do
    case "$old" in
      *Qt6Pas*)
        install_name_tool -change "$old" \
          @rpath/Qt6Pas.framework/Versions/6/Qt6Pas \
          "$exe" 2>/dev/null || true
        ;;
    esac
  done < <(otool -L "$exe" | awk 'NR>1 {print $1}')

  # Also rewrite plugins
  if [[ -d "$bundle/Contents/PlugIns" ]]; then
    local plug
    while IFS= read -r -d '' plug; do
      file "$plug" 2>/dev/null | grep -q 'Mach-O' || continue
      install_name_tool -add_rpath @executable_path/../Frameworks "$plug" 2>/dev/null || true
      fix_macho_deps "$plug" "$fwdir"
    done < <(find "$bundle/Contents/PlugIns" -type f -print0 2>/dev/null)
  fi

  # Ad-hoc sign after install_name_tool (required on modern macOS)
  if command -v codesign >/dev/null 2>&1; then
    codesign --force --deep --sign - "$bundle" 2>/dev/null || \
      codesign --force --sign - "$exe" 2>/dev/null || true
  fi

  assert_macos_relocatable "$fwdir"
  [[ -f "$bundle/Contents/PlugIns/platforms/libqcocoa.dylib" ]] \
    || die "libqcocoa.dylib missing after relink — cannot ship macOS bundle"

  cat > "$stage/README.txt" <<EOF
FPG Editor (Qt6)
Open ${APP}.app — Qt6Pas and Qt6 frameworks are embedded in Contents/Frameworks.
EOF

  tar -C "$DIST" -czf "${APP}-mac-${ARCH}.tar.gz" "$(basename "$stage")"
  echo "Created ${APP}-mac-${ARCH}.tar.gz"
  echo "Frameworks / dylibs bundled:"
  ls -1 "$fwdir"
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

#!/bin/bash
set -e

echo "=== HairCutTicketMachine Setup Script ==="

# ── 1. Enable armhf multiarch ──────────────────────────────────────────────
echo "[1/7] Enabling armhf multiarch..."
dpkg --add-architecture armhf
apt update

# ── 2. Install armhf Qt5/app dependencies ─────────────────────────────────
echo "[2/7] Installing armhf libraries..."
apt install -y \
    libgles2:armhf \
    libmd4c0:armhf \
    libdouble-conversion3:armhf \
    libpcre2-16-0:armhf \
    libgl1:armhf \
    libglx0:armhf \
    libglib2.0-0:armhf \
    libstdc++6:armhf \
    libgcc-s1:armhf \
    libc6:armhf \
    zlib1g:armhf \
    libpng16-16:armhf \
    libjpeg62-turbo:armhf \
    libfreetype6:armhf \
    libfontconfig1:armhf \
    libx11-6:armhf \
    libxext6:armhf \
    libxrender1:armhf \
    libxi6:armhf \
    libxcb1:armhf \
    libxcb-glx0:armhf \
    libxcb-icccm4:armhf \
    libxcb-image0:armhf \
    libxcb-keysyms1:armhf \
    libxcb-randr0:armhf \
    libxcb-render0:armhf \
    libxcb-render-util0:armhf \
    libxcb-shape0:armhf \
    libxcb-shm0:armhf \
    libxcb-sync1:armhf \
    libxcb-xfixes0:armhf \
    libxcb-xinerama0:armhf \
    libxcb-xkb1:armhf \
    libxkbcommon0:armhf \
    libxkbcommon-x11-0:armhf \
    libdbus-1-3:armhf \
    libatspi2.0-0:armhf \
    libegl1:armhf \
    libinput10:armhf \
    libmtdev1:armhf \
    libudev1:armhf \
    libevdev2:armhf \
    libgudev-1.0-0:armhf \
    libharfbuzz0b:armhf \
    libgssapi-krb5-2:armhf \
    libkrb5-3:armhf \
    libk5crypto3:armhf \
    libkrb5support0:armhf \
    libcom-err2:armhf \
    libkeyutils1:armhf

# ── 3. Install system tools ────────────────────────────────────────────────
echo "[3/7] Installing system tools..."
apt install -y net-tools i2c-tools git

# ── 4. Clone Qt5 libs from GitHub ─────────────────────────────────────────
echo "[4/7] Cloning qt5opi from GitHub..."
CLONE_DIR="/tmp/qt5opi"
rm -rf "$CLONE_DIR"
git clone https://github.com/vplong990/qt5opi "$CLONE_DIR"

# ── 5. Copy to /usr/local/qt5opi ──────────────────────────────────────────
echo "[5/7] Copying to /usr/local/qt5opi..."
rm -rf /usr/local/qt5opi
cp -r "$CLONE_DIR" /usr/local/qt5opi
echo "Qt5 libs installed at /usr/local/qt5opi"

# ── 6. Run ldd and fix missing symlinks ───────────────────────────────────
echo "[6/7] Checking ldd and fixing symlinks..."

APP_PATH="/usr/local/qt5opi/HairCutTicketMachine"

if [ ! -f "$APP_PATH" ]; then
    echo "WARNING: $APP_PATH not found — skipping ldd/symlink step."
    echo "         Place the binary there and re-run from step 6 manually."
else
    LIB_DIRS=(
        /usr/lib/arm-linux-gnueabihf
        /usr/local/qt5opi/lib
        /usr/local/qt5opi/plugins
    )

    echo "--- ldd output ---"
    ldd "$APP_PATH" || true
    echo "------------------"

    # Fix broken symlinks for known versioned libs in armhf lib dir
    ARMHF_LIB=/usr/lib/arm-linux-gnueabihf

    fix_symlink() {
        local soname="$1"          # e.g. libGLESv2.so.2
        local pattern="$2"         # e.g. libGLESv2.so.2.*
        local target
        target=$(ls "$ARMHF_LIB"/$pattern 2>/dev/null | head -n1)
        if [ -n "$target" ] && [ ! -e "$ARMHF_LIB/$soname" ]; then
            echo "Creating symlink: $ARMHF_LIB/$soname -> $(basename "$target")"
            ln -s "$(basename "$target")" "$ARMHF_LIB/$soname"
        fi
    }

    fix_symlink libGLESv2.so.2        "libGLESv2.so.2.*"
    fix_symlink libEGL.so.1           "libEGL.so.1.*"
    fix_symlink libGL.so.1            "libGL.so.1.*"
    fix_symlink libmd4c.so.0          "libmd4c.so.0.*"
    fix_symlink libdouble-conversion.so.3 "libdouble-conversion.so.3.*"
    fix_symlink libpcre2-16.so.0      "libpcre2-16.so.0.*"
    fix_symlink libharfbuzz.so.0      "libharfbuzz.so.0.*"
    fix_symlink libgssapi_krb5.so.2   "libgssapi_krb5.so.2.*"

    # Also fix symlinks inside qt5opi/lib if it exists
    QT5_LIB=/usr/local/qt5opi/lib
    if [ -d "$QT5_LIB" ]; then
        echo "Fixing symlinks in $QT5_LIB..."
        find "$QT5_LIB" -name "*.so.*" | while read -r versioned; do
            base=$(echo "$versioned" | sed 's/\.so\..*//')
            soname="${base}.so"
            if [ ! -e "$soname" ]; then
                echo "  Linking $(basename "$soname") -> $(basename "$versioned")"
                ln -sf "$(basename "$versioned")" "$soname"
            fi
        done
    fi

    ldconfig
    echo "ldconfig updated."

    echo "--- ldd after fix ---"
    ldd "$APP_PATH" || true
    echo "---------------------"
fi

# ── 7. Done ───────────────────────────────────────────────────────────────
echo "[7/7] Setup complete!"
echo ""
echo "To run the app:"
echo "  cd /usr/local/qt5opi && ./HairCutTicketMachine"
echo ""
echo "If you still see missing libraries, paste ldd output and run:"
echo "  sudo apt install lib<name>:armhf"

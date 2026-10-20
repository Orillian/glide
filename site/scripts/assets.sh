#!/bin/sh
# Rebuilds the site's icons and Open Graph image from the app in this repo. Run
# scripts/build.sh at the repo root first, or point GLIDE_REPO at a checkout
# with a built dist/Glide.app. Reads the app's files, never writes to them.
#
#   site/scripts/assets.sh
#   GLIDE_REPO=~/src/glide site/scripts/assets.sh
#
# The Open Graph image shows a frame of Glide's own synthetic recording
# (`glide synth`, no screen content), styled by scripts/og/style.json and
# rendered by Glide itself. It needs Google Chrome; cwebp and ImageMagick come
# from Homebrew. The demo and feature cards on the page are HTML, not assets.
set -eu
cd "$(dirname "$0")/.."
GLIDE_REPO="${GLIDE_REPO:-$(cd .. && pwd)}"
GLIDE="$GLIDE_REPO/dist/glide"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
ASSETS=src/lib/assets
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP" scripts/og/frame.png scripts/og/icon.png' EXIT
mkdir -p "$ASSETS" static

echo "==> Icons"
iconutil -c iconset -o "$TMP/AppIcon.iconset" "$GLIDE_REPO/dist/Glide.app/Contents/Resources/AppIcon.icns"
ICON="$TMP/AppIcon.iconset/icon_512x512@2x.png"
# The 1024 px icon follows the macOS grid: the tile itself is 824 px, inset 100 px.
magick "$ICON" -crop 824x824+100+100 +repage "$TMP/tile.png"
magick "$TMP/tile.png" -resize 224x224 -strip "$TMP/icon-224.png"
cwebp -quiet -q 90 -alpha_q 100 "$TMP/icon-224.png" -o "$ASSETS/icon.webp"
magick "$TMP/tile.png" -resize 64x64 -strip static/favicon.png
magick "$TMP/tile.png" -resize 180x180 -strip static/apple-touch-icon.png
magick "$TMP/tile.png" -define icon:auto-resize=48,32,16 static/favicon.ico

echo "==> Open Graph image"
# HOME points at an empty folder so Glide can't read your presets or settings.
mkdir "$TMP/home"
HOME="$TMP/home" "$GLIDE" frame --synthetic -t 0 --height 1080 \
	--style "$(cat scripts/og/style.json)" -o scripts/og/frame.png >/dev/null
cp "$TMP/tile.png" scripts/og/icon.png
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
	--window-size=1200,630 --screenshot="$TMP/og.png" "file://$PWD/scripts/og/og.html" 2>/dev/null
magick "$TMP/og.png" -strip -quality 88 static/og.jpg

ls -l "$ASSETS" static

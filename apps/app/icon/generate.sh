#!/usr/bin/env bash
# Renders the app icon of every platform from sonar.svg, or from sonar-small.svg
# under 48 px where the full sonar blurs. Needs rsvg-convert and magick.
set -euo pipefail
cd "$(dirname "$0")"
app=..
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

source_for() { if (($1 < 48)); then echo sonar-small.svg; else echo sonar.svg; fi; }

# Full bleed and opaque, for the platforms that cut the shape themselves.
square() { # size output
  rsvg-convert -w "$1" -h "$1" "$(source_for "$1")" | magick - -alpha off "PNG24:$2"
}

# A rounded square inset by $2 in a 1024 frame, scaled down to $1.
rounded() { # size inset output [shadow]
  local body=$((1024 - 2 * $2))
  local radius=$((body * 225 / 1000))
  rsvg-convert -w $body -h $body "$(source_for $(($1 * body / 1024)))" |
    magick - -alpha set \( -size ${body}x$body xc:none -fill white \
      -draw "roundrectangle 0,0 $((body - 1)),$((body - 1)) $radius,$radius" \) \
      -compose DstIn -composite -compose over -background none -gravity center -extent 1024x1024 "$tmp/frame.png"
  if [[ ${4:-} == shadow ]]; then
    magick "$tmp/frame.png" \( +clone -fill black -colorize 100 -channel A -blur 0x12 \
      -evaluate multiply 0.35 +channel -roll +0+12 \) +swap -compose over -composite "$tmp/frame.png"
  fi
  magick "$tmp/frame.png" -resize "$1x$1" "$3"
}

# An Android adaptive layer: the sonar in the 72 dp shown of a 108 dp layer.
layer() { # size output css
  local shown=$(($1 * 72 / 108))
  rsvg-convert -w $shown -h $shown -s <(echo "$3") sonar.svg |
    magick - -background none -gravity center -extent "$1x$1" "$2"
}

ios=$app/ios/Runner/Assets.xcassets/AppIcon.appiconset
for file in "$ios"/Icon-App-*.png; do
  [[ $file =~ -([0-9.]+)x[0-9.]+@([0-9])x ]]
  square "$(awk "BEGIN { print ${BASH_REMATCH[1]} * ${BASH_REMATCH[2]} }")" "$file"
done

for file in "$app"/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_*.png; do
  [[ $file =~ _([0-9]+)\.png ]]
  rounded "${BASH_REMATCH[1]}" 100 "$file" shadow
done

res=$app/android/app/src/main/res
for density in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
  dir=$res/mipmap-${density%:*}
  size=${density#*:}
  rounded $size 0 "$dir/ic_launcher.png"
  layer $((size * 9 / 4)) "$dir/ic_launcher_foreground.png" '.background { display: none }'
  layer $((size * 9 / 4)) "$dir/ic_launcher_monochrome.png" \
    '.background, .glow { display: none } .ring { opacity: .5 } .ring * { stroke: #fff } .signal { fill: #fff }'
done

web=$app/web
rounded 32 0 "$web/favicon.png"
for size in 192 512; do
  rounded $size 0 "$web/icons/Icon-$size.png"
  square $size "$web/icons/Icon-maskable-$size.png"
done

for size in 16 20 24 32 40 48 64 256; do
  rounded $size 0 "$tmp/windows-$size.png"
done
magick "$tmp"/windows-{16,20,24,32,40,48,64,256}.png -define icon:png-compression-size=256 \
  "$app/windows/runner/resources/app_icon.ico"

#!/usr/bin/env bash
# Signs the app as Xcode does with a provisioning profile, which the data
# protection keychain requires, but with Developer ID for notarization.
set -euo pipefail

app=$1
entitlements=$2
profile="$app/Contents/embedded.provisionprofile"
profile_plist="$RUNNER_TEMP/profile.plist"
signed_entitlements="$RUNNER_TEMP/Submarine.entitlements"

echo "$PROVISIONING_PROFILE_BASE64" | base64 --decode > "$profile"
security cms -D -i "$profile" > "$profile_plist"
team=$(/usr/libexec/PlistBuddy -c 'Print :TeamIdentifier:0' "$profile_plist")
app_id=$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:com.apple.application-identifier' "$profile_plist")
bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist")
if [ "$app_id" != "$team.$bundle_id" ]; then
  echo "The provisioning profile is for $app_id, not $team.$bundle_id" >&2
  exit 1
fi

sed "s/\$(AppIdentifierPrefix)/$team./" "$entitlements" > "$signed_entitlements"
/usr/libexec/PlistBuddy \
  -c "Add :com.apple.application-identifier string $app_id" \
  -c "Add :com.apple.developer.team-identifier string $team" \
  "$signed_entitlements"

sign() {
  codesign --force --timestamp --options runtime \
    --sign 'Developer ID Application' "$@"
}
for framework in "$app"/Contents/Frameworks/*.framework; do
  sign "$framework"
done
sign --entitlements "$signed_entitlements" "$app"
codesign --verify --deep --strict "$app"

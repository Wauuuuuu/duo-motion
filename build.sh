#!/bin/zsh
set -eu
cd "$(dirname "$0")"
duo_signing_identity="${DUO_SIGNING_IDENTITY:--}"
if [[ "$duo_signing_identity" == "-" && -d "build/Duo Motion.app" && "${DUO_ALLOW_ADHOC_UPDATE:-0}" != "1" ]]; then
    print -u2 'Build stopped before modifying the installed app: ad-hoc updates change its screen-recording identity.'
    print -u2 'Use DUO_SIGNING_IDENTITY with a stable signing certificate. For an intentional local update requiring new authorization, set DUO_ALLOW_ADHOC_UPDATE=1.'
    exit 64
fi
mkdir -p "build/Duo Motion.app/Contents/MacOS" "build/Duo Motion.app/Contents/Resources"
xcrun clang -target arm64-apple-macos14.0 -O2 -Wall -Wextra -c Sources/HingeSensor.c -o build/HingeSensor.o
xcrun swiftc -O -swift-version 5 -target arm64-apple-macos14.0 -import-objc-header Sources/HingeSensor.h Sources/Motion.swift Sources/CaptureAccess.swift Sources/Renderer.swift Sources/Capture.swift Sources/App.swift Sources/main.swift build/HingeSensor.o -framework AppKit -framework Metal -framework MetalKit -framework MetalPerformanceShaders -framework ScreenCaptureKit -framework IOKit -framework CoreFoundation -framework Carbon -o "build/Duo Motion.app/Contents/MacOS/Duo Motion"
cp Info.plist "build/Duo Motion.app/Contents/Info.plist"
cp Resources/Fold.metal "build/Duo Motion.app/Contents/Resources/Fold.metal"
codesign --force --sign "$duo_signing_identity" --identifier local.angle.duomotion "build/Duo Motion.app"
print 'Built: build/Duo Motion.app'

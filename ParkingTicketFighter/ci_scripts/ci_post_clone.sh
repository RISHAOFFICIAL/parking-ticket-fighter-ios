#!/bin/sh
# Xcode Cloud post-clone script for Parking Ticket Fighter.
#
# Xcode Cloud runs this right after it clones the repository, before
# it builds. This project has no third-party dependencies yet (pure
# SwiftUI, no Swift packages to fetch, no CocoaPods, no Homebrew
# tools), so there is nothing to install. The script exists so the
# hook is in place for the day a dependency arrives, and so the build
# log confirms the checkout landed where Xcode Cloud expects it.
#
# This folder (ci_scripts) must stay next to the .xcodeproj, or at the
# root of the repository, for Xcode Cloud to find it.

set -e

echo "Parking Ticket Fighter: post-clone check"
echo "Working directory: $(pwd)"
ls -la
echo "Post-clone check complete. No dependencies to fetch."

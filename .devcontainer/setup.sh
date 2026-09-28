#!/usr/bin/env bash
set -euo pipefail

if [[ ! -x "$HOME/flutter/bin/flutter" ]]; then
  git clone --depth 1 --branch 3.32.8 https://github.com/flutter/flutter.git "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$HOME/.pub-cache/bin:$PATH"
flutter --version
dart pub global activate melos 7.1.0
melos bootstrap

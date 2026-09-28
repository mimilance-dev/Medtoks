#!/usr/bin/env bash
set -euo pipefail

melos run format
melos run analyze
melos run test
(
  cd apps/mentor
  flutter build web --release
)

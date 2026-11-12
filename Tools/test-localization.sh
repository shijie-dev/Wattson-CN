#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 Tools/validate-localization.py
swiftc Sources/Wattson/Localization.swift Tools/localization-tests/main.swift -o Tools/localization-tests/check
for LANGUAGE in en zh-Hans; do
    WATTSON_LANGUAGE="$LANGUAGE" WATTSON_TEST_RESOURCES="$PWD/Sources/Wattson/Resources" \
        Tools/localization-tests/check Tools/localization-tests/catalog-cases.json
done

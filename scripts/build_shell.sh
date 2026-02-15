#!/bin/bash

cd ../shell/dartos_shell
flutter build linux --release
mv build/linux/arm64/release/bundle/ ../../dist/dartos_shell
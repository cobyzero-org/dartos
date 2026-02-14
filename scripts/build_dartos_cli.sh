#!/bin/bash
#Compile dart_cli
cd ../sdk/dartos_cli
dart compile exe bin/dartos_cli.dart -o dartos
sudo mv dartos /usr/local/bin/
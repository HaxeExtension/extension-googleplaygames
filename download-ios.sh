#!/bin/bash
curl -O "https://developers.google.com/games/services/downloads/gpg-cpp-sdk.v2.1.zip"
unzip gpg-cpp-sdk.v2.1.zip
mv gpg-cpp-sdk/ios/gpg.* frameworks
rm -rf gpg-cpp-sdk gpg-cpp-sdk.v2.1.zip

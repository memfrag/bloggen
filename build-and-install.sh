#!/bin/sh

swift build --configuration release

# Install to ~/bin
cp ./.build/release/bloggen ~/bin/bloggen

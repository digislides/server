#!/usr/bin/env bash

# Get dart executable
cp `which dart` ./

# Make app snapshot
dart --snapshot=app.dart.snapshot ../../bin/server.dart

# Build docker image
docker build --tag echannel .
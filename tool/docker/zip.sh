#!/usr/bin/env bash

# Get dart executable
cp `which dart` ./

# Make app snapshot
dart --snapshot=app.dart.snapshot ../../bin/server.dart

# Tar the necessary files
tar -czvf server.tar.gz dart app.dart.snapshot Dockerfile build.sh
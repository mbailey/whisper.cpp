#!/bin/bash

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
for cmd in make g++; do
    if ! command_exists $cmd; then
        echo "Error: $cmd is not installed. Please install it and try again."
        exit 1
    fi
done

# Check for CMake separately and provide installation instructions
if ! command_exists cmake; then
    echo "Error: cmake is not installed. Please install it and try again."
    echo "To install CMake on Fedora, run:"
    echo "sudo dnf install cmake"
    exit 1
fi

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake -DCMAKE_BUILD_TYPE=Release ..

# Build
make -j$(nproc)

echo "Build completed successfully!"
echo "The 'main' executable can be found in the 'build' directory."

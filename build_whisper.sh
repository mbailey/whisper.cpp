#!/bin/bash

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
for cmd in ccache cmake make g++; do
    if ! command_exists $cmd; then
        echo "Error: $cmd is not installed. Please install it and try again."
        echo "sudo dnf install $cmd"
        exit 1
    fi
done

# Download the model if it doesn't exist
MODEL_PATH="$(pwd)/../models/ggml-base.en.bin"
if [ ! -f "$MODEL_PATH" ]; then
    echo "Downloading the base.en model..."
    bash "$(pwd)/../models/download-ggml-model.sh" base.en
fi

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake -DCMAKE_BUILD_TYPE=Release ..

# Build
make -j$(nproc)

echo "Build completed successfully!"
echo "The 'main' executable can be found at: $(pwd)/bin/main"
echo "Running the main executable with the sample audio file..."
echo -e "\033[1;34mExecuting command:\033[0m $(pwd)/bin/main -m $MODEL_PATH -f $(pwd)/../samples/jfk.wav"
$(pwd)/bin/main -m $MODEL_PATH -f "$(pwd)/../samples/jfk.wav"

# Print the contents of the models directory
echo -e "\033[1;33mContents of the models directory:\033[0m"
ls -l ../models/ | sed 's/^/  /'

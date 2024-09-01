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

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set the models directory, use environment variable if set, otherwise use default
MODELS_DIR="${WHISPER_MODELS_DIR:-$SCRIPT_DIR/models}"

# Create models directory if it doesn't exist
mkdir -p "$MODELS_DIR"

# Download the model if it doesn't exist
MODEL_PATH="$MODELS_DIR/ggml-base.en.bin"
DOWNLOAD_SCRIPT="$SCRIPT_DIR/models/download-ggml-model.sh"
if [ ! -f "$MODEL_PATH" ]; then
    echo "Downloading the base.en model..."
    bash "$DOWNLOAD_SCRIPT" base.en "$MODELS_DIR"
fi

# Mention the new script for downloading all models
echo "Note: To download all available models, run the 'download_all_models.sh' script."

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
$(pwd)/bin/main -m "$MODEL_PATH" -f "$(pwd)/../samples/jfk.wav"

echo "Models are stored in: $MODELS_DIR"

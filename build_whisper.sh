#!/bin/bash

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# List of required packages
REQUIRED_PACKAGES=(ccache cmake make ffmpeg gcc-c++)

# Check for required tools and collect missing packages
MISSING_PACKAGES=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! command_exists ${pkg%%-*}; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

# If there are missing packages, offer to install them
if [ ${#MISSING_PACKAGES[@]} -ne 0 ]; then
    echo "The following required packages are missing:"
    printf '%s\n' "${MISSING_PACKAGES[@]}"
    
    read -p "Do you want to install these packages? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Installing missing packages..."
        sudo dnf install -y "${MISSING_PACKAGES[@]}"
    else
        echo "Cannot proceed without required packages. Exiting."
        exit 1
    fi
fi

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

# Download sample audio files if they don't exist
SAMPLES_DIR="$SCRIPT_DIR/samples"
mkdir -p "$SAMPLES_DIR"

download_sample() {
    local filename="$1"
    local url="$2"
    if [ ! -f "$SAMPLES_DIR/$filename" ]; then
        echo "Downloading $filename sample..."
        wget -q -O "$SAMPLES_DIR/$filename" "$url"
    fi
}

download_sample "jfk.wav" "https://github.com/ggerganov/whisper.cpp/raw/master/samples/jfk.wav"
download_sample "jfk.mp3" "https://github.com/ggerganov/whisper.cpp/raw/master/samples/jfk.mp3"

# Mention the new script for downloading all models
echo "Note: To download all available models, run the 'download_all_models.sh' script."

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF ..

# Build main and server
make -j$(nproc) main
make -j$(nproc) server

echo "Build completed successfully!"
echo "The 'main' executable can be found at: $(pwd)/bin/main"
echo "The 'server' executable can be found at: $(pwd)/bin/server"
echo "Running the main executable with sample audio files..."

# Test with WAV file - not supported yet
# echo -e "\033[1;34mTesting WAV file:\033[0m"
# echo -e "\033[1;34mExecuting command:\033[0m $(pwd)/bin/main -m $MODEL_PATH -f $(pwd)/../samples/jfk.wav"
# $(pwd)/bin/main -m "$MODEL_PATH" -f "$(pwd)/../samples/jfk.wav"

# Test with MP3 file
echo -e "\n\033[1;34mTesting MP3 file:\033[0m"
echo -e "\033[1;34mExecuting command:\033[0m $(pwd)/bin/main -m $MODEL_PATH -f $(pwd)/../samples/jfk.mp3"
$(pwd)/bin/main -m "$MODEL_PATH" -f "$(pwd)/../samples/jfk.mp3"

echo -e "\nModels are stored in: $MODELS_DIR"

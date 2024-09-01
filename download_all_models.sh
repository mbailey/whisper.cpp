#!/bin/bash

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
if ! command_exists wget; then
    echo "Error: wget is not installed. Please install it and try again."
    echo "sudo dnf install wget"
    exit 1
fi

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set the models directory, use environment variable if set, otherwise use default
MODELS_DIR="${WHISPER_MODELS_DIR:-$SCRIPT_DIR/models}"

# Create models directory if it doesn't exist
mkdir -p "$MODELS_DIR"

# Path to the download script
DOWNLOAD_SCRIPT="$SCRIPT_DIR/models/download-ggml-model.sh"

# List of all available models
MODELS=(
    "tiny.en"
    "tiny"
    "base.en"
    "base"
    "small.en"
    "small"
    "medium.en"
    "medium"
    "large-v1"
    "large"
)

# Download each model if it doesn't exist
for model in "${MODELS[@]}"; do
    MODEL_PATH="$MODELS_DIR/ggml-$model.bin"
    if [ ! -f "$MODEL_PATH" ]; then
        echo "Downloading $model model..."
        bash "$DOWNLOAD_SCRIPT" "$model" "$MODELS_DIR"
    else
        echo "$model model already exists. Skipping download."
    fi
done

echo "All models have been checked and downloaded if necessary."
echo "Models are stored in: $MODELS_DIR"

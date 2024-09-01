#!/bin/bash

# whisper-server-start

# Set the path to the model file
MODEL="${AILOCAL_WHISPER_DEFAULT_MODEL:-ggml-base.en.bin}"
MODELS_DIR="${AILOCAL_WHISPER_MODELS_DIR:-models}"
MODEL_FILE="${MODELS_DIR}/${MODEL}"

# Set the port for the server
API_ENDPOINT="${AILOCAL_WHISPER_API_ENDPOINT:-"http://localhost:${PORT}/audio/transcriptions"}"
API_PORT="${AILOCAL_WHISPER_API_PORT:-2022}"
API_HOST="${AILOCAL_WHISPER_API_HOST:-localhost}"
API_PATH="${AILOCAL_WHISPER_API_PATH:-localhost}"

# Set the path to the server executable
SERVER_EXECUTABLE="./build/bin/server"

# Check if the server executable exists
if [ ! -f "$SERVER_EXECUTABLE" ]; then
    echo "Error: $SERVER_EXECUTABLE not found. Please build the project first."
    exit 1
fi

# Check if the model file exists
if [ ! -f "$MODEL_FILE" ]; then
    echo "Error: $MODEL_FILE not found. Please download the model first."
    exit 1
fi

# Start the server
echo "Starting Whisper server..."
$SERVER_EXECUTABLE \
  --host "$API_HOST" \
  --inference-path /audio/transcriptions \
  --port "$API_PORT" \
  --convert \
  --language en \
  --model "$MODEL_FILE" \
  --threads 4 \
  --convert \
  &

# Wait for the server to start
sleep 2

# Print example curl command
echo "Server started on port $PORT"
echo "Example curl command to test the server:"
echo "curl -X POST -F \"file=@./samples/jfk.wav\" \"${API_ENDPOINT}\""

echo "Press Ctrl+C to stop the server"

# Wait for user input to keep the script running
wait

#!/bin/bash

#!/bin/bash

# Set the path to the server executable
SERVER_EXECUTABLE="./build/bin/server"

# Set the path to the model file
MODEL_FILE="./models/ggml-base.en.bin"

# Set the port for the server (default is 8080)
PORT=8080

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
$SERVER_EXECUTABLE -m "$MODEL_FILE" -t 4 &

# Wait for the server to start
sleep 2

# Print example curl command
echo "Server started on port $PORT"
echo "Example curl command to test the server:"
echo "curl -X POST -H \"Content-Type: audio/wav\" --data-binary @./samples/jfk.wav http://localhost:$PORT/inference"

echo "Press Ctrl+C to stop the server"

# Wait for user input to keep the script running
wait

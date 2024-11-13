# #!/bin/bash

# LOG_DIR="/home/ubuntu/verblaze/logs/"
# LOG_CONTROLLER=$LOG_DIR"controller.log"
# LOG_SERVER=$LOG_DIR"server.log"
# LOG_WORKER1=$LOG_DIR"worker1.log"
# LOG_WORKER2=$LOG_DIR"worker2.log"
# LOG_WORKER3=$LOG_DIR"worker3.log"
# #/home/ubuntu/verblaze/logs/worker2.log
# # Ensure the log directory exists
# echo "Checking if log directory exists..."
# mkdir -p $LOG_DIR
# echo "Log directory is set to $LOG_DIR"

# # Start the controller service
# echo "Starting controller service..."
# python3 -m videollama2.serve.controller --host 0.0.0.0 --port 10000 > $LOG_CONTROLLER 2>&1 &
# if [ $? -eq 0 ]; then
#   echo "Controller service started successfully."
# else
#   echo "Failed to start controller service."
# fi

# # Start the Gradio web server
# echo "Starting Gradio web server..."
# python3 -m videollama2.serve.gradio_web_server --controller http://localhost:10000 --model-list-mode reload > $LOG_SERVER 2>&1 &
# if [ $? -eq 0 ]; then
#   echo "Gradio web server started successfully."
# else
#   echo "Failed to start Gradio web server."
# fi

# # Export endpoint for Hugging Face
# echo "Setting HF_ENDPOINT to https://hf-mirror.com"
# export HF_ENDPOINT=https://hf-mirror.com

# # Start the worker services
# echo "Starting worker 1..."
# python3 -m videollama2.serve.model_worker --host 0.0.0.0 --controller http://localhost:10000 --port 40000 --worker http://localhost:40000 --model-path "DAMO-NLP-SG/VideoLLaMA2-7B" > $LOG_WORKER1 2>&1 &
# if [ $? -eq 0 ]; then
#   echo "Worker 1 started successfully."
# else
#   echo "Failed to start worker 1."
# fi

# # echo "Starting worker 2..."
# # python3 -m videollama2.serve.model_worker --host 0.0.0.0 --controller http://localhost:10000 --port 40000 --worker http://localhost:40000 --model-path "DAMO-NLP-SG/VideoLLaMA2-7B" > $LOG_WORKER2 2>&1 &
# # if [ $? -eq 0 ]; then
# #   echo "Worker 2 started successfully."
# # else
# #   echo "Failed to start worker 2."
# # fi

# # echo "Starting worker 3..."
# # python3 -m videollama2.serve.model_worker --host 0.0.0.0 --controller http://localhost:10000 --port 40000 --worker http://localhost:40000 --model-path "DAMO-NLP-SG/VideoLLaMA2-7B-16F" > $LOG_WORKER3 2>&1 &
# # if [ $? -eq 0 ]; then
# #   echo "Worker 3 started successfully."
# # else
# #   echo "Failed to start worker 3."
# # fi

# echo "All services have been started. Check logs for details."


#!/bin/bash
LOG_DIR="/home/ubuntu/verblaze"
LOG_FILE=$LOG_DIR"/videollama2.log"
# python3 -m videollama2.serve.controller --host 0.0.0.0 --port 10000 > $LOG_DIR/videollama2.log 2>&1 &
# python3 -m videollama2.serve.gradio_web_server --controller http://localhost:10000 --model-list-mode reload > $LOG_DIR/script_output.log 2>&1 &

PYTHONUNBUFFERED=1 python3 videollama2/serve/gradio_web_server_adhoc.py > $LOG_FILE 2>&1 &

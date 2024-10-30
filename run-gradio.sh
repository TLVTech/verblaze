#!/bin/bash
LOG_DIR="/home/ubuntu/verblaze"

python3 -m videollama2.serve.controller --host 0.0.0.0 --port 10000 > $LOG_DIR/videollama2.log 2>&1 &
python3 -m videollama2.serve.gradio_web_server --controller http://localhost:10000 --model-list-mode reload > $LOG_DIR/script_output.log 2>&1 &
#!/bin/bash

python3 -m videollama2.serve.controller --host 0.0.0.0 --port 10000 > /tmp/videollama2.log 2>&1 &
python3 -m videollama2.serve.gradio_web_server --controller http://localhost:10000 --model-list-mode reload > /tmp/gradio.log 2>&1 &&

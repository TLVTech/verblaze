python3 -m videollama2.serve.controller --host 0.0.0.0 --port 10000 &
python3 -m videollama2.serve.gradio_web_server --controller http://localhost:10000 --model-list-mode reload &

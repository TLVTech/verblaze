from google.cloud import aiplatform
import base64
import os

import vertexai

from vertexai.generative_models import GenerativeModel, Part

# TODO(developer): Update and un-comment below line
# PROJECT_ID = "your-project-id"



vision_model = GenerativeModel("gemini-1.5-flash-002")

def process_image_vertex(image_base64,message):
    
    response = vision_model.generate_content([
        Part.from_data(image_base64, mime_type="image/jpeg"), message,
    ])
    print(response.text)
    return response

def process_video_vertex(video_base64, message):
    # Send the video to the Vertex AI endpoint
    response = vision_model.generate_content([
        Part.from_data(video_base64, mime_type="video/mp4"), message 
    ])
    print(response.text)
    return response

def process_text_vertex(text):
    response = vision_model.generate_content([
        Part.from_data(text, mime_type="text/plain")
    ])
    print(response.predictions)
    return response
    # Process the video frame by frame or send the entire video to the endpoint
    # ...
# Example usage:
# if __name__ == "__main__":
    # image_path = "../assets/logo.png"
    # video_path = "../assets/sora.mp4"
    # text = "This is a text input"
    # with open(image_path, "rb") as image_file:
    #         image_data = base64.b64encode(image_file.read()).decode("utf-8")
    # with open(video_path, "rb") as video_file:
    #         video_data = base64.b64encode(video_file.read()).decode("utf-8")
    #process_image_vertex(image_data,"what is in the image?")
    #process_video_vertex(video_data,"what is in the video?")
    #process_text_vertex(text)

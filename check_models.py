import google.generativeai as genai

from dotenv import load_dotenv
import os

# 1. Load environment variables
load_dotenv()

# 2. Retrieve the key securely
api_key = os.getenv("API_KEY")
genai.configure(api_key)

print("Listing available models...")
for m in genai.list_models():
    if 'generateContent' in m.supported_generation_methods:
        print(m.name)
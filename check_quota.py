import google.generativeai as genai
from dotenv import load_dotenv
import os

# 1. Load environment variables
load_dotenv()

# 2. Retrieve the key securely
api_key = os.getenv("API_KEY")
genai.configure(api_key)

# The candidates we want to test (in order of preference for high limits)
candidates = [
     "gemini-2.0-flash-lite-preview-02-05"
]

print("🕵️  Hunting for a working model with quota...\n")

for model_name in candidates:
    print(f"👉 Testing: {model_name}...", end=" ")
    try:
        model = genai.GenerativeModel(model_name)
        # Send a tiny prompt to check access
        response = model.generate_content("Hi")
        print("✅ SUCCESS!")
        print(f"   🎉 USE THIS NAME IN YOUR SCRIPT: '{model_name}'")
        break # Stop after finding the best one
    except Exception as e:
        error_msg = str(e)
        if "404" in error_msg:
            print("❌ Not Found (404)")
        elif "429" in error_msg or "Quota" in error_msg:
            print("❌ Quota Full/Rate Limited")
        else:
            print(f"❌ Error: {error_msg}")
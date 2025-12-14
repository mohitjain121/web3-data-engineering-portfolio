import google.generativeai as genai
import time

# --- PASTE YOUR KEY HERE ---
API_KEY = "AIzaSyBojZ_APH6ZTTtF_TFOwUX1eM2j21Iy8FQ"
genai.configure(api_key=API_KEY)

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
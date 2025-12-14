import google.generativeai as genai

genai.configure(api_key="AIzaSyA2OeFzeNDAzNxZjSObqGXw5DcsH2dFgD8")

print("Listing available models...")
for m in genai.list_models():
    if 'generateContent' in m.supported_generation_methods:
        print(m.name)
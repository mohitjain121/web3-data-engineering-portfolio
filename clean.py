import os
import sys
import time
import re
import pyperclip
from groq import Groq  # <--- CHANGE 1: Engine Import

# --- CONFIGURATION ---
# Get Key: https://console.groq.com/keys

API_KEY = "groq_api_key_here"
client = Groq(api_key=API_KEY)  # <--- CHANGE 2: Config

# Using Llama 3.3 70B (Excellent SQL, 1000 req/day limit)
# Fallback: 'llama-3.1-8b-instant' (14,400 req/day limit) if you hit limits
MODEL_NAME = "llama-3.1-8b-instant"

# --- UNIVERSAL SQL SYSTEM INSTRUCTIONS ---
SYSTEM_INSTRUCTION = """
You are a Principal Data Engineer refactoring legacy SQL code for a GitHub portfolio.
The input code can be in ANY SQL dialect (Standard ANSI, Spark, Trino, PostgreSQL, MySQL, T-SQL, PL/SQL, BigQuery, Snowflake, etc.).

YOUR GOAL: Maximize professional readability while preserving execution integrity for THAT SPECIFIC DIALECT.

1. CRITICAL INTEGRITY RULES (ZERO TOLERANCE):
   - DETECT DIALECT: Analyze the syntax to determine the SQL flavor (e.g. `TOP` vs `LIMIT`, `LATERAL VIEW` vs `UNNEST`).
   - STAY IN CHARACTER: If the code is T-SQL, keep it T-SQL. If it is Spark, keep it Spark. Do NOT convert to a "standard" format that breaks valid proprietary functions.
   - NO HALLUCINATIONS: Do NOT change table names, column names, or logic.
   - PRESERVE ARTIFACTS: Keep `{{parameters}}`, Jinja templating, and hex/base58 strings (e.g. `0x...`, `vXi...`) exact.

2. INDUSTRY FORMATTING STANDARDS:
   - LOWERCASE: Use lowercase for field names and table names.
   - UPPERCASE: Use uppercase for SQL keywords (SELECT, FROM, WHERE, AS, ON, UNION, WITH).
   - NEW LINES: 
     - Start a new line for every major keyword (SELECT, FROM, WHERE, GROUP BY).
     - Start a new line for every column in the SELECT list.
     - Start a new line for logical operators (AND, OR) in WHERE clauses.
   - INDENTATION: Use 4 spaces for sub-logic.
   - ALIGNMENT: Left-align root keywords.

3. DOCUMENTATION:
   - HEADER: Add a single block comment at the top with ONLY a "Description" field.
     /* Description: [1-sentence summary]
     */
   - Add concise inline comments for complex aggregations or regex logic.

OUTPUT: Return ONLY the raw SQL code. No markdown backticks. No conversational text.
"""

def clean_markdown(text):
    """
    Robustly removes markdown code blocks (```sql, ```, etc) using Regex.
    """
    pattern = r"^```[a-zA-Z0-9]*\n"  
    text = re.sub(pattern, "", text)
    text = re.sub(r"```$", "", text) 
    return text.strip()

def clean_code(sector, protocol, filename):
    # 1. Get content from clipboard
    raw_code = pyperclip.paste()
    if not raw_code or len(raw_code) < 5:
        print("❌ Error: Clipboard is empty!")
        return

    # Preview for safety
    print(f"\n✨ Processing: {sector} / {protocol} / {filename}")
    print(f"📝 Input Preview: {raw_code[:50].replace(chr(10), ' ')}...")

    try:
        # 2. Call Groq API <--- CHANGE 3: API Call Structure
        print(f"🚀 Sending to Groq ({MODEL_NAME})...")
        
        chat_completion = client.chat.completions.create(
            messages=[
                {"role": "system", "content": SYSTEM_INSTRUCTION},
                {"role": "user", "content": f"RAW CODE:\n{raw_code}"}
            ],
            model=MODEL_NAME,
            temperature=0.1, # Low temp for precision
        )

        # 3. Robust cleaning <--- CHANGE 4: Response Handling
        response_text = chat_completion.choices[0].message.content
        cleaned_code = clean_markdown(response_text)

        # 4. Folder Management
        full_folder_path = os.path.join(sector, protocol)
        if not os.path.exists(full_folder_path):
            os.makedirs(full_folder_path)
            print(f"📂 Created new directory: {full_folder_path}")
        
        # 5. File Management
        if "." not in filename:
            filename += ".sql"
        filepath = os.path.join(full_folder_path, filename)
        
        # 6. Write to file (Enforce UTF-8)
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(cleaned_code)
            
        print(f"✅ Saved to: {filepath}")
        
        # 7. Rate Limit Protection (Groq is fast, but polite 2s wait)
        print("⏳ Cooldown (2s)...")
        time.sleep(2)

    except Exception as e:
        print(f"❌ API Error: {e}")

# --- COMMAND LINE RUNNER ---
if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("\n⚠️  Usage Error.")
        print("Correct Format: python clean.py \"Sector\" \"Protocol\" \"Filename\"")
        print("Example: python clean.py \"01_DeFi\" \"Uniswap\" \"volume_logic\"\n")
    else:
        clean_code(sys.argv[1], sys.argv[2], sys.argv[3])
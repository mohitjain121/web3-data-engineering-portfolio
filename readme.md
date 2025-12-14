# Web3 Data Engineering Portfolio

This is a collection of archive SQL queries and data models for EVM and Solana protocols, refactored from legacy Dune Analytics dashboards. The codes here can be used on top of current web3 daatsets by changing the table / column names.

## 📂 Project Structure
This repository is organized by sector, containing optimized SQL logic for 30+ protocols.

- **01_Credential_Networks/**: Identity and on-chain reputation analysis (e.g., Galxe).
- **02_Security/**: Network monitoring, exploit tracking, and bot detection logic (e.g., Forta).
- **03_Bridges/**: Cross-chain transaction analysis and bridge volume metrics.
- **04_Wallets/**: Wallet profiling, holding analysis, and user segmentation.
- **05_DeFi/**: Deep dives into AMMs (Uniswap) and Lending markets (Aave, Compound).
- **06_Chains/**: L1/L2 specific network health metrics (gas, throughput).
- **07_Gambling/**: On-chain prediction markets and betting protocol analysis.
- **08_Non_Fungible_Tokens/**: NFT marketplace volume, wash-trading filters, and mint analytics.
- **09_Treasury/**: DAO treasury diversification and asset management reports.

- **Tools/**: Python automation scripts used to refactor 600+ queries in a short time.

## 🛠 Tech Stack
- **SQL Dialects:** Spark SQL, Trino, PostgreSQL, DuneSQL.
- **Automation:** Python (Groq/LLM-based refactoring pipeline).
- **Architecture:** CTE-based modular query design.

## 🤖 Automation Logic
This repository includes the `clean.py` script I built to automate the standardization of legacy SQL. Also **`check_models.py` / `check_quota.py`**: Utility scripts built to manage LLM API rate limits and model selection dynamically. These scripts:
1.  Detect SQL dialect logic.
2.  Apply industry-standard formatting (Upper keywords, snake_case).
3.  Generate documentation headers automatically.
# Product & Business Data Analyst Portfolio

**Anastasia Mori · Product & Business Data Analyst**

SQL, Python, BI and AI-agent projects focused on turning operational, financial and product-related data into reliable reporting, useful business insights and practical automation.

> **Portfolio scope:** this repository combines illustrative projects, synthetic datasets, educational prototypes and sanitized examples. Metrics shown in screenshots or generated datasets are demonstrational and should not be interpreted as production results.

## Featured projects

| Project | Business question | Tools | What it demonstrates |
|---|---|---|---|
| [Marketplace Profitability Analytics](ecommerce/02-profitability_analytics/README.md) | What drives marketplace profitability, costs and returns? | PostgreSQL, SQL, Apache Superset | Analytical dataset design, KPI logic, joins, profitability reporting |
| [Financial Planning & Cash Flow Analytics](it-consulting/superset_financial_planning/README.md) | Where do actual cash flows diverge from plan? | SQL Server, SQL, Apache Superset | Financial data modeling, plan-vs-actual analysis, dashboard design |
| [Retail Loss Analysis](ecommerce/04-retail_loss/README.md) | How can sales changes, promotions and returns be investigated? | Python, pandas, NumPy, Matplotlib | Synthetic-data generation, EDA, time-series analysis, analytical caveats |
| [E-commerce Operations Automation](ecommerce/03-operations_automation/README.md) | How can repetitive spreadsheet processes be made repeatable? | Python, pandas, openpyxl, PyYAML | Data cleaning, validation, matching, file generation |
| [Automated Data Import Monitoring](it-consulting/import_monitoring/README.md) | How can failed or incomplete data imports be detected? | SQL Server, PowerShell | Log analysis, monitoring rules, incident detection |
| [Marketplace Platform Architecture](ecommerce/01-platform_architecture/README.md) | How do operational services exchange data? | System analysis, architecture diagrams | System context, integrations, service boundaries |
| [AI Shopping Assistant — Agents Week](ai-agents/ecommerce-shopping-assistant/README.md) | How can LLM agents support product discovery and personalized recommendations? | Python, Jupyter Notebook, LangChain tool abstractions, JSON | Tool calling, conversational memory, multi-agent orchestration, budget-aware ranking |

## AI Agents & Product Automation

As part of **Agents Week**, I worked on an educational e-commerce prototype exploring three patterns for LLM-powered agents:

- **Tool-calling agent:** searches and filters a predefined product catalog, sorts results, and can add a selected item to a cart.
- **Memory agent:** extracts user preferences, stores a profile in JSON, and reuses conversation history across turns.
- **Multi-agent recommendation system:** coordinates specialized agents to retrieve candidates, analyze pros and cons, rank products, and optionally add a selected product to the cart.

The project focuses on how agent patterns can support a product workflow, how responsibilities can be split between components, and how business constraints such as a maximum budget can be reflected in recommendation logic.

This is an educational prototype, not a production integration: it uses a predefined demo catalog and does not connect to a live retailer, inventory system, or payment provider. LLM-backed examples require valid model credentials. The full notebook should be run in the target environment before treating its behavior as fully validated.

## Skills demonstrated

- **SQL:** joins, CTEs, window functions, aggregations, conditional logic, data-quality checks
- **Python:** pandas-based transformations, validation, automation, exploratory analysis
- **BI:** Apache Superset dashboards, KPI definitions, drill-down reporting
- **Business & product analytics:** business-question framing, metric design, variance analysis, interpretation and recommendations
- **AI agents:** tool calling, conversational memory, multi-agent orchestration, structured tool interfaces, constraint-aware recommendations
- **Systems & operations:** import monitoring, data flows, integration requirements, process automation

## How to review the portfolio

1. Start with the featured case most relevant to the role.
2. Read the business question and data assumptions before reviewing the code.
3. Check the SQL/Python implementation and the validation steps.
4. Review screenshots and findings; illustrative values are clearly labeled as such.
5. For the AI Shopping Assistant, review the notebook and architecture diagram to see how the three agent patterns differ.

## Data, reproducibility and limitations

Public examples use synthetic, anonymized or otherwise non-confidential data. Where source schemas or production data are not included, the code demonstrates the approach rather than running unchanged against a live database. AI-agent examples are educational prototypes and may require model-provider credentials. Each project README describes its prerequisites, assumptions and limitations.

## Contact

- Telegram: @explorrre
- LinkedIn: linkedin.com/in/morican

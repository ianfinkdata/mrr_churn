# MRR Churn
Monthly Recurring Revenue Churn Project


## Project Overview
This project focuses on analyzing subscription-based revenue data to track growth, retention, and churn. The goal was to transform raw transactional data into a dynamic dashboard that provides actionable insights into Monthly Recurring Revenue (MRR) trends and customer lifecycle movements.

## Key Objectives
- **Calculate Core MRR Metrics:** Track New, Expansion, Churn, and Net Revenue Retention.
- **Customer Segmentation:** Categorize customers by subscription tier and tenure.
- **Churn Analysis:** Identify patterns in lost revenue to inform retention strategies.
- **Trend Forecasting:** Visualize revenue growth projections based on historical data.

## Data Architecture & Tooling
- **Data Source:** [e.g., SQL Server, Salesforce Export, CSV]
- **ETL & Cleaning:** [e.g., Power Query / SQL] to handle date alignment and subscription overlaps.
- **Data Modeling:** Star schema design with a centralized Fact Table and optimized Dimension Tables (Date, Customer, Product).
- **Analysis:** [e.g., DAX / Python / SQL] used for time-intelligence calculations
- **Visualization:** [e.g., Power BI / Tableau]

## The "MRR Waterfall" Logic
The dashboard utilizes a waterfall calculation to break down the change in MRR between months:

- New MRR: Revenue from brand-new customers.

- Expansion MRR: Existing customers upgrading their plans.

- Contraction MRR: Existing customers downgrading their plans.

- Churn MRR: Revenue lost from cancelled subscriptions.

- Resurrection MRR: Revenue from former customers returning.

Key Insights
Revenue Concentration: Found that [X]% of revenue is driven by the top [Y]% of customers.

Churn Sensitivity: Identified a correlation between [Metric A] and customer churn within the first 90 days.

Growth Levers: Expansion MRR outperformed New MRR in [Q3], suggesting a strong upsell opportunity within the existing base.

How to Use This Repo
Direct View: Open the [ProjectFileName].pdf or the live link [Insert Link Here] to view the final report.

Technical Review: Check the /Scripts folder for the SQL/DAX logic used to build the measures.

Data Schema: Review /Docs for the data dictionary and relationship diagram.

Tips for making this pop:
Add a GIF or Screenshot: People eat with their eyes first. Put a high-res screenshot of your best dashboard page right under the main title.

The "So What?": In the "Key Insights" section, don't just say what the data is; say what a business should do about it.

DAX/SQL Snippets: If you wrote a particularly "fun" (read: agonizing) piece of code to handle churn logic, include a small code block in the README to show off your technical chops.

Does this structure work for the specific way you've built your project, or are you leaning more toward a heavy SQL/back-end focus?
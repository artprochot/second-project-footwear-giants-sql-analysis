# Footwear Giants & Cultural Catalysts: Financial Impact Analysis (Nike vs. Adidas)

An end-to-end SQL data analytics project analyzing the financial performance of Nike and Adidas (2015–2023), specifically measuring the direct and indirect business impact of major artist partnerships: **Kanye West (Air Yeezy & Yeezy)**, **Travis Scott (Cactus Jack)**, and **Bad Bunny (Forum & Response)**.

---

## 📌 Project Overview & Objectives

* **Domain:** Corporate Finance, Retail Footwear & Streetwear Culture.
* **Core Business Problem:** Assess how dependent athletic footwear giants become on top-tier music collaborators. Did Adidas over-leverage itself on Kanye West compared to Nike’s multi-pronged cultural approach?
* **SQL Focus:** Relational database modeling (DDL), referential integrity constraints, analytical views, window functions (`LAG`, `DENSE_RANK`), Common Table Expressions (CTEs), and complex temporal interval joins.
* **Development & Collaboration:** Developed with interactive AI pair-programming and code review assistance from **Google Gemini Pro**.

---

## 🗄️ Database Architecture & Schema

The relational schema is normalized into 4 core tables:

1. **`brands`**: Corporate profiles and headquarters.
2. **`collaborators`**: Master catalog of musical artists and cultural partners.
3. **`annual_financials`**: Financial performance metrics from 2015 to 2023 (`total_revenue`, `footwear_revenue`, `operating_income`).
4. **`partnerships`**: Bridge table capturing deal timelines, contract boundaries, and estimated peak annual product revenues.

### Entity Relationship Model (ERD)

```text
[collaborators] (1) ───< (N) [partnerships] (N) >─── (1) [brands]
                                                             │ (1)
                                                             │
                                                             ▼ (N)
                                                   [annual_financials]

```

### Relational Integrity Highlights

* **Foreign Keys with `ON DELETE CASCADE**` to maintain referential hygiene.
* **Composite Unique Constraints** (`brand_id`, `fiscal_year`) ensuring reporting integrity.
* **Domain Check Constraints** enforcing non-negative monetary figures (`CHECK (total_revenue >= 0)`) and chronological validity (`CHECK (end_year IS NULL OR end_year >= start_year)`).

---

## 📂 Repository Structure

```bash
├── sql/
│   ├── 01_schema_setup.sql             # DDL statements, tables, keys, and constraints
│   ├── 02_data_seeding_and_cleaning.sql # DML scripts seeding financial and partnership records
│   ├── 03_views_and_marts.sql          # Analytical data marts (vw_partnership_performance)
│   └── 04_advanced_analytics.sql       # Complex window functions, YoY CTEs, and tier rankings
└── README.md                           # Documentation and business findings

```

---

## 🔍 Key Analytical Highlights & SQL Techniques

### 1. Temporal Range Joining in Analytical Marts

Connecting financial reporting years to active partnership timelines requires non-equi joins that handle active (open-ended) contracts:

```sql
CREATE OR REPLACE VIEW vw_partnership_performance AS
SELECT 
    b.name AS brand_name,
    c.name AS artist_name,
    p.sub_brand,
    p.start_year,
    p.end_year,
    p.est_peak_annual_rev,
    ROUND(AVG(af.total_revenue), 2) AS avg_brand_rev_during_deal,
    ROUND((p.est_peak_annual_rev / MAX(af.total_revenue)) * 100, 2) AS peak_revenue_share_pct
FROM partnerships p
JOIN brands b ON p.brand_id = b.id
JOIN collaborators c ON p.collaborator_id = c.id
LEFT JOIN annual_financials af 
    ON af.brand_id = p.brand_id
    AND af.fiscal_year >= p.start_year
    AND (af.fiscal_year <= p.end_year OR p.end_year IS NULL)
GROUP BY 
    b.name, c.name, p.sub_brand, p.start_year, p.end_year, p.est_peak_annual_rev;

```

### 2. Year-over-Year (YoY) Revenue Growth via Window Functions (`LAG`)

Using CTEs and `LAG()` partitioned by brand to track growth inflection points:

```sql
WITH brand_revenue_lagged AS (
    SELECT 
        b.name AS brand_name,
        af.fiscal_year,
        af.total_revenue,
        LAG(af.total_revenue) OVER (PARTITION BY af.brand_id ORDER BY af.fiscal_year) AS prev_year_revenue
    FROM annual_financials af
    JOIN brands b ON af.brand_id = b.id
)
SELECT 
    brand_name,
    fiscal_year,
    total_revenue,
    prev_year_revenue,
    ROUND(((total_revenue - prev_year_revenue) / prev_year_revenue) * 100, 2) AS yoy_revenue_growth_pct
FROM brand_revenue_lagged
ORDER BY brand_name ASC, fiscal_year ASC;

```

### 3. Business Tier Classification & Dense Ranking

Segmenting partnerships based on direct scale using `DENSE_RANK()` and `CASE`:

```sql
SELECT 
    artist_name,
    brand_name,
    sub_brand,
    est_peak_annual_rev,
    peak_revenue_share_pct,
    DENSE_RANK() OVER (ORDER BY est_peak_annual_rev DESC) AS revenue_rank,
    CASE 
        WHEN est_peak_annual_rev >= 1.0 THEN 'Mega-Franchise'
        WHEN est_peak_annual_rev >= 0.3 THEN 'Core Cultural Driver'
        ELSE 'Niche / Limited Capsule'
    END AS partnership_tier
FROM vw_partnership_performance
ORDER BY revenue_rank;

```

---

## 📊 Summary of Findings & Business Insights

| Artist | Brand | Line / Sub-brand | Peak Annual Rev (Est.) | Brand Share at Peak | Partnership Tier |
| --- | --- | --- | --- | --- | --- |
| **Kanye West** | Adidas | Yeezy | **$1.70B** | **6.42%** | Mega-Franchise |
| **Travis Scott** | Nike | Cactus Jack | **$0.40B** | **0.78%** | Core Cultural Driver |
| **Bad Bunny** | Adidas | Bad Bunny Forum | **$0.15B** | **0.60%** | Niche / Limited Capsule |
| **Kanye West** | Nike | Air Yeezy | **$0.05B** | **0.16%** | Niche / Limited Capsule |

### Core Takeaways:

1. **The "Single Point of Failure" Risk (Adidas & Yeezy):**
Yeezy generated over **6.4% of total group turnover** and an estimated 15%+ of operating profits for Adidas. This severe over-reliance triggered an immediate revenue decline in 2023 ($23.20B vs $24.10B in 2022) and cratered operating income ($0.29B in 2023 vs $2.35B in 2021) once the partnership was severed.
2. **Nike’s "Halo Effect" Playbook (Travis Scott):**
Despite dominating cultural mindshare and secondary markets, Travis Scott’s Cactus Jack line accounts for less than **1% of Nike's total revenue**. Nike deliberately uses cultural partnerships to elevate core inline franchises (Dunk, Air Jordan 1, Air Force 1) rather than letting an external partner become an operational pillar.
3. **Capsule Limits (Bad Bunny):**
Bad Bunny provided crucial momentum during a turbulent period for Adidas, but niche capsule launches ($150M) cannot realistically replace the multi-billion-dollar scale left vacant by Yeezy.

---

## 🤖 Methodology & Acknowledgments

This project was built following a hands-on "learning-by-doing" approach. Database modeling, analytical schema validation, and SQL optimization were developed in collaboration with **Google Gemini Pro**, serving as an AI technical advisor for query review, schema constraint debugging, and documentation synthesis.

---

## 🛠️ How to Run Locally

1. Clone this repository:
```bash
git clone [https://github.com/your-username/footwear-giants-sql-analysis.git](https://github.com/your-username/footwear-giants-sql-analysis.git)
cd footwear-giants-sql-analysis

```


2. Open your preferred SQL client (MySQL Workbench, DBeaver, or CLI).
3. Execute scripts in chronological order:
* Run `sql/01_schema_setup.sql`
* Run `sql/02_data_seeding_and_cleaning.sql`
* Run `sql/03_views_and_marts.sql`
* Run `sql/04_advanced_analytics.sql`



```

```

# RetailPulse Analytics — dbt + Snowflake

End-to-end e-commerce analytics pipeline built with dbt Core and Snowflake.

## Context

RetailPulse is a multi-country e-commerce platform operating across West Africa.
This project models sales, customer, product, marketing campaign, and web session
data to deliver reliable business metrics.

## Tech Stack

| Tool | Usage |
|---|---|
| Snowflake | Cloud Data Warehouse |
| dbt Core | Data transformation and modeling |
| Python | Data generation and loading |
| GitHub Actions | Automated CI/CD |

## Architecture

```
RAW (sources)
    └── 7 raw tables (33,000+ rows)

STAGING (cleaning)
    └── stg_customers, stg_orders, stg_order_items
    └── stg_products, stg_campaigns, stg_sessions, stg_refunds

INTERMEDIATE (enrichment)
    └── int_orders_enriched, int_customer_orders
    └── int_product_performance, int_campaign_attribution
    └── int_sessions_enriched

MARTS (analytics)
    └── fct_orders (incremental), fct_sessions
    └── dim_customers, dim_products, dim_campaigns
    └── mart_executive_summary
```

## Business Metrics

- Monthly and annual revenue
- Average basket size by customer segment
- Cancellation and refund rates
- Product performance (margin, volume, revenue)
- Campaign attribution (cost per order, conversion rate)
- RFM segmentation: prospect / new / regular / vip / churned

## Data Quality

- 40+ dbt tests (unique, not_null, accepted_values, relationships)
- 3 custom SQL tests
- SCD Type 2 snapshot on order status
- GitHub Actions CI/CD on every PR

## Getting Started

```bash
# Install dependencies
pip install dbt-core dbt-snowflake

# Configure profiles.yml with your Snowflake credentials
# See profiles.yml.example

# Run the full pipeline
dbt deps
dbt build

# Generate documentation
dbt docs generate && dbt docs serve
```

## Project Structure

```
retailpulse_analytics/
├── models/
│   ├── staging/        # source cleaning
│   ├── intermediate/   # enrichment and joins
│   └── marts/          # final analytics tables
├── snapshots/          # SCD Type 2
├── tests/              # custom SQL tests
├── macros/             # reusable Jinja functions
├── .github/workflows/  # GitHub Actions CI/CD
└── generate_data.py    # data generation script
```
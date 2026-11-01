# SaaS Revenue Analytics Engineering

An end-to-end SaaS analytics project built using **Snowflake, dbt Core, SQL, and Power BI** to model recurring revenue, analyze customer retention, and deliver business-ready KPIs.

## Business Objective

SaaS companies need reliable metrics to understand revenue growth and customer retention.

This project creates a centralized analytics layer to answer questions such as:

- How much Monthly Recurring Revenue (MRR) does the business generate?
- How much revenue comes from new, reactivated, and expanding customers?
- How much revenue is lost through contraction and churn?
- What are the customer churn rate and Net Revenue Retention (NRR)?
- How does recurring revenue change over time?

## Technology Stack

| Technology | Purpose |
|---|---|
| Snowflake | Cloud data warehouse |
| dbt Core | SQL transformation, testing, and documentation |
| SQL | Data modeling and SaaS metric calculations |
| Power BI | KPI reporting and visualization |
| Git & GitHub | Version control and collaboration |

## Data Architecture

The pipeline follows a layered analytics architecture:

**Parquet source files → Snowflake RAW → dbt Staging → dbt Intermediate → dbt Marts → Reporting → Power BI**

### Raw Layer

Six SaaS source datasets are loaded into Snowflake: organizations, plans, users, subscriptions, invoices, and usage events.

### Staging Layer

Standardizes source fields, data types, and naming conventions for organizations, plans, and subscriptions.

### Intermediate Layer

Calculates subscription MRR, generates monthly subscription and customer snapshots, and classifies customer revenue movements.

### Mart Layer

Produces customer-level monthly revenue facts and company-level SaaS KPIs.

### Reporting Layer

Exposes completed-month SaaS KPIs for Power BI reporting.

## Key SaaS Metrics

| Metric | Definition |
|---|---|
| MRR | Sum of recurring monthly-equivalent subscription revenue |
| New MRR | Revenue from first-time paying customers |
| Reactivation MRR | Revenue from previously paying customers returning |
| Expansion MRR | Additional revenue from existing paying customers |
| Contraction MRR | Revenue lost when paying customers downgrade |
| Churned MRR | Revenue lost when paying customers become non-paying |
| Customer Churn Rate | Churned customers / starting paying customers × 100 |
| NRR | (Starting MRR + Expansion − Contraction − Churned MRR) / Starting MRR × 100 |

## Data Quality and Validation

The project includes dbt tests for:

- Unique customer-month combinations
- Monthly subscription-to-customer MRR reconciliation
- Monthly revenue movement reconciliation
- Model-level key and null constraints

Subscription pricing was also checked against 46,000 invoice records, including monthly and annual billing.

## Power BI Dashboard

The dashboard currently includes:

- Total Monthly Recurring Revenue
- Customer Churn Rate
- Net Revenue Retention
- Monthly MRR trend

Additional revenue movement and retention visualizations are planned.

## Modeling Assumptions and Limitations

- Annual subscription prices are treated as monthly-equivalent amounts, supported by invoice reconciliation.
- Subscription MRR is calculated from plan base price and billable seat count.
- Customer activity is evaluated at month-end.
- Subscriptions without recorded end dates remain active in subsequent monthly snapshots.
- The dataset is synthetic. Later reporting months may contain no new source activity, so flat MRR and retention trends should not automatically be interpreted as real business stability.
- The project currently uses a manual CSV export to Power BI rather than a scheduled live connection.

## Future Improvements

- Automated dbt CI checks with GitHub Actions
- Scheduled data transformations
- Additional Power BI revenue movement visualizations
- Enhanced source freshness monitoring
- Deployment documentation

## Project Status

Core Snowflake ingestion, dbt transformations, SaaS KPI calculations, reconciliation tests, and initial Power BI reporting are complete. Production automation and further dashboard development are in progress.


## Development Workflow

This project follows a Git-based development workflow.

1. Create a feature branch from `main`.
2. Make changes to dbt models, tests, or documentation.
3. Commit and push changes to GitHub.
4. Open a Pull Request targeting `main`.
5. GitHub Actions automatically runs `dbt parse`.
6. Review the CI results before merging.

### Continuous Integration

GitHub Actions validates the dbt project structure
on pull requests to the main branch.

Current CI checks:
- Install Python and dbt-snowflake
- Load the dbt project configuration
- Run `dbt parse`

Future improvement:
- Execute dbt models and tests against an isolated
  Snowflake CI environment.


## CI/CD Pipeline

This project implements a CI/CD workflow using GitHub Actions, dbt Core, and Snowflake to validate analytics transformations and automate data quality testing.

### CI/CD Architecture

GitHub Repository
       |
       v
Pull Request
       |
       v
GitHub Actions — dbt parse
       |
       v
Schema Isolation Validation
       |
       v
Merge to Main
       |
       v
Manual Snowflake Integration Workflow
       |
       v
Snowflake Authentication (RSA Key Pair)
       |
       v
Snowflake CI Schema
       |
       v
dbt build (Models + Tests)
       |
       v
Pipeline Success / Failure

### Key Features

- **Automated validation:** GitHub Actions validates the dbt project when a Pull Request is created.
- **Isolated CI environment:** dbt models are built in `SAAS_ANALYTICS.CI`, separate from the development `STAGING` schema.
- **Secure authentication:** GitHub Actions authenticates to Snowflake using RSA key-pair authentication and encrypted GitHub Secrets.
- **Role-based access control:** A dedicated `SAAS_DBT_CI_ROLE` restricts CI permissions.
- **Automated data quality testing:** `dbt build` executes models and associated dbt tests.
- **Schema safety checks:** The workflow validates model destination schemas before execution.
- **Manual deployment control:** Snowflake integration runs through `workflow_dispatch`, preventing automatic database execution on every Pull Request.

### Validation Results

- GitHub Actions Snowflake authentication: Passed
- CI schema isolation check: Passed
- dbt build and data quality tests: Passed
- Snowflake CI schema: 10 dbt views created

### Technologies

Snowflake | dbt Core | SQL | GitHub Actions | Git | Python | RSA Key-Pair Authentication

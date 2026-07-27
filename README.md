# SQL Data Warehouse Project

End-to-end SQL Data Warehouse project built with PostgreSQL. The project follows the Medallion Architecture pattern with Bronze, Silver, and Gold layers for raw ingestion, cleaning/transformation, and analytics-ready data.

## Project Overview

This repository contains SQL scripts and sample source data for building a data warehouse from CRM and ERP CSV files.

Current implementation includes:

- PostgreSQL database and schema initialization
- Bronze layer table creation
- Bronze layer CSV loading procedure
- Source datasets for CRM and ERP systems

## Architecture

The warehouse is organized into three layers:

- Bronze: Raw data loaded from source systems with minimal changes.
- Silver: Cleaned, validated, and standardized data.
- Gold: Business-ready models for reporting and analytics.

At the moment, the repository contains the Bronze layer implementation.

## Folder Structure

```text
.
├── datasets
│   ├── source_crm
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
├── scripts
│   ├── init_database.sql
│   └── bronze
│       ├── init_tables.sql
│       └── load_tables.sql
├── LICENSE
└── README.md
```

## Prerequisites

- PostgreSQL installed and running
- A SQL client such as pgAdmin, VS Code PostgreSQL extension, DBeaver, or `psql`
- Permission to create databases, schemas, tables, and procedures
- Permission for PostgreSQL to read CSV files when using server-side `COPY`

## Setup Instructions

### 1. Create the Database

Connect to the default `postgres` database first, then run:

```sql
DROP DATABASE IF EXISTS datawarehouse;
CREATE DATABASE datawarehouse;
```

PostgreSQL does not support:

```sql
USE datawarehouse;
```

After creating the database, manually switch your SQL client connection to `datawarehouse`.

If you use `psql`, you can switch with:

```sql
\c datawarehouse
```

### 2. Create Schemas

After connecting to `datawarehouse`, run:

```sql
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
```

You can also use:

```text
scripts/init_database.sql
```

Important: run the schema statements while connected to `datawarehouse`, not `postgres`.

### 3. Create Bronze Tables

Run:

```text
scripts/bronze/init_tables.sql
```

This creates the following Bronze tables:

- `bronze.crm_cust_info`
- `bronze.crm_prd_info`
- `bronze.crm_sales_details`
- `bronze.erp_loc_a101`
- `bronze.erp_cust_az12`
- `bronze.erp_px_cat_g1v2`

### 4. Update CSV File Paths

Before loading data, open:

```text
scripts/bronze/load_tables.sql
```

Replace every placeholder:

```text
<path_to_project>
```

with the absolute path to this project on your machine.

Example:

```sql
FROM '<path_to_project>/datasets/source_crm/cust_info.csv'
```

should become something like:

```sql
FROM '/path/to/sql-data-warehouse-project-1/datasets/source_crm/cust_info.csv'
```

Do not commit personal machine paths if you are sharing this repository publicly.

### 5. Load Bronze Data

Run:

```text
scripts/bronze/load_tables.sql
```

This creates and executes:

```sql
CALL bronze.load_bronze();
```

The procedure:

- Truncates each Bronze table
- Loads data from CSV files using PostgreSQL `COPY`
- Prints progress using `RAISE NOTICE`
- Shows load duration per table
- Shows error details if loading fails

## Validate the Load

After loading data, run:

```sql
SELECT COUNT(*) FROM bronze.crm_cust_info;
SELECT COUNT(*) FROM bronze.crm_prd_info;
SELECT COUNT(*) FROM bronze.crm_sales_details;
SELECT COUNT(*) FROM bronze.erp_loc_a101;
SELECT COUNT(*) FROM bronze.erp_cust_az12;
SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;
```

You can also preview data:

```sql
SELECT * FROM bronze.crm_cust_info LIMIT 10;
```

## Common PostgreSQL Issues

### Database Is Being Accessed by Other Users

If you see:

```text
database "datawarehouse" is being accessed by other users
```

check active sessions:

```sql
SELECT
    pid,
    usename,
    application_name,
    client_addr,
    datname,
    state,
    query_start,
    query
FROM pg_stat_activity
WHERE datname = 'datawarehouse';
```

Terminate sessions:

```sql
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'datawarehouse'
  AND pid <> pg_backend_pid();
```

Run this while connected to another database, usually `postgres`.

### Schemas Created in `postgres` Instead of `datawarehouse`

This happens when your SQL client is still connected to `postgres`.

Fix:

1. Create `datawarehouse` while connected to `postgres`.
2. Switch your connection to `datawarehouse`.
3. Run the schema and table scripts.

### COPY Cannot Read the CSV File

PostgreSQL server-side `COPY` reads files from the database server machine, not always from your SQL client machine.

Common errors include:

```text
could not open file
```

or:

```text
must be superuser or have privileges of pg_read_server_files
```

Possible fixes:

- Use the correct absolute path visible to the PostgreSQL server.
- If PostgreSQL runs in Docker, mount the project folder into the container.
- Ask a superuser to grant file-read permission:

```sql
GRANT pg_read_server_files TO your_username;
```

Check your current user:

```sql
SELECT current_user;
```

## Notes

- PostgreSQL uses `COPY`, not SQL Server `BULK INSERT`.
- PostgreSQL uses `RAISE NOTICE`, not SQL Server `PRINT`.
- PostgreSQL procedures are executed with `CALL procedure_name();`.
- PostgreSQL does not have a `USE database_name;` command.

## License

This project is licensed under the terms included in the `LICENSE` file.

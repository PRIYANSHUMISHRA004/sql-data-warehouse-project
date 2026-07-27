/*
===============================================================================
Create Database and Schemas (PostgreSQL)
===============================================================================

Project:
    SQL Data Warehouse Project

Purpose:
    This script initializes the Data Warehouse environment by:
        1. Creating the 'datawarehouse' database.
        2. Creating the Bronze, Silver, and Gold schemas.

Schema Overview:
    • Bronze → Stores raw data exactly as received from source systems.
    • Silver → Stores cleaned, validated, and transformed data.
    • Gold   → Stores business-ready data for reporting and analytics.
===============================================================================
*/




DROP DATABASE IF EXISTS datawarehouse;

CREATE DATABASE datawarehouse;

--connect to database datawarehouse then run  

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;


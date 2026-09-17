# Automated Data Import & Monitoring

**Business / System Analysis · SQL · PowerShell · Automation**

**Product:** Financial management software\
**Domain:** Financial data integration and automation\
**Role:** Business / System Analyst

> **Note:** This portfolio case is a sanitized reconstruction based on a
> production workflow. Names, credentials, infrastructure details and
> internal identifiers have been removed or replaced.

## Overview

Designed and automated a data import workflow with monitoring for failed
and incomplete imports.

The solution combined **PowerShell automation, SQL Server, application
logs and configurable monitoring rules** to reduce manual control and
make integration issues easier to detect and investigate.

## Business Problem

The system regularly imported financial data from external sources.

The process required reliable execution and timely detection of
problems. Two important failure scenarios had to be covered:

-   an explicit import error;
-   an import for which a successful completion message was not
    recorded.

The monitoring logic therefore checked both error events and expected
completion events.

## Solution

``` text
Data Source
    ↓
Automated Import
    ↓
Application / Database
    ↓
Application Logs
    ↓
SQL Monitoring
    ↓
Incident Detection
    ↓
Responsible User / Further Handling
```

## 1. Automated Data Import

A PowerShell script automated the import launch.

### Key logic

1.  Connect to SQL Server.
2.  Retrieve the current closed-period date.
3.  Calculate the next import start date.
4.  Pass the calculated period and required parameters to the
    application.
5.  Start the import process and wait for completion.

### Business rule

``` text
Import Start Date = Closed Period Date + 1 day
```

This allowed the import period to be determined dynamically instead of
being entered manually.

See: `powershell/automated_import_demo.ps1`

## 2. Import Monitoring

A SQL-based monitoring mechanism analyzed application logs and
identified:

### Explicit errors

``` text
Import
  ↓
Error in log
  ↓
Incident
```

### Missing completion

``` text
Import
  ↓
No error
  ↓
No successful completion event
  ↓
Incident
```

The monitoring covered different import types and normalized their
results into a common incident output.

See: `sql/import_monitoring_demo.sql`

## 3. Configurable Monitoring

Monitoring parameters were stored as configuration data rather than
being hard-coded into the monitoring logic.

For each import, the configuration could define:

-   responsible person;
-   monitoring period.

Example:

``` text
Import A → 1 day
Import B → 7 days
Import C → 30 days
```

## 4. Structured Incident Output

The monitoring result contains information such as:

-   import/module;
-   event time;
-   error or diagnostic message;
-   session information;
-   responsible person;
-   monitoring period;
-   incident type.

This makes the result suitable for further investigation and
notification workflows.

## 5. Email Notification Automation

A related SQL automation generated an HTML table from query results and
sent it to the responsible user by email.

The notification pattern can be used for operational processes where
users need a structured list of records requiring action.

See: `sql/email_notification_demo.sql`

## My Contribution

### Business Analysis

-   analyzed the existing import process and business rules;
-   identified failure and monitoring scenarios;
-   defined configurable monitoring parameters;
-   translated business requirements into technical logic.

### System / Data Analysis

-   worked with SQL Server and application logs;
-   analyzed database structures and relationships;
-   designed data extraction and monitoring logic;
-   worked with integration parameters and application configuration.

### Automation

-   PowerShell;
-   SQL Server;
-   application log monitoring;
-   dynamic date calculation;
-   incident detection;
-   HTML email reporting.

## Technologies

**SQL:** MS SQL Server, CTE, JOIN, OUTER APPLY, subqueries\
**Automation:** PowerShell\
**Database:** SQL Server\
**Integration:** application/database integration\
**Reporting:** HTML email notifications

## Key Takeaway

This project demonstrates the ability to work across the full path from
**business problem to technical implementation**:

**Business Problem → Process Analysis → Requirements → Data Logic →
Automation → Monitoring → Operational Handling**

It combines business analysis, system analysis, SQL, automation and
integration work in one end-to-end case.

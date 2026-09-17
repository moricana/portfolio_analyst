# Architecture Notes

## Key analytical questions

1. What business capability belongs to each service?
2. Which actors use which interfaces?
3. Where does data enter and leave the platform?
4. Which integrations are internal vs external?
5. Which workloads are transactional vs analytical?

## Simplified dependency model

```text
Users / Channels
      ↓
 API Gateways
      ↓
Core Services
      ↓
Transactional DB
      ↓
   OLAP
      ↓
    BI
```

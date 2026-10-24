# Nexora Systems — Operational Troubleshooting Matrix

| Symptom | Probable Cause | Action |
|:---|:---|:---|
| IIS HTTP 500.19 | ASP.NET Core Hosting Bundle unmapped | Reinstall Hosting Bundle; run iisreset |
| IIS HTTP 503 | AppPool stopped due to runtime crash | Check Windows Event Viewer |
| PostgreSQL Seed Fail | Column missing | Run migrations 000 through 004 |

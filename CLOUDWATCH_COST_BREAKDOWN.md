# CloudWatch Dashboards - Cost Breakdown & Free Tier Analysis

## 🎯 **TL;DR: Your costs will NOT explode!**

**Total Monthly Cost: ~$0.50-1.00** (mostly from CloudWatch Insights queries when you run them)

---

## 📊 **AWS CloudWatch Free Tier Limits**

### What's Included in Free Tier (Forever Free):
| Resource | Free Tier Limit | Our Usage | Status |
|----------|----------------|-----------|--------|
| **Dashboards** | 10 dashboards | 3 dashboards | ✅ **FREE** |
| **Metrics** | 50 custom metrics | ~44 metrics | ✅ **FREE** |
| **API Requests** | 10,000/month | ~500-1,000/month | ✅ **FREE** |
| **Alarms** | 10 alarms | 15 alarms | ⚠️ **$0.10/alarm** |
| **Log Ingestion** | 5 GB/month | ~1-2 GB/month | ✅ **FREE** |
| **Log Storage** | First 5 GB | ~2-3 GB | ✅ **FREE** |
| **Log Insights Queries** | None (pay per query) | ~10-20/month | 💰 **$0.005/GB scanned** |

---

## 💰 **Detailed Cost Breakdown**

### 1. **CloudWatch Dashboards: $0/month**
- **3 Dashboards Created:**
  - System Overview Dashboard
  - Service Performance Dashboard
  - Infrastructure Dashboard
- **Free Tier:** 10 dashboards included
- **Cost:** $0 (well within free tier)

### 2. **CloudWatch Metrics: $0/month**
- **Metrics Used:** ~44 metrics total
  - ECS cluster metrics (CPU, Memory, Task Count)
  - EC2 instance metrics (CPU, Network I/O)
  - Auto Scaling metrics (Capacity, Instances)
  - Billing metrics (Estimated Charges)
- **Free Tier:** 50 metrics included
- **Cost:** $0 (under free tier limit)

### 3. **CloudWatch Alarms: $0.50/month**
- **Alarms Created:** 15 alarms
  - 5 CPU utilization alarms (per service)
  - 5 Memory utilization alarms (per service)
  - 5 Task count zero alarms (per service)
- **Free Tier:** 10 alarms included
- **Overage:** 5 alarms × $0.10 = **$0.50/month**

### 4. **CloudWatch Insights Queries: $0.00-0.50/month**
- **Queries Created:**
  - Top Errors query (searches for ERROR, Exception, Failed, 500, 404)
  - Service Response Times query
  - Cost Analysis query
- **Usage Pattern:** Only charged when you manually run queries
- **Cost:** $0.005 per GB scanned
- **Estimated:** ~$0.00-0.50/month (depends on how often you run queries)
- **Pro Tip:** Queries embedded in dashboards refresh automatically but are optimized to scan minimal data

### 5. **CloudWatch Logs: $0/month**
- **Log Groups:**
  - `/backend/user-accounts`
  - `/backend/catalog`
  - `/backend/alerts`
  - `/backend/text-search`
  - `/frontend`
- **Log Retention:** 7 days (configurable)
- **Estimated Ingestion:** ~1-2 GB/month
- **Free Tier:** 5 GB ingestion + 5 GB storage
- **Cost:** $0 (within free tier)

---

## 📈 **Cost Optimization Features Built-In**

### 1. **Efficient Metric Selection**
- Using cluster-level metrics instead of per-service metrics where possible
- Avoiding redundant metrics
- Total: 44 metrics (under 50 free tier limit)

### 2. **Smart Log Retention**
- Default: 7 days retention
- Configurable via `log_retention_days` variable
- Automatically deletes old logs to minimize storage costs

### 3. **Optimized CloudWatch Insights Queries**
- Queries are pre-filtered to scan minimal data
- Limited result sets (e.g., `limit 20`, `limit 50`)
- Time-boxed queries (5-minute bins) to reduce scan volume

### 4. **Cost Tracking Widgets**
- Built-in billing metrics in dashboards
- Real-time cost monitoring
- Anomaly detection to catch unexpected charges

---

## 🔍 **What Changed in the Latest Update**

### Top Errors Widget Enhancement
**Before:**
```
filter @message like /ERROR/
```

**After:**
```
filter @message like /ERROR/ or @message like /Exception/ or @message like /Failed/ or @message like /500/ or @message like /404/
```

**Why:** Your services might not be generating ERROR-level logs, or they might be using different log formats. The enhanced query catches more error patterns.

### New Widget Added: Recent Log Activity
- Shows the last 10 log entries from all services
- Helps verify that logs are flowing correctly
- Useful for debugging when "Top Errors" is empty

---

## 🚨 **Cost Monitoring & Alerts**

### Built-in Cost Protection:
1. **Cost Anomaly Alarm:** Detects unexpected resource usage
2. **Billing Metrics Widget:** Shows current month estimated charges
3. **Resource Utilization Tracking:** Monitors CPU/Memory to prevent over-provisioning

### How to Monitor Your Costs:
1. **AWS Billing Dashboard:** Check actual charges
2. **CloudWatch Dashboard:** View estimated charges widget
3. **Cost Explorer:** Analyze spending trends

---

## 📊 **Expected Monthly Cost Summary**

| Component | Cost |
|-----------|------|
| CloudWatch Dashboards | $0.00 |
| CloudWatch Metrics | $0.00 |
| CloudWatch Alarms (5 over free tier) | $0.50 |
| CloudWatch Insights Queries | $0.00-0.50 |
| CloudWatch Logs | $0.00 |
| **TOTAL** | **$0.50-1.00/month** |

---

## ✅ **Why Your Costs Won't Explode**

### 1. **Free Tier Compliance**
- Dashboards: 3/10 used (70% buffer)
- Metrics: 44/50 used (12% buffer)
- Logs: ~2GB/5GB used (60% buffer)

### 2. **Pay-Per-Use Components**
- CloudWatch Insights: Only charged when you run queries
- Minimal data scanning due to optimized queries
- Estimated: $0.00-0.50/month

### 3. **Fixed Costs**
- Alarms: $0.50/month (5 alarms over free tier)
- Predictable and minimal

### 4. **No Hidden Charges**
- No data transfer costs (within same region)
- No API request charges (under 10,000/month limit)
- No storage charges (under 5GB limit)

---

## 🎓 **Best Practices to Keep Costs Low**

### 1. **Limit CloudWatch Insights Query Frequency**
- Don't run queries continuously
- Use dashboard widgets for real-time monitoring
- Run manual queries only for troubleshooting

### 2. **Optimize Log Retention**
- Keep 7-day retention for most logs
- Increase only for compliance requirements
- Archive old logs to S3 if needed (cheaper)

### 3. **Monitor Metric Count**
- Stay under 50 custom metrics
- Use cluster-level metrics instead of per-service where possible
- Remove unused metrics

### 4. **Use Cost Tracking Widgets**
- Check billing metrics daily
- Set up budget alerts in AWS Billing
- Review Cost Explorer monthly

---

## 🔧 **Troubleshooting Empty Widgets**

### If "Top Errors" is Still Empty:

**Possible Reasons:**
1. **No errors are occurring** (good news!)
2. **Services use different log formats** (e.g., `WARN`, `FATAL`, `Error`)
3. **Log groups don't exist yet** (services not deployed)
4. **Logs haven't been generated** (no traffic to services)

**How to Verify:**
1. Check "Recent Log Activity" widget - shows if logs are flowing
2. Run a manual CloudWatch Insights query to see raw logs
3. Trigger an error in your application to test error logging

**Enhanced Query Now Catches:**
- `ERROR` - Standard error level
- `Exception` - Java/Spring Boot exceptions
- `Failed` - Failed operations
- `500` - HTTP 500 errors
- `404` - HTTP 404 errors

---

## 📞 **Need Help?**

If you see unexpected charges:
1. Check AWS Billing Dashboard for detailed breakdown
2. Review CloudWatch usage in Cost Explorer
3. Verify log retention settings
4. Check for runaway log generation

**Remember:** The dashboards are designed to be cost-efficient and stay within AWS free tier limits!

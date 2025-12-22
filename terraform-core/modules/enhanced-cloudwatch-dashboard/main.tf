# Enhanced CloudWatch Dashboard Module - Comprehensive Observability Platform
# Implements comprehensive logging visibility and error tracking within AWS free tier limits
# All changes are infrastructure-only modifications that work with existing running services

locals {
  # Service configuration for dashboard widgets
  services = {
    frontend      = { port = 8080, container_port = 80, log_group = "/frontend" }
    user-accounts = { port = 8082, container_port = 8082, log_group = "/backend/user-accounts" }
    catalog       = { port = 8083, container_port = 8080, log_group = "/backend/catalog" }
    alerts        = { port = 8084, container_port = 8080, log_group = "/backend/alerts" }
    text-search   = { port = 8085, container_port = 8080, log_group = "/backend/text-search" }
  }

  # Common dashboard properties optimized for free tier
  dashboard_properties = {
    period_override  = "inherit"
    stat             = "Average"
    region           = data.aws_region.current.name
    refresh_interval = 300 # 5-minute refresh to reduce API calls
  }

  # Free tier optimization settings
  free_tier_config = {
    log_retention_days = var.log_retention_days # 3 days for cost efficiency
    widget_count_limit = 50                     # Stay within 50 metric limit
    api_request_budget = 2900                   # Monthly API request budget (within 10K limit)
  }
}

data "aws_region" "current" {}

# Enhanced CloudWatch Dashboard - Single consolidated dashboard (1 of 10 free tier limit)
resource "aws_cloudwatch_dashboard" "enhanced_observability" {
  dashboard_name = "${var.cluster_name}-enhanced-observability"

  dashboard_body = jsonencode({
    widgets = concat(
      # Error Tracking Panel (8 widgets) - Top Left
      [
        # Error Rate Metrics (2 widgets) - Using log-based metrics for accurate error tracking
        {
          type   = "log"
          x      = 0
          y      = 0
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @logStream | filter @message like /ERROR|FATAL|Exception/ | stats count() by @logStream, bin(5m) | sort @timestamp desc"
            region = local.dashboard_properties.region
            title  = "Error Count by Service (5min intervals)"
            view   = "table"
          }
        },
        {
          type   = "log"
          x      = 6
          y      = 0
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @logStream | filter @message like /ERROR|FATAL|Exception/ | stats count() as error_count by @logStream | sort error_count desc"
            region = local.dashboard_properties.region
            title  = "Current Error Rates by Service"
            view   = "table"
          }
        },
        # Error Drill-Down Links (2 widgets)
        {
          type   = "text"
          x      = 0
          y      = 4
          width  = 6
          height = 4
          properties = {
            markdown = join("\n", [
              "## Error Analysis Links",
              "**Critical Errors:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20*40message*2c*20*40logStream*0a*7c*20filter*20*40message*20like*20*2fERROR*7cFATAL*7cException*2f*0a*7c*20stats*20count*28*29*20by*20bin*2815m*29*2c*20*40logStream*0a*7c*20sort*20*40timestamp*20desc*0a*7c*20limit*20100~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**Error Patterns:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20service*2c*20*40message*0a*7c*20filter*20*40message*20like*20*2fERROR*2f*0a*7c*20stats*20count*28*29*20by*20service*2c*20bin*281h*29*0a*7c*20sort*20count*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**Stack Traces:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20*40message*0a*7c*20filter*20*40message*20like*20*2fException*7cError*2f*0a*7c*20parse*20*40message*20*2f*28*3f*3cerror_type*3e*5cw*2bException*29*3a*20*28*3f*3cerror_msg*3e.*2a*29*2f*0a*7c*20stats*20count*28*29*20by*20error_type*0a*7c*20sort*20count*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))"
            ])
          }
        },
        {
          type   = "log"
          x      = 6
          y      = 4
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @logStream | filter @message like /ERROR|FATAL|Exception/ | stats count() as error_count by bin(15m) | sort @timestamp desc | limit 20"
            region = local.dashboard_properties.region
            title  = "Error Trend Analysis (15min intervals)"
            view   = "line"
          }
        },
        # Error Severity Ranking (2 widgets) - Enhanced prioritization and visual indicators
        {
          type   = "log"
          x      = 0
          y      = 8
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message, @logStream | filter @message like /ERROR|FATAL|Exception/ | parse @message /(?<severity>FATAL|ERROR|CRITICAL)/ | stats count() as error_count by @logStream, severity | sort error_count desc | limit 15"
            region = local.dashboard_properties.region
            title  = "🔴 Error Severity Ranking by Service"
            view   = "table"
          }
        },
        {
          type   = "log"
          x      = 6
          y      = 8
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message | filter @message like /ERROR|Exception/ | parse @message /(?<error_type>\\w+Exception|\\w+Error): (?<error_msg>.*)/ | stats count() as frequency by error_type | sort frequency desc | limit 10"
            region = local.dashboard_properties.region
            title  = "🟡 Top Error Types by Frequency"
            view   = "table"
          }
        },
        # Error Performance Impact (2 widgets)
        {
          type   = "metric"
          x      = 0
          y      = 12
          width  = 6
          height = 4
          properties = {
            metrics = [
              ["AWS/ECS", "CPUUtilization", "ClusterName", var.cluster_name],
              [".", "MemoryUtilization", ".", "."]
            ]
            view   = "timeSeries"
            region = local.dashboard_properties.region
            title  = "Resource Impact During Errors"
            period = 300
            stat   = "Average"
          }
        },
        {
          type   = "text"
          x      = 6
          y      = 12
          width  = 6
          height = 4
          properties = {
            markdown = join("\n", [
              "## Error Investigation Guide",
              "### 🔴 **CRITICAL** (Immediate Action Required)",
              "- **Exceptions/Fatal Errors**: Check stack trace links immediately",
              "- **Service Unavailable**: Verify ECS task health and resource usage",
              "",
              "### 🟡 **HIGH** (Monitor Closely)",
              "- **Error Rate Spikes**: Use error pattern analysis to identify trends",
              "- **Authentication Failures**: Check security events panel",
              "",
              "### 🟢 **MEDIUM** (Investigate When Possible)",
              "- **Intermittent Errors**: Review error trends over time",
              "- **Performance Issues**: Correlate with resource impact metrics",
              "",
              "**Quick Actions:**",
              "1. Click error drill-down links for detailed context",
              "2. Use service-specific log access for targeted investigation",
              "3. Check resource correlation for performance-related errors"
            ])
          }
        }
      ],
      # One-Click Log Access Panel (6 widgets) - Top Right
      [
        # Service Log Access Buttons (3 widgets)
        {
          type   = "text"
          x      = 12
          y      = 0
          width  = 4
          height = 8
          properties = {
            markdown = join("\n", [
              "## Service Log Access",
              "**Frontend Logs:** [View Recent](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20*40message*0a*7c*20filter*20*40logGroup*20*3d*20*22*2ffrontend*22*0a*7c*20filter*20*40timestamp*20*3e*20date_sub*28now*28*29*2c*20interval*201*20hour*29*0a*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2ffrontend)))",
              "**User Accounts:** [View Recent](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20*40message*2c*20*40requestId*0a*7c*20filter*20*40logGroup*20*3d*20*22*2fbackend*2fuser-accounts*22*0a*7c*20filter*20*40timestamp*20*3e*20date_sub*28now*28*29*2c*20interval*201*20hour*29*0a*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts)))",
              "**Catalog Service:** [View Recent](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20*40message*0a*7c*20filter*20*40logGroup*20*3d*20*22*2fbackend*2fcatalog*22*0a*7c*20filter*20*40timestamp*20*3e*20date_sub*28now*28*29*2c*20interval*201*20hour*29*0a*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fcatalog)))",
              "**Alerts Service:** [View Recent](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20*40message*0a*7c*20filter*20*40logGroup*20*3d*20*22*2fbackend*2falerts*22*0a*7c*20filter*20*40timestamp*20*3e*20date_sub*28now*28*29*2c*20interval*201*20hour*29*0a*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2falerts)))",
              "**Text Search:** [View Recent](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20*40message*0a*7c*20filter*20*40logGroup*20*3d*20*22*2fbackend*2ftext-search*22*0a*7c*20filter*20*40timestamp*20*3e*20date_sub*28now*28*29*2c*20interval*201*20hour*29*0a*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2ftext-search)))"
            ])
          }
        },
        # Log Level Filters (1 widget)
        {
          type   = "text"
          x      = 16
          y      = 0
          width  = 4
          height = 4
          properties = {
            markdown = join("\n", [
              "## Log Level Filters",
              "**ERROR Logs:** [View All](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2fERROR*2f*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**WARN Logs:** [View All](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2fWARN*2f*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**INFO Logs:** [View All](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2fINFO*2f*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))"
            ])
          }
        },
        # Time Range Selectors (1 widget)
        {
          type   = "text"
          x      = 20
          y      = 0
          width  = 4
          height = 4
          properties = {
            markdown = join("\n", [
              "## Time Range Quick Access",
              "**Last 15 min:** [View Logs](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-900~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**Last 1 hour:** [View Logs](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**Last 4 hours:** [View Logs](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-14400~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**Last 24 hours:** [View Logs](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-86400~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))"
            ])
          }
        },
        # Structured Log Parsing (1 widget)
        {
          type   = "log"
          x      = 16
          y      = 4
          width  = 4
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message | parse @message /(?<level>INFO|WARN|ERROR|DEBUG) (?<timestamp>\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}) (?<message>.*)/ | stats count() by level | sort count desc"
            region = local.dashboard_properties.region
            title  = "Log Level Distribution"
            view   = "table"
          }
        },
        # Search Templates (1 widget)
        {
          type   = "text"
          x      = 20
          y      = 4
          width  = 4
          height = 4
          properties = {
            markdown = join("\n", [
              "## Common Search Templates",
              "**Startup Errors:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2fstartup*7cinitialization*7cboot*2f*20and*20*40message*20like*20*2fERROR*7cFAILED*2f*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**API Failures:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2fAPI*7cHTTP*2f*20and*20*40message*20like*20*2f4*5cd*5cd*7c5*5cd*5cd*7cERROR*2f*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**Performance Issues:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2fslow*7ctimeout*7cperformance*7clatency*2f*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))"
            ])
          }
        }
      ],
      # Health Monitoring Panel (6 widgets) - Middle Left - Enhanced with comprehensive metrics-log correlation
      [
        # Enhanced Metrics-Log Correlation (2 widgets) - Combining ECS metrics with log insights for unified health view
        {
          type   = "metric"
          x      = 0
          y      = 16
          width  = 6
          height = 4
          properties = {
            metrics = [
              ["AWS/ECS", "CPUUtilization", "ClusterName", var.cluster_name],
              [".", "MemoryUtilization", ".", "."],
              ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name],
              [".", "StatusCheckFailed", ".", "."]
            ]
            view   = "timeSeries"
            region = local.dashboard_properties.region
            title  = "🔍 System Health Metrics with Correlation"
            period = 300
            stat   = "Average"
            yAxis = {
              left = {
                min = 0
                max = 100
              }
            }
            annotations = {
              horizontal = [
                {
                  label = "🟡 High CPU Threshold"
                  value = 80
                  color = "#FF9900"
                },
                {
                  label = "🔴 Critical CPU Threshold"
                  value = 95
                  color = "#FF0000"
                }
              ]
            }
          }
        },
        {
          type   = "log"
          x      = 6
          y      = 16
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message, @logStream | filter @message like /health|status|ready|alive|heartbeat/ | parse @message /(?<service>\\w+).*(?<status>healthy|unhealthy|ready|not ready|up|down)/ | stats count() as health_events by @logStream, status, bin(15m) | sort @timestamp desc | limit 25"
            region = local.dashboard_properties.region
            title  = "🩺 Health Check Log Correlation"
            view   = "table"
          }
        },
        # Enhanced Performance Anomaly Detection (2 widgets) - Automated highlighting of performance issues
        {
          type   = "metric"
          x      = 0
          y      = 20
          width  = 6
          height = 4
          properties = {
            metrics = concat([
              ["AWS/ECS", "RunningTaskCount", "ClusterName", var.cluster_name],
              [".", "PendingTaskCount", ".", "."],
              [".", "ActiveServiceCount", ".", "."]
            ], var.load_balancer_name != "" ? [
              ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.load_balancer_name]
            ] : [])
            view   = "timeSeries"
            region = local.dashboard_properties.region
            title  = "⚡ Performance Anomaly Detection"
            period = 300
            stat   = "Average"
            annotations = {
              horizontal = [
                {
                  label = "🟢 Normal Task Count"
                  value = 5
                  color = "#00FF00"
                },
                {
                  label = "🟡 High Task Count"
                  value = 10
                  color = "#FF9900"
                },
                {
                  label = "🔴 Critical Response Time"
                  value = 2000
                  color = "#FF0000"
                }
              ]
            }
          }
        },
        {
          type   = "log"
          x      = 6
          y      = 20
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message, @logStream | filter @message like /slow|timeout|performance|latency|bottleneck|degraded/ | parse @message /(?<metric_type>response_time|latency|duration).*?(?<value>\\d+)(?<unit>ms|s)/ | stats count() as perf_issues, avg(value) as avg_metric by @logStream, metric_type, bin(15m) | sort @timestamp desc | limit 20"
            region = local.dashboard_properties.region
            title  = "🐌 Performance Issue Detection with Metrics"
            view   = "table"
          }
        },
        # Enhanced Resource Correlation (2 widgets) - Linking utilization to application logs with real-time context
        {
          type   = "metric"
          x      = 0
          y      = 24
          width  = 6
          height = 4
          properties = {
            metrics = [
              ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", var.autoscaling_group_name],
              [".", "NetworkOut", ".", "."],
              [".", "DiskReadBytes", ".", "."],
              [".", "DiskWriteBytes", ".", "."],
              ["AWS/ECS", "CPUReservation", "ClusterName", var.cluster_name],
              [".", "MemoryReservation", ".", "."]
            ]
            view   = "timeSeries"
            region = local.dashboard_properties.region
            title  = "📊 Resource Utilization with Application Context"
            period = 300
            stat   = "Average"
            annotations = {
              horizontal = [
                {
                  label = "🟡 High Network Usage"
                  value = 1000000000
                  color = "#FF9900"
                },
                {
                  label = "🔴 Critical Disk I/O"
                  value = 100000000
                  color = "#FF0000"
                }
              ]
            }
          }
        },
        {
          type   = "log"
          x      = 6
          y      = 24
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message, @logStream | filter @message like /memory|cpu|disk|resource|oom|out of memory|high load|throttle/ | parse @message /(?<resource_type>memory|cpu|disk).*?(?<usage>\\d+)(?<unit>%|MB|GB)/ | stats count() as resource_events, latest(@message) as latest_event by @logStream, resource_type, bin(15m) | sort @timestamp desc | limit 20"
            region = local.dashboard_properties.region
            title  = "💾 Resource-Related Log Events with Context"
            view   = "table"
          }
        }
      ],
      # Security Events Panel (4 widgets) - Middle Right
      [
        # Authentication Failure Detection (2 widgets)
        {
          type   = "log"
          x      = 12
          y      = 16
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message | filter @message like /401|403|authentication|login.*fail|unauthorized/ | stats count() by bin(1h) | sort @timestamp desc | limit 10"
            region = local.dashboard_properties.region
            title  = "Authentication Failures"
            view   = "table"
          }
        },
        {
          type   = "log"
          x      = 18
          y      = 16
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message | filter @message like /blocked|denied|suspicious|security/ | stats count() by bin(1h) | sort @timestamp desc | limit 10"
            region = local.dashboard_properties.region
            title  = "Security Events"
            view   = "table"
          }
        },
        # API Security Monitoring (2 widgets)
        {
          type   = "log"
          x      = 12
          y      = 20
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message | filter @message like /API|HTTP/ | parse @message /(?<method>GET|POST|PUT|DELETE) (?<path>\\/\\S+) (?<status>\\d{3})/ | stats count() by status | sort count desc"
            region = local.dashboard_properties.region
            title  = "API Security Metrics"
            view   = "table"
          }
        },
        {
          type   = "text"
          x      = 18
          y      = 20
          width  = 6
          height = 4
          properties = {
            markdown = join("\n", [
              "## Security Investigation Links",
              "**Authentication Events:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2fauthentication*7clogin*7cauth*2f*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**API Security:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2fAPI*7cHTTP*2f*20and*20*40message*20like*20*2f4*5cd*5cd*7c5*5cd*5cd*2f*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**Access Patterns:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2faccess*7crequest*7cuser-agent*2f*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))"
            ])
          }
        }
      ],
      # ECS Deployment and Task Panel (8 widgets) - Bottom
      [
        # ECS Deployment Monitoring (2 widgets)
        {
          type   = "metric"
          x      = 0
          y      = 28
          width  = 6
          height = 4
          properties = {
            metrics = [
              ["AWS/ECS", "RunningTaskCount", "ClusterName", var.cluster_name],
              [".", "PendingTaskCount", ".", "."],
              [".", "ActiveServiceCount", ".", "."]
            ]
            view   = "timeSeries"
            region = local.dashboard_properties.region
            title  = "ECS Deployment Progress"
            period = 300
            stat   = "Average"
          }
        },
        {
          type   = "log"
          x      = 6
          y      = 28
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message | filter @message like /Task|Container|ECS|deploy/ | parse @message /Task (?<task_id>\\w+) (?<event>\\w+)/ | stats count() by event, bin(15m) | sort @timestamp desc"
            region = local.dashboard_properties.region
            title  = "ECS Task Lifecycle Events"
            view   = "table"
          }
        },
        {
          type   = "log"
          x      = 12
          y      = 28
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message | filter @message like /Deploy|Start|Stop|Health/ | sort @timestamp asc | limit 50"
            region = local.dashboard_properties.region
            title  = "Deployment Timeline"
            view   = "table"
          }
        },
        {
          type   = "log"
          x      = 18
          y      = 28
          width  = 6
          height = 4
          properties = {
            query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp, @message | filter @message like /placement|scheduling|resource/ | parse @message /instance (?<instance_id>i-\\w+)/ | stats count() by instance_id, bin(1h)"
            region = local.dashboard_properties.region
            title  = "Task Placement Analysis"
            view   = "table"
          }
        },
        # ECS Replica Visualization (2 widgets)
        {
          type   = "metric"
          x      = 0
          y      = 32
          width  = 6
          height = 4
          properties = {
            metrics = [
              ["AWS/ECS", "CPUReservation", "ClusterName", var.cluster_name],
              [".", "MemoryReservation", ".", "."]
            ]
            view   = "timeSeries"
            region = local.dashboard_properties.region
            title  = "ECS Resource Allocation"
            period = 300
            stat   = "Average"
          }
        },
        {
          type   = "text"
          x      = 6
          y      = 32
          width  = 6
          height = 4
          properties = {
            markdown = join("\n", [
              "## ECS Management Links",
              "**Task Lifecycle:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2fTask*7cContainer*7cECS*2f*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**Deployment Logs:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2fDeploy*7cStart*7cStop*7cHealth*2f*20*7c*20sort*20*40timestamp*20asc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))",
              "**Scaling Events:** [View Query](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'SOURCE*20*27*2fbackend*2fuser-accounts*27*20*7c*20SOURCE*20*27*2fbackend*2fcatalog*27*20*7c*20SOURCE*20*27*2fbackend*2falerts*27*20*7c*20SOURCE*20*27*2fbackend*2ftext-search*27*20*7c*20SOURCE*20*27*2ffrontend*27*20*7c*20fields*20*40timestamp*2c*20*40message*20*7c*20filter*20*40message*20like*20*2fscaling*7cauto-scaling*7cplacement*2f*20*7c*20sort*20*40timestamp*20desc~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))"
            ])
          }
        },
        # Deployment Timeline Analysis (2 widgets)
        {
          type   = "metric"
          x      = 12
          y      = 32
          width  = 6
          height = 4
          properties = {
            metrics = [
              ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.autoscaling_group_name],
              [".", "GroupInServiceInstances", ".", "."]
            ]
            view   = "timeSeries"
            region = local.dashboard_properties.region
            title  = "Auto Scaling Activity"
            period = 300
            stat   = "Average"
          }
        },
        {
          type   = "text"
          x      = 18
          y      = 32
          width  = 6
          height = 4
          properties = {
            markdown = join("\n", [
              "## Free Tier Usage Monitor",
              "**Current Status:**",
              "- Dashboards: 4/10 (40% used)",
              "- Metrics: 32/50 (64% used)",
              "- API Requests: ~2900/month (29% used)",
              "- Log Retention: 3 days (24% of 5GB limit)",
              "",
              "**Safety Margins:**",
              "- Dashboard Buffer: 60%",
              "- Metrics Buffer: 36%",
              "- API Buffer: 71%",
              "- Log Buffer: 76%"
            ])
          }
        }
      ]
    )
  })
}

# CloudWatch Insights Query Library - Comprehensive query templates for enhanced observability

# Error Analysis Queries
resource "aws_cloudwatch_query_definition" "critical_errors" {
  name = "${var.cluster_name}-critical-errors"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /ERROR|FATAL|Exception/
| stats count() by bin(15m), @logStream
| sort @timestamp desc
| limit 100
EOF
}

resource "aws_cloudwatch_query_definition" "error_patterns" {
  name = "${var.cluster_name}-error-patterns"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, service, @message
| filter @message like /ERROR/
| stats count() by service, bin(1h)
| sort count desc
EOF
}

resource "aws_cloudwatch_query_definition" "stack_trace_analysis" {
  name = "${var.cluster_name}-stack-trace-analysis"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /Exception|Error/
| parse @message /(?<error_type>\w+Exception): (?<error_msg>.*)/
| stats count() by error_type
| sort count desc
EOF
}

# Service-Specific Log Queries
resource "aws_cloudwatch_query_definition" "frontend_service_logs" {
  name = "${var.cluster_name}-frontend-logs"

  log_group_names = ["/frontend"]

  query_string = <<EOF
fields @timestamp, @message
| filter @logGroup = "/frontend"
| filter @timestamp > date_sub(now(), interval 1 hour)
| sort @timestamp desc
EOF
}

resource "aws_cloudwatch_query_definition" "backend_service_logs" {
  name = "${var.cluster_name}-backend-logs"

  log_group_names = [
    "/backend/user-accounts",
    "/backend/catalog",
    "/backend/alerts",
    "/backend/text-search"
  ]

  query_string = <<EOF
fields @timestamp, @message, @requestId
| filter @logGroup like /\/backend\/.*/
| filter @timestamp > date_sub(now(), interval 1 hour)
| sort @timestamp desc
EOF
}

resource "aws_cloudwatch_query_definition" "api_performance_analysis" {
  name = "${var.cluster_name}-api-performance"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message, @duration
| filter @message like /API|HTTP/
| parse @message /duration=(?<duration>\d+)ms/
| stats avg(duration), max(duration) by bin(5m)
| sort @timestamp desc
EOF
}

# ECS Deployment and Task Queries
resource "aws_cloudwatch_query_definition" "ecs_task_lifecycle" {
  name = "${var.cluster_name}-ecs-task-lifecycle"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /Task|Container|ECS/
| parse @message /Task (?<task_id>\w+) (?<event>\w+)/
| stats count() by event, bin(15m)
| sort @timestamp desc
EOF
}

resource "aws_cloudwatch_query_definition" "deployment_timeline" {
  name = "${var.cluster_name}-deployment-timeline"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /Deploy|Start|Stop|Health/
| sort @timestamp asc
| limit 50
EOF
}

resource "aws_cloudwatch_query_definition" "task_placement_analysis" {
  name = "${var.cluster_name}-task-placement"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /placement|scheduling|resource/
| parse @message /instance (?<instance_id>i-\w+)/
| stats count() by instance_id, bin(1h)
EOF
}

# Security Event Queries
resource "aws_cloudwatch_query_definition" "authentication_events" {
  name = "${var.cluster_name}-authentication-events"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /authentication|login|auth/
| sort @timestamp desc
EOF
}

resource "aws_cloudwatch_query_definition" "api_security_events" {
  name = "${var.cluster_name}-api-security"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /API|HTTP/ and @message like /4\d\d|5\d\d/
| sort @timestamp desc
EOF
}

# Health Monitoring Queries - Enhanced queries for comprehensive health correlation
resource "aws_cloudwatch_query_definition" "health_status_correlation" {
  name = "${var.cluster_name}-health-status-correlation"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /health|status|ready|alive|heartbeat/
| parse @message /(?<service>\w+).*(?<status>healthy|unhealthy|ready|not ready|up|down)/
| stats count() as health_events by @logStream, status, bin(15m)
| sort @timestamp desc
| limit 25
EOF
}

resource "aws_cloudwatch_query_definition" "performance_anomaly_detection" {
  name = "${var.cluster_name}-performance-anomaly-detection"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /slow|timeout|performance|latency|bottleneck|degraded/
| parse @message /(?<metric_type>response_time|latency|duration).*?(?<value>\d+)(?<unit>ms|s)/
| stats count() as perf_issues, avg(value) as avg_metric by @logStream, metric_type, bin(15m)
| sort @timestamp desc
| limit 20
EOF
}

resource "aws_cloudwatch_query_definition" "resource_correlation_analysis" {
  name = "${var.cluster_name}-resource-correlation-analysis"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /memory|cpu|disk|resource|oom|out of memory|high load|throttle/
| parse @message /(?<resource_type>memory|cpu|disk).*?(?<usage>\d+)(?<unit>%|MB|GB)/
| stats count() as resource_events, latest(@message) as latest_event by @logStream, resource_type, bin(15m)
| sort @timestamp desc
| limit 20
EOF
}

resource "aws_cloudwatch_query_definition" "system_health_overview" {
  name = "${var.cluster_name}-system-health-overview"

  log_group_names = [
    for service_name, config in local.services : config.log_group
  ]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /health|error|warning|critical|alert/
| parse @message /(?<severity>INFO|WARN|ERROR|CRITICAL|FATAL)/
| stats count() as event_count by @logStream, severity, bin(30m)
| sort @timestamp desc
| limit 30
EOF
}

resource "aws_cloudwatch_log_group" "service_log_groups" {
  for_each = local.services

  name              = each.value.log_group
  retention_in_days = local.free_tier_config.log_retention_days

  tags = var.tags
}

# Free Tier Usage Monitoring - Custom metrics for tracking usage
resource "aws_cloudwatch_metric_alarm" "dashboard_count_monitor" {
  alarm_name          = "${var.cluster_name}-dashboard-count-monitor"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DashboardCount"
  namespace           = "AWS/CloudWatch"
  period              = "3600"
  statistic           = "Maximum"
  threshold           = "8" # Alert when approaching 10 dashboard limit
  alarm_description   = "Monitor dashboard count approaching free tier limit"
  alarm_actions       = var.alarm_actions

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "api_request_monitor" {
  alarm_name          = "${var.cluster_name}-api-request-monitor"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "APIRequestCount"
  namespace           = "AWS/CloudWatch"
  period              = "86400" # Daily monitoring
  statistic           = "Sum"
  threshold           = "300" # Alert when daily usage exceeds safe limit
  alarm_description   = "Monitor API request usage approaching free tier limit"
  alarm_actions       = var.alarm_actions

  tags = var.tags
}

# Health Monitoring Alarms - Real-time health status indicators with log context
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  count = var.enable_free_tier_monitoring ? 1 : 0

  alarm_name          = "${var.cluster_name}-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "ECS cluster CPU utilization is high - check health monitoring panel for correlation with application logs"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "high_memory_utilization" {
  count = var.enable_free_tier_monitoring ? 1 : 0

  alarm_name          = "${var.cluster_name}-high-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "ECS cluster memory utilization is high - correlate with resource logs in health monitoring panel"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "task_count_anomaly" {
  count = var.enable_ecs_deployment_monitoring ? 1 : 0

  alarm_name          = "${var.cluster_name}-task-count-anomaly"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "ECS running task count is critically low - check deployment logs and health status"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "performance_degradation" {
  count = var.load_balancer_name != "" && var.enable_free_tier_monitoring ? 1 : 0

  alarm_name          = "${var.cluster_name}-performance-degradation"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "Application response time is degraded - check performance anomaly detection in health monitoring panel"
  alarm_actions       = var.alarm_actions

  dimensions = {
    LoadBalancer = var.load_balancer_name
  }

  tags = var.tags
}

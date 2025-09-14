terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Only create budget if billing_account_id is provided
resource "google_billing_budget" "budget" {
  count = var.billing_account_id != "" ? 1 : 0

  billing_account = var.billing_account_id
  display_name    = var.budget_name

  budget_filter {
    projects = ["projects/${var.project_id}"]

    # Include specific services if provided, otherwise include all
    dynamic "services" {
      for_each = length(var.services) > 0 ? [1] : []
      content {
        service_ids = var.services
      }
    }

    credit_types_treatment = var.credit_types_treatment
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.amount)
    }
  }

  # Create threshold rules for each threshold percentage
  dynamic "threshold_rules" {
    for_each = var.thresholds
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = "CURRENT_SPEND"
    }
  }

  # Email notifications if addresses are provided
  dynamic "all_updates_rule" {
    for_each = length(var.notification_emails) > 0 ? [1] : []
    content {
      monitoring_notification_channels = []
      disable_default_iam_recipients   = false

      # Note: Email notifications require setting up notification channels
      # This is a simplified configuration for the hackathon
    }
  }
}

# Output instructions for setting up email notifications
locals {
  notification_setup_instructions = length(var.notification_emails) > 0 ? "To set up email notifications for budget alerts:\n\n1. Create notification channels:\n   gcloud alpha monitoring channels create --display-name=\"Budget Alerts\" \\\n     --type=email --channel-labels=email_address=${join(",", var.notification_emails)}\n\n2. Update the budget with the notification channel ID:\n   # Get the channel ID from the previous command and update the budget configuration\n\n3. Alternatively, set up notifications in the Google Cloud Console:\n   - Go to Monitoring > Alerting > Notification Channels\n   - Create email notification channels\n   - Link them to the budget in Billing > Budgets & alerts" : ""
}

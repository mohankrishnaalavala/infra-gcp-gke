output "budget_name" {
  description = "The name of the created budget"
  value       = var.billing_account_id != "" ? google_billing_budget.budget[0].display_name : null
}

output "budget_id" {
  description = "The ID of the created budget"
  value       = var.billing_account_id != "" ? google_billing_budget.budget[0].name : null
}

output "budget_amount" {
  description = "The budget amount"
  value       = var.amount
}

output "budget_created" {
  description = "Whether a budget was created"
  value       = var.billing_account_id != ""
}

output "notification_setup_instructions" {
  description = "Instructions for setting up email notifications"
  value       = local.notification_setup_instructions
}

output "billing_account_required" {
  description = "Message about billing account requirement"
  value       = var.billing_account_id == "" ? "No budget created because billing_account_id was not provided.\nTo create a budget, set the billing_account_id variable to your billing account ID.\nYou can find your billing account ID in the Google Cloud Console under Billing." : null
}

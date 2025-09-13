variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "billing_account_id" {
  description = "The billing account ID. If empty, no budget will be created."
  type        = string
  default     = ""
}

variable "budget_name" {
  description = "The name of the budget"
  type        = string
  default     = "fraudguard-hackathon-budget"
}

variable "amount" {
  description = "The budget amount in USD"
  type        = number
  default     = 100
  
  validation {
    condition     = var.amount > 0
    error_message = "Budget amount must be greater than 0."
  }
}

variable "thresholds" {
  description = "List of threshold percentages for budget alerts"
  type        = list(number)
  default     = [0.5, 0.9, 1.0]
  
  validation {
    condition     = alltrue([for t in var.thresholds : t > 0 && t <= 1.0])
    error_message = "All thresholds must be between 0 and 1.0."
  }
}

variable "notification_emails" {
  description = "List of email addresses to notify when budget thresholds are exceeded"
  type        = list(string)
  default     = []
}

variable "credit_types_treatment" {
  description = "How to treat credits in the budget"
  type        = string
  default     = "INCLUDE_ALL_CREDITS"
  
  validation {
    condition = contains([
      "INCLUDE_ALL_CREDITS",
      "EXCLUDE_ALL_CREDITS", 
      "INCLUDE_SPECIFIED_CREDITS"
    ], var.credit_types_treatment)
    error_message = "Credit types treatment must be one of: INCLUDE_ALL_CREDITS, EXCLUDE_ALL_CREDITS, INCLUDE_SPECIFIED_CREDITS."
  }
}

variable "services" {
  description = "List of service IDs to include in the budget. If empty, includes all services."
  type        = list(string)
  default     = []
}

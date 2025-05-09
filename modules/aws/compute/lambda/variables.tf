/**
 * # Lambda Module Variables
 *
 * Variables for the AWS Lambda module
 */

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "client" {
  description = "Client name for resource naming"
  type        = string
  validation {
    condition     = length(var.client) > 0
    error_message = "Client name cannot be empty."
  }
}

variable "functionality" {
  description = "Functionality name for resource naming"
  type        = string
  validation {
    condition     = length(var.functionality) > 0
    error_message = "Functionality name cannot be empty."
  }
}

variable "environment" {
  description = "Environment name for resource naming (dev, qa, pdn)"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "Environment must be one of: dev, qa, pdn."
  }
}

variable "lambda_config" {
  description = "Map of Lambda functions configurations"
  type = map(object({
    # Code configuration
    filename         = string
    source_code_hash = string
    handler          = string
    runtime          = string
    description      = optional(string, "Lambda function managed by Terraform")
    
    # Performance configuration
    memory_size = optional(number, 128)
    timeout     = optional(number, 3)
    
    # Environment variables
    environment_variables = optional(map(string), null)
    
    # VPC configuration
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
    }), null)
    
    # Dead letter configuration
    dead_letter_target_arn = optional(string, null)
    
    # Tracing configuration
    tracing_mode = optional(string, null)
    
    # IAM configuration
    custom_policy = optional(string, null)
    
    # Permission configuration
    permission = optional(object({
      statement_id = string
      action       = string
      principal    = string
      source_arn   = string
    }), null)
    
    # Monitoring configuration
    log_retention_days  = optional(number, 30)
    enable_alarms       = optional(bool, true)
    error_threshold     = optional(number, 0)
    throttle_threshold  = optional(number, 0)
    duration_threshold  = optional(number, 3000)
    alarm_actions       = optional(list(string), [])
    ok_actions          = optional(list(string), [])
    
    # Tagging
    additional_tags = optional(map(string), {})
  }))
  
  validation {
    condition = alltrue([
      for k, v in var.lambda_config : v.memory_size >= 128 && v.memory_size <= 10240
    ])
    error_message = "Lambda memory size must be between 128 MB and 10240 MB."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.lambda_config : v.timeout >= 1 && v.timeout <= 900
    ])
    error_message = "Lambda timeout must be between 1 and 900 seconds."
  }
}

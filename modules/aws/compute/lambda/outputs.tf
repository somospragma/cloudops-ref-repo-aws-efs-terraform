/**
 * # Lambda Module Outputs
 *
 * Outputs for the AWS Lambda module
 */

output "lambda_functions" {
  description = "Map of Lambda functions created"
  value = {
    for k, v in aws_lambda_function.lambda : k => {
      function_name    = v.function_name
      function_arn     = v.arn
      invoke_arn       = v.invoke_arn
      qualified_arn    = v.qualified_arn
      version          = v.version
      source_code_hash = v.source_code_hash
      last_modified    = v.last_modified
    }
  }
}

output "lambda_roles" {
  description = "Map of IAM roles created for Lambda functions"
  value = {
    for k, v in aws_iam_role.lambda_role : k => {
      role_name = v.name
      role_arn  = v.arn
    }
  }
}

output "lambda_log_groups" {
  description = "Map of CloudWatch Log Groups created for Lambda functions"
  value = {
    for k, v in aws_cloudwatch_log_group.lambda_log_group : k => {
      name = v.name
      arn  = v.arn
    }
  }
}

output "lambda_alarms" {
  description = "Map of CloudWatch Alarms created for Lambda functions"
  value = {
    for k, v in var.lambda_config : k => {
      errors_alarm    = v.enable_alarms ? aws_cloudwatch_metric_alarm.lambda_errors_alarm[k].arn : null
      throttles_alarm = v.enable_alarms ? aws_cloudwatch_metric_alarm.lambda_throttles_alarm[k].arn : null
      duration_alarm  = v.enable_alarms ? aws_cloudwatch_metric_alarm.lambda_duration_alarm[k].arn : null
    } if v.enable_alarms
  }
}

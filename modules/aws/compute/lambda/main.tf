/**
 * # AWS Lambda Module
 *
 * This module creates AWS Lambda functions with associated resources following Pragma CloudOps standards.
 * It supports multiple Lambda functions with customizable configurations, including:
 * - IAM roles and policies
 * - CloudWatch logs
 * - Environment variables
 * - VPC configuration
 * - Dead letter configuration
 * - Monitoring and alerting
 */

# ---------------------------------------------------------------------------------------------------------------------
# LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Generate standardized names for Lambda functions
  lambda_names = {
    for k, v in var.lambda_config : k => {
      function_name = "${var.client}-${var.functionality}-${var.environment}-lambda-${k}"
    }
  }

  # Default IAM policy for Lambda execution
  lambda_basic_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  # Merge default and custom IAM policies
  lambda_policies = {
    for k, v in var.lambda_config : k => v.custom_policy != null ? v.custom_policy : local.lambda_basic_policy
  }

  # Generate CloudWatch log group names
  log_group_names = {
    for k, v in var.lambda_config : k => "/aws/lambda/${local.lambda_names[k].function_name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM ROLE FOR LAMBDA FUNCTIONS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
  for_each = var.lambda_config

  name = "${local.lambda_names[each.key].function_name}-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name = "${local.lambda_names[each.key].function_name}-role"
    },
    each.value.additional_tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM POLICY FOR LAMBDA FUNCTIONS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "lambda_policy" {
  for_each = var.lambda_config

  name        = "${local.lambda_names[each.key].function_name}-policy"
  description = "Policy for Lambda function ${local.lambda_names[each.key].function_name}"
  policy      = local.lambda_policies[each.key]

  tags = merge(
    {
      Name = "${local.lambda_names[each.key].function_name}-policy"
    },
    each.value.additional_tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICY TO ROLE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  for_each = var.lambda_config

  role       = aws_iam_role.lambda_role[each.key].name
  policy_arn = aws_iam_policy.lambda_policy[each.key].arn
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP FOR LAMBDA FUNCTIONS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  for_each = var.lambda_config

  name              = local.log_group_names[each.key]
  retention_in_days = each.value.log_retention_days

  tags = merge(
    {
      Name = "${local.lambda_names[each.key].function_name}-logs"
    },
    each.value.additional_tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA FUNCTIONS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "lambda" {
  for_each = var.lambda_config

  function_name = local.lambda_names[each.key].function_name
  description   = each.value.description
  role          = aws_iam_role.lambda_role[each.key].arn
  
  # Code configuration
  filename         = each.value.filename
  source_code_hash = each.value.source_code_hash
  handler          = each.value.handler
  runtime          = each.value.runtime
  
  # Performance configuration
  memory_size = each.value.memory_size
  timeout     = each.value.timeout
  
  # Environment variables
  dynamic "environment" {
    for_each = each.value.environment_variables != null ? [1] : []
    content {
      variables = each.value.environment_variables
    }
  }
  
  # VPC configuration
  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [1] : []
    content {
      subnet_ids         = each.value.vpc_config.subnet_ids
      security_group_ids = each.value.vpc_config.security_group_ids
    }
  }
  
  # Dead letter configuration
  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = each.value.dead_letter_target_arn
    }
  }
  
  # Tracing configuration
  dynamic "tracing_config" {
    for_each = each.value.tracing_mode != null ? [1] : []
    content {
      mode = each.value.tracing_mode
    }
  }
  
  # Ensure CloudWatch logs are created before Lambda
  depends_on = [aws_cloudwatch_log_group.lambda_log_group]
  
  tags = merge(
    {
      Name = local.lambda_names[each.key].function_name
    },
    each.value.additional_tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA FUNCTION PERMISSIONS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_permission" "lambda_permission" {
  for_each = {
    for k, v in var.lambda_config : k => v
    if v.permission != null
  }

  statement_id  = each.value.permission.statement_id
  action        = each.value.permission.action
  function_name = aws_lambda_function.lambda[each.key].function_name
  principal     = each.value.permission.principal
  source_arn    = each.value.permission.source_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH ALARMS FOR LAMBDA FUNCTIONS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "lambda_errors_alarm" {
  for_each = {
    for k, v in var.lambda_config : k => v
    if v.enable_alarms
  }

  alarm_name          = "${local.lambda_names[each.key].function_name}-errors-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = each.value.error_threshold
  alarm_description   = "This alarm monitors errors in the Lambda function ${local.lambda_names[each.key].function_name}"
  
  dimensions = {
    FunctionName = aws_lambda_function.lambda[each.key].function_name
  }
  
  alarm_actions = each.value.alarm_actions
  ok_actions    = each.value.ok_actions
  
  tags = merge(
    {
      Name = "${local.lambda_names[each.key].function_name}-errors-alarm"
    },
    each.value.additional_tags
  )
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles_alarm" {
  for_each = {
    for k, v in var.lambda_config : k => v
    if v.enable_alarms
  }

  alarm_name          = "${local.lambda_names[each.key].function_name}-throttles-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = each.value.throttle_threshold
  alarm_description   = "This alarm monitors throttles in the Lambda function ${local.lambda_names[each.key].function_name}"
  
  dimensions = {
    FunctionName = aws_lambda_function.lambda[each.key].function_name
  }
  
  alarm_actions = each.value.alarm_actions
  ok_actions    = each.value.ok_actions
  
  tags = merge(
    {
      Name = "${local.lambda_names[each.key].function_name}-throttles-alarm"
    },
    each.value.additional_tags
  )
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration_alarm" {
  for_each = {
    for k, v in var.lambda_config : k => v
    if v.enable_alarms
  }

  alarm_name          = "${local.lambda_names[each.key].function_name}-duration-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Average"
  threshold           = each.value.duration_threshold
  alarm_description   = "This alarm monitors execution duration of the Lambda function ${local.lambda_names[each.key].function_name}"
  
  dimensions = {
    FunctionName = aws_lambda_function.lambda[each.key].function_name
  }
  
  alarm_actions = each.value.alarm_actions
  ok_actions    = each.value.ok_actions
  
  tags = merge(
    {
      Name = "${local.lambda_names[each.key].function_name}-duration-alarm"
    },
    each.value.additional_tags
  )
}

output "efs_info" {
   value = {for efs in aws_efs_file_system.efs: efs.tags_all.application => {"efs_arn" : efs.arn,"efs_id" : efs.id}}
}
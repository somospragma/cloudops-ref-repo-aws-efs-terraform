resource "aws_efs_file_system" "efs" {
  for_each = {
    for item in var.efs_config : item.application_id => {
      kms_key_id = item.kms_key_id
    }
  }
  creation_token = join("-", [var.client,  each.key, var.environment, "efs", var.service])
  encrypted      = true
  kms_key_id     = each.value.kms_key_id
  tags = merge(
    { Name = join("-", [var.client, each.key, var.environment, "efs", var.service]) },
    { application = each.key }
  )
}

resource "aws_efs_mount_target" "efs" {
  for_each = {
    for item in var.efs_config : item.application_id => {
      subnet_id       = item.subnet_id
      security_groups = item.security_groups
    }
  }
  file_system_id  = aws_efs_file_system.efs[each.key].id
  subnet_id       = each.value.subnet_id
  security_groups = each.value.security_groups
}


resource "aws_efs_access_point" "efs" {
  for_each = {
    for item in flatten([for efs in var.efs_config : [for access_point in efs.access_points : {
      "application_id" : efs.application_id
      "access_point_index" : index(efs.access_points,access_point)
      "name" : access_point.name
      "path" : access_point.path
      "owner_gid" : access_point.owner_gid
      "owner_uid" : access_point.owner_uid
      "permissions" : access_point.permissions
    }]]) : "${item.application_id}-${item.name}" => item
  }
  file_system_id  = aws_efs_file_system.efs[each.value["application_id"]].id
  posix_user {
    gid = each.value["owner_gid"]
    uid = each.value["owner_uid"]
  }
  root_directory {
    path = each.value["path"]
    creation_info {
      owner_gid   = each.value["owner_gid"]
      owner_uid   = each.value["owner_uid"]
      permissions = each.value["permissions"]
    }
  }
  tags           = merge({ Name = "${each.value["name"]}" })
}
# dms.tf

# Creating a replication instance
resource "aws_dms_replication_instance" "replication_instance" {
  replication_instance_identifier = "my-replication-instance"
  replication_instance_class      = "db.t3.2xlarge"
  allocated_storage               = 100
  publicly_accessible             = false
  vpc_security_group_ids          = [module.security_group.this_security_group_id]
  availability_zone               = "us-west-1a"  # Replace with your desired availability zone
}

# Creating a replication subnet group
resource "aws_dms_replication_subnet_group" "replication_subnet_group" {
  replication_subnet_group_identifier = "my-replication-subnet-group"
  replication_subnet_group_description = "Replication subnet group for DMS"
  subnet_ids = [module.subnet.this_subnet_id]
}

# Creating a replication db
resource "aws_dms_replication_db" "replication_db" {
  replication_task_identifier = "my-replication-task"
  migration_type              = "full-load-and-cdc"
  source_endpoint_arn         = "arn:aws:dms:us-west-2:123456789012:endpoint:source-endpoint"
  target_endpoint_arn         = "arn:aws:dms:us-west-2:123456789012:endpoint:target-endpoint"
  replication_instance_arn    = aws_dms_replication_instance.replication_instance.arn
  table_mappings = <<EOF
{
  "rules": [
    {
      "rule-type": "selection",
      "rule-id": "1",
      "rule-name": "1",
      "object-locator": {
        "schema-name": "%",
        "table-name": "%"
      },
      "rule-action": "include"
    }
  ]
}
EOF
}
resource "aws_dynamodb_table" "rates-table" {
  name           = "Rates"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "TimeStamp"
  range_key      = "RateType"

  attribute {
    name = "TimeStamp"
    type = "N"
  }

  attribute {
    name = "RateType"
    type = "S"
  }

  attribute {
    name = "RateValue"
    type = "N"
  }

  global_secondary_index {
    name               = "RateTypeIndex"
    hash_key           = "RateType"
    range_key          = "RateValue"
    projection_type    = "INCLUDE"
    non_key_attributes = ["TimeStamp"]
  }

  tags = {
    Name        = "Rates-Table"
    Environment = "Review"
  }
}
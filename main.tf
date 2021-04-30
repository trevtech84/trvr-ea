#Create lambda role
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

#Add AmazonDynamoDBFullAccess policy/AmazonS3FullAccess policies to role iam_for_lambda 
resource "aws_iam_role_policy_attachment" "iam_for_lambda" {
    for_each = toset([
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess", 
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ])
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = each.value
}

data "aws_iam_policy" "iam_for_lambda" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

#Link trigger to lambda function
resource "aws_lambda_function" "func" {
  filename      = "process_rate.zip"
  function_name = "process_rate"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "process_rate.lambda_handler"
  runtime       = "python3.8"
}

#Setup bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "rates-inbox"
  force_destroy = true
}

#Setup bucket trigger
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
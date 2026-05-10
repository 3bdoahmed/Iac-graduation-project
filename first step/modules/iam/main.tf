resource "aws_iam_role" "lambda_role" {

  name = "s3-monitoring-lambda-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

#################################################
# IAM POLICY
#################################################

resource "aws_iam_policy" "lambda_policy" {

  name = "s3-monitoring-policy"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      #################################################
      # READ FROM SOURCE BUCKETS
      #################################################

      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = [
          "arn:aws:s3:::batteries-data-2026/*",
          "arn:aws:s3:::panels-data-2026/*"
        ]
      },

      #################################################
      # WRITE TO MONITORING BUCKET
      #################################################

      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = [
          "arn:aws:s3:::montering-data-2026/*"
        ]
      },

      #################################################
      # SNS PUBLISH
      #################################################

      {
        Effect = "Allow"

        Action = [
          "sns:Publish"
        ]

        Resource = var.sns_topic_arn
      },

      #################################################
      # DYNAMODB ACCESS
      #################################################

      {
        Effect = "Allow"

        Action = [
          "dynamodb:Scan",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]

        Resource = [

          "arn:aws:dynamodb:eu-west-3:*:table/battery_data",

          "arn:aws:dynamodb:eu-west-3:*:table/solar_data",

          "arn:aws:dynamodb:eu-west-3:*:table/system_status"
        ]
      },

      #################################################
      # CLOUDWATCH LOGS
      #################################################

      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      }
    ]
  })
}

#################################################
# ATTACH POLICY TO ROLE
#################################################

resource "aws_iam_role_policy_attachment" "attach" {

  role = aws_iam_role.lambda_role.name

  policy_arn = aws_iam_policy.lambda_policy.arn
}
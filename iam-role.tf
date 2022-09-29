#role
resource "aws_iam_role" "artifactory" {
  name = "artifactory-cicd"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "artifactory-cicd"
  }
}

#policy
resource "aws_iam_policy" "artifactory" {
  name        = "artifactory_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

#attach
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.artifactory.name
  policy_arn = aws_iam_policy.artifactory.arn
}

#roletoec2

resource "aws_iam_instance_profile" "artifactory" {
  name = "artifactory-profile"
  role = aws_iam_role.artifactory.name
}
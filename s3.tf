resource "aws_s3_bucket" "artifactory" {
  bucket = "artifactory-jenkins-tomcat"

  tags = {
    Name = "artifactory-jenkins-tomcat"
  }

}
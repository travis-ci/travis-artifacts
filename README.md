# Travis Artifacts

If your tests produce files, for example stack traces or logs, you can
easily upload them to Amazon S3.

See the Travis blog for more:

http://about.travis-ci.org/blog/2012-12-18-travis-artifacts/

## The minimum AWS policy needed for the gem to work

    {
      "Statement": [
        {
          "Action": [
            "s3:ListBucket"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:s3:::your-bucket"
          ]
        },
        {
          "Action": [
            "s3:PutObject",
            "s3:PutObjectAcl"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:s3:::your-bucket/*"
          ]
        }
      ]
    }

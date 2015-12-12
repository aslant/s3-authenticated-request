# s3-authenticated-request

A bash script to interact with the AWS REST API. Sends requests authenticated with [AWS Signature Version 4](http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html).

## Usage

```sh
$ ./request.sh URL [AWS_ACCESS_KEY_ID [AWS_SECRET_ACCESS_KEY [AWS_REGION]]]
```

When AWS variables are not passed as arguments, the script uses environment variables:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

AWS_REGION defaults to 'us-east-1' in the absence of both command line arg and env var.

## Dependencies

- bash
- perl
- OpenSSL

## Limitation

Currently only handles GET requests to s3 endoints. Trivial to modify. Payload variable exists already. No reason to restrict script to s3.

# s3-authenticated-request

A bash script to interact with the AWS REST API. Sends requests authenticated with [AWS Signature Version 4](http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html).

## Dependencies

- bash
- perl
- OpenSSL

## Limitations

Currently only handles GET requests to s3 endoints. Trivial to modify.

## Usage

```sh
$ ./request.sh URL [AWS_REGION]
```

When AWS_REGION is absent, uses environment variable AWS_REGION if set and otherwise defaults to 'us-east-1'.

### Environment Variables

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

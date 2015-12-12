#!/bin/bash

# REF: http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html

# ENV: AWS_SECRET_ACCESS_KEY
# ENV: AWS_ACCESS_KEY_ID
# ENV: AWS_REGION (default 'us-east-1', overridden by $2 if supplied)

HASH_ALGO=AWS4-HMAC-SHA256
http_method=GET
payload=

host=$(echo "$1" | grep -oP '^(?!https?://)[^/?]+|(?<=^http://)[^/?]+|(?<=^https://)[^/?]+')
canonical_uri='/'$(echo "$1" | grep -oP '(?<=[^/]/)[^/?][^?]*')
canonical_query_string=$(echo "$1" | grep -oP '(?<=\?).*')
aws_region=${2:-${AWS_REGION:-us-east-1}}
timestamp=$(date -u +'%FT%TZ' | perl -pe 's/[-:]//g')

hex_hash () {
  str="$1"
  key="$2"
  [ -z "$key" ] && hash_opts="-sha256"
  [ -n "$key" ] && hash_opts="-sha256 -mac HMAC -macopt $key"
  out="$(echo -n "$str" | openssl dgst $hash_opts | grep -oP '\S+$')"
  echo -n "$out"
  #echo -e "\n>>>\nkey:\t$key\nstr:\t$(echo -en "$str" | perl -pe 's/[ \t]+/\e[41m$&\e[0m/g' | perl -pe 'BEGIN {undef $/;} s/\n(?=\s*\S)/\n\t/g')\nout:\t$out\n<<<\n" >&2
}

# Task 1: Canonical Request
hashed_payload=$(hex_hash $payload)
canonical_headers="host:$host\nx-amz-content-sha256:$hashed_payload\nx-amz-date:$timestamp\n"
signed_headers=$(echo "$canonical_headers" | perl -pe 's/:.*?\\n/;/g' | grep -oP '.+(?!$)')
canonical_request=$(echo -e "$http_method\n$canonical_uri\n$canonical_query_string\n$canonical_headers\n$signed_headers\n$hashed_payload")
canonical_request_hash=$(hex_hash "$canonical_request")

# Task 2: String to Sign
scope="${timestamp::8}/$aws_region/s3/aws4_request"
string_to_sign=$(echo -e "$HASH_ALGO\n$timestamp\n$scope\n$canonical_request_hash")

# Task 3: Signing Key
signing_key=
for part in $(echo $scope | grep -oP '[^/]+')
do
  [ -z "$signing_key" ] && key="key:AWS4$AWS_SECRET_ACCESS_KEY"
  [ -n "$signing_key" ] && key="hexkey:$signing_key"
  signing_key=$(hex_hash "$part" "$key")
done

# Task 4: Signature
signature=$(hex_hash "$string_to_sign" hexkey:$signing_key)

# Task 5: Authorization header
authorization_header="Authorization:$HASH_ALGO Credential=$AWS_ACCESS_KEY_ID/$scope,SignedHeaders=$signed_headers,Signature=$signature"

# Task 6: Request
headers="$authorization_header\n${canonical_headers::-2}" # remove tailing newline
curl_header_opts=$(echo -e "$headers" | perl -pe 's/^(.*)$/-H "\1" /g' | perl -pe 's/\n//g');

cmd="curl -s -v $curl_header_opts 'https://$host$canonical_uri?$canonical_query_string'"
echo "$cmd" >&2

eval $cmd

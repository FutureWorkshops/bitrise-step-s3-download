# Download file form S3
This step allows to download a file from an S3 bucket using an Access/secret keypair for authentication.

## How to use this Step

This step can be configured using:

- aws_access_key: This is the access key of an IAM user with access to the s3_bucket
- aws_secret_access_key: This is the secret access key associated to the access_key above
- s3_bucket: This is the name of the bucket where the file can be found
- s3_filepath: Name of the file that will be downloaded (relative to the bucket)
- output_location: This is the local output path where the file will be stored. By default, this value is `.`

Output:

- S3_DOWNLOAD_OUTPUT_PATH: This is the full path of the downloaded file

```
- git::https://github.com/FutureWorkshops/bitrise-step-s3-download.git@master:
    title: Download keystore
    inputs:
    - aws_access_key: "$AWS_ACCESS_KEY_ID"
    - aws_secret_access_key: "$AWS_SECRET_ACCESS_KEY"
    - s3_bucket: "$CERTIFICATE_BUCKET"
    - s3_filepath: "$KEYSTORE_NAME"
    - output_location: "$BITRISE_SOURCE_DIR"
- script@1:
    title: Echo path
    inputs:
    - content: |-
        #!/usr/bin/env bash
        # fail if any commands fails
        set -e
        # debug log
        set -x
​
        # write your script here
        echo "Path: $S3_DOWNLOAD_OUTPUT_PATH"
        echo "Computed path: $BITRISE_SOURCE_DIR/$KEYSTORE_NAME"
​
        ls "$BITRISE_SOURCE_DIR"
```



---
title: Build aws-devops
---

# Build: aws-devops

<span class="di-pill di-pill--aws">aws-devops</span> is the `base` stage plus an AWS layer. It has no Google Cloud SDK.

```mermaid
flowchart LR
  B["base"] --> L["aws-devops layer<br/>crcmod, pytest, s3cmd, boto3,<br/>cfn-lint, requests, bs4, lxml,<br/>AWS CLI v2, Session Manager plugin"]
  L --> I["aws-devops:local"]

  classDef base fill:#0d9488,stroke:#0f766e,color:#fff
  classDef aws fill:#ea7a0c,stroke:#c2410c,color:#fff
  class B base
  class L,I aws
```

## Build

```bash
docker build --target aws-devops -t aws-devops:local .
```

The AWS layer has no version build arguments: the AWS CLI and Session Manager plugin always come from the latest official packages for the build architecture. The [base build arguments](index.md#build-arguments) still apply.

## Verify

```bash
docker run --rm aws-devops:local bash -c '
  aws --version && session-manager-plugin --version &&
  cfn-lint --version && terragrunt --version'
```

## Run

```bash
docker run -it --rm \
  -v "$PWD":/srv -w /srv \
  -v ~/.aws:/root/.aws \
  aws-devops:local
```

See [Using aws-devops](../use-images/aws-devops.md) for everyday usage.

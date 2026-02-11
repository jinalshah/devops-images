# Build: AWS DevOps

## Local Build

```bash
docker build --target aws-devops -t aws-devops:local .
```

## Run

```bash
docker run -it --rm aws-devops:local
```

## Quick Verification

```bash
docker run --rm aws-devops:local aws --version
docker run --rm aws-devops:local terragrunt --version
docker run --rm aws-devops:local cfn-lint --version
```

## Example With Local AWS Credentials

```bash
docker run -it --rm -v ~/.aws:/root/.aws aws-devops:local aws sts get-caller-identity
```

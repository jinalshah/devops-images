#!/usr/bin/env bash
set -euo pipefail

# Requires: gh CLI authenticated (GH_TOKEN env var or gh auth login)
# Requires: jq installed

# Fetch latest versions
GCLOUD_VERSION=$(curl -s https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json | jq -r '.version')
PACKER_VERSION=$(curl -s https://api.github.com/repos/hashicorp/packer/releases/latest | jq -r .tag_name | sed 's/^v//')
TERRAGRUNT_VERSION=$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r .tag_name | sed 's/^v//')
TFLINT_VERSION=$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | jq -r .tag_name | sed 's/^v//')
TFSEC_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | jq -r .tag_name | sed 's/^v//')
GHORG_VERSION=$(curl -s https://api.github.com/repos/gabrie30/ghorg/releases/latest | jq -r .tag_name | sed 's/^v//')
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r .tag_name | sed 's/^v//')
PYTHON_VERSION=$(curl -s 'https://api.github.com/repos/python/cpython/tags?per_page=20' | jq -r '.[].name' | grep -E '^v3\.[0-9]+\.[0-9]+$' | sed 's/^v//' | sort -V | tail -n1)
PYTHON_VERSION_TO_USE="python${PYTHON_VERSION%.*}"

repo="${GITHUB_REPOSITORY:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"

# Fetch current GitHub variable values
gh_var() { gh variable get "$1" --repo "$repo" | grep -v '^$' | tail -n1; }

CHANGED=0
DRY_RUN=${DRY_RUN:-0}
CHANGE_LOG=""

log_version_update() {
  local log_issue_title="Version Update Log"
  local repo="${GITHUB_REPOSITORY:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
  local log_body="$1"
  local issue_number

  # Find or create the log issue
  issue_number=$(gh issue list --repo "$repo" --state open --search "$log_issue_title" --json number,title | jq -r ".[] | select(.title==\"$log_issue_title\") | .number")
  if [[ -z "$issue_number" ]]; then
    issue_url=$(gh issue create --repo "$repo" --title "$log_issue_title" --body "This issue tracks all automated version updates." | tail -n1)
    issue_number="${issue_url##*/}"
    # Assign the issue to the current user
    gh issue edit "$issue_number" --repo "$repo" --add-assignee "$(gh api user --jq .login)"
  fi

  # Add a comment with the update details (beautified with Markdown)
  gh issue comment "$issue_number" --repo "$repo" --body "$log_body"
}

update_var() {
  local var_name="$1"
  local new_value="$2"
  local current_value
  current_value=$(gh_var "$var_name" || true)
  if [[ "$current_value" != "$new_value" ]]; then
    echo "Updating $var_name: $current_value -> $new_value"
    if [[ "$DRY_RUN" == "0" ]]; then
      gh variable set "$var_name" --body "$new_value" --repo "$repo"
    fi
    CHANGED=1
    CHANGE_LOG+="| $var_name | $current_value | $new_value |"$'\n'
  else
    echo "$var_name unchanged ($new_value)"
  fi
}

update_var GCLOUD_VERSION "$GCLOUD_VERSION"
update_var PACKER_VERSION "$PACKER_VERSION"
update_var TERRAGRUNT_VERSION "$TERRAGRUNT_VERSION"
update_var TFLINT_VERSION "$TFLINT_VERSION"
update_var TFSEC_VERSION "$TFSEC_VERSION"
update_var GHORG_VERSION "$GHORG_VERSION"
update_var K9S_VERSION "$K9S_VERSION"
update_var PYTHON_VERSION "$PYTHON_VERSION"
update_var PYTHON_VERSION_TO_USE "$PYTHON_VERSION_TO_USE"

if [[ $CHANGED -eq 1 ]]; then
  if [[ "$DRY_RUN" == "0" ]]; then
    log_version_update $'### :sparkles: Automated Version Update :sparkles:\n\n**Date:** '"$(date -u)"$'\n\n| Variable | Old Version | New Version |\n|---|---|---|\n'"$CHANGE_LOG"
    echo "Triggering image-builder workflow..."
    gh workflow run image-builder.yml
  else
    echo "[DRY RUN] Would trigger image-builder workflow and log:\n$CHANGE_LOG"
  fi
else
  echo "No version changes detected. Workflow not triggered."
fi

echo "Done."

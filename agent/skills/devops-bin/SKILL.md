---
name: devops-bin-tools
description: Catalog of custom bash scripts in ~/.pi/agent/bin/ for DevOps, GitHub, and Kubernetes automation. Use this skill to understand which script to call via the bash tool.
---

# DevOps Bin Tools

You have access to several custom bash scripts located in `~/.pi/agent/bin/`. You can execute them using your `bash` tool by specifying the absolute path, e.g., `bash -c "~/.pi/agent/bin/gh-clone repo main"`.

## Available Scripts

### GitHub Operations (Hardcoded Org: Qoin-Digital-Indonesia unless specified)
*   `gh-clone <repo> <ref> [org]` - Clones a GitHub repository (single-branch). Default org: Qoin-Digital-Indonesia.
*   `gh-check-lang <repo> [branch]` - Checks the primary programming language of a GitHub repo. Default branch: staging.
*   `gh-get-file <repo> <ref> <file_path>` - Fetches a specific file from a GitHub repo using gh cli.
*   `gh-latest-tag <repo>` - Gets the latest release tag for a GitHub repo.
*   `check-deploy-repo <namespace> [org]` - Checks if deployments in a k8s namespace have corresponding repos in GitHub.

### Kubernetes Operations
*   `k8s-latest-tag <deployment> <namespace>` - Fetches the current image tag of a deployment in a given namespace.
*   `k8s-logs <pod_name> <namespace> [tail_lines]` - Gets logs for a pod.
*   `set-image <deployment> <namespace> <image_tag>` - Updates the image of a deployment.
*   `get-file-secret <namespace>` - Generates kubernetes secret yaml based on config files.
*   `patch-dotenv-go <namespace> <deployment>` - Patch deployment dengan volumeMount (tz-config, file-config-volume) dan volume (hostPath Asia/Jakarta, secret file-config-{deploy}). Juga export YAML ke `{deploy}_deployment.yaml`.
*   `match-secret <file>` - Matches secrets/envs.
*   `is-match <args>` / `is-match-ns <args>` - Utility scripts for matching deployments with repos.

### CI/CD & DevOps
*   `cicd-init` - Initializes CI/CD templates.
*   `devops-ci-py` - Python CI/CD utility.
*   `neo-s3` - Utility for interacting with Neo S3 storage.
*   `pi-cost` - Calculates pi cost/tokens.

### Core Utilities
*   `fd` - Fast find alternative.
*   `rg` - Ripgrep for fast searching.

## How to Use
Always use the `bash` tool to invoke these scripts.
Example: `~/.pi/agent/bin/gh-check-lang qoinplus-backend staging`

#!/usr/bin/env bash
set -euo pipefail

# ponytail: auto-detect language from config file name. No lang param needed.
DIR=${1?usage: generate.sh <deploy_dir> [namespace]}
NS=${2:-$(basename "$(dirname "$DIR")")}
APP=$(basename "$DIR")
ENV=${NS%%-*}   # production-ngenwal → production

# auto-detect: Go (.env.{env}) or dotnet (appsettings.{env}.json)
if [ -f "$DIR/appsettings.${ENV}.json" ]; then
  KEY="appsettings.${ENV}.json"
  SRC="$DIR/$KEY"
elif [ -f "$DIR/.env.${ENV}" ]; then
  KEY=".env"
  SRC="$DIR/.env.${ENV}"
else
  echo "? no appsettings.${ENV}.json or .env.${ENV} in $DIR"
  exit 1
fi

NAME="file-config-${APP}"
OUTPUT="$(dirname "$DIR")/file-config-${APP}_secret.yaml"

# ponytail: kubectl dry-run is shortest path. Fallback to base64 if kubectl missing.
if command -v kubectl &>/dev/null; then
  kubectl create secret generic "$NAME" \
    --namespace="$NS" \
    --from-file="$KEY=$SRC" \
    --dry-run=client -o yaml > "$OUTPUT"
else
  B64=$(base64 < "$SRC" | tr -d '\n')
  cat > "$OUTPUT" <<EOF
apiVersion: v1
kind: Secret
metadata:
  annotations: {}
  name: ${NAME}
  namespace: ${NS}
type: Opaque
data:
  ${KEY}: ${B64}
EOF
fi
echo "? $OUTPUT"
#!/bin/bash

set -euo pipefail

echo "$UPF_IPV4_ADDRESS"  oai-spgwu >> /etc/hosts

exec /openair-smf/bin/entrypoint.sh "$@"

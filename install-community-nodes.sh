#!/bin/sh
set -e

N8N_NODES_DIR=/home/node/.n8n/nodes

mkdir -p $N8N_NODES_DIR
cd $N8N_NODES_DIR

echo "Installing community nodes into $N8N_NODES_DIR"

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    \#*|'') continue ;;
  esac

  node=$(echo "$line" | xargs)
  echo "Installing $node"
  npm install "$node"
done < /tmp/community-nodes.txt

chown -R node:node /home/node/.n8n

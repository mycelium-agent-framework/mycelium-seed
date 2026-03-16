#!/usr/bin/env bash
# Initialize a content ring in the current directory.
# Usage: /path/to/init-content-ring.sh <ring-name>
#
# This stamps out the mycelium content ring structure (no bridge_buffer, no global_tags).
# Run this inside an empty or freshly cloned repo.
set -euo pipefail

RING_NAME="${1:?Usage: init-content-ring.sh <ring-name>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SEED_DIR="$(dirname "$SCRIPT_DIR")"

echo "Initializing content ring '$RING_NAME'..."

# Create directories
mkdir -p .mycelium .githooks schemas journals pages channels/general

# Copy schemas
cp "$SEED_DIR/schemas/"*.json schemas/

# Copy hooks
cp "$SEED_DIR/.githooks/pre-commit" .githooks/pre-commit
cp "$SEED_DIR/.githooks/post-checkout" .githooks/post-checkout
chmod +x .githooks/*

# Copy Makefile
cp "$SEED_DIR/Makefile" Makefile

# Gitkeeps
touch .mycelium/.gitkeep journals/.gitkeep pages/.gitkeep channels/general/.gitkeep

# .gitignore
cat > .gitignore << 'GITIGNORE'
.mycelium/index.sqlite
.mycelium/index.sqlite-wal
.mycelium/index.sqlite-shm
.DS_Store
.claude/agents/
.claude/skills/
.idea/
.vscode/
*.swp
__pycache__/
*.pyc
.venv/
GITIGNORE

# .mycelium/.gitignore
cat > .mycelium/.gitignore << 'GITIGNORE'
index.sqlite
index.sqlite-wal
index.sqlite-shm
GITIGNORE

# MEMORY.md
cat > MEMORY.md << EOF
# ${RING_NAME} — Memory Index

<!-- Distilled wisdom for this ring -->
EOF

# manifest.json (content ring — minimal, no pops/rings)
cat > manifest.json << EOF
{
  "agent_name": "Vivian",
  "version": "0.1.0",
  "pops": [],
  "rings": [],
  "channels": [
    {
      "name": "general",
      "ring": "${RING_NAME}",
      "last_active": null,
      "is_active": true
    }
  ],
  "active_ring": null
}
EOF

# SOUL.md template
cat > SOUL.md << EOF
# SOUL.md — Vivian (${RING_NAME})

## Identity & Persona

<!-- Describe Vivian's voice and manner in this ring context -->

## Gospel Rules (Non-Negotiable)

1. Never fabricate memories. If you do not know, say so.
2. Never expose content from one ring to another unless explicitly bridged.
3. Always attribute the origin PoP when creating spores.
4. Persist decisions and discoveries as structured spores, not ephemeral chat.
5. Respect the ring boundary — a mounted ring is the only accessible ring.

## Mycelial Protocol

- **Ring integrity**: Content stays in this ring.
- **Memory sharding**: Write only to your own \`*-{device_id}.jsonl\` files.
- **Handoff spores**: Generate a session recap spore on every session close.

## Memory Protocol

- **Transcripts**: Every conversation turn is appended to the active channel transcript.
- **Structured memory**: Promoted explicitly ("remember this") or by classification.
- **Compaction**: Old spores are summarized and archived, never deleted.
- **SQLite index**: Rebuilt from JSONL on launch — JSONL is the source of truth.

## Capabilities (${RING_NAME})

<!-- What can Vivian do in this ring? -->

## Context Window Priming

<!-- Key facts for system prompt -->
EOF

# Configure git hooks
git config core.hooksPath .githooks 2>/dev/null || true

echo ""
echo "Content ring '${RING_NAME}' initialized."
echo "  - Edit SOUL.md with ring-specific personality"
echo "  - Run 'make setup' to configure hooks and agents"
echo "  - Register this ring in Ring 0's manifest.json"

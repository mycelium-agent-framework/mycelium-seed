# Mycelium Seed

Template repository for stamping out new agent instances (Ring 0) in the Mycelium Agent Framework.

## Quick Start

```bash
# 1. Create a new repo from this template on GitHub
# 2. Clone it locally
git clone git@github.com:youruser/agent-control.git
cd agent-control

# 3. Run setup (configures git hooks, copies agent files)
make setup

# 4. Fill in SOUL.md from the template
cp SOUL.md.template SOUL.md
# Edit SOUL.md with your agent's identity

# 5. Configure manifest.json with your PoPs and rings
```

## Directory Structure

```
├── SOUL.md.template       Agent identity template
├── MEMORY.md              Distilled wisdom index
├── manifest.json          PoP ownership, channels, ring registry
├── global_tags.json       Canonical tag registry
├── bridge_buffer/         Cross-ring nutrient transport
├── .mycelium/             Memory spore storage (sharded by device)
├── journals/              Logseq-style daily journals
├── pages/                 Permanent knowledge nodes
├── channels/
│   └── default/           Transcript files (sharded by device)
├── .githooks/
│   ├── pre-commit         Validates JSONL before commit
│   └── post-checkout      Rehydrates SQLite index
├── schemas/               JSON Schema for all data contracts
└── Makefile               `make setup` for hooks + agents
```

## Data Contracts

All data is stored as JSONL (one JSON object per line), sharded by writer device to prevent Git merge conflicts.

- **Spores** (`.mycelium/memory-{device_id}.jsonl`): Atomic memory units — tasks, notes, decisions, discoveries, handoff recaps
- **Transcripts** (`channels/{name}/transcript-{device_id}.jsonl`): Conversation turns
- **REF files** (`channels/{name}/REF_*.json`): References to external artifacts

Schemas defined as Pydantic models (source of truth) and exported as JSON Schema for cross-platform validation.

## Memory Sharding

Each Point of Presence writes only to its own files:
- `memory-osx-desktop.jsonl` — macOS writes here
- `memory-android-phone.jsonl` — Android writes here

This eliminates Git merge conflicts on concurrent writes. A local SQLite index (gitignored) provides unified queries across all shards.

## Ring Architecture

- **Ring 0** (this repo): Core identity, switchboard, bridge buffer
- **Content Rings**: Separate repos for different life contexts (personal, work, etc.)
- Ring boundaries are hard — content never crosses without explicit bridging through Ring 0

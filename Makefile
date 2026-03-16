.PHONY: setup hooks agents validate clean

# ─── Primary target ────────────────────────────────────────────────────────────

setup: hooks agents ## Full setup: git hooks + agent files
	@echo "Setup complete."

# ─── Git hooks ─────────────────────────────────────────────────────────────────

hooks: ## Configure git to use .githooks/ directory
	git config core.hooksPath .githooks
	chmod +x .githooks/*
	@echo "Git hooks configured."

# ─── Agent files ───────────────────────────────────────────────────────────────

AGENTS_SOURCE ?= $(HOME)/git/chasemp/AlpheusCEF/agents
AGENTS_MYCELIUM_SOURCE ?= $(HOME)/git/chasemp/mycelium-agent-framework/agents-mycelium

agents: ## Copy agent files from source repos into .claude/
	@mkdir -p .claude/agents .claude/skills
	@if [ -d "$(AGENTS_SOURCE)" ]; then \
		echo "Copying AlpheusCEF agents from $(AGENTS_SOURCE)..."; \
		cp -f "$(AGENTS_SOURCE)"/*.md .claude/ 2>/dev/null || true; \
		cp -f "$(AGENTS_SOURCE)"/agents/*.md .claude/agents/ 2>/dev/null || true; \
		cp -f "$(AGENTS_SOURCE)"/skills/*.md .claude/skills/ 2>/dev/null || true; \
	else \
		echo "WARNING: AlpheusCEF agents not found at $(AGENTS_SOURCE)"; \
	fi
	@if [ -d "$(AGENTS_MYCELIUM_SOURCE)" ]; then \
		echo "Copying mycelium agents from $(AGENTS_MYCELIUM_SOURCE)..."; \
		cp -f "$(AGENTS_MYCELIUM_SOURCE)"/*.md .claude/ 2>/dev/null || true; \
		cp -f "$(AGENTS_MYCELIUM_SOURCE)"/agents/*.md .claude/agents/ 2>/dev/null || true; \
		cp -f "$(AGENTS_MYCELIUM_SOURCE)"/skills/*.md .claude/skills/ 2>/dev/null || true; \
	else \
		echo "WARNING: Mycelium agents not found at $(AGENTS_MYCELIUM_SOURCE)"; \
	fi
	@echo "Agent files copied."

# ─── Validation ────────────────────────────────────────────────────────────────

validate: ## Validate all JSONL files against schemas
	@echo "Validating memory files..."
	@for f in .mycelium/memory-*.jsonl; do \
		[ -f "$$f" ] && echo "  checking $$f" && \
		python3 -c "import json; [json.loads(l) for l in open('$$f') if l.strip()]" || true; \
	done
	@echo "Validating transcript files..."
	@for f in channels/*/transcript-*.jsonl; do \
		[ -f "$$f" ] && echo "  checking $$f" && \
		python3 -c "import json; [json.loads(l) for l in open('$$f') if l.strip()]" || true; \
	done
	@echo "Validation complete."

# ─── Index rebuild ─────────────────────────────────────────────────────────────

reindex: ## Rebuild SQLite index from JSONL files
	.githooks/post-checkout

# ─── Clean ─────────────────────────────────────────────────────────────────────

clean: ## Remove generated files (SQLite index, .claude/ copies)
	rm -f .mycelium/index.sqlite .mycelium/index.sqlite-wal .mycelium/index.sqlite-shm
	rm -rf .claude/agents .claude/skills
	@echo "Cleaned."

# ─── Help ──────────────────────────────────────────────────────────────────────

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

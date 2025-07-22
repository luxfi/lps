# Makefile for Lux Improvement Proposals (LIPs)
# This file provides convenient shortcuts for common LIP management tasks

.PHONY: help new validate check-links update-index validate-all clean permissions

# Default target - show help
help:
	@echo "Lux Improvement Proposals (LIPs) Management"
	@echo "==========================================="
	@echo ""
	@echo "Available commands:"
	@echo "  make new           - Create a new LIP using the interactive wizard"
	@echo "  make validate      - Validate a specific LIP file (use FILE=path/to/lip.md)"
	@echo "  make validate-all  - Validate all LIP files in the repository"
	@echo "  make check-links   - Check all links in LIP files"
	@echo "  make update-index  - Update the LIP index in README.md"
	@echo "  make permissions   - Fix script permissions (make them executable)"
	@echo "  make clean         - Clean up temporary files"
	@echo ""
	@echo "Examples:"
	@echo "  make new                              # Create a new LIP"
	@echo "  make validate FILE=LIPs/lip-20.md     # Validate a specific LIP"
	@echo "  make validate-all                     # Validate all LIPs"
	@echo ""

# Create a new LIP using the interactive wizard
new:
	@echo "Starting LIP creation wizard..."
	@./scripts/new-lip.sh

# Validate a specific LIP file
# Usage: make validate FILE=LIPs/lip-20.md
validate:
ifndef FILE
	@echo "Error: Please specify a file to validate"
	@echo "Usage: make validate FILE=path/to/lip.md"
	@echo "Example: make validate FILE=LIPs/lip-20.md"
	@exit 1
else
	@echo "Validating $(FILE)..."
	@./scripts/validate-lip.sh $(FILE)
endif

# Validate all LIP files
validate-all:
	@echo "Validating all LIP files..."
	@for file in LIPs/lip-*.md; do \
		if [ -f "$$file" ]; then \
			echo "Checking $$file..."; \
			./scripts/validate-lip.sh "$$file" || exit 1; \
		fi \
	done
	@echo "All LIP files validated successfully!"

# Check all links in LIP files
check-links:
	@echo "Checking all links in LIP files..."
	@./scripts/check-links.sh

# Update the LIP index in README.md
update-index:
	@echo "Updating LIP index..."
	@python3 ./scripts/update-index.py

# Fix script permissions (make them executable)
permissions:
	@echo "Setting executable permissions on scripts..."
	@chmod +x scripts/*.sh
	@echo "Permissions updated!"

# Clean up temporary files
clean:
	@echo "Cleaning up temporary files..."
	@find . -name "*.tmp" -delete
	@find . -name "*.bak" -delete
	@find . -name ".DS_Store" -delete
	@echo "Cleanup complete!"

# Shortcut aliases
n: new
v: validate
va: validate-all
cl: check-links
ui: update-index
p: permissions

# Advanced targets for maintainers

# Run all validation checks
.PHONY: check-all
check-all: validate-all check-links
	@echo "All validation checks passed!"

# Prepare for PR submission
.PHONY: pre-pr
pre-pr: validate-all check-links update-index
	@echo "Pre-PR checks complete!"
	@echo "Your changes are ready for submission."

# Show current LIP statistics
.PHONY: stats
stats:
	@echo "LIP Statistics"
	@echo "=============="
	@echo "Total LIPs: $$(ls -1 LIPs/lip-*.md 2>/dev/null | wc -l)"
	@echo ""
	@echo "By Status:"
	@for status in Draft Review "Last Call" Final Withdrawn Stagnant; do \
		count=$$(grep -l "status: $$status" LIPs/lip-*.md 2>/dev/null | wc -l); \
		printf "  %-12s %s\n" "$$status:" "$$count"; \
	done
	@echo ""
	@echo "By Type:"
	@for type in "Standards Track" Meta Informational; do \
		count=$$(grep -l "type: $$type" LIPs/lip-*.md 2>/dev/null | wc -l); \
		printf "  %-12s %s\n" "$$type:" "$$count"; \
	done

# List all LIPs with their titles
.PHONY: list
list:
	@echo "Current LIPs:"
	@echo "============="
	@for file in LIPs/lip-*.md; do \
		if [ -f "$$file" ]; then \
			lip=$$(grep "^lip:" "$$file" | cut -d' ' -f2); \
			title=$$(grep "^title:" "$$file" | cut -d' ' -f2-); \
			printf "LIP-%-4s %s\n" "$$lip:" "$$title"; \
		fi \
	done

# Watch for changes and auto-validate (requires entr)
.PHONY: watch
watch:
	@command -v entr >/dev/null 2>&1 || { echo "Error: 'entr' is required but not installed. Install with: brew install entr"; exit 1; }
	@echo "Watching for changes in LIPs directory..."
	@echo "Press Ctrl+C to stop"
	@find LIPs -name "*.md" | entr -c make validate-all

# Create a draft from template
.PHONY: draft
draft:
	@cp LIPs/TEMPLATE.md LIPs/lip-draft.md
	@echo "Created LIPs/lip-draft.md from template"
	@echo "Edit this file and submit as a PR to get your LIP number"

# Development helpers
.PHONY: setup
setup: permissions
	@echo "Checking Python 3..."
	@command -v python3 >/dev/null 2>&1 || { echo "Warning: Python 3 is required for update-index"; }
	@echo "Setup complete!"

# Show recent changes
.PHONY: recent
recent:
	@echo "Recently modified LIPs (last 10):"
	@ls -lt LIPs/lip-*.md 2>/dev/null | head -10 | awk '{print $$9}'
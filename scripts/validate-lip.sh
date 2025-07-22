#!/bin/bash

# LIP Validation Script
# Validates that a LIP file meets all formatting and content requirements

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if file is provided
if [ $# -eq 0 ]; then
    print_error "No file provided"
    echo "Usage: $0 <lip-file.md>"
    exit 1
fi

LIP_FILE=$1

# Check if file exists
if [ ! -f "$LIP_FILE" ]; then
    print_error "File not found: $LIP_FILE"
    exit 1
fi

echo "Validating LIP: $LIP_FILE"
echo "================================"

ERRORS=0
WARNINGS=0

# Check YAML frontmatter
echo -n "Checking YAML frontmatter... "
if ! grep -q "^---$" "$LIP_FILE"; then
    print_error "Missing YAML frontmatter"
    ((ERRORS++))
else
    # Extract frontmatter
    FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$LIP_FILE")
    
    # Check required fields
    for field in "lip" "title" "description" "author" "status" "type" "created"; do
        if ! echo "$FRONTMATTER" | grep -q "^$field:"; then
            print_error "Missing required field: $field"
            ((ERRORS++))
        fi
    done
    
    # Check if Standards Track has category
    if echo "$FRONTMATTER" | grep -q "^type: Standards Track"; then
        if ! echo "$FRONTMATTER" | grep -q "^category:"; then
            print_error "Standards Track LIPs must have a category"
            ((ERRORS++))
        fi
    fi
    
    if [ $ERRORS -eq 0 ]; then
        print_success "Valid"
    fi
fi

# Check required sections
echo "Checking required sections..."
REQUIRED_SECTIONS=("Abstract" "Motivation" "Specification" "Rationale" "Backwards Compatibility" "Security Considerations")

for section in "${REQUIRED_SECTIONS[@]}"; do
    echo -n "  Checking $section... "
    if ! grep -q "^## $section" "$LIP_FILE"; then
        print_error "Missing required section: $section"
        ((ERRORS++))
    else
        print_success "Found"
    fi
done

# Check abstract length
echo -n "Checking abstract length... "
ABSTRACT=$(sed -n '/^## Abstract$/,/^##/p' "$LIP_FILE" | sed '1d;$d')
WORD_COUNT=$(echo "$ABSTRACT" | wc -w)
if [ $WORD_COUNT -gt 300 ]; then
    print_warning "Abstract is $WORD_COUNT words (recommended: ~200)"
    ((WARNINGS++))
else
    print_success "OK ($WORD_COUNT words)"
fi

# Check for test cases in Standards Track
if grep -q "^type: Standards Track" "$LIP_FILE"; then
    echo -n "Checking for test cases... "
    if ! grep -q "^## Test Cases" "$LIP_FILE"; then
        print_warning "Standards Track LIPs should include test cases"
        ((WARNINGS++))
    else
        print_success "Found"
    fi
fi

# Check for proper markdown formatting
echo "Checking markdown formatting..."

# Check for broken links
echo -n "  Checking for broken internal links... "
BROKEN_LINKS=$(grep -o '\[.*\](.*)' "$LIP_FILE" | grep -v "http" | grep -c "]()" || true)
if [ $BROKEN_LINKS -gt 0 ]; then
    print_warning "Found $BROKEN_LINKS potentially broken links"
    ((WARNINGS++))
else
    print_success "OK"
fi

# Check code blocks
echo -n "  Checking code blocks... "
if grep -q '```' "$LIP_FILE"; then
    # Check if code blocks have language specified
    if grep -q '^```$' "$LIP_FILE"; then
        print_warning "Code blocks should specify language"
        ((WARNINGS++))
    else
        print_success "OK"
    fi
fi

# Check LIP number format
echo -n "Checking LIP number format... "
FILENAME=$(basename "$LIP_FILE")
if [[ $FILENAME =~ ^lip-[0-9]+\.md$ ]] || [[ $FILENAME == "lip-draft.md" ]]; then
    print_success "Valid"
else
    print_error "Invalid filename format. Should be 'lip-N.md' or 'lip-draft.md'"
    ((ERRORS++))
fi

# Summary
echo "================================"
echo "Validation Summary:"
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"

if [ $ERRORS -gt 0 ]; then
    print_error "Validation failed with $ERRORS errors"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    print_warning "Validation passed with $WARNINGS warnings"
    exit 0
else
    print_success "Validation passed!"
    exit 0
fi
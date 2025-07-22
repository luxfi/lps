#!/usr/bin/env python3

"""
Update Index Script
Automatically updates the LIP index in README.md based on LIP files
"""

import os
import re
import yaml
from datetime import datetime
from pathlib import Path

def extract_frontmatter(filepath):
    """Extract YAML frontmatter from a markdown file"""
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Find frontmatter between --- markers
    match = re.search(r'^---\s*\n(.*?)\n---\s*\n', content, re.MULTILINE | re.DOTALL)
    if match:
        try:
            return yaml.safe_load(match.group(1))
        except:
            print(f"Error parsing YAML in {filepath}")
            return None
    return None

def get_all_lips(directory='LIPs'):
    """Get all LIP files and their metadata"""
    lips = []
    
    for filename in os.listdir(directory):
        if filename.endswith('.md') and filename.startswith('lip-'):
            filepath = os.path.join(directory, filename)
            frontmatter = extract_frontmatter(filepath)
            
            if frontmatter:
                # Extract LIP number from filename
                match = re.search(r'lip-(\d+)\.md', filename)
                if match:
                    lip_number = int(match.group(1))
                    frontmatter['number'] = lip_number
                    frontmatter['filename'] = filename
                    lips.append(frontmatter)
    
    # Sort by LIP number
    lips.sort(key=lambda x: x['number'])
    return lips

def categorize_lips(lips):
    """Categorize LIPs by type and category"""
    categories = {
        'meta': [],
        'core': [],
        'networking': [],
        'interface': [],
        'lrc': [],
        'informational': []
    }
    
    for lip in lips:
        lip_type = lip.get('type', '').lower()
        category = lip.get('category', '').lower()
        
        if lip_type == 'meta':
            categories['meta'].append(lip)
        elif lip_type == 'informational':
            categories['informational'].append(lip)
        elif lip_type == 'standards track':
            if category == 'core':
                categories['core'].append(lip)
            elif category == 'networking':
                categories['networking'].append(lip)
            elif category == 'interface':
                categories['interface'].append(lip)
            elif category == 'lrc':
                categories['lrc'].append(lip)
    
    return categories

def format_table_row(lip):
    """Format a LIP as a markdown table row"""
    number = lip['number']
    title = lip.get('title', 'Untitled')
    authors = lip.get('author', 'Unknown')
    lip_type = lip.get('type', 'Unknown')
    category = lip.get('category', '-')
    status = lip.get('status', 'Unknown')
    
    # Clean up authors (remove emails/github handles for brevity)
    authors = re.sub(r'\s*\([^)]*\)', '', authors)
    authors = re.sub(r'\s*<[^>]*>', '', authors)
    
    # Truncate long titles
    if len(title) > 50:
        title = title[:47] + '...'
    
    return f"| [LIP-{number}](./LIPs/lip-{number}.md) | {title} | {authors} | {lip_type} | {category} | {status} |"

def generate_index_section():
    """Generate the index section for README"""
    lips = get_all_lips()
    
    if not lips:
        return "No LIPs found."
    
    # Main table
    output = ["## Current Proposals\n"]
    output.append("| Number | Title | Author(s) | Type | Category | Status |")
    output.append("|:-------|:------|:----------|:-----|:---------|:-------|")
    
    for lip in lips:
        output.append(format_table_row(lip))
    
    # LRC-specific table
    lrcs = [lip for lip in lips if lip.get('category', '').lower() == 'lrc']
    if lrcs:
        output.append("\n### Notable LRCs (Application Standards)\n")
        output.append("| LRC Number | LIP | Title | Status |")
        output.append("|:-----------|:----|:------|:-------|")
        
        for lrc in lrcs:
            number = lrc['number']
            title = lrc.get('title', 'Untitled')
            status = lrc.get('status', 'Unknown')
            
            # Extract LRC number from title if present
            lrc_match = re.search(r'LRC-(\d+)', title)
            if lrc_match:
                lrc_num = f"LRC-{lrc_match.group(1)}"
            else:
                lrc_num = f"LRC-{number}"
            
            output.append(f"| {lrc_num} | [LIP-{number}](./LIPs/lip-{number}.md) | {title} | {status} |")
    
    return '\n'.join(output)

def update_readme():
    """Update the README.md file with the new index"""
    readme_path = 'README.md'
    
    # Read current README
    with open(readme_path, 'r') as f:
        content = f.read()
    
    # Find the section to replace
    start_marker = "## Current Proposals"
    end_marker = "## Contributing"
    
    start_idx = content.find(start_marker)
    end_idx = content.find(end_marker)
    
    if start_idx == -1 or end_idx == -1:
        print("Could not find the index section in README.md")
        return False
    
    # Generate new index
    new_index = generate_index_section()
    
    # Replace the section
    new_content = content[:start_idx] + new_index + "\n\n" + content[end_idx:]
    
    # Write back
    with open(readme_path, 'w') as f:
        f.write(new_content)
    
    print(f"README.md updated successfully!")
    return True

def generate_statistics():
    """Generate statistics about LIPs"""
    lips = get_all_lips()
    categories = categorize_lips(lips)
    
    print("\nLIP Statistics:")
    print(f"  Total LIPs: {len(lips)}")
    print(f"  Meta: {len(categories['meta'])}")
    print(f"  Core: {len(categories['core'])}")
    print(f"  Networking: {len(categories['networking'])}")
    print(f"  Interface: {len(categories['interface'])}")
    print(f"  LRC: {len(categories['lrc'])}")
    print(f"  Informational: {len(categories['informational'])}")
    
    # Status breakdown
    status_count = {}
    for lip in lips:
        status = lip.get('status', 'Unknown')
        status_count[status] = status_count.get(status, 0) + 1
    
    print("\nStatus Breakdown:")
    for status, count in sorted(status_count.items()):
        print(f"  {status}: {count}")

if __name__ == "__main__":
    print("Updating LIP index...")
    
    # Change to script directory
    script_dir = Path(__file__).parent
    os.chdir(script_dir.parent)
    
    # Update README
    if update_readme():
        generate_statistics()
    else:
        print("Failed to update README.md")
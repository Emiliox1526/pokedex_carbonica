#!/usr/bin/env python3
"""
Validation script for ARB localization files.
Checks for duplicate keys, JSON validity, and proper formatting.
"""

import json
import sys
import re
from pathlib import Path
from collections import Counter


def validate_arb_file(filepath):
    """
    Validates an ARB (Application Resource Bundle) file.
    
    Checks:
    - Valid JSON format
    - No duplicate top-level keys
    - Proper structure with translation keys and metadata
    
    Args:
        filepath: Path to the ARB file
        
    Returns:
        tuple: (is_valid, issues_list)
    """
    print(f"\n{'='*70}")
    print(f"Validating: {filepath}")
    print('='*70)
    
    issues = []
    
    # Read file
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.split('\n')
    except Exception as e:
        issues.append(f"Error reading file: {e}")
        return False, issues
    
    # Validate JSON structure
    try:
        data = json.loads(content)
        translation_keys = [k for k in data.keys() if not k.startswith('@')]
        metadata_keys = [k for k in data.keys() if k.startswith('@')]
        
        print(f"✓ Valid JSON structure")
        print(f"  - {len(translation_keys)} translation keys")
        print(f"  - {len(metadata_keys)} metadata entries")
        
    except json.JSONDecodeError as e:
        issues.append(f"JSON Parse Error at line {e.lineno}, col {e.colno}: {e.msg}")
        print(f"✗ Invalid JSON: {e}")
        return False, issues
    
    # Check for duplicate top-level keys by analyzing text
    # (Python's json.loads would fail if there were exact duplicates at same level)
    key_pattern = r'^\s*"([^"@][^"]*)"\s*:'
    key_occurrences = {}
    
    for i, line in enumerate(lines, 1):
        match = re.match(key_pattern, line)
        if match:
            key = match.group(1)
            # Calculate indentation to detect nesting level
            indent = len(line) - len(line.lstrip())
            
            # Only track top-level keys (indent <= 2 spaces)
            if indent <= 2:
                if key not in key_occurrences:
                    key_occurrences[key] = []
                key_occurrences[key].append(i)
    
    # Find any keys that appear more than once at top level
    duplicates = {k: v for k, v in key_occurrences.items() if len(v) > 1}
    
    if duplicates:
        for key, line_nums in duplicates.items():
            issues.append(f"Duplicate top-level key '{key}' at lines: {', '.join(map(str, line_nums))}")
            print(f"✗ Duplicate key '{key}' found at lines: {', '.join(map(str, line_nums))}")
            for ln in line_nums:
                print(f"    Line {ln}: {lines[ln-1].strip()[:70]}")
    
    # Check for specific key if needed
    if 'allGenerations' in translation_keys:
        count = content.count('"allGenerations"')
        print(f"✓ Key 'allGenerations' found (appears {count} time(s) in file)")
    
    # Check for trailing commas before closing braces (JSON syntax error in strict mode)
    for i, line in enumerate(lines, 1):
        if re.match(r'^\s*,\s*[}\]]', line):
            issues.append(f"Line {i}: Invalid trailing comma before closing brace/bracket")
            print(f"✗ Line {i}: Trailing comma before closing brace/bracket")
    
    # Summary
    if not issues:
        print(f"\n✅ No issues found - file is properly formatted")
        return True, []
    else:
        print(f"\n❌ Found {len(issues)} issue(s)")
        return False, issues


def main():
    """Main validation function."""
    base_path = Path(__file__).parent / 'lib' / 'l10n'
    
    files_to_check = [
        base_path / 'app_en.arb',
        base_path / 'app_es.arb',
    ]
    
    all_valid = True
    all_issues = []
    
    for filepath in files_to_check:
        if not filepath.exists():
            print(f"\n❌ File not found: {filepath}")
            all_valid = False
            continue
        
        is_valid, issues = validate_arb_file(filepath)
        if not is_valid:
            all_valid = False
            all_issues.extend(issues)
    
    # Final summary
    print(f"\n{'='*70}")
    if all_valid:
        print("✅ ALL LOCALIZATION FILES ARE VALID")
        print("   No duplicate keys, proper JSON format, all checks passed.")
    else:
        print("❌ VALIDATION FAILED")
        print(f"   Found issues in one or more files:")
        for issue in all_issues:
            print(f"   - {issue}")
    print('='*70)
    
    return 0 if all_valid else 1


if __name__ == '__main__':
    sys.exit(main())

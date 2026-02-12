#!/usr/bin/env python3
"""
British English Conversion Script

Converts markdown files from American English to British English spelling
while preserving technical content (code blocks, URLs, inline code, etc.)
"""

import re
import sys
from pathlib import Path
from typing import List, Tuple

# Conversion rules: American → British
CONVERSIONS = {
    # -ize to -ise
    r'\boptimize\b': 'optimise',
    r'\boptimized\b': 'optimised',
    r'\boptimizing\b': 'optimising',
    r'\boptimization\b': 'optimisation',
    r'\boptimizations\b': 'optimisations',
    r'\bcustomize\b': 'customise',
    r'\bcustomized\b': 'customised',
    r'\bcustomizing\b': 'customising',
    r'\bcustomization\b': 'customisation',
    r'\borganize\b': 'organise',
    r'\borganized\b': 'organised',
    r'\borganizing\b': 'organising',
    r'\borganization\b': 'organisation',
    r'\borganizations\b': 'organisations',
    r'\brecognize\b': 'recognise',
    r'\brecognized\b': 'recognised',
    r'\bauthorize\b': 'authorise',
    r'\bauthorized\b': 'authorised',
    r'\bstandardize\b': 'standardise',
    r'\bstandardized\b': 'standardised',
    r'\bminimize\b': 'minimise',
    r'\bminimized\b': 'minimised',
    r'\bmaximize\b': 'maximise',
    r'\bmaximized\b': 'maximised',
    r'\bvisualize\b': 'visualise',
    r'\bvisualization\b': 'visualisation',

    # -or to -our
    r'\bcolor\b': 'colour',
    r'\bcolored\b': 'coloured',
    r'\bcolors\b': 'colours',
    r'\bfavor\b': 'favour',
    r'\bfavors\b': 'favours',
    r'\bhonor\b': 'honour',
    r'\bbehavior\b': 'behaviour',
    r'\bbehaviors\b': 'behaviours',

    # -er to -re
    r'\bcenter\b': 'centre',
    r'\bcentered\b': 'centred',

    # Other patterns
    r'\blicense\b(?=\s+details|\s+file|\s+\.)': 'licence',  # Noun only
}

# Special cases that should NOT be converted (context-aware)
PRESERVE_PATTERNS = [
    r'GitHub organization',
    r'github organization',
    r'organization cloner',
    r'organization secrets',
    r'color:#[0-9A-Fa-f]{3,6}',  # Mermaid CSS
    r'color\s*=\s*["\']',  # HTML/XML color attribute
]


def find_protected_regions(content: str) -> List[Tuple[int, int, str]]:
    """
    Identify all regions in the markdown that should not be converted.
    Returns list of (start_pos, end_pos, type) tuples.
    """
    regions = []

    # Find code blocks (highest priority, multiline)
    for match in re.finditer(r'```.*?```', content, re.DOTALL):
        regions.append((match.start(), match.end(), 'code_block'))

    # Find inline code
    for match in re.finditer(r'`[^`\n]+`', content):
        regions.append((match.start(), match.end(), 'inline_code'))

    # Find URLs
    for match in re.finditer(r'https?://[^\s)\]]+', content):
        regions.append((match.start(), match.end(), 'url'))

    # Find Mermaid CSS color properties
    for match in re.finditer(r'color:#[0-9A-Fa-f]{3,6}', content):
        regions.append((match.start(), match.end(), 'mermaid_css'))

    # Find HTML color attributes
    for match in re.finditer(r'color\s*=\s*["\'][^"\']*["\']', content):
        regions.append((match.start(), match.end(), 'html_color'))

    # Sort by start position
    regions.sort(key=lambda x: x[0])

    # Merge overlapping regions
    return merge_overlapping_regions(regions)


def merge_overlapping_regions(regions: List[Tuple[int, int, str]]) -> List[Tuple[int, int, str]]:
    """Merge overlapping or nested protected regions."""
    if not regions:
        return []

    merged = [regions[0]]

    for current in regions[1:]:
        last = merged[-1]

        # If current region overlaps with last, extend last region
        if current[0] <= last[1]:
            merged[-1] = (last[0], max(last[1], current[1]), last[2])
        else:
            merged.append(current)

    return merged


def is_protected(position: int, protected_regions: List[Tuple[int, int, str]]) -> bool:
    """Check if a position is within any protected region."""
    for start, end, _ in protected_regions:
        if start <= position < end:
            return True
    return False


def should_preserve_context(text: str, match_start: int, match_end: int) -> bool:
    """
    Check if the matched text should be preserved based on context.
    E.g., "GitHub organization" should not be converted.
    """
    # Get surrounding context (100 chars before and after)
    context_start = max(0, match_start - 100)
    context_end = min(len(text), match_end + 100)
    context = text[context_start:context_end]

    # Check against preserve patterns
    for pattern in PRESERVE_PATTERNS:
        if re.search(pattern, context, re.IGNORECASE):
            return True

    return False


def convert_text(content: str, dry_run: bool = False) -> Tuple[str, int]:
    """
    Convert American English to British English in markdown content.
    Returns (converted_content, conversion_count).
    """
    # Find all protected regions first
    protected_regions = find_protected_regions(content)

    result = content
    conversion_count = 0

    # Apply each conversion rule
    for american_pattern, british_replacement in CONVERSIONS.items():
        matches = list(re.finditer(american_pattern, result, re.IGNORECASE))

        # Process matches in reverse order to maintain position indices
        for match in reversed(matches):
            match_start = match.start()
            match_end = match.end()

            # Skip if in protected region
            if is_protected(match_start, protected_regions):
                continue

            # Skip if should be preserved based on context
            if should_preserve_context(result, match_start, match_end):
                continue

            # Get the matched text to preserve case
            matched_text = match.group(0)

            # Determine if first letter is uppercase
            if matched_text[0].isupper():
                replacement = british_replacement.capitalize()
            else:
                replacement = british_replacement

            # Apply replacement
            result = result[:match_start] + replacement + result[match_end:]
            conversion_count += 1

    return result, conversion_count


def convert_file(file_path: Path, dry_run: bool = False) -> Tuple[bool, int]:
    """
    Convert a single markdown file.
    Returns (success, conversion_count).
    """
    try:
        # Read file
        with open(file_path, 'r', encoding='utf-8') as f:
            original_content = f.read()

        # Convert
        converted_content, conversion_count = convert_text(original_content, dry_run)

        # Write back if not dry-run and changes were made
        if not dry_run and converted_content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(converted_content)
            print(f"✓ Converted {file_path.name}: {conversion_count} changes")
        elif dry_run and conversion_count > 0:
            print(f"[DRY RUN] {file_path.name}: {conversion_count} changes would be made")
        elif conversion_count == 0:
            print(f"  {file_path.name}: no changes needed")

        return True, conversion_count

    except Exception as e:
        print(f"✗ Error processing {file_path}: {e}", file=sys.stderr)
        return False, 0


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description='Convert markdown files from American to British English'
    )
    parser.add_argument(
        'files',
        nargs='+',
        type=Path,
        help='Markdown files to convert'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be changed without modifying files'
    )

    args = parser.parse_args()

    total_conversions = 0
    successful_files = 0
    failed_files = 0

    print(f"{'DRY RUN: ' if args.dry_run else ''}Converting {len(args.files)} file(s)...\n")

    for file_path in args.files:
        if not file_path.exists():
            print(f"✗ File not found: {file_path}", file=sys.stderr)
            failed_files += 1
            continue

        success, count = convert_file(file_path, args.dry_run)

        if success:
            successful_files += 1
            total_conversions += count
        else:
            failed_files += 1

    print(f"\n{'DRY RUN ' if args.dry_run else ''}Summary:")
    print(f"  Files processed: {successful_files}")
    print(f"  Files failed: {failed_files}")
    print(f"  Total conversions: {total_conversions}")

    return 0 if failed_files == 0 else 1


if __name__ == '__main__':
    sys.exit(main())

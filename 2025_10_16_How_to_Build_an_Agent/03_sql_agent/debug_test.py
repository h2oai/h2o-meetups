#!/usr/bin/env python3
"""Debug script to test the SQL agent and see what's returned."""

import sys
from pathlib import Path

# Add parent directory to path
parent_dir = Path(__file__).parent.parent
sys.path.insert(0, str(parent_dir))

from sql_agent import run_sql_agent

# Run the agent
result = run_sql_agent(
    question="Which artist has the most albums?",
    max_iterations=3,
    verbose=True  # Enable verbose to see what's happening
)

print("\n" + "="*70)
print("RESULT DICTIONARY KEYS:")
print("="*70)
print(f"Keys in result: {list(result.keys())}")

print("\n" + "="*70)
print("RESULT CONTENTS:")
print("="*70)
for key, value in result.items():
    print(f"\n{key}: {value}")

"""
CLI entry point for the SQL agent.

This module allows the agent to be run as:
    python -m sql_agent "Your question here"
"""

import sys
from .agent import main

if __name__ == "__main__":
    sys.exit(main())

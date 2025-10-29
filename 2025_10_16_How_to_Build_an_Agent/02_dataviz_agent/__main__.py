"""
Entry point for running the dataviz agent from command line.

Usage:
    python -m dataviz_agent data.csv "Show sales trends"
"""

import sys
from .agent import main

if __name__ == "__main__":
    sys.exit(main())

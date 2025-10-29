"""
Text-to-SQL Agent with Triple Reflection Pattern.

This package implements a secure, production-ready SQL agent for the Chinook database
that uses a triple reflection pattern for:
1. Intent triage and security validation
2. SQL query generation and validation
3. Answer formatting and quality assurance

Example:
    >>> from sql_agent import run_sql_agent
    >>> result = run_sql_agent(
    ...     question="Which artist has the most albums?",
    ...     db_path="chinook.db"
    ... )
    >>> print(result['final_answer'])
"""

__version__ = "1.0.0"
__author__ = "Agentic AI Team"

from .agent import run_sql_agent

__all__ = ["run_sql_agent"]

"""
Utility functions for the SQL agent.

This module provides helper functions for:
- Database schema extraction and query execution
- SQL query safety validation
- API calls to Anthropic Claude
- JSON parsing from LLM responses
"""

import os
import re
import json
import sqlite3
from typing import Tuple, Dict, Any, Optional, List
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from anthropic import Anthropic

# Load environment variables
load_dotenv()

# Initialize Anthropic client
anthropic_api_key = os.getenv("ANTHROPIC_API_KEY")
anthropic_client = Anthropic(api_key=anthropic_api_key) if anthropic_api_key else None


def get_database_schema(db_path: str) -> str:
    """
    Extract the complete database schema with table structures.

    Args:
        db_path: Path to SQLite database

    Returns:
        Formatted string with complete schema information

    Raises:
        ValueError: If database cannot be accessed
    """
    if not os.path.exists(db_path):
        raise ValueError(f"Database not found: {db_path}")

    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        # Get all tables (excluding sqlite internal tables)
        cursor.execute("""
            SELECT name FROM sqlite_master
            WHERE type='table'
            AND name NOT LIKE 'sqlite_%'
            ORDER BY name
        """)
        tables = [row[0] for row in cursor.fetchall()]

        schema_parts = []
        schema_parts.append(f"Database: {Path(db_path).name}")
        schema_parts.append(f"Total tables: {len(tables)}\n")

        for table in tables:
            # Get table schema
            cursor.execute(f"PRAGMA table_info({table})")
            columns = cursor.fetchall()

            schema_parts.append(f"TABLE: {table}")
            schema_parts.append("Columns:")
            for col in columns:
                col_id, col_name, col_type, not_null, default, pk = col
                constraints = []
                if pk:
                    constraints.append("PRIMARY KEY")
                if not_null:
                    constraints.append("NOT NULL")
                constraint_str = f" ({', '.join(constraints)})" if constraints else ""
                schema_parts.append(f"  - {col_name}: {col_type}{constraint_str}")

            # Get sample row count
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            schema_parts.append(f"  Rows: {count}")
            schema_parts.append("")

        conn.close()
        return "\n".join(schema_parts)

    except Exception as e:
        raise ValueError(f"Failed to extract schema: {str(e)}")


def execute_sql_query(query: str, db_path: str) -> Tuple[bool, Optional[pd.DataFrame], Optional[str]]:
    """
    Execute a SQL query and return results.

    Args:
        query: SQL query string
        db_path: Path to SQLite database

    Returns:
        Tuple of (success: bool, dataframe: Optional[pd.DataFrame], error: Optional[str])
    """
    try:
        # Clean query
        cleaned_query = query.strip()
        cleaned_query = cleaned_query.removeprefix("```sql").removeprefix("```")
        cleaned_query = cleaned_query.removesuffix("```").strip()

        # Validate query is read-only (basic check)
        if not is_query_read_only(cleaned_query):
            return False, None, "Query contains forbidden write operations (INSERT, UPDATE, DELETE, DROP, ALTER, CREATE)"

        # Execute query
        conn = sqlite3.connect(db_path)
        df = pd.read_sql_query(cleaned_query, conn)
        conn.close()

        return True, df, None

    except Exception as e:
        return False, None, f"Query execution error: {str(e)}"


def is_query_read_only(query: str) -> bool:
    """
    Validate that a SQL query is read-only (no writes, updates, deletes).

    Args:
        query: SQL query string

    Returns:
        True if query is read-only, False otherwise
    """
    # Convert to uppercase for case-insensitive matching
    query_upper = query.upper()

    # List of forbidden keywords that indicate write operations
    forbidden_keywords = [
        'INSERT', 'UPDATE', 'DELETE', 'DROP', 'ALTER',
        'CREATE', 'REPLACE', 'TRUNCATE', 'RENAME',
        'PRAGMA', 'ATTACH', 'DETACH', 'VACUUM'
    ]

    # Check for forbidden keywords at word boundaries
    for keyword in forbidden_keywords:
        # Use word boundary regex to avoid false positives
        # (e.g., "INSERTED_DATE" should not trigger "INSERT")
        pattern = r'\b' + keyword + r'\b'
        if re.search(pattern, query_upper):
            return False

    return True


def call_anthropic_api(
    model: str,
    prompt: str,
    temperature: float = 0.0,
    max_tokens: int = 2000,
) -> str:
    """
    Call Anthropic API with text prompt.

    Args:
        model: Model name (e.g., "claude-sonnet-4.5-20250929")
        prompt: Text prompt
        temperature: Sampling temperature (default: 0.0 for deterministic)
        max_tokens: Maximum tokens in response

    Returns:
        Model response as string

    Raises:
        ValueError: If API call fails
    """
    if anthropic_client is None:
        raise ValueError("Anthropic API key not configured. Set ANTHROPIC_API_KEY environment variable.")

    try:
        response = anthropic_client.messages.create(
            model=model,
            max_tokens=max_tokens,
            temperature=temperature,
            messages=[{
                "role": "user",
                "content": prompt,
            }],
        )

        # Collect all text blocks
        parts = []
        for block in response.content:
            if hasattr(block, "type") and block.type == "text":
                parts.append(block.text)

        return "".join(parts).strip()

    except Exception as e:
        raise ValueError(f"Anthropic API call failed: {str(e)}")


def parse_json_response(response: str) -> Dict[str, Any]:
    """
    Parse JSON from LLM response with robust fallback handling.

    Args:
        response: LLM response string that should contain JSON

    Returns:
        Parsed JSON as dictionary

    Raises:
        ValueError: If JSON cannot be parsed
    """
    try:
        # Try direct JSON parse
        return json.loads(response)
    except json.JSONDecodeError:
        pass

    # Try to extract from markdown code blocks
    patterns = [
        r'```json\n(.*?)\n```',
        r'```\n(.*?)\n```',
        r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}',  # Match nested JSON
    ]

    for pattern in patterns:
        match = re.search(pattern, response, re.DOTALL)
        if match:
            try:
                json_str = match.group(1) if '```' in pattern else match.group(0)
                return json.loads(json_str)
            except (json.JSONDecodeError, IndexError):
                continue

    raise ValueError(f"Could not parse JSON from response. First 200 chars: {response[:200]}...")


def extract_sql_from_response(response: str) -> str:
    """
    Extract SQL query from LLM response.

    Args:
        response: LLM response that may contain SQL

    Returns:
        Extracted SQL query
    """
    # Try to extract from code blocks
    patterns = [
        r'```sql\n(.*?)\n```',
        r'```\n(.*?)\n```',
        r'<sql>(.*?)</sql>',
    ]

    for pattern in patterns:
        match = re.search(pattern, response, re.DOTALL | re.IGNORECASE)
        if match:
            return match.group(1).strip()

    # If no code blocks, return the response as-is
    return response.strip()


def format_dataframe_for_display(df: pd.DataFrame, max_rows: int = 20) -> str:
    """
    Format a DataFrame for display in prompts or output.

    Args:
        df: pandas DataFrame
        max_rows: Maximum number of rows to include

    Returns:
        Formatted string representation
    """
    if df.empty:
        return "No results returned."

    # Limit rows
    display_df = df.head(max_rows)

    # Convert to markdown table
    result = display_df.to_markdown(index=False)

    # Add row count info
    if len(df) > max_rows:
        result += f"\n\n(Showing {max_rows} of {len(df)} total rows)"
    else:
        result += f"\n\n(Total: {len(df)} rows)"

    return result


def validate_database_path(db_path: str) -> str:
    """
    Validate and normalize database path.

    Args:
        db_path: Path to database file

    Returns:
        Normalized absolute path

    Raises:
        ValueError: If path is invalid
    """
    if not db_path:
        raise ValueError("Database path is required")

    path = Path(db_path)

    if not path.exists():
        raise ValueError(f"Database file not found: {db_path}")

    if not path.is_file():
        raise ValueError(f"Database path is not a file: {db_path}")

    if path.suffix.lower() not in ['.db', '.sqlite', '.sqlite3']:
        raise ValueError(f"Invalid database file extension: {path.suffix}")

    return str(path.absolute())


def detect_malicious_patterns(text: str) -> Tuple[bool, Optional[str]]:
    """
    Detect potentially malicious patterns in user input.

    Args:
        text: User input text

    Returns:
        Tuple of (is_malicious: bool, reason: Optional[str])
    """
    text_lower = text.lower()

    # Patterns that might indicate malicious intent
    malicious_patterns = {
        r'\b(drop|delete|truncate|destroy)\s+(table|database|all|everything)\b':
            "Attempting to destroy data",
        r'\bi\s+am\s+(admin|administrator|owner|boss|root|superuser)\b':
            "Unauthorized privilege claim",
        r'\b(ignore|disregard|bypass|override)\s+(previous|all|above|security|restrictions)\b':
            "Attempting to bypass security",
        r'<script|javascript:|onerror=|onload=':
            "Potential XSS injection",
        r'(exec|eval|system|shell|cmd)\s*\(':
            "Potential code injection",
    }

    for pattern, reason in malicious_patterns.items():
        if re.search(pattern, text_lower):
            return True, reason

    return False, None

"""
Utility functions for the data visualization agent.

This module provides helper functions for:
- Loading datasets from files or URLs
- Executing Python code safely
- Encoding images for vision APIs
- Extracting code from LLM responses
- Generating dataset descriptions
"""

import os
import re
import json
import base64
import mimetypes
from typing import Optional, Tuple
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from anthropic import Anthropic
from openai import OpenAI

# Load environment variables
load_dotenv()

# Initialize API clients
openai_api_key = os.getenv("OPENAI_API_KEY")
anthropic_api_key = os.getenv("ANTHROPIC_API_KEY")

openai_client = OpenAI(api_key=openai_api_key) if openai_api_key else None
anthropic_client = Anthropic(api_key=anthropic_api_key) if anthropic_api_key else None


def load_dataset(source: str) -> pd.DataFrame:
    """
    Load dataset from a file path or URL.

    Args:
        source: File path or URL to a CSV file

    Returns:
        pandas DataFrame containing the data

    Raises:
        ValueError: If the source cannot be loaded
    """
    try:
        # Check if it's a URL
        if source.startswith(('http://', 'https://')):
            df = pd.read_csv(source)
        else:
            # Local file path
            if not os.path.exists(source):
                raise ValueError(f"File not found: {source}")
            df = pd.read_csv(source)

        if df.empty:
            raise ValueError("Loaded dataset is empty")

        return df

    except Exception as e:
        raise ValueError(f"Failed to load dataset from {source}: {str(e)}")


def make_dataset_schema(df: pd.DataFrame) -> str:
    """
    Generate a human-readable schema from a DataFrame.

    Args:
        df: pandas DataFrame

    Returns:
        String describing columns and their types
    """
    schema_lines = []
    for col, dtype in df.dtypes.items():
        # Add some sample values for context
        sample_values = df[col].dropna().head(3).tolist()
        sample_str = ", ".join(str(v) for v in sample_values)
        if len(sample_str) > 50:
            sample_str = sample_str[:50] + "..."

        schema_lines.append(f"  - {col} ({dtype}): e.g., {sample_str}")

    return "Columns:\n" + "\n".join(schema_lines)


def auto_generate_dataset_description(df: pd.DataFrame) -> str:
    """
    Auto-generate a basic dataset description if none provided.

    Args:
        df: pandas DataFrame

    Returns:
        String describing the dataset
    """
    num_rows = len(df)
    num_cols = len(df.columns)
    col_list = ", ".join(df.columns[:5])
    if len(df.columns) > 5:
        col_list += f", and {len(df.columns) - 5} more"

    return f"Dataset with {num_rows} rows and {num_cols} columns. Columns include: {col_list}."


def extract_code_from_tags(text: str) -> str:
    """
    Extract Python code from <execute_python> tags or markdown code blocks.

    Args:
        text: Text containing code

    Returns:
        Extracted code as string

    Raises:
        ValueError: If no code is found
    """
    # Try to extract from <execute_python> tags first
    match = re.search(r"<execute_python>(.*?)</execute_python>", text, re.DOTALL)
    if match:
        return match.group(1).strip()

    # Try to extract from markdown code blocks
    match = re.search(r"```python\n(.*?)\n```", text, re.DOTALL)
    if match:
        return match.group(1).strip()

    # Try generic code block
    match = re.search(r"```\n(.*?)\n```", text, re.DOTALL)
    if match:
        return match.group(1).strip()

    # If no tags found, assume the entire text is code (after stripping)
    cleaned = text.strip()
    if cleaned:
        return cleaned

    raise ValueError("No code found in response")


def execute_plotly_code(
    code: str,
    df: pd.DataFrame,
    output_path: str,
) -> Tuple[bool, Optional[str]]:
    """
    Execute Plotly code safely with a DataFrame context.

    Args:
        code: Python code to execute
        df: DataFrame to make available as 'df' in execution context
        output_path: Expected output file path

    Returns:
        Tuple of (success: bool, error_message: Optional[str])
    """
    try:
        # Create execution context with necessary imports
        exec_globals = {
            "df": df,
            "pd": pd,
            "__builtins__": __builtins__,
        }

        # Add plotly imports
        import plotly.express as px
        import plotly.graph_objects as go
        exec_globals["px"] = px
        exec_globals["go"] = go

        # Execute the code
        exec(code, exec_globals)

        # Check if output file was created
        if not os.path.exists(output_path):
            return False, f"Code executed but output file not created at: {output_path}"

        return True, None

    except Exception as e:
        return False, f"Error executing code: {str(e)}"


def encode_image_b64(image_path: str) -> Tuple[str, str]:
    """
    Encode an image file to base64 for vision API.

    Args:
        image_path: Path to the image file

    Returns:
        Tuple of (media_type: str, base64_encoded: str)

    Raises:
        ValueError: If file doesn't exist or can't be read
    """
    if not os.path.exists(image_path):
        raise ValueError(f"Image file not found: {image_path}")

    # Guess the MIME type
    mime_type, _ = mimetypes.guess_type(image_path)
    if mime_type is None:
        mime_type = "image/png"  # Default to PNG

    try:
        with open(image_path, "rb") as f:
            image_data = f.read()
            b64_encoded = base64.b64encode(image_data).decode("utf-8")
        return mime_type, b64_encoded
    except Exception as e:
        raise ValueError(f"Failed to encode image: {str(e)}")


def call_anthropic_with_vision(
    model: str,
    prompt: str,
    image_path: str,
) -> str:
    """
    Call Anthropic API with text + image.

    Args:
        model: Model name (e.g., "claude-sonnet-4.5-20250929")
        prompt: Text prompt
        image_path: Path to image file

    Returns:
        Model response as string

    Raises:
        ValueError: If API call fails
    """
    if anthropic_client is None:
        raise ValueError("Anthropic API key not configured")

    try:
        media_type, b64_data = encode_image_b64(image_path)

        response = anthropic_client.messages.create(
            model=model,
            max_tokens=2000,
            temperature=0,
            messages=[{
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": media_type,
                            "data": b64_data,
                        },
                    },
                ],
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


def call_anthropic_text(
    model: str,
    prompt: str,
) -> str:
    """
    Call Anthropic API with text only.

    Args:
        model: Model name (e.g., "claude-haiku-4.5-20250915")
        prompt: Text prompt

    Returns:
        Model response as string

    Raises:
        ValueError: If API call fails
    """
    if anthropic_client is None:
        raise ValueError("Anthropic API key not configured")

    try:
        response = anthropic_client.messages.create(
            model=model,
            max_tokens=2000,
            temperature=0,
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


def parse_critique_json(response: str) -> dict:
    """
    Parse critique response as JSON, with fallback handling.

    Args:
        response: LLM response string

    Returns:
        Dictionary with critique feedback

    Raises:
        ValueError: If JSON cannot be parsed
    """
    try:
        # Try direct JSON parse
        return json.loads(response)
    except json.JSONDecodeError:
        # Try to extract JSON from markdown code blocks
        match = re.search(r"```json\n(.*?)\n```", response, re.DOTALL)
        if match:
            try:
                return json.loads(match.group(1))
            except json.JSONDecodeError:
                pass

        # Try to find any JSON object in the response
        match = re.search(r"\{.*\}", response, re.DOTALL)
        if match:
            try:
                return json.loads(match.group(0))
            except json.JSONDecodeError:
                pass

        raise ValueError(f"Could not parse JSON from response: {response[:200]}...")


def ensure_output_directory(file_path: str) -> None:
    """
    Ensure the directory for a file path exists.

    Args:
        file_path: Path to file
    """
    directory = os.path.dirname(file_path)
    if directory and not os.path.exists(directory):
        os.makedirs(directory, exist_ok=True)

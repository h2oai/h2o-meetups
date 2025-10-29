"""
Data Visualization Agent with Reflection Pattern.

This module implements an agentic workflow for generating high-quality
data visualizations using Plotly with iterative refinement through critique.

Workflow:
1. Load dataset from CSV file or URL
2. Generate initial chart code using Claude Haiku
3. Execute code and save PNG
4. Critique chart using Claude Sonnet (with vision)
5. Improve code based on feedback
6. Repeat steps 3-5 until max iterations or no improvements needed
7. Return final code and chart
"""

import os
from typing import Optional, Dict, Any, List
from pathlib import Path

from .utils import (
    load_dataset,
    make_dataset_schema,
    auto_generate_dataset_description,
    extract_code_from_tags,
    execute_plotly_code,
    call_anthropic_text,
    call_anthropic_with_vision,
    parse_critique_json,
    ensure_output_directory,
)
from .prompts import (
    get_chart_generation_prompt,
    get_chart_critique_prompt,
    get_chart_improvement_prompt,
)


def run_dataviz_agent(
    csv_source: str,
    user_request: str,
    dataset_description: Optional[str] = None,
    max_iterations: int = 3,
    generation_model: str = "claude-haiku-4.5-20250915",
    critique_model: str = "claude-sonnet-4.5-20250929",
    output_dir: str = "./outputs",
    output_basename: str = "chart",
    verbose: bool = True,
) -> Dict[str, Any]:
    """
    Run the data visualization agent with reflection pattern.

    Args:
        csv_source: Path to CSV file or URL
        user_request: Description of the desired visualization
        dataset_description: Optional description of the dataset (auto-generated if not provided)
        max_iterations: Maximum number of refinement iterations (default: 3)
        generation_model: Model for code generation (default: Claude Haiku 4.5)
        critique_model: Model for critique (default: Claude Sonnet 4.5)
        output_dir: Directory for output files (default: "./outputs")
        output_basename: Base name for output files (default: "chart")
        verbose: Print progress messages (default: True)

    Returns:
        Dictionary containing:
            - status: "success" or "error"
            - final_chart_path: Path to final PNG
            - final_code: Final Python code
            - iteration_count: Number of iterations performed
            - all_iterations: List of dicts with details for each iteration
            - error_message: Error message if status is "error"

    Example:
        >>> result = run_dataviz_agent(
        ...     csv_source="data.csv",
        ...     user_request="Show sales by region",
        ...     max_iterations=3,
        ... )
        >>> print(result['final_chart_path'])
        ./outputs/chart_final.png
    """
    try:
        # Step 1: Load dataset
        if verbose:
            print(f"\n{'='*60}")
            print(f"DATAVIZ AGENT - Starting")
            print(f"{'='*60}")
            print(f"\n[1/7] Loading dataset from: {csv_source}")

        df = load_dataset(csv_source)

        if verbose:
            print(f"  ✓ Loaded {len(df)} rows and {len(df.columns)} columns")

        # Step 2: Prepare dataset information
        if verbose:
            print(f"\n[2/7] Preparing dataset information")

        dataset_schema = make_dataset_schema(df)

        if dataset_description is None:
            dataset_description = auto_generate_dataset_description(df)
            if verbose:
                print(f"  ✓ Auto-generated dataset description")
        else:
            if verbose:
                print(f"  ✓ Using provided dataset description")

        # Ensure output directory exists
        ensure_output_directory(os.path.join(output_dir, "dummy.txt"))

        # Step 3: Generate initial chart code
        if verbose:
            print(f"\n[3/7] Generating initial chart code using {generation_model}")

        output_path_v1 = os.path.join(output_dir, f"{output_basename}_v1.png")

        generation_prompt = get_chart_generation_prompt(
            dataset_schema=dataset_schema,
            dataset_description=dataset_description,
            user_request=user_request,
            output_path=output_path_v1,
        )

        code_response = call_anthropic_text(generation_model, generation_prompt)
        current_code = extract_code_from_tags(code_response)

        if verbose:
            print(f"  ✓ Generated initial code ({len(current_code)} chars)")

        # Step 4: Execute initial code
        if verbose:
            print(f"\n[4/7] Executing initial code")

        success, error_msg = execute_plotly_code(current_code, df, output_path_v1)

        if not success:
            return {
                "status": "error",
                "error_message": f"Failed to execute initial code: {error_msg}",
                "code": current_code,
            }

        current_chart_path = output_path_v1

        if verbose:
            print(f"  ✓ Chart saved to: {current_chart_path}")

        # Track all iterations
        all_iterations = [{
            "iteration": 0,
            "code": current_code,
            "chart_path": current_chart_path,
            "critique": None,
        }]

        # Step 5: Iterative refinement loop
        if verbose:
            print(f"\n[5/7] Starting refinement loop (max {max_iterations} iterations)")

        for iteration in range(1, max_iterations + 1):
            if verbose:
                print(f"\n  --- Iteration {iteration}/{max_iterations} ---")
                print(f"  [5.{iteration}.1] Critiquing chart with {critique_model}")

            # Critique current chart
            critique_prompt = get_chart_critique_prompt(
                user_request=user_request,
                dataset_description=dataset_description,
            )

            critique_response = call_anthropic_with_vision(
                critique_model,
                critique_prompt,
                current_chart_path,
            )

            try:
                critique_feedback = parse_critique_json(critique_response)
            except ValueError as e:
                if verbose:
                    print(f"  ⚠ Warning: Could not parse critique JSON: {e}")
                    print(f"  Stopping refinement loop")
                break

            if verbose:
                print(f"  ✓ Received critique feedback")
                should_continue = critique_feedback.get("should_continue", True)
                print(f"  Should continue: {should_continue}")

            # Check if we should stop
            if not critique_feedback.get("should_continue", True):
                if verbose:
                    print(f"  ✓ Critic says no more improvements needed!")
                all_iterations[-1]["critique"] = critique_feedback
                break

            # Improve code based on feedback
            if verbose:
                print(f"  [5.{iteration}.2] Improving code based on feedback")

            output_path_vN = os.path.join(output_dir, f"{output_basename}_v{iteration + 1}.png")

            improvement_prompt = get_chart_improvement_prompt(
                original_code=current_code,
                critique_feedback=critique_feedback,
                user_request=user_request,
                dataset_schema=dataset_schema,
                dataset_description=dataset_description,
                output_path=output_path_vN,
            )

            improved_code_response = call_anthropic_text(generation_model, improvement_prompt)
            improved_code = extract_code_from_tags(improved_code_response)

            if verbose:
                print(f"  ✓ Generated improved code ({len(improved_code)} chars)")
                print(f"  [5.{iteration}.3] Executing improved code")

            # Execute improved code
            success, error_msg = execute_plotly_code(improved_code, df, output_path_vN)

            if not success:
                if verbose:
                    print(f"  ⚠ Warning: Failed to execute improved code: {error_msg}")
                    print(f"  Keeping previous version")
                all_iterations[-1]["critique"] = critique_feedback
                break

            # Update current state
            current_code = improved_code
            current_chart_path = output_path_vN

            if verbose:
                print(f"  ✓ Improved chart saved to: {current_chart_path}")

            # Record this iteration
            all_iterations.append({
                "iteration": iteration,
                "code": current_code,
                "chart_path": current_chart_path,
                "critique": critique_feedback,
            })

        # Step 6: Save final version
        if verbose:
            print(f"\n[6/7] Saving final version")

        final_chart_path = os.path.join(output_dir, f"{output_basename}_final.png")

        # Copy current chart to final path
        import shutil
        shutil.copy2(current_chart_path, final_chart_path)

        if verbose:
            print(f"  ✓ Final chart saved to: {final_chart_path}")

        # Step 7: Prepare result
        if verbose:
            print(f"\n[7/7] Preparing result")
            print(f"  ✓ Completed {len(all_iterations)} iterations")
            print(f"\n{'='*60}")
            print(f"DATAVIZ AGENT - Complete!")
            print(f"{'='*60}\n")

        return {
            "status": "success",
            "final_chart_path": final_chart_path,
            "final_code": current_code,
            "iteration_count": len(all_iterations),
            "all_iterations": all_iterations,
            "dataset_rows": len(df),
            "dataset_columns": len(df.columns),
        }

    except Exception as e:
        error_msg = f"Agent failed with error: {str(e)}"
        if verbose:
            print(f"\n❌ ERROR: {error_msg}\n")
        return {
            "status": "error",
            "error_message": error_msg,
        }


def main():
    """
    Command-line interface for the dataviz agent.
    """
    import argparse

    parser = argparse.ArgumentParser(
        description="Data Visualization Agent with Reflection Pattern"
    )
    parser.add_argument(
        "csv_source",
        help="Path to CSV file or URL",
    )
    parser.add_argument(
        "user_request",
        help="Description of desired visualization",
    )
    parser.add_argument(
        "--description",
        help="Optional dataset description",
        default=None,
    )
    parser.add_argument(
        "--max-iterations",
        type=int,
        default=3,
        help="Maximum refinement iterations (default: 3)",
    )
    parser.add_argument(
        "--output-dir",
        default="./outputs",
        help="Output directory (default: ./outputs)",
    )
    parser.add_argument(
        "--output-name",
        default="chart",
        help="Output file basename (default: chart)",
    )
    parser.add_argument(
        "--generation-model",
        default="claude-haiku-4.5-20250915",
        help="Model for code generation (default: claude-haiku-4.5-20250915)",
    )
    parser.add_argument(
        "--critique-model",
        default="claude-sonnet-4.5-20250929",
        help="Model for critique (default: claude-sonnet-4.5-20250929)",
    )
    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Suppress progress messages",
    )

    args = parser.parse_args()

    result = run_dataviz_agent(
        csv_source=args.csv_source,
        user_request=args.user_request,
        dataset_description=args.description,
        max_iterations=args.max_iterations,
        generation_model=args.generation_model,
        critique_model=args.critique_model,
        output_dir=args.output_dir,
        output_basename=args.output_name,
        verbose=not args.quiet,
    )

    if result["status"] == "success":
        print(f"\n✓ Success! Final chart: {result['final_chart_path']}")
        return 0
    else:
        print(f"\n✗ Failed: {result['error_message']}")
        return 1


if __name__ == "__main__":
    import sys
    sys.exit(main())

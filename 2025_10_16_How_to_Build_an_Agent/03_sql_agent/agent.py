"""
Text-to-SQL Agent with Triple Reflection Pattern.

This module implements the main agent orchestration with three reflection stages:
1. Intent Triage & Security Validation
2. SQL Query Generation & Validation
3. Answer Formatting & Quality Assurance

Each stage uses iterative refinement with up to N feedback loops.
"""

import os
from typing import Dict, Any, Optional, List
from pathlib import Path

from .utils import (
    get_database_schema,
    execute_sql_query,
    call_anthropic_api,
    parse_json_response,
    format_dataframe_for_display,
    validate_database_path,
    detect_malicious_patterns,
)
from .prompts import (
    get_triage_prompt,
    get_triage_critique_prompt,
    get_sql_generation_prompt,
    get_sql_critique_prompt,
    get_answer_generation_prompt,
    get_answer_critique_prompt,
)


def run_sql_agent(
    question: str,
    db_path: str = None,
    max_iterations: int = 3,
    model: str = "claude-sonnet-4-5-20250929",
    verbose: bool = True,
) -> Dict[str, Any]:
    """
    Run the SQL agent with triple reflection pattern.

    Args:
        question: User's natural language question
        db_path: Path to SQLite database (defaults to chinook.db in same directory)
        max_iterations: Maximum reflection iterations per stage (default: 3)
        model: Claude model to use (default: claude-sonnet-4-5-20250929)
        verbose: Print detailed progress (default: True)

    Returns:
        Dictionary containing:
            - status: "success", "rejected", or "error"
            - final_answer: Final formatted answer (if success)
            - rejection_reason: Reason for rejection (if rejected)
            - error_message: Error details (if error)
            - sql_query: Final SQL query used (if success)
            - query_results: Raw query results (if success)
            - all_stages: Detailed info for each stage
            - iteration_counts: Dict with iteration count per stage

    Example:
        >>> result = run_sql_agent("Which artist has the most albums?")
        >>> print(result['final_answer'])
    """
    try:
        # Validate and set database path
        if db_path is None:
            db_path = str(Path(__file__).parent / "chinook.db")

        db_path = validate_database_path(db_path)

        if verbose:
            print(f"\n{'='*70}")
            print(f"SQL AGENT - Starting")
            print(f"{'='*70}")
            print(f"Question: {question}")
            print(f"Database: {db_path}")
            print(f"Model: {model}")
            print(f"Max iterations per stage: {max_iterations}")
            print(f"{'='*70}\n")

        # Get database schema
        database_schema = get_database_schema(db_path)
        database_info = f"Chinook Database - A music store database containing information about artists, albums, tracks, customers, invoices, and sales."

        # Quick malicious pattern check
        is_malicious, malicious_reason = detect_malicious_patterns(question)
        if is_malicious:
            if verbose:
                print(f"\n[PRE-CHECK] Malicious pattern detected: {malicious_reason}")
                print(f"[PRE-CHECK] Rejecting request immediately.\n")
            return {
                "status": "rejected",
                "rejection_reason": f"Security violation: {malicious_reason}",
                "question": question,
            }

        # ====================================================================
        # STAGE 1: INTENT TRIAGE & SECURITY VALIDATION
        # ====================================================================
        if verbose:
            print(f"\n{'─'*70}")
            print(f"STAGE 1: INTENT TRIAGE & SECURITY VALIDATION")
            print(f"{'─'*70}\n")

        stage1_result = _run_triage_stage(
            question=question,
            database_info=database_info,
            database_schema=database_schema,
            model=model,
            max_iterations=max_iterations,
            verbose=verbose,
        )

        if stage1_result["decision"] == "REJECT":
            if verbose:
                print(f"\n[STAGE 1] Question REJECTED")
                print(f"[STAGE 1] Reason: {stage1_result['rejection_reason']}\n")

            return {
                "status": "rejected",
                "rejection_reason": stage1_result["rejection_reason"],
                "question": question,
                "stage1": stage1_result,
            }

        if verbose:
            print(f"\n[STAGE 1] Question APPROVED - Proceeding to SQL generation\n")

        # ====================================================================
        # STAGE 2: SQL QUERY GENERATION & VALIDATION
        # ====================================================================
        if verbose:
            print(f"\n{'─'*70}")
            print(f"STAGE 2: SQL QUERY GENERATION & VALIDATION")
            print(f"{'─'*70}\n")

        stage2_result = _run_sql_generation_stage(
            question=question,
            database_schema=database_schema,
            db_path=db_path,
            model=model,
            max_iterations=max_iterations,
            verbose=verbose,
        )

        if stage2_result["status"] == "error":
            return {
                "status": "error",
                "error_message": stage2_result["error_message"],
                "question": question,
                "stage1": stage1_result,
                "stage2": stage2_result,
            }

        if verbose:
            print(f"\n[STAGE 2] SQL query validated and executed successfully\n")

        # ====================================================================
        # STAGE 3: ANSWER FORMATTING & QUALITY ASSURANCE
        # ====================================================================
        if verbose:
            print(f"\n{'─'*70}")
            print(f"STAGE 3: ANSWER FORMATTING & QUALITY ASSURANCE")
            print(f"{'─'*70}\n")

        stage3_result = _run_answer_formatting_stage(
            question=question,
            sql_query=stage2_result["final_sql_query"],
            query_results_df=stage2_result["query_results_df"],
            model=model,
            max_iterations=max_iterations,
            verbose=verbose,
        )

        if verbose:
            print(f"\n[STAGE 3] Answer formatted and validated\n")

        # ====================================================================
        # FINAL RESULT
        # ====================================================================
        if verbose:
            print(f"\n{'='*70}")
            print(f"SQL AGENT - Complete!")
            print(f"{'='*70}")
            print(f"\nFINAL ANSWER:")
            print(f"{stage3_result['final_answer']}\n")
            print(f"{'='*70}\n")

        return {
            "status": "success",
            "final_answer": stage3_result["final_answer"],
            "sql_query": stage2_result["final_sql_query"],
            "query_results": stage2_result["query_results_formatted"],
            "key_insights": stage3_result.get("key_insights", []),
            "question": question,
            "iteration_counts": {
                "stage1_triage": stage1_result["iteration_count"],
                "stage2_sql": stage2_result["iteration_count"],
                "stage3_answer": stage3_result["iteration_count"],
            },
            "all_stages": {
                "stage1_triage": stage1_result,
                "stage2_sql": stage2_result,
                "stage3_answer": stage3_result,
            },
        }

    except Exception as e:
        error_msg = f"Agent failed with error: {str(e)}"
        if verbose:
            print(f"\n❌ ERROR: {error_msg}\n")
        return {
            "status": "error",
            "error_message": error_msg,
            "question": question,
        }


def _run_triage_stage(
    question: str,
    database_info: str,
    database_schema: str,
    model: str,
    max_iterations: int,
    verbose: bool,
) -> Dict[str, Any]:
    """
    Run Stage 1: Intent Triage & Security Validation with reflection.

    Returns dict with: decision, rejection_reason, iteration_count, all_iterations
    """
    if verbose:
        print(f"[1.1] Generating initial triage decision...")

    # Initial triage
    triage_prompt = get_triage_prompt(question, database_info)
    triage_response = call_anthropic_api(model, triage_prompt)
    current_triage = parse_json_response(triage_response)

    if verbose:
        print(f"  ✓ Initial decision: {current_triage.get('decision')}")
        if current_triage.get('decision') == 'REJECT':
            print(f"  ✓ Reason: {current_triage.get('rejection_reason')}")

    all_iterations = [{
        "iteration": 0,
        "triage": current_triage,
        "critique": None,
    }]

    # Reflection loop
    for iteration in range(1, max_iterations + 1):
        if verbose:
            print(f"\n[1.{iteration + 1}] Running critique iteration {iteration}/{max_iterations}...")

        # Critique current triage
        critique_prompt = get_triage_critique_prompt(
            question, current_triage, database_info
        )
        critique_response = call_anthropic_api(model, critique_prompt)
        critique = parse_json_response(critique_response)

        if verbose:
            print(f"  ✓ Critique suggested decision: {critique.get('suggested_decision')}")
            print(f"  ✓ Should continue: {critique.get('should_continue')}")

        all_iterations[-1]["critique"] = critique

        # Check if we should stop
        if not critique.get("should_continue", True):
            if verbose:
                print(f"  ✓ Triage validated - no changes needed")
            break

        # Apply critique suggestions
        if critique.get("suggested_decision"):
            current_triage["decision"] = critique["suggested_decision"]
        if critique.get("suggested_rejection_reason"):
            current_triage["rejection_reason"] = critique["suggested_rejection_reason"]

        if verbose:
            print(f"  ✓ Updated decision: {current_triage.get('decision')}")

        all_iterations.append({
            "iteration": iteration,
            "triage": current_triage.copy(),
            "critique": None,
        })

    return {
        "decision": current_triage.get("decision", "REJECT"),
        "rejection_reason": current_triage.get("rejection_reason"),
        "is_database_related": current_triage.get("is_database_related", False),
        "security_assessment": current_triage.get("security_assessment"),
        "iteration_count": len(all_iterations),
        "all_iterations": all_iterations,
    }


def _run_sql_generation_stage(
    question: str,
    database_schema: str,
    db_path: str,
    model: str,
    max_iterations: int,
    verbose: bool,
) -> Dict[str, Any]:
    """
    Run Stage 2: SQL Query Generation & Validation with reflection.

    Returns dict with: status, final_sql_query, query_results_df, query_results_formatted, iteration_count, all_iterations
    """
    if verbose:
        print(f"[2.1] Generating initial SQL query...")

    # Initial SQL generation
    sql_prompt = get_sql_generation_prompt(question, database_schema)
    sql_response = call_anthropic_api(model, sql_prompt)
    current_sql_gen = parse_json_response(sql_response)

    current_sql_query = current_sql_gen.get("sql_query")

    if verbose:
        print(f"  ✓ Generated SQL query")
        print(f"  ✓ Tables used: {', '.join(current_sql_gen.get('tables_used', []))}")

    # Execute initial query
    if verbose:
        print(f"\n[2.2] Executing SQL query...")

    success, df, error = execute_sql_query(current_sql_query, db_path)

    if not success:
        if verbose:
            print(f"  ✗ Query execution failed: {error}")
        return {
            "status": "error",
            "error_message": f"SQL execution failed: {error}",
            "sql_query": current_sql_query,
        }

    query_results_formatted = format_dataframe_for_display(df)

    if verbose:
        print(f"  ✓ Query executed successfully")
        print(f"  ✓ Returned {len(df)} rows")

    execution_result = {
        "success": success,
        "row_count": len(df),
        "columns": list(df.columns),
        "preview": query_results_formatted,
    }

    all_iterations = [{
        "iteration": 0,
        "sql_generation": current_sql_gen,
        "sql_query": current_sql_query,
        "execution_result": execution_result,
        "critique": None,
    }]

    # Reflection loop
    for iteration in range(1, max_iterations + 1):
        if verbose:
            print(f"\n[2.{2 * iteration + 1}] Running critique iteration {iteration}/{max_iterations}...")

        # Critique current SQL
        critique_prompt = get_sql_critique_prompt(
            question, current_sql_gen, database_schema, execution_result
        )
        critique_response = call_anthropic_api(model, critique_prompt)
        critique = parse_json_response(critique_response)

        if verbose:
            print(f"  ✓ Critique completed")
            print(f"  ✓ Issues found: {len(critique.get('issues_found', []))}")
            print(f"  ✓ Should continue: {critique.get('should_continue')}")

        all_iterations[-1]["critique"] = critique

        # Check if we should stop
        if not critique.get("should_continue", True):
            if verbose:
                print(f"  ✓ SQL query validated - no changes needed")
            break

        # Apply improvements if suggested
        revised_sql = critique.get("revised_sql_query")
        if revised_sql:
            if verbose:
                print(f"\n[2.{2 * iteration + 2}] Executing revised SQL query...")

            current_sql_query = revised_sql

            # Execute revised query
            success, df, error = execute_sql_query(current_sql_query, db_path)

            if not success:
                if verbose:
                    print(f"  ⚠ Revised query failed: {error}")
                    print(f"  ⚠ Keeping previous version")
                break

            query_results_formatted = format_dataframe_for_display(df)

            if verbose:
                print(f"  ✓ Revised query executed successfully")
                print(f"  ✓ Returned {len(df)} rows")

            execution_result = {
                "success": success,
                "row_count": len(df),
                "columns": list(df.columns),
                "preview": query_results_formatted,
            }

            all_iterations.append({
                "iteration": iteration,
                "sql_generation": current_sql_gen,
                "sql_query": current_sql_query,
                "execution_result": execution_result,
                "critique": None,
            })

    return {
        "status": "success",
        "final_sql_query": current_sql_query,
        "query_results_df": df,
        "query_results_formatted": query_results_formatted,
        "iteration_count": len(all_iterations),
        "all_iterations": all_iterations,
    }


def _run_answer_formatting_stage(
    question: str,
    sql_query: str,
    query_results_df,
    model: str,
    max_iterations: int,
    verbose: bool,
) -> Dict[str, Any]:
    """
    Run Stage 3: Answer Formatting & Quality Assurance with reflection.

    Returns dict with: final_answer, key_insights, iteration_count, all_iterations
    """
    query_results_formatted = format_dataframe_for_display(query_results_df)

    if verbose:
        print(f"[3.1] Generating formatted answer...")

    # Initial answer generation
    answer_prompt = get_answer_generation_prompt(
        question, sql_query, query_results_formatted
    )
    answer_response = call_anthropic_api(model, answer_prompt)
    current_answer = parse_json_response(answer_response)

    if verbose:
        print(f"  ✓ Generated initial answer")

    all_iterations = [{
        "iteration": 0,
        "answer_generation": current_answer,
        "critique": None,
    }]

    # Reflection loop
    for iteration in range(1, max_iterations + 1):
        if verbose:
            print(f"\n[3.{iteration + 1}] Running critique iteration {iteration}/{max_iterations}...")

        # Critique current answer
        critique_prompt = get_answer_critique_prompt(
            question, query_results_formatted, current_answer
        )
        critique_response = call_anthropic_api(model, critique_prompt)
        critique = parse_json_response(critique_response)

        if verbose:
            print(f"  ✓ Critique completed")
            print(f"  ✓ Issues found: {len(critique.get('issues_found', []))}")
            print(f"  ✓ Should continue: {critique.get('should_continue')}")

        all_iterations[-1]["critique"] = critique

        # Check if we should stop
        if not critique.get("should_continue", True):
            if verbose:
                print(f"  ✓ Answer validated - no changes needed")
            break

        # Apply improvements if suggested
        revised_answer = critique.get("revised_answer")
        if revised_answer:
            if verbose:
                print(f"  ✓ Applying improved answer")

            current_answer["answer"] = revised_answer

            all_iterations.append({
                "iteration": iteration,
                "answer_generation": current_answer.copy(),
                "critique": None,
            })

    return {
        "final_answer": current_answer.get("answer", ""),
        "key_insights": current_answer.get("key_insights", []),
        "data_summary": current_answer.get("data_summary", ""),
        "iteration_count": len(all_iterations),
        "all_iterations": all_iterations,
    }


def main():
    """
    Command-line interface for the SQL agent.
    """
    import argparse

    parser = argparse.ArgumentParser(
        description="Text-to-SQL Agent with Triple Reflection Pattern"
    )
    parser.add_argument(
        "question",
        help="Natural language question about the Chinook database",
    )
    parser.add_argument(
        "--db",
        default=None,
        help="Path to SQLite database (default: chinook.db in same directory)",
    )
    parser.add_argument(
        "--max-iterations",
        type=int,
        default=3,
        help="Maximum reflection iterations per stage (default: 3)",
    )
    parser.add_argument(
        "--model",
        default="claude-sonnet-4-5-20250929",
        help="Claude model to use (default: claude-sonnet-4-5-20250929)",
    )
    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Suppress progress messages",
    )

    args = parser.parse_args()

    result = run_sql_agent(
        question=args.question,
        db_path=args.db,
        max_iterations=args.max_iterations,
        model=args.model,
        verbose=not args.quiet,
    )

    # Print result based on status
    if result["status"] == "success":
        if args.quiet:
            print(result["final_answer"])
        return 0
    elif result["status"] == "rejected":
        print(f"\n✗ Request Rejected: {result['rejection_reason']}\n")
        return 1
    else:
        print(f"\n✗ Error: {result['error_message']}\n")
        return 1


if __name__ == "__main__":
    import sys
    sys.exit(main())

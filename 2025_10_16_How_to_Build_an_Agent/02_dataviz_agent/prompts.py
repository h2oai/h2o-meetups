"""
Prompt templates for the data visualization agent.

This module provides structured prompts for:
1. Initial chart code generation
2. Chart critique (with vision)
3. Chart code improvement
"""


def get_chart_generation_prompt(
    dataset_schema: str,
    dataset_description: str,
    user_request: str,
    output_path: str,
) -> str:
    """
    Generate prompt for initial chart code generation.

    Args:
        dataset_schema: String describing dataset columns and types
        dataset_description: Human-readable description of the dataset
        user_request: User's visualization request
        output_path: Path where the chart PNG should be saved

    Returns:
        Formatted prompt string
    """
    return f"""You are an expert data visualization engineer specializing in Plotly.

Your task is to generate Python code that creates a professional, insightful visualization.

DATASET SCHEMA:
{dataset_schema}

DATASET DESCRIPTION:
{dataset_description}

USER REQUEST:
{user_request}

REQUIREMENTS:
1. Use plotly.express or plotly.graph_objects (choose the most appropriate)
2. Assume a pandas DataFrame named 'df' already exists with the data
3. Create a clear, professional visualization that directly answers the user's request
4. Include:
   - Descriptive title that explains what the chart shows
   - Clear axis labels with units if applicable
   - Legend if multiple series are present
   - Appropriate color scheme (use colorblind-friendly palettes)
5. Save the figure as a high-quality PNG:
   - Use fig.write_image("{output_path}", width=1200, height=800, scale=2)
   - This creates a 2400x1600 pixel image at 2x scale for crisp rendering
6. Do NOT use plt.show() or fig.show()
7. Handle any necessary data transformations (groupby, pivot, etc.)
8. Use appropriate chart type for the data (bar, line, scatter, pie, etc.)

OUTPUT FORMAT:
Return ONLY the Python code wrapped in <execute_python>...</execute_python> tags.
Do not include explanations or commentary outside the tags.

Example format:
<execute_python>
import plotly.express as px
import pandas as pd

# Your code here
fig = px.bar(...)
fig.update_layout(title="...", xaxis_title="...", yaxis_title="...")
fig.write_image("{output_path}", width=1200, height=800, scale=2)
</execute_python>

Generate the code now:"""


def get_chart_critique_prompt(
    user_request: str,
    dataset_description: str,
) -> str:
    """
    Generate prompt for chart critique (with vision).

    Args:
        user_request: Original user's visualization request
        dataset_description: Description of the dataset

    Returns:
        Formatted prompt string for critique
    """
    return f"""You are a data visualization expert reviewing a chart for quality and effectiveness.

USER'S ORIGINAL REQUEST:
{user_request}

DATASET CONTEXT:
{dataset_description}

Please analyze the attached chart image comprehensively across these dimensions:

1. **ACCURACY**: Does the chart correctly answer the user's request? Is the data represented accurately?

2. **CLARITY**: Are the following elements clear and complete?
   - Title: Is it descriptive and informative?
   - Axis labels: Are they present, clear, and include units if needed?
   - Legend: Is it present (if needed) and easy to understand?
   - Data labels: Would additional labels improve understanding?

3. **COLOR & ACCESSIBILITY**:
   - Are colors accessible (colorblind-friendly)?
   - Is there good contrast between elements?
   - Are colors semantically meaningful?

4. **CHART TYPE**: Is the chosen chart type optimal for the data and question?

5. **VISUAL QUALITY**:
   - Is the chart cluttered or clean?
   - Are there too many or too few elements?
   - Is the overall design professional?

6. **SPECIFIC IMPROVEMENTS**: What concrete changes would make this chart better?

OUTPUT FORMAT:
Return ONLY a valid JSON object with this exact structure:

{{
  "accuracy_feedback": "Brief assessment of whether the chart correctly answers the request",
  "clarity_feedback": "Assessment of titles, labels, legends, and overall clarity",
  "color_feedback": "Assessment of color choices and accessibility",
  "chart_type_feedback": "Assessment of whether the chart type is appropriate",
  "visual_quality_feedback": "Assessment of overall visual design and professionalism",
  "improvement_suggestions": [
    "Specific improvement 1",
    "Specific improvement 2",
    "Specific improvement 3"
  ],
  "should_continue": true or false
}}

Set "should_continue" to false if the chart is excellent and needs no improvements.
Set "should_continue" to true if there are meaningful improvements to be made.

Provide your critique now:"""


def get_chart_improvement_prompt(
    original_code: str,
    critique_feedback: dict,
    user_request: str,
    dataset_schema: str,
    dataset_description: str,
    output_path: str,
) -> str:
    """
    Generate prompt for improving chart code based on critique.

    Args:
        original_code: The original Python code that generated the chart
        critique_feedback: Dictionary containing the critique feedback
        user_request: Original user's visualization request
        dataset_schema: String describing dataset columns and types
        dataset_description: Human-readable description of the dataset
        output_path: Path where the improved chart PNG should be saved

    Returns:
        Formatted prompt string for improvement
    """
    # Format the critique feedback nicely
    feedback_text = f"""
ACCURACY: {critique_feedback.get('accuracy_feedback', 'N/A')}

CLARITY: {critique_feedback.get('clarity_feedback', 'N/A')}

COLOR & ACCESSIBILITY: {critique_feedback.get('color_feedback', 'N/A')}

CHART TYPE: {critique_feedback.get('chart_type_feedback', 'N/A')}

VISUAL QUALITY: {critique_feedback.get('visual_quality_feedback', 'N/A')}

IMPROVEMENT SUGGESTIONS:
"""
    for i, suggestion in enumerate(critique_feedback.get('improvement_suggestions', []), 1):
        feedback_text += f"{i}. {suggestion}\n"

    return f"""You are an expert data visualization engineer improving a Plotly chart based on critique feedback.

USER'S ORIGINAL REQUEST:
{user_request}

DATASET SCHEMA:
{dataset_schema}

DATASET DESCRIPTION:
{dataset_description}

ORIGINAL CODE:
{original_code}

CRITIQUE FEEDBACK:
{feedback_text}

YOUR TASK:
Refine the code to address ALL the feedback points while:
1. Maintaining all working functionality
2. Ensuring the code still saves to: {output_path}
3. Improving visual quality and clarity
4. Following Plotly best practices
5. Keeping the same general approach (don't completely rewrite unless necessary)

KEY IMPROVEMENTS TO FOCUS ON:
- Address each improvement suggestion specifically
- Enhance titles, labels, and legends based on clarity feedback
- Improve color schemes based on accessibility feedback
- Refine chart type if suggested
- Enhance overall visual design

OUTPUT FORMAT:
Return ONLY the refined Python code wrapped in <execute_python>...</execute_python> tags.
Do not include explanations or commentary outside the tags.

Example format:
<execute_python>
import plotly.express as px
import pandas as pd

# Improved code here
fig = px.bar(...)
fig.update_layout(
    title="More descriptive title",
    xaxis_title="Clear axis label",
    yaxis_title="Clear axis label with units"
)
fig.write_image("{output_path}", width=1200, height=800, scale=2)
</execute_python>

Generate the improved code now:"""

# Data Visualization Agent with Reflection Pattern

An intelligent agent that generates high-quality data visualizations using Plotly with iterative refinement through AI critique.

## Overview

This agent implements the **reflection pattern** for automated visualization generation:

1. **Generate**: Claude Haiku 4.5 creates initial Plotly code
2. **Execute**: Run code and save PNG chart
3. **Critique**: Claude Sonnet 4.5 analyzes the chart image (vision-based)
4. **Improve**: Haiku refines code based on feedback
5. **Loop**: Repeat until max iterations or no improvements needed
6. **Return**: Final chart and code

## Features

- **Vision-Based Critique**: AI analyzes the actual rendered chart, not just code
- **Iterative Refinement**: Automatically improves visualizations through multiple rounds
- **Flexible Input**: Supports both local CSV files and URLs
- **Smart Stopping**: Automatically stops when no improvements are needed
- **Professional Output**: High-quality PNG charts with proper labels, titles, and colors
- **Customizable**: Configure models, iterations, and output locations
- **Plotly-Powered**: Modern, interactive-ready visualizations

## Installation

### Prerequisites

- Python 3.12+
- Anthropic API key (for Claude models)

### Setup

1. Install dependencies:
```bash
# From the project root
pip install -e .
```

This will install:
- `plotly` (visualization library)
- `kaleido` (PNG export)
- `pandas` (data handling)
- `pillow` (image processing)
- `anthropic` (Claude API)
- Other dependencies from `pyproject.toml`

2. Set up your API key:
```bash
# Create a .env file in the project root
echo "ANTHROPIC_API_KEY=your-key-here" > .env
```

## Usage

### Python API

```python
from dataviz_agent.agent import run_dataviz_agent

# Basic usage
result = run_dataviz_agent(
    csv_source="data.csv",
    user_request="Show sales by region",
)

print(f"Chart saved to: {result['final_chart_path']}")
```

### Full Example

```python
result = run_dataviz_agent(
    csv_source="customer_churn.csv",
    user_request="Visualize all customer churn reasons with percentage breakdown",
    dataset_description="Customer churn data with reasons, tenure, and satisfaction scores",
    max_iterations=3,
    generation_model="claude-haiku-4.5-20250915",
    critique_model="claude-sonnet-4.5-20250929",
    output_dir="./outputs",
    output_basename="churn_analysis",
    verbose=True,
)

if result["status"] == "success":
    print(f"✓ Created chart in {result['iteration_count']} iterations")
    print(f"✓ Final chart: {result['final_chart_path']}")

    # Access iteration details
    for iteration in result['all_iterations']:
        print(f"Iteration {iteration['iteration']}: {iteration['chart_path']}")
else:
    print(f"✗ Error: {result['error_message']}")
```

### Command-Line Interface

```bash
# Basic usage
python -m dataviz_agent.agent data.csv "Show sales trends over time"

# With options
python -m dataviz_agent.agent \
    data.csv \
    "Visualize customer churn reasons" \
    --description "Customer churn dataset with multiple features" \
    --max-iterations 3 \
    --output-dir ./outputs \
    --output-name my_chart

# Quiet mode
python -m dataviz_agent.agent data.csv "Show distribution" --quiet
```

### Using a URL

```python
result = run_dataviz_agent(
    csv_source="https://example.com/data.csv",
    user_request="Create a scatter plot of the data",
    max_iterations=2,
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `csv_source` | str | **required** | Path to CSV file or URL |
| `user_request` | str | **required** | Description of desired visualization |
| `dataset_description` | str | None | Dataset description (auto-generated if not provided) |
| `max_iterations` | int | 3 | Maximum refinement iterations |
| `generation_model` | str | `claude-haiku-4.5-20250915` | Model for code generation |
| `critique_model` | str | `claude-sonnet-4.5-20250929` | Model for critique |
| `output_dir` | str | `./outputs` | Directory for output files |
| `output_basename` | str | `chart` | Base name for output files |
| `verbose` | bool | True | Print progress messages |

## Return Value

The agent returns a dictionary with:

```python
{
    "status": "success" or "error",
    "final_chart_path": "path/to/chart_final.png",
    "final_code": "# Python code that generated the chart",
    "iteration_count": 3,
    "all_iterations": [
        {
            "iteration": 0,
            "code": "...",
            "chart_path": "...",
            "critique": None or {...}
        },
        # ... more iterations
    ],
    "dataset_rows": 1000,
    "dataset_columns": 5,
    "error_message": "..." (only if status is "error")
}
```

## Examples

See `example_runs.ipynb` for comprehensive examples:

1. **Coffee Sales Analysis**: Time-series visualization with categorical grouping
2. **Customer Churn**: Categorical breakdown with percentages
3. **Sales Performance**: Multi-region trend comparison
4. **URL Source**: Using remote CSV data

Run the notebook:
```bash
cd dataviz-agent
jupyter notebook example_runs.ipynb
```

## Architecture

### File Structure

```
dataviz-agent/
├── agent.py          # Main workflow orchestration
├── utils.py          # Helper functions
├── prompts.py        # Prompt templates
├── example_runs.ipynb # Demonstration notebook
└── README.md         # This file
```

### Workflow Details

#### 1. Dataset Loading
- Supports local CSV files and URLs
- Auto-detects and parses data
- Generates schema description

#### 2. Initial Generation
- Creates a detailed prompt with dataset schema
- Claude Haiku generates Plotly code
- Code is wrapped in `<execute_python>` tags

#### 3. Execution
- Safely executes code with DataFrame context
- Saves high-quality PNG (2400x1600 pixels at 2x scale)
- Error handling with detailed messages

#### 4. Vision-Based Critique
- Claude Sonnet analyzes the rendered PNG image
- Evaluates accuracy, clarity, colors, and design
- Returns structured JSON feedback with `should_continue` flag

#### 5. Iterative Improvement
- Generates improved code based on critique
- Executes and saves new version
- Compares against original request
- Continues until max iterations or critique says stop

#### 6. Result Compilation
- Saves final chart
- Returns all iteration details
- Provides final code for reproduction

## Prompt Design

### Generation Prompt
Emphasizes:
- Plotly best practices
- Clear titles, labels, legends
- Accessible color schemes
- High-quality output (300 DPI)
- Dataset schema understanding

### Critique Prompt
Evaluates:
- **Accuracy**: Does it answer the request?
- **Clarity**: Are labels and titles clear?
- **Colors**: Accessible and meaningful?
- **Chart Type**: Appropriate for the data?
- **Design**: Professional and clean?

### Improvement Prompt
Focuses on:
- Addressing specific feedback
- Maintaining functionality
- Enhancing visual quality
- Following best practices

## Customization

### Using Different Models

```python
result = run_dataviz_agent(
    csv_source="data.csv",
    user_request="...",
    generation_model="claude-3-opus-20240229",  # Use a different model
    critique_model="claude-3-sonnet-20240229",
)
```

### Adjusting Iterations

```python
# Quick mode (1 iteration)
result = run_dataviz_agent(
    csv_source="data.csv",
    user_request="...",
    max_iterations=1,
)

# Thorough mode (5 iterations)
result = run_dataviz_agent(
    csv_source="data.csv",
    user_request="...",
    max_iterations=5,
)
```

### Custom Output Location

```python
result = run_dataviz_agent(
    csv_source="data.csv",
    user_request="...",
    output_dir="/path/to/my/charts",
    output_basename="custom_name",
)
# Creates: /path/to/my/charts/custom_name_final.png
```

## Troubleshooting

### API Key Issues

```
ValueError: Anthropic API key not configured
```

**Solution**: Set your API key in `.env` file:
```bash
echo "ANTHROPIC_API_KEY=your-key-here" > .env
```

### CSV Loading Errors

```
ValueError: Failed to load dataset from source.csv
```

**Solutions**:
- Check file path is correct
- For URLs, ensure they're publicly accessible
- Verify CSV format is valid

### Code Execution Errors

If the generated code fails:
- Check the error message in `result['error_message']`
- Verify dataset has expected columns
- Try simplifying the visualization request
- Review the generated code in `result['code']`

### Kaleido Installation Issues

If PNG export fails:
```bash
pip install --upgrade kaleido
```

For M1/M2 Macs:
```bash
pip install kaleido --no-binary kaleido
```

## Advanced Usage

### Accessing Iteration Details

```python
result = run_dataviz_agent(...)

for i, iteration in enumerate(result['all_iterations']):
    print(f"\n--- Iteration {i} ---")
    print(f"Chart: {iteration['chart_path']}")

    if iteration['critique']:
        critique = iteration['critique']
        print(f"Accuracy: {critique['accuracy_feedback']}")
        print(f"Improvements: {len(critique['improvement_suggestions'])}")
        print(f"Continue: {critique['should_continue']}")
```

### Comparing Iterations

```python
from IPython.display import Image, display

result = run_dataviz_agent(...)

# Display all iterations side by side
for iteration in result['all_iterations']:
    print(f"Iteration {iteration['iteration']}")
    display(Image(filename=iteration['chart_path']))
```

### Extracting Final Code

```python
result = run_dataviz_agent(...)

# Save final code to file
with open("final_visualization.py", "w") as f:
    f.write(result['final_code'])
```

## Best Practices

1. **Clear Requests**: Be specific about what you want to visualize
   - ✓ "Show monthly sales trends by region with line chart"
   - ✗ "Show data"

2. **Dataset Description**: Provide context when available
   - ✓ "Customer churn data with demographics and service usage"
   - ✗ None (though auto-generation works)

3. **Appropriate Iterations**: Balance quality vs. API calls
   - Quick analysis: 1-2 iterations
   - Production charts: 3-4 iterations
   - Not recommended: >5 iterations

4. **Output Organization**: Use descriptive output names
   ```python
   output_basename="customer_churn_by_region_2024"
   ```

5. **Review Results**: Check the critique feedback
   ```python
   if result['status'] == 'success':
       last_critique = result['all_iterations'][-1]['critique']
       if last_critique:
           print(last_critique['improvement_suggestions'])
   ```

## Limitations

- Requires Anthropic API access
- Vision critique needs Claude models with vision support
- PNG export requires kaleido
- Large datasets may need preprocessing
- Complex multi-chart dashboards not supported (single chart focus)

## Contributing

To extend the agent:

1. **Add new prompt templates** in `prompts.py`
2. **Add utility functions** in `utils.py`
3. **Modify workflow** in `agent.py`
4. **Add examples** in `example_runs.ipynb`

## License

See project root for license information.

## Support

For issues or questions:
- Check the examples in `example_runs.ipynb`
- Review this README
- Examine the code in `agent.py` and `utils.py`

---

Built with the reflection pattern for iterative AI improvement.

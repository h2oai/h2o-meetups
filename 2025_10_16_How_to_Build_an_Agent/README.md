# Agentic AI: Building Agents with Reflection

This repository contains practical examples of building AI agents using the **reflection pattern** — a technique where agents iteratively improve their outputs through self-critique and refinement.

## 📊 Background

For a comprehensive understanding of the AI agent landscape, including types of agents, autonomy levels, and real-world applications, please refer to the [presentation slides](how-to-build-an-agent-2025-10-16.pdf) included in this repository.

**Key Concepts Covered in the Presentation:**
- What defines an AI agent (autonomy, goal-directedness, perception, adaptation)
- Spectrum of agent autonomy: from RPA workflows to fully autonomous agents
- Types of agents: Tool-calling, MCP agents, Reflection agents, and Autonomous agents
- Production-ready agentic systems at H2O.ai

## 🚀 Quick Start

### Prerequisites

- Python 3.12+
- [uv](https://docs.astral.sh/uv/) package manager

### Installation

1. Clone this repository:
```bash
git clone https://github.com/h2oai/h2o-meetups.git
cd h2o-meetups/2025_10_16_How_to_Build_an_Agent
```

2. Install dependencies using `uv`:
```bash
uv sync
```

This will install all required packages from `pyproject.toml`.

### Configuration

Each agent example has its own `.env.example` file. Before running any agent:

1. Navigate to the agent directory (e.g., `01_simple_agent/`)
2. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
3. Add your API key(s) to the `.env` file:
   ```
   OPENAI_API_KEY=your-openai-api-key
   ANTHROPIC_API_KEY=your-anthropic-api-key
   ```

## 🤖 Example Agents

### 1. Simple Agent with Reflection (`01_simple_agent/`)

**What it does:** A poetry-writing agent that demonstrates the basic reflection pattern. The agent writes a poem, critiques it, and then improves it based on the feedback.

**Reflection Pattern:**
1. **Generate**: Write initial poem on a given topic with word count constraints
2. **Reflect**: Analyze the poem for topic adherence and word count accuracy
3. **Improve**: Revise the poem based on critique feedback

**Key Features:**
- Single-loop reflection (one iteration)
- Uses different models for generation (GPT-5 Nano) and critique (GPT-5)
- Demonstrates separation of "creator" and "critic" roles
- JSON-structured feedback and outputs

**Run the example:**
```bash
cd 01_simple_agent
jupyter lab simple_agent.ipynb
```

### 2. Data Visualization Agent (`02_dataviz_agent/`)

**What it does:** An intelligent agent that generates professional data visualizations using Plotly with iterative refinement through vision-based AI critique.

**Reflection Pattern:**
1. **Generate**: Claude Haiku creates initial Plotly visualization code
2. **Execute**: Run the code and save the chart as PNG
3. **Critique**: Claude Sonnet analyzes the actual rendered chart image (vision model)
4. **Improve**: Haiku refines code based on visual feedback
5. **Loop**: Repeats up to N iterations or until no improvements needed

**Key Features:**
- Multi-iteration reflection loop (configurable max iterations)
- Vision-based critique (AI analyzes the actual chart, not just code)
- Automatic convergence detection (stops when no improvements are needed)
- Supports CSV files and URLs as data sources
- Produces publication-quality PNG outputs

**Run the example:**
```bash
cd 02_dataviz_agent
jupyter lab example_runs.ipynb
```

### 3. Text-to-SQL Agent (`03_sql_agent/`)

**What it does:** A production-ready SQL agent that converts natural language questions into safe, validated SQL queries using a **triple reflection pattern** for comprehensive quality assurance.

**Triple Reflection Pattern:**

**Stage 1: Intent Triage & Security Validation**
- Validates the question is database-related
- Detects malicious intent (social engineering, injection attempts)
- Iteratively refines understanding with up to N loops

**Stage 2: SQL Query Generation & Validation**
- Generates read-only SQL queries
- Validates query syntax and security
- Ensures no data modification operations (INSERT, UPDATE, DELETE)
- Iteratively refines with up to N loops

**Stage 3: Answer Formatting & Quality Assurance**
- Executes validated query
- Formats results into natural language
- Ensures answer quality and completeness
- Iteratively refines with up to N loops

**Key Features:**
- Security-first design with multiple validation layers
- Read-only enforcement at multiple stages
- Works with Chinook music store database (included)
- Malicious pattern detection (privilege escalation, injection, social engineering)
- Natural language answers from raw SQL results
- Comprehensive logging for transparency

**Run the example:**
```bash
cd 03_sql_agent
jupyter lab example_runs.ipynb
```

## 📚 Learning Path

**Recommended order for learning:**

1. **Start with `01_simple_agent/`** - Understand the basic reflection loop
2. **Move to `02_dataviz_agent/`** - See multi-iteration reflection with convergence
3. **Study `03_sql_agent/`** - Explore advanced triple-stage reflection for production use

## 🔑 Key Takeaways

**What is Reflection in AI Agents?**

Reflection is a pattern where an AI agent:
1. Generates an initial output
2. Critiques its own work (or uses another model to critique)
3. Improves the output based on feedback
4. Optionally repeats until convergence or max iterations

**Why Use Reflection?**
- **Higher Quality**: Catches mistakes and refines outputs
- **Self-Correction**: Agents can improve without external feedback
- **Specialization**: Separate models for generation vs. critique
- **Production Ready**: Multiple validation stages for critical applications

**When to Use Multiple Reflection Loops?**
- Simple tasks: 1 loop (example: `01_simple_agent`)
- Moderate complexity: 2-3 loops (example: `02_dataviz_agent`)
- High-stakes applications: Multiple stages with N loops each (example: `03_sql_agent`)

## 🎯 Running the Notebooks

Each agent directory contains a Jupyter notebook with interactive examples:

```bash
# After setting up your .env file in the agent directory
cd <agent_directory>
jupyter lab <notebook_name>.ipynb
```

Follow the cells in order to see the agent in action. The notebooks include:
- Setup and imports
- Configuration
- Step-by-step execution
- Output visualization
- Reflection loop demonstrations

## 📖 Additional Resources

- **Anthropic's Building Effective Agents**: Best practices from Claude's creators
- **12-Factor Agents (HumanLayer)**: Patterns for reliable LLM applications
- **DeepLearning.AI Courses**: Comprehensive agent development tutorials
- **H2O.ai Platform**: Production-grade agentic AI platform

## 🤝 Contributing

Feel free to explore, experiment, and extend these examples! Each agent serves as a foundation for building more sophisticated agentic systems.

**Happy Agent Building! 🚀**

For questions or feedback, please open an issue or reach out to the maintainers.

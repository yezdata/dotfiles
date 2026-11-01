# Global Coding & Tooling Rules

## Code Documentation, Comments & Naming
- **Language:** Write all identifiers (variables, functions, classes, modules), code comments, docstrings, type annotations, log/print messages, exception strings, and commit messages strictly in English. Never use Czech anywhere in the codebase, even if the prompt is in Czech.
- **Naming Conventions:** Keep all identifiers concise, general, and appropriately scoped. Do not encode specific datasets, hardware targets, execution contexts, or temporary implementation details into function or variable names (e.g., use `run_pipeline` instead of `run_pipeline_cuda_emo_dataset`). Let parameters, configuration, and surrounding scope carry the specifics.
- **Formatting & Alignment:** Never vertically align assignment operators (`=`), dictionary colons (`:`), type annotations, or inline comments across lines using extra spaces. Always use a single space around operators (`VAR = value`, never `VAR    = value`).
- **Logging & Output:** Do not clutter code with narration or step-by-step status `print` statements (e.g., `print("Loading data...")`, `print("Data loaded.")`...). Keep standard output minimal, high-signal, and reserved strictly for essential results, final metrics, or explicitly requested output.
- **Zero-Noise Policy:** Do not write redundant comments that merely restate what the code does. Self-explanatory code requires no comments.
- **When to Comment:** Add inline comments ONLY for non-obvious edge cases, complex algorithmic logic, performance workarounds, or unintuitive business constraints (explain the *why*, never the *what*).
- **Docstrings:** Omit docstrings for simple, self-descriptive functions, methods, and classes. Write concise docstrings only for complex public APIs, non-trivial classes, or functions with intricate signatures/side effects.

## Python Environment & Package Management (`uv`)
Always use `uv` for all Python execution, environment management, and package installation. Never use raw `pip`, `python -m venv`, or `poetry`.
- **With `pyproject.toml`:** Use `uv run`, `uv add`, and `uv sync`.
- **Without `pyproject.toml` (ad-hoc/legacy directories):** Still enforce `uv`. Use `uv venv` to initialize environments, `uv pip install <pkg>` to install packages, and `uv run python <script.py>` (or `uv run --with <pkg> <script.py>`) to execute code.

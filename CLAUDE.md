# LTA-HHS Fairness Awareness R Project Guide

## Build Commands
- Initial setup: `source("_Setup.R")` - install required packages
- Render advanced report: `quarto render --profile advanced-report`
- Render basic report: `quarto render --profile basic-report`
- Programmatic rendering: `Rscript quarto-render-advanced-report.R` or `Rscript quarto-render-basic-report.R`

## Code Style Guidelines
- Follow [Tidyverse style guide](https://style.tidyverse.org/) conventions
- Use tidyverse packages (dplyr, tidyr, purrr, etc.) for data manipulation
- Prefer %>% pipe operator for chaining operations
- Variable/function names: use snake_case (lowercase with underscores)
- Indent with 2 spaces
- Comment code thoroughly, especially when implementing statistical methods
- Always use explicit return statements in functions
- Handle errors with tryCatch() for graceful error handling

## Git Workflow
- Always pull before committing: `git pull`
- Use short, concise commit messages with the format:
  - `fix: short description` (for bug fixes)
  - `feat: short description` (for new features)
  - `docs: short description` (for documentation changes)
  - `chore: short description` (for maintenance tasks)
- Example: `git commit -m "fix: add vscode user to rstudio-server group"`

## Project Structure
- R/ - Core functions and data
- R/functions/ - Helper function modules
- R/scripts/ - Analysis scripts
- R/qmd/ - Quarto document components

This project uses the renv package for dependency management.
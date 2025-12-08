# Scripts Directory

This directory contains utility scripts for maintaining code quality and consistency.

## Available Scripts

### validate_data_layer.sh

**Purpose:** Validates that all features follow the unified data layer architecture.

**Usage:**
```bash
bash scripts/validate_data_layer.sh
```

**What it checks:**
- Each feature has a `data` directory
- Each feature has a local datasource file
- Each feature has a remote datasource file (or stub)
- Each feature has at least one DTO file
- Shared helpers exist (GraphQL error handler, cache helper)

**Exit codes:**
- `0`: All checks passed
- `1`: One or more checks failed

**When to run:**
- Before committing data layer changes
- After adding a new feature
- As part of CI/CD pipeline

### Future Scripts

Additional scripts may be added here for:
- Code generation automation
- Test coverage checks
- Documentation validation
- Performance benchmarks

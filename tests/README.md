# Property-Based Tests for ECS Migration

This directory contains property-based tests for the Render to ECS migration project.

## Setup

Install the required dependencies:

```bash
pip install -r requirements.txt
```

## Running Tests

Run all tests:

```bash
python -m pytest -v
```

Run specific test file:

```bash
python -m pytest test_memory_allocation.py -v
```

## Test Coverage

### Memory Allocation Constraints (`test_memory_allocation.py`)

**Property 1: Memory Allocation Constraint**
- **Validates**: Requirements 2.4
- **Description**: Tests that memory allocation for any service deployment configuration does not exceed t3.micro usable capacity (840MB, leaving 100MB system buffer)

The test includes:
- Property-based testing with 100+ random configurations
- Boundary condition testing
- Multiple services scenario testing
- System buffer calculation validation

## Test Framework

- **Property-Based Testing Library**: Hypothesis for Python
- **Test Configuration**: Minimum 100 iterations per property test
- **Test Runner**: pytest

Each property test is tagged with the corresponding requirement reference for traceability.
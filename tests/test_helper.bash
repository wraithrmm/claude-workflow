#!/bin/bash

# Test helper for claude-workflow plugin tests
# Since scripts use env vars, no sed path rewriting needed — just set PLAYGROUND_DIR

export PLUGIN_ROOT="$BATS_TEST_DIRNAME/.."
export TEST_DIR="/tmp/test-workflow-$$"

setup() {
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    export PROJECT_ROOT="$TEST_DIR"
    export PLAYGROUND_DIR="$TEST_DIR/ai-playground"
}

teardown() {
    rm -rf "$TEST_DIR"
}

# Create ai-playground structure
create_playground() {
    mkdir -p "$PLAYGROUND_DIR/tasks"/{planning,approved,in-progress,completed}
    mkdir -p "$PLAYGROUND_DIR/projects"
}

# Create a test project
create_test_project() {
    local name="$1"
    local status="${2:-active}"
    local dir="$PLAYGROUND_DIR/projects/$name"
    mkdir -p "$dir/tasks"/{planning,approved,in-progress,completed}
    echo "# Project: $name" > "$dir/plan.md"
    echo "# Progress Log" > "$dir/progress.md"
    echo "# Project Notes" > "$dir/notes.md"
    cat > "$dir/status.json" << EOF
{
  "project": "$name",
  "created": "2026-01-01 00:00:00",
  "status": "$status",
  "completion_percent": 0,
  "last_updated": "2026-01-01 00:00:00",
  "summary": "Test project"
}
EOF
}

# Create a task file
create_task_file() {
    local status="$1"
    local task_name="$2"
    mkdir -p "$PLAYGROUND_DIR/tasks/$status"
    cat > "$PLAYGROUND_DIR/tasks/$status/$task_name.md" << EOF
# Task: $task_name
Status: $status
Created: 2026-01-01 00:00:00
Updated: 2026-01-01 00:00:00
PRP-Template: none

## Project Intention
Test task

## Acceptance Criteria
- [ ] Test criterion

## Notes
Test notes
EOF
}

# Create a project task file
create_project_task_file() {
    local project="$1"
    local status="$2"
    local task_name="$3"
    mkdir -p "$PLAYGROUND_DIR/projects/$project/tasks/$status"
    cat > "$PLAYGROUND_DIR/projects/$project/tasks/$status/$task_name.md" << EOF
# Task: $task_name
Status: $status
Created: 2026-01-01 00:00:00
Updated: 2026-01-01 00:00:00
PRP-Template: none
Project: $project

## Project Intention
Test task in project $project

## Acceptance Criteria
- [ ] Test criterion

## Notes
Test notes
EOF
}

# Assertions
assert_success() { [[ "$status" -eq 0 ]] || { echo "Expected success, got $status: $output" >&2; return 1; }; }
assert_failure() { [[ "$status" -ne 0 ]] || { echo "Expected failure: $output" >&2; return 1; }; }
assert_output_contains() { echo "$output" | grep -Fq -- "$1" || { echo "Missing: $1" >&2; echo "Got: $output" >&2; return 1; }; }
refute_output_contains() { ! echo "$output" | grep -Fq -- "$1" || { echo "Unexpected: $1" >&2; return 1; }; }
assert_dir_exists() { [[ -d "$1" ]] || { echo "Dir missing: $1" >&2; return 1; }; }
assert_file_exists() { [[ -f "$1" ]] || { echo "File missing: $1" >&2; return 1; }; }
assert_file_contains() { grep -q "$2" "$1" || { echo "File $1 missing: $2" >&2; return 1; }; }

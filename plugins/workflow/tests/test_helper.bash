#!/bin/bash
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Test helper for claude-workflow plugin tests.
# Scripts resolve their paths from PROJECT_ROOT and PLAYGROUND_DIR, so each test
# points both at a throwaway directory and runs the scripts in place.

export PLUGIN_ROOT="$BATS_TEST_DIRNAME/.."
export TEST_DIR="/tmp/test-workflow-$$"

setup() {
    setup_test_env
}

teardown() {
    rm -rf "$TEST_DIR"
}

setup_test_env() {
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    export PROJECT_ROOT="$TEST_DIR"
    export PLAYGROUND_DIR="$TEST_DIR/ai-playground"
}

setup_playground_test() {
    setup_test_env
    create_playground
}

create_playground() {
    mkdir -p "$PLAYGROUND_DIR/tasks"/{planning,approved,in-progress,completed}
    mkdir -p "$PLAYGROUND_DIR/projects"
}

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

create_task_file() {
    local status="$1"
    local task_name="$2"
    local created_date="${3:-2024-01-15 10:00:00}"
    local template="${4:-none}"
    mkdir -p "$PLAYGROUND_DIR/tasks/$status"
    cat > "$PLAYGROUND_DIR/tasks/$status/$task_name.md" << EOF
# Task: $task_name
Status: $status
Created: $created_date
Updated: $created_date
PRP-Template: $template

## Project Intention
Test task for $task_name

## Acceptance Criteria
- [ ] Test criterion 1
- [ ] Test criterion 2

## Implementation Approach
Test implementation approach

## Technical Details
Test technical details

## Notes
Test notes
EOF
}

create_project_task_file() {
    local project="$1"
    local status="$2"
    local task_name="$3"
    local created_date="${4:-2024-01-15 10:00:00}"
    local template="${5:-none}"
    mkdir -p "$PLAYGROUND_DIR/projects/$project/tasks/$status"
    cat > "$PLAYGROUND_DIR/projects/$project/tasks/$status/$task_name.md" << EOF
# Task: $task_name
Status: $status
Created: $created_date
Updated: $created_date
PRP-Template: $template
Project: $project

## Project Intention
Test task for $task_name in project $project

## Acceptance Criteria
- [ ] Test criterion 1
- [ ] Test criterion 2

## Implementation Approach
Test implementation approach

## Technical Details
Test technical details

## Notes
Test notes
EOF
}

create_file() {
    local file="$1"
    local content="$2"
    mkdir -p "$(dirname "$file")"
    echo "$content" > "$file"
}

assert_success() { [[ "$status" -eq 0 ]] || { echo "Expected success, got $status: $output" >&2; return 1; }; }
assert_failure() { [[ "$status" -ne 0 ]] || { echo "Expected failure: $output" >&2; return 1; }; }
assert_exit_code() { [[ "$status" -eq "$1" ]] || { echo "Expected exit code $1, got $status: $output" >&2; return 1; }; }
assert_output() { [[ "$output" == "$1" ]] || { echo "Expected: $1" >&2; echo "Actual: $output" >&2; return 1; }; }
assert_output_contains() { echo "$output" | grep -Fq -- "$1" || { echo "Missing: $1" >&2; echo "Got: $output" >&2; return 1; }; }
refute_output_contains() { ! echo "$output" | grep -Fq -- "$1" || { echo "Unexpected: $1" >&2; echo "Got: $output" >&2; return 1; }; }
assert_dir_exists() { [[ -d "$1" ]] || { echo "Dir missing: $1" >&2; return 1; }; }
assert_file_exists() { [[ -f "$1" ]] || { echo "File missing: $1" >&2; return 1; }; }
assert_file_not_exists() { [[ ! -f "$1" ]] || { echo "File should not exist: $1" >&2; return 1; }; }
assert_file_contains() { grep -q -- "$2" "$1" || { echo "File $1 missing: $2" >&2; return 1; }; }
refute_file_contains() { ! grep -q -- "$2" "$1" || { echo "File $1 unexpectedly contains: $2" >&2; return 1; }; }

assert_output_contains_all() {
    local str
    for str in "$@"; do
        assert_output_contains "$str" || return 1
    done
}

assert_next_steps_message() {
    echo "$output" | grep -E "(Next steps:|To continue:|You can now:|Note:|Now you can)" >/dev/null || {
        echo "Output does not contain next steps guidance: $output" >&2
        return 1
    }
}

assert_script_requires_args() {
    local script_path="$1"
    local expected_error="$2"
    local expected_usage="${3:-}"
    run "$script_path"
    assert_failure || return 1
    assert_output_contains "$expected_error" || return 1
    if [[ -n "$expected_usage" ]]; then
        assert_output_contains "$expected_usage"
    fi
}

assert_creates_project_structure() {
    local project_dir="$PLAYGROUND_DIR/projects/$1"
    local sub
    for sub in "" tasks/planning tasks/approved tasks/in-progress tasks/completed; do
        assert_dir_exists "$project_dir/$sub" || return 1
    done
    for sub in plan.md progress.md notes.md status.json; do
        assert_file_exists "$project_dir/$sub" || return 1
    done
}

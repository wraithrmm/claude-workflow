#!/usr/bin/env bats
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Tests for create-task script

load test_helper

@test "create-task: requires task name" {
    assert_script_requires_args "$PLUGIN_ROOT/scripts/create-task" \
        "Error: Task name is required" \
        "Usage: create-task <task-name>"
}

@test "create-task: creates task directory structure on first run" {
    run "$PLUGIN_ROOT/scripts/create-task" "test-task"
    
    assert_success
    assert_dir_exists "$PLAYGROUND_DIR/tasks/planning"
    assert_dir_exists "$PLAYGROUND_DIR/tasks/approved"
    assert_dir_exists "$PLAYGROUND_DIR/tasks/in-progress"
    assert_dir_exists "$PLAYGROUND_DIR/tasks/completed"
}

@test "create-task: creates task file in planning directory" {
    run "$PLUGIN_ROOT/scripts/create-task" "implement-feature"
    
    assert_success
    assert_file_exists "$PLAYGROUND_DIR/tasks/planning/implement-feature.md"
    assert_output_contains "Task created successfully: $PLAYGROUND_DIR/tasks/planning/implement-feature.md"
}

@test "create-task: task file contains correct structure" {
    run "$PLUGIN_ROOT/scripts/create-task" "test-structure"
    
    assert_success
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/test-structure.md" "# Task: test-structure"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/test-structure.md" "Status: planning"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/test-structure.md" "Created:"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/test-structure.md" "Updated:"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/test-structure.md" "PRP-Template: none"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/test-structure.md" "## Project Intention"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/test-structure.md" "## Acceptance Criteria"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/test-structure.md" "## Implementation Approach"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/test-structure.md" "## Technical Details"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/test-structure.md" "## Notes"
}

@test "create-task: prevents duplicate task creation in same directory" {
    # Create first task
    run "$PLUGIN_ROOT/scripts/create-task" "duplicate-test"
    assert_success
    
    # Try to create same task again
    run "$PLUGIN_ROOT/scripts/create-task" "duplicate-test"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Task 'duplicate-test' already exists in planning directory"
}

@test "create-task: prevents duplicate task creation across all directories" {
    # Create task structure first
    mkdir -p "$PLAYGROUND_DIR/tasks/approved"
    # Create existing task in approved directory
    touch "$PLAYGROUND_DIR/tasks/approved/existing-task.md"
    
    # Try to create task with same name
    run "$PLUGIN_ROOT/scripts/create-task" "existing-task"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Task 'existing-task' already exists in approved directory"
}

@test "create-task: provides next steps guidance" {
    run "$PLUGIN_ROOT/scripts/create-task" "guidance-test"
    
    assert_success
    assert_output_contains "Next steps:"
    assert_output_contains "1. Edit the task file to add details"
    assert_output_contains "2. When ready, use 'move-task guidance-test approved' to approve the task"
}

@test "create-task: handles task names with spaces" {
    # The script receives multiple arguments when spaces are used
    # It will create a task with just the first word
    run "$PLUGIN_ROOT/scripts/create-task" task with spaces
    
    assert_success
    assert_file_exists "$PLAYGROUND_DIR/tasks/planning/task.md"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/task.md" "# Task: task"
}

@test "create-task: handles task names with special characters" {
    run "$PLUGIN_ROOT/scripts/create-task" "task-with-dashes"
    
    assert_success
    assert_file_exists "$PLAYGROUND_DIR/tasks/planning/task-with-dashes.md"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/task-with-dashes.md" "# Task: task-with-dashes"
}
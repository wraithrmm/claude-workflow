#!/usr/bin/env bats
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Tests for create-project-task script

load test_helper

# Each test starts with an initialised playground
setup() {
    setup_playground_test
}

@test "create-project-task: requires project name" {
    run "$PLUGIN_ROOT/scripts/create-project-task"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Project name and task name are required"
    assert_output_contains "Usage: create-project-task <project-name> <task-name>"
}

@test "create-project-task: requires task name" {
    run "$PLUGIN_ROOT/scripts/create-project-task" "test-project"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Project name and task name are required"
    assert_output_contains "Usage: create-project-task <project-name> <task-name>"
}

@test "create-project-task: fails if project does not exist" {
    run "$PLUGIN_ROOT/scripts/create-project-task" "non-existent-project" "test-task"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Project 'non-existent-project' does not exist"
    assert_output_contains "Use '/create-project non-existent-project' to create it first"
}

@test "create-project-task: creates task in existing project" {
    create_test_project "test-project"
    
    run "$PLUGIN_ROOT/scripts/create-project-task" "test-project" "implement-feature"
    
    assert_success
    assert_file_exists "$PLAYGROUND_DIR/projects/test-project/tasks/planning/implement-feature.md"
    assert_output_contains "✅ Task created successfully in project 'test-project'"
    assert_output_contains "Task file: $PLAYGROUND_DIR/projects/test-project/tasks/planning/implement-feature.md"
}

@test "create-project-task: task file contains correct structure" {
    create_test_project "test-project"
    
    run "$PLUGIN_ROOT/scripts/create-project-task" "test-project" "test-structure"
    
    assert_success
    local task_file="$PLAYGROUND_DIR/projects/test-project/tasks/planning/test-structure.md"
    assert_file_contains "$task_file" "# Task: test-structure"
    assert_file_contains "$task_file" "Status: planning"
    assert_file_contains "$task_file" "Created:"
    assert_file_contains "$task_file" "Updated:"
    assert_file_contains "$task_file" "PRP-Template: none"
    assert_file_contains "$task_file" "Project: test-project"
    assert_file_contains "$task_file" "## Project Intention"
    assert_file_contains "$task_file" "## Acceptance Criteria"
    assert_file_contains "$task_file" "## Implementation Approach"
    assert_file_contains "$task_file" "## Technical Details"
    assert_file_contains "$task_file" "## Notes"
}

@test "create-project-task: prevents duplicate task creation in same directory" {
    create_test_project "test-project"
    
    # Create first task
    run "$PLUGIN_ROOT/scripts/create-project-task" "test-project" "duplicate-test"
    assert_success
    
    # Try to create same task again
    run "$PLUGIN_ROOT/scripts/create-project-task" "test-project" "duplicate-test"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Task 'duplicate-test' already exists in planning directory"
}

@test "create-project-task: prevents duplicate task creation across all status directories" {
    create_test_project "test-project"
    
    # Create existing task in approved directory
    touch "$PLAYGROUND_DIR/projects/test-project/tasks/approved/existing-task.md"
    
    # Try to create task with same name
    run "$PLUGIN_ROOT/scripts/create-project-task" "test-project" "existing-task"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Task 'existing-task' already exists in approved directory"
}

@test "create-project-task: provides helpful next steps" {
    create_test_project "test-project"
    
    run "$PLUGIN_ROOT/scripts/create-project-task" "test-project" "guidance-test"
    
    assert_success
    assert_output_contains "Next steps:"
    assert_output_contains "1. Edit the task file to add details and acceptance criteria"
    assert_output_contains "2. Name the skill that covers the work, if one applies"
    assert_output_contains "3. When ready, move the task file to the approved directory to begin work"
}

@test "create-project-task: creates task directories if they don't exist" {
    # Create project without task directories
    mkdir -p "$PLAYGROUND_DIR/projects/minimal-project"
    echo "# Project: minimal-project" > "$PLAYGROUND_DIR/projects/minimal-project/plan.md"
    
    run "$PLUGIN_ROOT/scripts/create-project-task" "minimal-project" "test-task"
    
    assert_success
    assert_dir_exists "$PLAYGROUND_DIR/projects/minimal-project/tasks/planning"
    assert_dir_exists "$PLAYGROUND_DIR/projects/minimal-project/tasks/approved"
    assert_dir_exists "$PLAYGROUND_DIR/projects/minimal-project/tasks/in-progress"
    assert_dir_exists "$PLAYGROUND_DIR/projects/minimal-project/tasks/completed"
}

@test "create-project-task: handles task names with hyphens" {
    create_test_project "test-project"
    
    run "$PLUGIN_ROOT/scripts/create-project-task" "test-project" "implement-new-feature"
    
    assert_success
    assert_file_exists "$PLAYGROUND_DIR/projects/test-project/tasks/planning/implement-new-feature.md"
    assert_file_contains "$PLAYGROUND_DIR/projects/test-project/tasks/planning/implement-new-feature.md" "# Task: implement-new-feature"
}

@test "create-project-task: handles project names with hyphens" {
    create_test_project "my-awesome-project"
    
    run "$PLUGIN_ROOT/scripts/create-project-task" "my-awesome-project" "test-task"
    
    assert_success
    assert_file_exists "$PLAYGROUND_DIR/projects/my-awesome-project/tasks/planning/test-task.md"
}

@test "create-project-task: respects PLAYGROUND_DIR environment variable" {
    # Set custom playground directory
    export CUSTOM_PLAYGROUND="$TEST_DIR/custom-playground"
    export PLAYGROUND_DIR="$CUSTOM_PLAYGROUND"
    
    # Create project in custom location
    mkdir -p "$CUSTOM_PLAYGROUND/projects/custom-project"
    echo "# Project: custom-project" > "$CUSTOM_PLAYGROUND/projects/custom-project/plan.md"
    
    run "$PLUGIN_ROOT/scripts/create-project-task" "custom-project" "test-task"
    
    assert_success
    assert_file_exists "$CUSTOM_PLAYGROUND/projects/custom-project/tasks/planning/test-task.md"
}
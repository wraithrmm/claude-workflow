#!/usr/bin/env bats
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Tests for move-task script

load test_helper

@test "move-task: requires both task name and status" {
    assert_script_requires_args "$PLUGIN_ROOT/scripts/move-task" \
        "Error: Task name and target status are required"
    assert_output_contains "Usage: move-task <task-name> <status>"
}

@test "move-task: requires target status when task name provided" {
    run "$PLUGIN_ROOT/scripts/move-task" "some-task"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Task name and target status are required"
}

@test "move-task: validates target status" {
    run "$PLUGIN_ROOT/scripts/move-task" "task-name" "invalid-status"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Invalid status 'invalid-status'"
    assert_output_contains "Valid statuses: planning, approved, in-progress, completed"
}

@test "move-task: reports task not found" {
    mkdir -p "$PLAYGROUND_DIR/tasks/planning"
    
    run "$PLUGIN_ROOT/scripts/move-task" "non-existent-task" "approved"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Task 'non-existent-task' not found"
}

@test "move-task: moves task from planning to approved" {
    create_task_file "planning" "test-task"
    
    run "$PLUGIN_ROOT/scripts/move-task" "test-task" "approved"
    
    assert_success
    assert_output_contains "Task 'test-task' moved from planning to approved"
    assert_file_not_exists "$PLAYGROUND_DIR/tasks/planning/test-task.md"
    assert_file_exists "$PLAYGROUND_DIR/tasks/approved/test-task.md"
}

@test "move-task: updates status field in moved file" {
    create_task_file "planning" "status-test"
    
    run "$PLUGIN_ROOT/scripts/move-task" "status-test" "in-progress"
    
    assert_success
    assert_file_contains "$PLAYGROUND_DIR/tasks/in-progress/status-test.md" "Status: in-progress"
    refute_file_contains "$PLAYGROUND_DIR/tasks/in-progress/status-test.md" "Status: planning"
}

@test "move-task: updates timestamp when moving" {
    create_task_file "approved" "timestamp-test" "2024-01-01 00:00:00"
    
    # Store original content
    original_content=$(cat "$PLAYGROUND_DIR/tasks/approved/timestamp-test.md")
    
    run "$PLUGIN_ROOT/scripts/move-task" "timestamp-test" "in-progress"
    
    assert_success
    # Check that Updated field has changed (won't match original date)
    refute_file_contains "$PLAYGROUND_DIR/tasks/in-progress/timestamp-test.md" "Updated: 2024-01-01 00:00:00"
    assert_file_contains "$PLAYGROUND_DIR/tasks/in-progress/timestamp-test.md" "Updated: "
}

@test "move-task: handles task already in target status" {
    create_task_file "approved" "already-there"
    
    run "$PLUGIN_ROOT/scripts/move-task" "already-there" "approved"
    
    assert_success
    assert_output_contains "Task 'already-there' is already in approved"
    assert_file_exists "$PLAYGROUND_DIR/tasks/approved/already-there.md"
}

@test "move-task: finds task across all status directories" {
    create_task_file "completed" "find-me"
    
    run "$PLUGIN_ROOT/scripts/move-task" "find-me" "planning"
    
    assert_success
    assert_output_contains "Task 'find-me' moved from completed to planning"
    assert_file_not_exists "$PLAYGROUND_DIR/tasks/completed/find-me.md"
    assert_file_exists "$PLAYGROUND_DIR/tasks/planning/find-me.md"
}

@test "move-task: provides next steps for approved status" {
    create_task_file "planning" "guide-approved"
    
    run "$PLUGIN_ROOT/scripts/move-task" "guide-approved" "approved"
    
    assert_success
    assert_output_contains "Task is now approved and ready to be worked on"
    assert_output_contains "Use 'move-task guide-approved in-progress' when you start working on it"
}

@test "move-task: provides next steps for in-progress status" {
    create_task_file "approved" "guide-progress"
    
    run "$PLUGIN_ROOT/scripts/move-task" "guide-progress" "in-progress"
    
    assert_success
    assert_output_contains "Task is now in progress"
    assert_output_contains "Use 'move-task guide-progress completed' when finished"
}

@test "move-task: provides celebration for completed status" {
    create_task_file "in-progress" "guide-complete"
    
    run "$PLUGIN_ROOT/scripts/move-task" "guide-complete" "completed"
    
    assert_success
    assert_output_contains "Task completed! 🎉"
}

@test "move-task: creates target directory if it doesn't exist" {
    create_task_file "planning" "create-dir-test"
    # Remove the target directory
    rm -rf "$PLAYGROUND_DIR/tasks/approved"
    
    run "$PLUGIN_ROOT/scripts/move-task" "create-dir-test" "approved"
    
    assert_success
    assert_dir_exists "$PLAYGROUND_DIR/tasks/approved"
    assert_file_exists "$PLAYGROUND_DIR/tasks/approved/create-dir-test.md"
}

@test "move-task: preserves file content except status and updated fields" {
    create_task_file "planning" "content-test"
    # Add some custom content
    echo "Custom content here" >> "$PLAYGROUND_DIR/tasks/planning/content-test.md"
    
    run "$PLUGIN_ROOT/scripts/move-task" "content-test" "approved"
    
    assert_success
    assert_file_contains "$PLAYGROUND_DIR/tasks/approved/content-test.md" "# Task: content-test"
    assert_file_contains "$PLAYGROUND_DIR/tasks/approved/content-test.md" "## Project Intention"
    assert_file_contains "$PLAYGROUND_DIR/tasks/approved/content-test.md" "Custom content here"
}
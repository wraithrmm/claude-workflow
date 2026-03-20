#!/usr/bin/env bats

load test_helper

@test "move-task: requires both arguments" {
    run "$PLUGIN_ROOT/scripts/move-task"

    assert_failure
    assert_output_contains "Error: Task name and target status are required"
}

@test "move-task: moves task between statuses" {
    create_playground
    create_task_file "planning" "test-task"

    run "$PLUGIN_ROOT/scripts/move-task" "test-task" "approved"

    assert_success
    assert_output_contains "moved from planning to approved"
    assert_file_exists "$PLAYGROUND_DIR/tasks/approved/test-task.md"
    [[ ! -f "$PLAYGROUND_DIR/tasks/planning/test-task.md" ]]
}

@test "move-task: rejects invalid status" {
    run "$PLUGIN_ROOT/scripts/move-task" "test-task" "invalid"

    assert_failure
    assert_output_contains "Invalid status"
}

@test "move-task: handles task not found" {
    create_playground

    run "$PLUGIN_ROOT/scripts/move-task" "nonexistent" "approved"

    assert_failure
    assert_output_contains "not found"
}

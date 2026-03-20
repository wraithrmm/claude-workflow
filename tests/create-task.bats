#!/usr/bin/env bats

load test_helper

@test "create-task: requires task name" {
    run "$PLUGIN_ROOT/scripts/create-task"

    assert_failure
    assert_output_contains "Error: Task name is required"
}

@test "create-task: creates task file in planning" {
    run "$PLUGIN_ROOT/scripts/create-task" "my-task"

    assert_success
    assert_file_exists "$PLAYGROUND_DIR/tasks/planning/my-task.md"
    assert_file_contains "$PLAYGROUND_DIR/tasks/planning/my-task.md" "Status: planning"
}

@test "create-task: prevents duplicates" {
    "$PLUGIN_ROOT/scripts/create-task" "dupe-task"

    run "$PLUGIN_ROOT/scripts/create-task" "dupe-task"

    assert_failure
    assert_output_contains "already exists"
}

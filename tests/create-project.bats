#!/usr/bin/env bats

load test_helper

@test "create-project: requires project name" {
    run "$PLUGIN_ROOT/scripts/create-project"

    assert_failure
    assert_output_contains "Error: Project name is required"
}

@test "create-project: creates full structure" {
    create_playground

    run "$PLUGIN_ROOT/scripts/create-project" "test-proj"

    assert_success
    assert_file_exists "$PLAYGROUND_DIR/projects/test-proj/plan.md"
    assert_file_exists "$PLAYGROUND_DIR/projects/test-proj/progress.md"
    assert_file_exists "$PLAYGROUND_DIR/projects/test-proj/status.json"
    assert_file_exists "$PLAYGROUND_DIR/projects/test-proj/notes.md"
    assert_dir_exists "$PLAYGROUND_DIR/projects/test-proj/tasks/planning"
    assert_dir_exists "$PLAYGROUND_DIR/projects/test-proj/tasks/completed"
}

@test "create-project: prevents duplicates" {
    create_playground
    "$PLUGIN_ROOT/scripts/create-project" "dupe-proj"

    run "$PLUGIN_ROOT/scripts/create-project" "dupe-proj"

    assert_failure
    assert_output_contains "already exists"
}

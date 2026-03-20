#!/usr/bin/env bats

load test_helper

@test "init-playground: creates full directory structure when missing" {
    run "$PLUGIN_ROOT/scripts/init-playground"

    assert_success
    assert_output_contains "Creating ai-playground directory structure..."
    assert_output_contains "✅ ai-playground directory structure created"
    assert_dir_exists "$PLAYGROUND_DIR/projects"
    assert_dir_exists "$PLAYGROUND_DIR/tasks/planning"
    assert_dir_exists "$PLAYGROUND_DIR/tasks/approved"
    assert_dir_exists "$PLAYGROUND_DIR/tasks/in-progress"
    assert_dir_exists "$PLAYGROUND_DIR/tasks/completed"
}

@test "init-playground: handles existing directory" {
    mkdir -p "$PLAYGROUND_DIR"

    run "$PLUGIN_ROOT/scripts/init-playground"

    assert_success
    assert_output_contains "✅ ai-playground directory exists"
    refute_output_contains "Creating ai-playground directory structure..."
}

@test "init-playground: lists existing projects" {
    create_playground
    mkdir -p "$PLAYGROUND_DIR/projects/alpha"
    mkdir -p "$PLAYGROUND_DIR/projects/beta"

    run "$PLUGIN_ROOT/scripts/init-playground"

    assert_success
    assert_output_contains "Found 2 project(s)"
}

@test "init-playground: counts tasks" {
    create_playground
    touch "$PLAYGROUND_DIR/tasks/planning/task1.md"
    touch "$PLAYGROUND_DIR/tasks/approved/task2.md"

    run "$PLUGIN_ROOT/scripts/init-playground"

    assert_success
    assert_output_contains "Found 2 task(s)"
}

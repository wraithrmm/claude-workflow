#!/usr/bin/env bats

load test_helper

@test "create-project-task: requires both arguments" {
    run "$PLUGIN_ROOT/scripts/create-project-task"

    assert_failure
    assert_output_contains "Error: Project name and task name are required"
}

@test "create-project-task: creates task in project" {
    create_playground
    create_test_project "my-proj"

    run "$PLUGIN_ROOT/scripts/create-project-task" "my-proj" "my-task"

    assert_success
    assert_file_exists "$PLAYGROUND_DIR/projects/my-proj/tasks/planning/my-task.md"
}

@test "create-project-task: fails if project missing" {
    create_playground

    run "$PLUGIN_ROOT/scripts/create-project-task" "nope" "my-task"

    assert_failure
    assert_output_contains "does not exist"
}

@test "move-project-task: moves task between statuses" {
    create_playground
    create_test_project "my-proj"
    create_project_task_file "my-proj" "planning" "my-task"

    run "$PLUGIN_ROOT/scripts/move-project-task" "my-proj" "my-task" "in-progress"

    assert_success
    assert_output_contains "moved from planning to in-progress"
    assert_file_exists "$PLAYGROUND_DIR/projects/my-proj/tasks/in-progress/my-task.md"
}

@test "list-project-tasks: requires project name" {
    run "$PLUGIN_ROOT/scripts/list-project-tasks"

    assert_failure
    assert_output_contains "Error: Project name required"
}

@test "list-project-tasks: shows tasks for project" {
    create_playground
    create_test_project "my-proj"
    create_project_task_file "my-proj" "planning" "task-a"
    create_project_task_file "my-proj" "approved" "task-b"

    run "$PLUGIN_ROOT/scripts/list-project-tasks" "my-proj"

    assert_success
    assert_output_contains "task-a"
    assert_output_contains "task-b"
    assert_output_contains "Total tasks: 2"
}

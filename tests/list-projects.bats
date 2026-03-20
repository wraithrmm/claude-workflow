#!/usr/bin/env bats

load test_helper

@test "list-projects: shows message when no projects" {
    create_playground

    run "$PLUGIN_ROOT/scripts/list-projects"

    assert_success
    assert_output_contains "No projects found"
}

@test "list-projects: lists projects with status" {
    create_playground
    create_test_project "alpha" "active"
    create_test_project "beta" "planning"

    run "$PLUGIN_ROOT/scripts/list-projects"

    assert_success
    assert_output_contains "alpha"
    assert_output_contains "beta"
    assert_output_contains "Total projects: 2"
}

@test "count-projects: returns correct count" {
    create_playground
    create_test_project "a"
    create_test_project "b"
    create_test_project "c"

    run "$PLUGIN_ROOT/scripts/count-projects"

    assert_success
    assert_output_contains "3"
}

@test "count-projects: returns 0 when empty" {
    run "$PLUGIN_ROOT/scripts/count-projects"

    assert_success
    assert_output_contains "0"
}

@test "verify-project: requires project name" {
    run "$PLUGIN_ROOT/scripts/verify-project"

    assert_failure
    assert_output_contains "Error: Project name required"
}

@test "verify-project: reports existing files" {
    create_playground
    create_test_project "my-proj"

    run "$PLUGIN_ROOT/scripts/verify-project" "my-proj"

    assert_success
    assert_output_contains "✅ plan.md exists"
    assert_output_contains "✅ status.json exists"
}

#!/usr/bin/env bats
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Tests for list-project-tasks script

load test_helper

# Each test starts with an initialised playground
setup() {
    setup_playground_test
}

@test "list-project-tasks: requires project name" {
    mkdir -p "$PLAYGROUND_DIR"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Project name required"
    assert_output_contains "Usage: list-project-tasks <project-name>"
}

@test "list-project-tasks: fails when ai-playground not initialized" {
    rm -rf "$PLAYGROUND_DIR"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "test-project"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: AI playground not initialized"
    assert_output_contains "Run '/init-playground' first"
}

@test "list-project-tasks: fails when project does not exist" {
    mkdir -p "$PLAYGROUND_DIR/projects"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "non-existent-project"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Project 'non-existent-project' does not exist"
    assert_output_contains "Use '/list-projects' to see available projects"
}

@test "list-project-tasks: shows empty message when project has no tasks" {
    create_test_project "empty-project"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "empty-project"
    
    assert_success
    assert_output_contains "# Task List for Project: empty-project"
    assert_output_contains "## planning (0 tasks)"
    assert_output_contains "No tasks"
    assert_output_contains "## approved (0 tasks)"
    assert_output_contains "## in-progress (0 tasks)"
    assert_output_contains "## completed (0 tasks)"
    assert_output_contains "Total tasks: 0"
}

@test "list-project-tasks: lists tasks in planning status" {
    create_test_project "test-project"
    create_project_task_file "test-project" "planning" "design-api" "2024-01-15 10:00:00" "none"
    create_project_task_file "test-project" "planning" "create-models" "2024-01-15 11:00:00" "create-model"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "test-project"
    
    assert_success
    assert_output_contains "## planning (2 tasks)"
    assert_output_contains "- design-api"
    assert_output_contains "Created: 2024-01-15 10:00:00"
    assert_output_contains "- create-models"
    assert_output_contains "Created: 2024-01-15 11:00:00"
    assert_output_contains "Template: create-model"
}

@test "list-project-tasks: lists tasks in all statuses" {
    create_test_project "full-project"
    create_project_task_file "full-project" "planning" "plan-task"
    create_project_task_file "full-project" "approved" "approved-task"
    create_project_task_file "full-project" "in-progress" "current-task"
    create_project_task_file "full-project" "completed" "done-task"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "full-project"
    
    assert_success
    assert_output_contains "## planning (1 tasks)"
    assert_output_contains "- plan-task"
    assert_output_contains "## approved (1 tasks)"
    assert_output_contains "- approved-task"
    assert_output_contains "## in-progress (1 tasks)"
    assert_output_contains "- current-task"
    assert_output_contains "## completed (1 tasks)"
    assert_output_contains "- done-task"
    assert_output_contains "Total tasks: 4"
}

@test "list-project-tasks: shows PRP template when specified" {
    create_test_project "template-project"
    create_project_task_file "template-project" "planning" "api-task" "2024-01-15 10:00:00" "api-endpoint"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "template-project"
    
    assert_success
    assert_output_contains "- api-task"
    assert_output_contains "Template: api-endpoint"
}

@test "list-project-tasks: does not show template line when template is none" {
    create_test_project "no-template-project"
    create_project_task_file "no-template-project" "planning" "simple-task" "2024-01-15 10:00:00" "none"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "no-template-project"
    
    assert_success
    assert_output_contains "- simple-task"
    refute_output_contains "Template: none"
}

@test "list-project-tasks: handles missing Created field gracefully" {
    create_test_project "broken-project"
    mkdir -p "$PLAYGROUND_DIR/projects/broken-project/tasks/planning"
    # Create task without Created field
    cat > "$PLAYGROUND_DIR/projects/broken-project/tasks/planning/broken-task.md" << EOF
# Task: broken-task
Status: planning
Updated: 2024-01-15 10:00:00
PRP-Template: none
EOF
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "broken-project"
    
    assert_success
    assert_output_contains "- broken-task"
    assert_output_contains "Created: Unknown"
}

@test "list-project-tasks: ignores non-md files in task directories" {
    create_test_project "mixed-project"
    create_project_task_file "mixed-project" "planning" "real-task"
    touch "$PLAYGROUND_DIR/projects/mixed-project/tasks/planning/not-a-task.txt"
    touch "$PLAYGROUND_DIR/projects/mixed-project/tasks/planning/.hidden"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "mixed-project"
    
    assert_success
    assert_output_contains "## planning (1 tasks)"
    assert_output_contains "- real-task"
    refute_output_contains "not-a-task"
    refute_output_contains ".hidden"
    assert_output_contains "Total tasks: 1"
}

@test "list-project-tasks: counts multiple tasks correctly" {
    create_test_project "big-project"
    create_project_task_file "big-project" "planning" "task1"
    create_project_task_file "big-project" "planning" "task2"
    create_project_task_file "big-project" "approved" "task3"
    create_project_task_file "big-project" "in-progress" "task4"
    create_project_task_file "big-project" "in-progress" "task5"
    create_project_task_file "big-project" "completed" "task6"
    create_project_task_file "big-project" "completed" "task7"
    create_project_task_file "big-project" "completed" "task8"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "big-project"
    
    assert_success
    assert_output_contains "## planning (2 tasks)"
    assert_output_contains "## approved (1 tasks)"
    assert_output_contains "## in-progress (2 tasks)"
    assert_output_contains "## completed (3 tasks)"
    assert_output_contains "Total tasks: 8"
}

@test "list-project-tasks: creates task directories if they don't exist" {
    create_test_project "new-project"
    # Don't create task directories
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "new-project"
    
    assert_success
    assert_dir_exists "$PLAYGROUND_DIR/projects/new-project/tasks/planning"
    assert_dir_exists "$PLAYGROUND_DIR/projects/new-project/tasks/approved"
    assert_dir_exists "$PLAYGROUND_DIR/projects/new-project/tasks/in-progress"
    assert_dir_exists "$PLAYGROUND_DIR/projects/new-project/tasks/completed"
}

@test "list-project-tasks: works with project names containing spaces" {
    create_test_project "my awesome project"
    create_project_task_file "my awesome project" "planning" "test-task"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "my awesome project"
    
    assert_success
    assert_output_contains "# Task List for Project: my awesome project"
    assert_output_contains "## planning (1 tasks)"
    assert_output_contains "- test-task"
}

@test "list-project-tasks: respects PLAYGROUND_DIR environment variable" {
    # Set custom playground directory
    export PLAYGROUND_DIR="$TEST_DIR/custom-playground"
    mkdir -p "$PLAYGROUND_DIR/projects/env-project"
    create_file "$PLAYGROUND_DIR/projects/env-project/status.json" '{"project": "env-project", "status": "active"}'
    mkdir -p "$PLAYGROUND_DIR/projects/env-project/tasks/planning"
    
    run "$PLUGIN_ROOT/scripts/list-project-tasks" "env-project"
    
    assert_success
    assert_output_contains "# Task List for Project: env-project"
}
#!/usr/bin/env bats
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Tests for list-tasks script

load test_helper

# Each test starts with an initialised playground
setup() {
    setup_playground_test
}

@test "list-tasks: shows empty message when no tasks exist" {
    mkdir -p "$PLAYGROUND_DIR/tasks"
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    assert_output_contains "# Task List (All Tasks)"
    assert_output_contains "# Global Tasks"
    assert_output_contains "planning (0 tasks)"
    assert_output_contains "approved (0 tasks)"
    assert_output_contains "in-progress (0 tasks)"
    assert_output_contains "completed (0 tasks)"
    assert_output_contains "Total tasks: 0"
}

@test "list-tasks: shows tasks in planning status" {
    create_task_file "planning" "implement-feature" "2024-01-15 10:00:00" "none"
    create_task_file "planning" "fix-bug" "2024-01-15 11:00:00" "none"
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    assert_output_contains "## planning (2 tasks)"
    assert_output_contains "- implement-feature"
    assert_output_contains "Created: 2024-01-15 10:00:00"
    assert_output_contains "- fix-bug"
    assert_output_contains "Created: 2024-01-15 11:00:00"
}

@test "list-tasks: shows tasks in all statuses" {
    create_task_file "planning" "plan-task"
    create_task_file "approved" "approved-task"
    create_task_file "in-progress" "current-task"
    create_task_file "completed" "done-task"
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
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

@test "list-tasks: shows PRP template when specified" {
    create_task_file "planning" "sql-task" "2024-01-15 10:00:00" "sql-to-entity-mapper"
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    assert_output_contains "- sql-task"
    assert_output_contains "Template: sql-to-entity-mapper"
}

@test "list-tasks: does not show template line when template is none" {
    create_task_file "planning" "no-template-task" "2024-01-15 10:00:00" "none"
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    assert_output_contains "- no-template-task"
    refute_output_contains "Template: none"
}

@test "list-tasks: handles missing Created field gracefully" {
    mkdir -p "$PLAYGROUND_DIR/tasks/planning"
    # Create task without Created field
    cat > "$PLAYGROUND_DIR/tasks/planning/broken-task.md" << EOF
# Task: broken-task
Status: planning
Updated: 2024-01-15 10:00:00
PRP-Template: none
EOF
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    assert_output_contains "- broken-task"
    assert_output_contains "Created: Unknown"
}

@test "list-tasks: handles empty status directories" {
    # Create empty directories
    mkdir -p "$PLAYGROUND_DIR/tasks/planning"
    mkdir -p "$PLAYGROUND_DIR/tasks/approved"
    mkdir -p "$PLAYGROUND_DIR/tasks/in-progress"
    mkdir -p "$PLAYGROUND_DIR/tasks/completed"
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    assert_output_contains "## planning (0 tasks)"
    assert_output_contains "No tasks"
    assert_output_contains "## approved (0 tasks)"
    assert_output_contains "## in-progress (0 tasks)"
    assert_output_contains "## completed (0 tasks)"
    assert_output_contains "Total tasks: 0"
}

@test "list-tasks: ignores non-md files in task directories" {
    mkdir -p "$PLAYGROUND_DIR/tasks/planning"
    touch "$PLAYGROUND_DIR/tasks/planning/not-a-task.txt"
    touch "$PLAYGROUND_DIR/tasks/planning/.hidden"
    create_task_file "planning" "real-task"
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    assert_output_contains "## planning (1 tasks)"
    assert_output_contains "- real-task"
    refute_output_contains "not-a-task"
    refute_output_contains ".hidden"
    assert_output_contains "Total tasks: 1"
}

@test "list-tasks: works when tasks directory doesn't exist" {
    # Don't create any task directories
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    assert_output_contains "# Task List (All Tasks)"
    assert_output_contains "Total tasks: 0"
}

@test "list-tasks: counts multiple tasks correctly" {
    create_task_file "planning" "task1"
    create_task_file "planning" "task2"
    create_task_file "approved" "task3"
    create_task_file "in-progress" "task4"
    create_task_file "in-progress" "task5"
    create_task_file "completed" "task6"
    create_task_file "completed" "task7"
    create_task_file "completed" "task8"
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    assert_output_contains "## planning (2 tasks)"
    assert_output_contains "## approved (1 tasks)"
    assert_output_contains "## in-progress (2 tasks)"
    assert_output_contains "## completed (3 tasks)"
    assert_output_contains "Total tasks: 8"
}

@test "list-tasks: shows project tasks" {
    # Create global tasks
    create_task_file "planning" "global-task1"
    create_task_file "approved" "global-task2"
    
    # Create project with tasks
    mkdir -p "$PLAYGROUND_DIR/projects/test-project"
    create_project_task_file "test-project" "planning" "project-task1"
    create_project_task_file "test-project" "in-progress" "project-task2"
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    assert_output_contains "# Global Tasks"
    assert_output_contains "- global-task1"
    assert_output_contains "- global-task2"
    assert_output_contains "# Project Tasks"
    assert_output_contains "## Project: test-project"
    assert_output_contains "- [test-project] project-task1"
    assert_output_contains "- [test-project] project-task2"
    assert_output_contains "Global tasks: 2"
    assert_output_contains "Project tasks: 2"
    assert_output_contains "Total tasks: 4"
}

@test "list-tasks: shows multiple projects" {
    # Create tasks in different projects
    mkdir -p "$PLAYGROUND_DIR/projects/project-a"
    mkdir -p "$PLAYGROUND_DIR/projects/project-b"
    create_project_task_file "project-a" "planning" "task-a1"
    create_project_task_file "project-a" "completed" "task-a2"
    create_project_task_file "project-b" "approved" "task-b1"
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    assert_output_contains "## Project: project-a"
    assert_output_contains "- [project-a] task-a1"
    assert_output_contains "- [project-a] task-a2"
    assert_output_contains "## Project: project-b"
    assert_output_contains "- [project-b] task-b1"
    assert_output_contains "Project tasks: 3"
}

@test "list-tasks: handles projects without tasks directory" {
    # Create project without tasks subdirectory
    mkdir -p "$PLAYGROUND_DIR/projects/empty-project"
    touch "$PLAYGROUND_DIR/projects/empty-project/plan.md"
    
    # Create another project with tasks
    mkdir -p "$PLAYGROUND_DIR/projects/active-project"
    create_project_task_file "active-project" "planning" "task1"
    
    run "$PLUGIN_ROOT/scripts/list-tasks"
    
    assert_success
    refute_output_contains "empty-project"
    assert_output_contains "## Project: active-project"
    assert_output_contains "- [active-project] task1"
}
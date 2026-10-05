#!/usr/bin/env bats
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Tests for init-playground script

load test_helper

@test "init-playground: creates full directory structure when missing" {
    # Run init script
    run "$PLUGIN_ROOT/scripts/init-playground"
    
    assert_success
    assert_output_contains "Following CLAUDE.md process"
    assert_output_contains "Creating ai-playground directory structure..."
    assert_output_contains "✅ ai-playground directory structure created"
    assert_dir_exists "$PLAYGROUND_DIR"
    assert_dir_exists "$PLAYGROUND_DIR/projects"
    assert_dir_exists "$PLAYGROUND_DIR/tasks"
    assert_dir_exists "$PLAYGROUND_DIR/tasks/planning"
    assert_dir_exists "$PLAYGROUND_DIR/tasks/approved"
    assert_dir_exists "$PLAYGROUND_DIR/tasks/in-progress"
    assert_dir_exists "$PLAYGROUND_DIR/tasks/completed"
}

@test "init-playground: handles existing ai-playground directory" {
    # Create ai-playground directory first
    mkdir -p "$PLAYGROUND_DIR"
    
    run "$PLUGIN_ROOT/scripts/init-playground"
    
    assert_success
    assert_output_contains "✅ ai-playground directory exists"
    refute_output_contains "Creating ai-playground directory structure..."
    # Should still create subdirectories
    assert_dir_exists "$PLAYGROUND_DIR/projects"
    assert_dir_exists "$PLAYGROUND_DIR/tasks"
}

@test "init-playground: lists existing projects with numbers" {
    # Create some test projects
    mkdir -p "$PLAYGROUND_DIR/projects/project-alpha"
    mkdir -p "$PLAYGROUND_DIR/projects/project-beta"
    mkdir -p "$PLAYGROUND_DIR/projects/project-gamma"
    
    run "$PLUGIN_ROOT/scripts/init-playground"
    
    assert_success
    assert_output_contains "Existing projects:"
    assert_output_contains "1. 📁 project-alpha"
    assert_output_contains "2. 📁 project-beta"
    assert_output_contains "3. 📁 project-gamma"
    assert_output_contains "Found 3 project(s)"
}

@test "init-playground: counts tasks correctly" {
    # Create some test tasks
    mkdir -p "$PLAYGROUND_DIR/tasks/planning"
    mkdir -p "$PLAYGROUND_DIR/tasks/approved"
    touch "$PLAYGROUND_DIR/tasks/planning/task1.md"
    touch "$PLAYGROUND_DIR/tasks/planning/task2.md"
    touch "$PLAYGROUND_DIR/tasks/approved/task3.md"
    
    run "$PLUGIN_ROOT/scripts/init-playground"
    
    assert_success
    assert_output_contains "Found 3 task(s)"
}

@test "init-playground: provides usage guidance" {
    run "$PLUGIN_ROOT/scripts/init-playground"
    
    assert_success
    assert_output_contains "Ready for new work:"
    assert_output_contains "Use /list-projects to see projects or /list-tasks to see tasks"
}
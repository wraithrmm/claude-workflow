#!/usr/bin/env bats
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Tests for continue-project script

load test_helper

# Each test starts with an initialised playground
setup() {
    setup_playground_test
}

@test "continue-project: requires project name or number" {
    run "$PLUGIN_ROOT/scripts/continue-project"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Project name or number required"
    assert_output_contains "Usage: continue-project <project-name|number>"
}

@test "continue-project: works with project name" {
    mkdir -p "$PLAYGROUND_DIR/projects/my-project"
    touch "$PLAYGROUND_DIR/projects/my-project/plan.md"
    touch "$PLAYGROUND_DIR/projects/my-project/progress.md"
    touch "$PLAYGROUND_DIR/projects/my-project/status.json"
    touch "$PLAYGROUND_DIR/projects/my-project/notes.md"
    
    run "$PLUGIN_ROOT/scripts/continue-project" "my-project"
    
    assert_success
    assert_output_contains "📋 Preparing to resume project: my-project"
    assert_output_contains "✅ plan.md exists"
    assert_output_contains "✅ progress.md exists"
    assert_output_contains "✅ status.json exists"
    assert_output_contains "✅ notes.md exists"
    assert_output_contains "✅ Project my-project is ready to continue"
}

@test "continue-project: works with project number" {
    mkdir -p "$PLAYGROUND_DIR/projects/alpha-project"
    mkdir -p "$PLAYGROUND_DIR/projects/beta-project"
    mkdir -p "$PLAYGROUND_DIR/projects/gamma-project"
    
    # Create required files for beta-project
    touch "$PLAYGROUND_DIR/projects/beta-project/plan.md"
    touch "$PLAYGROUND_DIR/projects/beta-project/progress.md"
    touch "$PLAYGROUND_DIR/projects/beta-project/status.json"
    touch "$PLAYGROUND_DIR/projects/beta-project/notes.md"
    
    # Continue project #2 (beta-project due to alphabetical order)
    run "$PLUGIN_ROOT/scripts/continue-project" "2"
    
    assert_success
    assert_output_contains "📋 Preparing to resume project: beta-project"
}

@test "continue-project: handles invalid project number" {
    mkdir -p "$PLAYGROUND_DIR/projects/test-project"
    
    run "$PLUGIN_ROOT/scripts/continue-project" "5"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Invalid project number '5'"
    assert_output_contains "Valid range: 1-1"
}

@test "continue-project: handles non-existent project name" {
    mkdir -p "$PLAYGROUND_DIR/projects/existing-project"
    
    run "$PLUGIN_ROOT/scripts/continue-project" "non-existent"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Project 'non-existent' not found"
    assert_output_contains "Available projects:"
    assert_output_contains "1. existing-project"
}

@test "continue-project: shows project file paths" {
    mkdir -p "$PLAYGROUND_DIR/projects/show-paths"
    touch "$PLAYGROUND_DIR/projects/show-paths/plan.md"
    touch "$PLAYGROUND_DIR/projects/show-paths/progress.md"
    touch "$PLAYGROUND_DIR/projects/show-paths/status.json"
    touch "$PLAYGROUND_DIR/projects/show-paths/notes.md"
    
    run "$PLUGIN_ROOT/scripts/continue-project" "show-paths"
    
    assert_success
    assert_output_contains "Project files ready for reading:"
    assert_output_contains "Read(\"$PLAYGROUND_DIR/projects/show-paths/plan.md\")"
    assert_output_contains "Read(\"$PLAYGROUND_DIR/projects/show-paths/progress.md\")"
    assert_output_contains "Read(\"$PLAYGROUND_DIR/projects/show-paths/status.json\")"
    assert_output_contains "Read(\"$PLAYGROUND_DIR/projects/show-paths/notes.md\")"
}
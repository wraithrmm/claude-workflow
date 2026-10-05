#!/usr/bin/env bats
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Tests for verify-project script

load test_helper

@test "verify-project: requires project name" {
    run "$PLUGIN_ROOT/scripts/verify-project"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Project name required"
    assert_output_contains "Usage: verify-project <project-name>"
}

@test "verify-project: checks all required files" {
    mkdir -p "$PLAYGROUND_DIR/projects/complete-project"
    touch "$PLAYGROUND_DIR/projects/complete-project/plan.md"
    touch "$PLAYGROUND_DIR/projects/complete-project/progress.md"
    touch "$PLAYGROUND_DIR/projects/complete-project/status.json"
    touch "$PLAYGROUND_DIR/projects/complete-project/notes.md"
    
    run "$PLUGIN_ROOT/scripts/verify-project" "complete-project"
    
    assert_success
    assert_output_contains "✅ plan.md exists"
    assert_output_contains "✅ progress.md exists"
    assert_output_contains "✅ status.json exists"
    assert_output_contains "✅ notes.md exists"
}

@test "verify-project: reports missing files" {
    mkdir -p "$PLAYGROUND_DIR/projects/incomplete-project"
    touch "$PLAYGROUND_DIR/projects/incomplete-project/plan.md"
    # Missing progress.md, status.json, notes.md
    
    run "$PLUGIN_ROOT/scripts/verify-project" "incomplete-project"
    
    assert_success
    assert_output_contains "✅ plan.md exists"
    assert_output_contains "⚠️  Missing required files:"
    assert_output_contains "- progress.md"
    assert_output_contains "- status.json"
    assert_output_contains "- notes.md"
}

@test "verify-project: handles non-existent project" {
    mkdir -p "$PLAYGROUND_DIR/projects"
    
    run "$PLUGIN_ROOT/scripts/verify-project" "non-existent"
    
    assert_failure
    assert_exit_code 1
    assert_output_contains "Error: Project directory not found:"
}
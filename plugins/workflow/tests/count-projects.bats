#!/usr/bin/env bats
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Tests for count-projects script

load test_helper

@test "count-projects: returns 0 when no projects directory" {
    run "$PLUGIN_ROOT/scripts/count-projects"
    
    assert_success
    assert_output "0"
}

@test "count-projects: returns 0 when projects directory is empty" {
    mkdir -p "$PLAYGROUND_DIR/projects"
    
    run "$PLUGIN_ROOT/scripts/count-projects"
    
    assert_success
    assert_output "0"
}

@test "count-projects: returns correct project count" {
    mkdir -p "$PLAYGROUND_DIR/projects/project1"
    mkdir -p "$PLAYGROUND_DIR/projects/project2"
    mkdir -p "$PLAYGROUND_DIR/projects/project3"
    # Create a file (not a directory) - should not be counted
    touch "$PLAYGROUND_DIR/projects/not-a-project.txt"
    
    run "$PLUGIN_ROOT/scripts/count-projects"
    
    assert_success
    assert_output "3"
}

@test "count-projects: ignores files in projects directory" {
    mkdir -p "$PLAYGROUND_DIR/projects"
    touch "$PLAYGROUND_DIR/projects/file1.txt"
    touch "$PLAYGROUND_DIR/projects/file2.md"
    mkdir -p "$PLAYGROUND_DIR/projects/real-project"
    
    run "$PLUGIN_ROOT/scripts/count-projects"
    
    assert_success
    assert_output "1"
}
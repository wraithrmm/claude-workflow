#!/usr/bin/env bats
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Tests for list-projects script

load test_helper

@test "list-projects: handles missing projects directory" {
    run "$PLUGIN_ROOT/scripts/list-projects"
    
    assert_success
    assert_output_contains "No projects directory found"
    assert_output_contains "Run /init-playground to set up the ai-playground structure"
}

@test "list-projects: handles empty projects directory" {
    mkdir -p "$PLAYGROUND_DIR/projects"
    
    run "$PLUGIN_ROOT/scripts/list-projects"
    
    assert_success
    assert_output_contains "No projects found"
    assert_output_contains "Use /create-project <project-name> to create a new project"
}

@test "list-projects: shows numbered projects with status.json" {
    mkdir -p "$PLAYGROUND_DIR/projects/test-project"
    
    # Create a status.json file
    cat > "$PLAYGROUND_DIR/projects/test-project/status.json" << EOF
{
    "project": "test-project",
    "status": "active",
    "completion_percent": 75,
    "created": "2024-01-15 10:00:00",
    "last_updated": "2024-01-15 14:30:00",
    "summary": "Test project for unit tests"
}
EOF
    
    run "$PLUGIN_ROOT/scripts/list-projects"
    
    assert_success
    assert_output_contains "1. 📁 test-project"
    assert_output_contains "Status: active"
    assert_output_contains "Progress: 75%"
    assert_output_contains "Created: 2024-01-15 10:00:00"
    assert_output_contains "Last updated: 2024-01-15 14:30:00"
    assert_output_contains "Summary: Test project for unit tests"
    assert_output_contains "Total projects: 1"
}

@test "list-projects: handles missing status.json" {
    mkdir -p "$PLAYGROUND_DIR/projects/no-status-project"
    
    run "$PLUGIN_ROOT/scripts/list-projects"
    
    assert_success
    assert_output_contains "1. 📁 no-status-project"
    assert_output_contains "⚠️  No status.json file"
}

@test "list-projects: maintains alphabetical order with numbering" {
    mkdir -p "$PLAYGROUND_DIR/projects/zebra-project"
    mkdir -p "$PLAYGROUND_DIR/projects/alpha-project"
    mkdir -p "$PLAYGROUND_DIR/projects/middle-project"
    
    run "$PLUGIN_ROOT/scripts/list-projects"
    
    assert_success
    assert_output_contains "1. 📁 alpha-project"
    assert_output_contains "2. 📁 middle-project"
    assert_output_contains "3. 📁 zebra-project"
}

@test "list-projects: shows correct command hint" {
    mkdir -p "$PLAYGROUND_DIR/projects/test-project"
    
    run "$PLUGIN_ROOT/scripts/list-projects"
    
    assert_success
    assert_output_contains "Use '/continue-project <project-name>' or '/continue-project <number>' to resume a project"
}

@test "list-projects: lists multiple projects with status and total" {
    create_test_project "alpha" "active"
    create_test_project "beta" "planning"

    run "$PLUGIN_ROOT/scripts/list-projects"

    assert_success
    assert_output_contains "1. 📁 alpha"
    assert_output_contains "2. 📁 beta"
    assert_output_contains "Status: planning"
    assert_output_contains "Total projects: 2"
}

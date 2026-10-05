#!/usr/bin/env bats
# SPDX-License-Identifier: PolyForm-Shield-1.0.0
# Copyright (c) 2025-present Richard Mann
# Licensed under the PolyForm Shield License 1.0.0
# https://polyformproject.org/licenses/shield/1.0.0/

# Tests for create-project script

load test_helper

@test "create-project: requires project name" {
    assert_script_requires_args "$PLUGIN_ROOT/scripts/create-project" \
        "Error: Project name is required" \
        "Usage: create-project <project-name>"
}

@test "create-project: creates project directory structure" {
    run "$PLUGIN_ROOT/scripts/create-project" "test-project"
    
    assert_success
    assert_dir_exists "$PLAYGROUND_DIR/projects/test-project"
    assert_output_contains "Project created successfully: $PLAYGROUND_DIR/projects/test-project"
}

@test "create-project: creates all required files" {
    run "$PLUGIN_ROOT/scripts/create-project" "complete-project"
    
    assert_success
    assert_creates_project_structure "complete-project"
}

@test "create-project: plan.md contains correct structure" {
    run "$PLUGIN_ROOT/scripts/create-project" "plan-test"
    
    assert_success
    local plan_file="$PLAYGROUND_DIR/projects/plan-test/plan.md"
    assert_file_contains "$plan_file" "# Project: plan-test"
    assert_file_contains "$plan_file" "## Overview"
    assert_file_contains "$plan_file" "## File Map"
    assert_file_contains "$plan_file" "### New Files 🆕"
    assert_file_contains "$plan_file" "### Modified Files ✏️"
    assert_file_contains "$plan_file" "### Deleted Files 🗑️"
    assert_file_contains "$plan_file" "## Implementation Steps"
    assert_file_contains "$plan_file" "## Success Criteria"
    assert_file_contains "$plan_file" "## Risk Assessment"
    assert_file_contains "$plan_file" "## Dependencies"
}

@test "create-project: progress.md contains initial entry" {
    run "$PLUGIN_ROOT/scripts/create-project" "progress-test"
    
    assert_success
    local progress_file="$PLAYGROUND_DIR/projects/progress-test/progress.md"
    assert_file_contains "$progress_file" "# Progress Log"
    assert_file_contains "$progress_file" "🆕 Project created"
    assert_file_contains "$progress_file" "⏳ Planning phase"
}

@test "create-project: status.json contains correct metadata" {
    run "$PLUGIN_ROOT/scripts/create-project" "status-test"
    
    assert_success
    local status_file="$PLAYGROUND_DIR/projects/status-test/status.json"
    assert_file_contains "$status_file" '"project": "status-test"'
    assert_file_contains "$status_file" '"status": "planning"'
    assert_file_contains "$status_file" '"completion_percent": 0'
    assert_file_contains "$status_file" '"summary": "Project description pending"'
}

@test "create-project: notes.md contains section headers" {
    run "$PLUGIN_ROOT/scripts/create-project" "notes-test"
    
    assert_success
    local notes_file="$PLAYGROUND_DIR/projects/notes-test/notes.md"
    assert_file_contains "$notes_file" "# Project Notes"
    assert_file_contains "$notes_file" "## Design Decisions"
    assert_file_contains "$notes_file" "## Issues Encountered"
    assert_file_contains "$notes_file" "## References"
}

@test "create-project: prevents duplicate project creation" {
    # Create first project
    run "$PLUGIN_ROOT/scripts/create-project" "duplicate-project"
    assert_success
    
    # Try to create same project again
    run "$PLUGIN_ROOT/scripts/create-project" "duplicate-project"
    assert_failure
    assert_output_contains "Error: Project 'duplicate-project' already exists"
}

@test "create-project: provides next steps guidance" {
    run "$PLUGIN_ROOT/scripts/create-project" "guidance-project"
    
    assert_success
    assert_output_contains_all \
        "Files created:" \
        "- plan.md (Project PRP)" \
        "- progress.md (Progress tracking)" \
        "- status.json (Project metadata)" \
        "- notes.md (Additional notes)"
    assert_next_steps_message
    assert_output_contains_all \
        "1. Edit plan.md to define the project requirements" \
        "2. Present the plan to the user for approval" \
        "3. Update status to 'active' when approved"
}

@test "create-project: handles project names with dashes" {
    run "$PLUGIN_ROOT/scripts/create-project" "my-awesome-project"
    
    assert_success
    assert_dir_exists "$PLAYGROUND_DIR/projects/my-awesome-project"
    assert_file_contains "$PLAYGROUND_DIR/projects/my-awesome-project/plan.md" "# Project: my-awesome-project"
}

@test "create-project: handles project names with spaces" {
    # The script receives multiple arguments when spaces are used
    # It will create a project with just the first word
    run "$PLUGIN_ROOT/scripts/create-project" project with spaces
    
    assert_success
    assert_dir_exists "$PLAYGROUND_DIR/projects/project"
    assert_file_contains "$PLAYGROUND_DIR/projects/project/plan.md" "# Project: project"
}
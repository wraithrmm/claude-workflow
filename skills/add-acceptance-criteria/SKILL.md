---
name: add-acceptance-criteria
description: Add acceptance criteria to an existing feature, implement the changes, and test.
user_invocable: true
argument-hint: <feature-name> <use-case description>
---

# Add Acceptance Criteria

Adds new acceptance criteria to an existing feature, implements the required changes, and creates tests.

## Arguments

- `$ARGUMENTS` - Must include:
  - The feature or system name (maps to a file in `acceptance-criteria/`)
  - One or more use cases describing the desired behaviour

## CRITICAL: Use Case Requirement

**MANDATORY**: If `$ARGUMENTS` does not contain a clear use case description, you MUST:

1. **STOP immediately**
2. **Ask the user**: "What use case(s) should be added? Please describe the behaviour you want."
3. **DO NOT proceed** until you have at least one concrete use case

## Workflow

### Step 1 — Identify the acceptance criteria file

1. Find the relevant `acceptance-criteria/` directory for the system being changed
2. Locate the existing `.md` file for the feature named in the arguments
3. Read the file to understand the existing AC numbering and structure
4. If no file exists, ask the user which feature this belongs to or whether to create a new AC file

### Step 2 — Write the acceptance criteria

1. Reformat each use case into Gherkin structure (**Given** / **When** / **Then**)
2. Assign AC numbers that follow the existing numbering scheme in the file
3. Add the new ACs to the appropriate section of the file
4. Present the new ACs to the user for review before proceeding

### Step 3 — Implement the feature

1. Read the codebase to understand the current state of the relevant components
2. Implement the changes required to satisfy the new acceptance criteria
3. Follow the project's code change process (read before edit, review changes, track revisions)
4. Run linters and tests as specified by the project's CLAUDE.md
5. Fix any failures before proceeding

### Step 4 — Write tests

1. Add tests to the existing spec file for the feature, or create a new one if none exists
2. Each test assertion must trace back to a specific AC (reference via `// AC-X.Y.Z` comments)
3. Use page objects or test helpers — avoid raw selectors in spec files
4. Include appropriate setup/teardown
5. Use reliable element targeting (data-testid attributes)

### Step 5 — Run tests

**MANDATORY**: Tests must pass locally before the work is considered complete.

1. Run the tests as specified by the project's test configuration
2. If tests fail, fix and re-run until all pass
3. Report the final pass/fail summary to the user

## Related Commands
- `/create-task` - Create a standalone task with full PRP

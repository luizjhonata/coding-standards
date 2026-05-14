Create a Jira ticket (Epic, Story, Bug, or Subtask) with structured content generated from user context.

The user provides the goal or problem informally (often in their native language). This command generates the title, description, and acceptance criteria in English, presents a draft for approval, and creates the ticket via the Atlassian MCP.

## Issue hierarchy

```
Epic
  └── Story or Bug
        └── Subtask (optional)
```

## Step 1: Determine ticket type

Ask the user what type of ticket to create if not specified:
- **Epic** — large initiative containing multiple stories
- **Story** — user-facing feature or deliverable (lives under an Epic)
- **Bug** — defect in existing functionality (lives under an Epic)
- **Subtask** — small piece of work under a Story or Bug

## Step 2: Load defaults from memory

Check memory for Jira defaults (cloud ID, project key, team, field IDs, sprint conventions). If not found, ask the user and save to memory for future sessions.

## Step 3: Collect context from user

Ask the user to describe what the ticket should cover. Accept informal input in any language. Probe for:

- What is the goal or problem?
- What is the expected outcome?
- Are there technical constraints or dependencies?
- Which components/repos are affected?

If the user already provided this context in the conversation, do NOT ask again.

**Sprint**: ask the user if the work is starting now or is for future planning.
- Starting now → assign the current sprint (monthly, format: "Mon YY", e.g., "Apr 26")
- Future planning → leave sprint empty

**Assignee**: ask who should be assigned to this ticket.
- If the user names someone, use `lookupJiraAccountId` to resolve their account ID
- If the user says "me" or does not specify, use `lookupJiraAccountId` with the current user's email

## Step 4: Generate draft

Generate ALL content in English.

### Epic draft
```
Title: [concise, max 80 chars]

Description:
## Objective
[what this epic achieves and why]

## Scope
[what is included and explicitly excluded]

## Stories
- [ ] Story 1: [title]
- [ ] Story 2: [title]

## Success Criteria
- [measurable outcome 1]
- [measurable outcome 2]

## Dependencies
- [list any dependencies or blockers]
```

### Story draft
```
Title: [concise, max 80 chars]
Story Points: [estimated based on scope — minimum 1]
Priority: [Critical | High | Medium | Low | Informational]
Sprint: [current sprint or empty]

Description:
## Context
[why this work is needed]

## Requirements
- [requirement 1]
- [requirement 2]

## Acceptance Criteria
- [ ] [testable criterion 1]
- [ ] [testable criterion 2]
- [ ] [testable criterion 3]

## Technical Notes
- [relevant technical details, affected components/repos]
```

### Bug draft
```
Title: [Bug] [concise description]
Story Points: [estimated based on scope — minimum 1]
Sprint: [current sprint or empty]

Description:
## Current Behavior
[what happens now]

## Expected Behavior
[what should happen]

## Steps to Reproduce
1. [step 1]
2. [step 2]

## Environment
- [affected environment/component]

## Acceptance Criteria
- [ ] [the bug is fixed: specific verification]
- [ ] [no regression in related functionality]
```

### Subtask draft
```
Title: [concise, max 80 chars]

Description:
[what this subtask covers and definition of done]
```

## Step 5: Present draft for approval

Show the complete draft to the user including all fields that will be set (type, title, description, story points, priority, sprint, assignee, team, parent epic, initial status). Wait for explicit approval before creating.

The user may:
- Approve as-is → proceed to create
- Request changes → modify and present again
- Cancel → stop without creating

## Step 6: Create in Jira

Use the Atlassian MCP to create the ticket with all required fields:

**Epic**: project, summary, description, assignee
**Story**: project, summary, description, team, story points, priority, sprint (if applicable), parent (epic), assignee
**Bug**: project, summary, description, team, story points, sprint (if applicable), parent (epic), assignee
**Subtask**: project, summary, description, parent (story or bug), assignee

After creation, report the ticket key and URL.

## Step 7: Transition initial status (if applicable)

After creation, check whether the ticket should be moved out of "To Do":
- If the user indicated they are starting work now (e.g., sprint is current, or they said so explicitly) → ask if it should be transitioned to "In Progress"
- Default: leave as "To Do" unless the user specifies otherwise
- If confirmed → use `getTransitionsForJiraIssue` to find the correct transition ID, then `transitionJiraIssue` to move to "In Progress"

## Step 8: Link to Epic (if applicable)

If creating a Story or Bug, ask which Epic it belongs to. Set the `parent` field to link it. If the user doesn't know the Epic key, search for recent Epics in the project to help them choose.

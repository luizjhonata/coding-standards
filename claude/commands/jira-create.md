Create a Jira ticket (Epic, Story, Task, or Bug) with structured content generated from user context.

The user provides the goal or problem informally (often in their native language). This command generates the title, description, and acceptance criteria in English, presents a draft for approval, and creates the ticket via the Atlassian MCP.

## Step 1: Determine ticket type

Ask the user what type of ticket to create if not specified:
- **Epic** — large initiative with multiple stories
- **Story** — user-facing feature or deliverable
- **Task** — technical work not directly user-facing
- **Bug** — defect in existing functionality

## Step 2: Load team defaults

Check memory for saved Jira defaults. If found, use them. If not found, ask the user:

1. **Jira Cloud ID** — the Atlassian site identifier
2. **Project key** — e.g., `DS`
3. **Team name** — for the Team field
4. **Default story points** — typical SP for stories/tasks
5. **Any custom required fields** — fields specific to their Jira setup

After collecting, save these defaults to memory so they are available in future sessions. Inform the user: "Defaults saved. Next time I'll use these automatically."

## Step 3: Collect context from user

Ask the user to describe what the ticket should cover. Accept informal input in any language. Probe for:

- What is the goal or problem?
- What is the expected outcome?
- Are there technical constraints or dependencies?
- Which components/repos are affected?

If the user already provided this context in the conversation, do NOT ask again.

## Step 4: Generate draft

Generate ALL content in English:

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
- [ ] ...

## Success Criteria
- [measurable outcome 1]
- [measurable outcome 2]

## Dependencies
- [list any dependencies or blockers]
```

### Story / Task draft
```
Title: [concise, max 80 chars]

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

## Step 5: Present draft for approval

Show the complete draft to the user. Wait for explicit approval before creating.

The user may:
- Approve as-is → proceed to create
- Request changes → modify and present again
- Cancel → stop without creating

## Step 6: Create in Jira

Use the Atlassian MCP to create the ticket with:
- The approved title and description
- Team defaults from memory (project, team, story points)
- Appropriate issue type

After creation, report the ticket key and URL.

## Step 7: Link to Epic (if applicable)

If creating a Story, Task, or Bug, ask if it should be linked to an existing Epic. If yes, use the Atlassian MCP to create the link.

---
description: Review the current repository changes for bugs, security risks, and missing verification.
agent: workbench
---

Review the current repository changes with a code-review mindset.

Focus on:
- Correctness bugs and behavioral regressions.
- Secret leakage, unsafe shell commands, and overly broad permissions.
- Missing or weak verification.
- Dotfiles portability issues when relevant.

Return findings first, ordered by severity, with file and line references. If there are no findings, say so and list residual risks.

User input: $ARGUMENTS

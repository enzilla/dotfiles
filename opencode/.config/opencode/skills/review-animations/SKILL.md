---
name: review-animations
description: Reviews animation and motion code against Emil Kowalski's high craft bar. Use only for motion and animation reviews; default to flagging and require evidence before approval.
---

# Reviewing Animations

Review only motion code. Do not fix unrelated features or perform a general code review. Judge whether motion feels right, not merely whether it runs. Cite `file:line` for every finding.

## Non-negotiable standards

1. Motion has a purpose, not just decoration.
2. High-frequency and keyboard actions have no animation; frequent motion is reduced.
3. Entering/exiting motion uses strong `ease-out`, never `ease-in`.
4. Routine UI motion stays under 300ms unless justified.
5. Trigger-anchored surfaces use their trigger as origin; never enter from `scale(0)`.
6. Rapid or gesture-driven motion is interruptible and retargets from its current state.
7. Prefer `transform` and `opacity` to layout properties.
8. Honor reduced motion and gate hover motion to fine pointers.
9. Deliberate actions can be slow, but system responses should be fast.
10. Motion matches the product and component personality; delete unnecessary motion.

## Required output

First, output exactly one findings table:

| Before | After | Why |
| --- | --- | --- |

Then group commentary by impact: feel-breaking regressions, missed simplifications, performance, interruptibility and timing, origin/physicality/cohesion, and accessibility. Close with **Block** or **Approve**. Block for `ease-in` UI motion, `scale(0)`, keyboard/high-frequency animation, or easy GPU-safe performance fixes.

Load [STANDARDS.md](STANDARDS.md) when a precise value or implementation is needed.

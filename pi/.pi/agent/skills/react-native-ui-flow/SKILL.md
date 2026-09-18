---
name: react-native-ui-flow
description: Automatically routes React Native and Expo UI/UX work through the appropriate installed design and review skills based on the current phase. Use for any user-facing mobile task involving screens, components, navigation, accessibility, design systems, gestures, animation, UI review, or polish. Infer the stage and load the relevant skills without requiring manual skill commands.
---

# React Native UI Flow

Act as a dispatcher, not another design system. Infer the current phase from the request and repository, then load only the skills needed for that phase.

## Start every matching task

1. Read project instructions, `package.json`, and the existing theme, tokens, and shared components relevant to the request.
2. Identify the installed React Native and, when present, Expo versions. Follow project-pinned documentation; never assume `latest`.
3. Infer the phase below. Ask only when the user goal, platform scope, or expected behavior is materially ambiguous.
4. Find each selected skill in Pi's available-skills list and read its `SKILL.md` before applying it. Never install a missing skill automatically.

## Phase routing

| Current phase | Signals | Load |
| --- | --- | --- |
| Product/flow discovery | New or unclear workflow, navigation model, user journey, information architecture | `product-designer`, then `ui-ux-pro-max` |
| Screen/component work | Building or changing a user-visible screen or component | `ui-ux-pro-max` |
| Design-system work | Shared tokens, themes, component APIs, or repeated cross-screen inconsistency | `ui-ux-pro-max` + `ui-design-system` |
| Motion/gesture work | Drag, swipe, sheet, spring, haptic, transition, or interruptible animation | `apple-design` + `emil-design-eng`; add `ui-ux-pro-max` when layout or accessibility also changes |
| UI/code review | Reviewing existing React Native UI, hooks, state, accessibility, or maintainability | `ui-ux-pro-max` + `typescript-react-reviewer` |
| Final polish | Behavior is complete and project checks pass; only consistency and micro-details remain | `polish` + `ui-ux-pro-max` |

Default to **screen/component work** for a clear implementation request. Do not run discovery for a small fix, create a design system for one screen, or polish unfinished behavior.

## Automatic progression

- Continue to the next phase without asking when it is an obvious part of the requested work.
- After implementation, run the project's existing checks and inspect the diff.
- When behavior is complete and checks pass, automatically perform a compact UI/code review.
- Use final polish only when the foundation is already sound. If review finds functional issues, fix those before polishing.
- Report the inferred phase and loaded skills in one short line only when useful; the user should not need to invoke skills manually.

## React Native guardrails

- Project instructions, installed versions, platform documentation, and existing code patterns override generic skill advice.
- Reuse the app's current design language and components before creating new tokens or abstractions.
- Translate web-oriented examples into native React Native APIs. Do not emit DOM, CSS, Tailwind, browser media queries, or web animation libraries for native code.
- Preserve iOS and Android conventions unless the task explicitly targets one platform.
- Check safe areas, touch targets, screen-reader labels, Dynamic Type/font scaling, reduced motion, loading, empty, error, disabled, and offline states when relevant.
- Do not force React 19 APIs, a state library, an animation library, or a new dependency. Match the project.
- For Expo, verify SDK compatibility and use the exact applicable versioned docs before changing Expo code.
- Never persist sensitive data in AsyncStorage or expose client secrets through environment variables.

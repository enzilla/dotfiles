---
name: apple-design
description: Apple's approach to interface design and fluid physical motion for the web. Use when building or reviewing gesture-driven UI, spring animation, drag/swipe/sheets, momentum, translucent materials, typography, reduced motion, or Apple-style design foundations.
---

# Apple Design

Build interfaces that feel like direct manipulation: motion starts at the live on-screen value, tracks the user's input continuously, inherits release velocity, projects momentum, and can be grabbed and reversed at any time.

## Rules

1. Respond on pointer-down, not release. Feedback must be immediate and continuous.
2. Use Pointer Events and `setPointerCapture`; preserve a drag's grab offset and sample velocity.
3. Never lock input while an element transitions. Retarget from its presentation value, not an old destination.
4. Use critically damped springs by default; add small bounce only to momentum-carrying gestures.
5. Choose a snap point from the velocity-projected endpoint, then hand release velocity to the spring.
6. Keep enter and exit paths symmetric; anchor popovers to their triggers with `transform-origin`.
7. Use progressive rubber-banding at boundaries instead of hard stops.
8. Animate compositor-friendly `transform` and `opacity`; preserve smooth frames under load.
9. Translucency should establish hierarchy, not obscure content. Do not stack weak glass surfaces.
10. For reduced motion, replace travel, parallax, and bounce with brief opacity cross-fades; preserve feedback that aids comprehension.

```js
function project(velocity, rate = 0.998) {
  return (velocity / 1000) * rate / (1 - rate);
}
```

```css
@media (prefers-reduced-motion: reduce) {
  .sheet { transition: opacity 200ms ease; transform: none !important; }
}
```

Typography must be optical: tighten display tracking, use tighter display leading and looser body leading, scale spacing with user text size, and prefer system fonts when a custom face has no strong reason.

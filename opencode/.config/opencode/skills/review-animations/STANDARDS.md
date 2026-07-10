# Animation Standards Reference

## Values

| Element | Duration |
| --- | --- |
| Button press | 100–160ms |
| Tooltip or small popover | 125–200ms |
| Dropdown or select | 150–250ms |
| Routine UI | Under 300ms |

```css
--ease-out: cubic-bezier(0.23, 1, 0.32, 1);
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);
```

- Enter or exit with `ease-out`; use `ease-in-out` for on-screen movement; never use `ease-in` for UI.
- Start entries at `scale(0.9–0.97)` with `opacity: 0`; use trigger-aware popover origins.
- Make press feedback `scale(0.97)` with a 100–160ms transform transition.
- Use springs for interruptible drags and retain release velocity. Keep bounce around `0.1–0.3` when justified.
- Use transitions, not keyframes, for rapidly retriggered UI.
- Animate `transform` and `opacity`; do not drive child motion through frequently updated inherited CSS variables.
- Use pointer capture, velocity-aware dismissal, and progressive boundary friction for drag interactions.
- Under reduced motion, retain opacity/color feedback while dropping movement. Gate hover animation behind fine-pointer media queries.
- Test in slow motion and frame-by-frame; verify touch gestures on real devices.

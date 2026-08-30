# web

React + Vite + TypeScript + Tailwind front-end for NextShow, using the shadcn
project layout (`components.json`, `@/` alias, `src/lib/utils.ts`,
`src/components/ui/`).

```bash
npm install
npm run dev      # vite dev server
npm run build    # tsc --noEmit + vite build -> dist/
npm run preview  # serve the build
```

## Components

### `src/components/ui/auth-switch.tsx` — `AuthSwitch`

Split-panel auth modal with a sliding-overlay transition.

- Two halves: a solid brand panel and a white form panel. Sign In → form on the
  right; Sign Up → form on the left. The dividing edge is a curved lip, not a
  straight line.
- Switching is a three-step move on one element — horizontal on `md+`, vertical
  when the panels stack on small screens:
  1. the brand panel **expands until it covers the whole modal** (0.32s ease);
  2. both forms and the overlay copy swap while fully hidden underneath;
  3. the panel **retracts to the opposite half** on the characterful spring
     (`type: "spring", stiffness: 100, damping: 20`), revealing the new side.
- `framer-motion` `AnimatePresence mode="wait"` swaps the overlay copy; both
  forms stay mounted in their own half and cross-fade under the cover — so
  there is never a blank gap or a visual overlap.

```tsx
import AuthSwitch from "@/components/ui/auth-switch";

<AuthSwitch
  defaultMode="sign-in"
  onSignIn={({ email, password }) => {}}
  onSignUp={({ username, email, password }) => {}}
/>;
```

Demo: `src/components/ui/auth-switch.demo.tsx` (rendered by `src/App.tsx`).

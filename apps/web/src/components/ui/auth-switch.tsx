import {
  useCallback,
  useEffect,
  useRef,
  useState,
  type FormEvent,
  type ReactNode,
} from "react";
import {
  AnimatePresence,
  motion,
  useAnimationControls,
  type Transition,
} from "framer-motion";
import { Lock, Mail, User } from "lucide-react";
import { FaFacebookF, FaGoogle, FaLinkedinIn, FaTwitter } from "react-icons/fa";
import { cn } from "@/lib/utils";

type Mode = "sign-in" | "sign-up";

export interface AuthSwitchProps {
  defaultMode?: Mode;
  onSignIn?: (data: { email: string; password: string }) => void;
  onSignUp?: (data: {
    username: string;
    email: string;
    password: string;
  }) => void;
  className?: string;
}

/**
 * Split-panel authentication modal with a "sliding-overlay" transition.
 *
 * The solid brand panel is a single element that first **expands until it
 * covers the whole modal**, swaps both sides while nothing is visible, then
 * **retracts to the opposite half** — horizontally on `md+`, vertically when
 * stacked on small screens. `AnimatePresence mode="wait"` swaps the content
 * on the overlay and the forms while they sit hidden under the full cover, so
 * there is never any visual overlap.
 */
export function AuthSwitch({
  defaultMode = "sign-in",
  onSignIn,
  onSignUp,
  className,
}: AuthSwitchProps) {
  const [mode, setMode] = useState<Mode>(defaultMode);
  const isSignUp = mode === "sign-up";
  const isMobile = useIsMobile();

  const panel = useAnimationControls();
  const busy = useRef(false);

  // Snap the panel to its resting side on mount and whenever the axis flips
  // (viewport crosses the `md` breakpoint) — but never mid-transition.
  useEffect(() => {
    if (busy.current) return;
    panel.set(panelInset(isMobile, mode));
  }, [isMobile, mode, panel]);

  const switchTo = useCallback(
    async (next: Mode) => {
      if (busy.current) return;
      busy.current = true;

      // 1 — grow the panel until it covers the entire modal.
      await panel.start({ ...panelInset(isMobile, "cover"), transition: COVER });

      // 2 — swap both sides while they're completely hidden.
      setMode(next);
      await raf();
      await wait(80);

      // 3 — retract to the opposite side, revealing the new form.
      await panel.start({ ...panelInset(isMobile, next), transition: SPRING });

      busy.current = false;
    },
    [isMobile, panel],
  );

  return (
    <div
      className={cn(
        "relative isolate w-full max-w-4xl overflow-hidden rounded-modal bg-white shadow-[0_30px_80px_-20px_rgba(76,70,201,0.45)]",
        "h-[780px] md:h-[560px]",
        className,
      )}
    >
      {/* ---- Form layer ------------------------------------------------- */}
      {/* Both forms stay mounted in their own half; the covered one fades out
          and the revealed one fades in while hidden under the full cover. */}
      <FormPane side="right" active={!isSignUp} isMobile={isMobile}>
        <SignInForm onSubmit={onSignIn} />
      </FormPane>
      <FormPane side="left" active={isSignUp} isMobile={isMobile}>
        <SignUpForm onSubmit={onSignUp} />
      </FormPane>

      {/* ---- Expanding brand overlay -------------------------------------- */}
      <motion.div
        className={cn(
          "absolute z-30 flex items-center justify-center text-center text-white",
          isMobile ? "inset-x-0" : "inset-y-0",
        )}
        initial={panelInset(isMobile, defaultMode)}
        animate={panel}
      >
        <div className="absolute inset-0 bg-brand" />
        <Curve isMobile={isMobile} isSignUp={isSignUp} />

        <AnimatePresence mode="wait" initial={false}>
          <motion.div
            key={mode}
            className="relative z-10 flex max-w-[300px] flex-col items-center px-8"
            initial={{ opacity: 0, y: 16 }}
            animate={{
              opacity: 1,
              y: 0,
              transition: { duration: 0.26, ease: "easeOut" },
            }}
            exit={{ opacity: 0, y: -14, transition: { duration: 0.12 } }}
          >
            {isSignUp ? (
              <OverlaySide
                title="One of us?"
                body="Welcome back! Sign in to continue your journey with us."
                cta="Sign in"
                onClick={() => switchTo("sign-in")}
              />
            ) : (
              <OverlaySide
                title="New here?"
                body="Join us today and discover a world of possibilities. Create your account in seconds!"
                cta="Sign up"
                onClick={() => switchTo("sign-up")}
              />
            )}
          </motion.div>
        </AnimatePresence>
      </motion.div>
    </div>
  );
}

export default AuthSwitch;

/* ------------------------------------------------------------------ */
/*  Motion + layout primitives                                        */
/* ------------------------------------------------------------------ */

/**
 * The characterful spring — deliberately a touch underdamped so the panel
 * settles with a little momentum. Used for the reveal (step 3).
 */
const SPRING: Transition = { type: "spring", stiffness: 100, damping: 20 };

/**
 * The cover expansion (step 1) is a fixed-duration ease rather than a spring:
 * it's mostly hidden and its job is just to get out of the way on a
 * predictable clock so the swap doesn't stall behind a settling spring tail.
 */
const COVER: Transition = { duration: 0.32, ease: [0.4, 0, 0.2, 1] };

const raf = () =>
  new Promise<void>((r) => requestAnimationFrame(() => r()));
const wait = (ms: number) => new Promise<void>((r) => setTimeout(r, ms));

/** Inset the brand panel should hold for a given state. */
function panelInset(isMobile: boolean, state: Mode | "cover") {
  if (state === "cover") {
    return isMobile
      ? { top: "0%", bottom: "0%" }
      : { left: "0%", right: "0%" };
  }
  const signUp = state === "sign-up";
  if (isMobile) {
    return signUp ? { top: "50%", bottom: "0%" } : { top: "0%", bottom: "50%" };
  }
  return signUp ? { left: "50%", right: "0%" } : { left: "0%", right: "50%" };
}

/** One half of the modal holding a single form, faded by whether it's shown. */
function FormPane({
  side,
  active,
  isMobile,
  children,
}: {
  side: "left" | "right";
  active: boolean;
  isMobile: boolean;
  children: ReactNode;
}) {
  // Extra room on the edge that meets the curved lip of the overlay.
  const pos = isMobile
    ? side === "left"
      ? "inset-x-0 top-0 h-1/2 px-6 pb-16 pt-5"
      : "inset-x-0 bottom-0 h-1/2 px-6 pb-5 pt-16"
    : side === "left"
      ? "inset-y-0 left-0 w-1/2 py-12 pl-12 pr-16"
      : "inset-y-0 right-0 w-1/2 py-12 pl-16 pr-12";

  return (
    <motion.div
      className={cn(
        "absolute flex items-center justify-center overflow-y-auto",
        pos,
      )}
      initial={false}
      animate={
        active
          ? {
              opacity: 1,
              y: 0,
              transition: { duration: 0.25, ease: "easeOut" },
            }
          : {
              opacity: 0,
              y: 6,
              transition: { duration: 0.15, ease: "easeIn" },
            }
      }
      style={{ pointerEvents: active ? "auto" : "none" }}
      aria-hidden={!active}
    >
      {children}
    </motion.div>
  );
}

function useIsMobile() {
  const [isMobile, setIsMobile] = useState(false);
  useEffect(() => {
    const mq = window.matchMedia("(max-width: 767px)");
    const sync = () => setIsMobile(mq.matches);
    sync();
    mq.addEventListener("change", sync);
    return () => mq.removeEventListener("change", sync);
  }, []);
  return isMobile;
}

/** The curved lip on the inner edge of the brand overlay. */
function Curve({
  isMobile,
  isSignUp,
}: {
  isMobile: boolean;
  isSignUp: boolean;
}) {
  if (isMobile) {
    // Attached to the horizontal edge facing the form panel.
    const onBottom = !isSignUp; // overlay sits on top -> lip points down
    return (
      <svg
        className="pointer-events-none absolute left-0 h-11 w-full text-brand"
        style={onBottom ? { top: "99.5%" } : { bottom: "99.5%" }}
        viewBox="0 0 100 44"
        preserveAspectRatio="none"
        aria-hidden
      >
        <path
          fill="currentColor"
          d={
            onBottom
              ? "M-1,-1 L101,-1 L101,8 C78,44 22,44 -1,8 Z"
              : "M-1,45 L101,45 L101,36 C78,0 22,0 -1,36 Z"
          }
        />
      </svg>
    );
  }

  // Desktop: lip on the vertical edge facing the form panel.
  const onRight = !isSignUp; // overlay sits on the left -> lip points right
  return (
    <svg
      className="pointer-events-none absolute top-0 h-full w-16 text-brand"
      style={onRight ? { left: "99.5%" } : { right: "99.5%" }}
      viewBox="0 0 64 100"
      preserveAspectRatio="none"
      aria-hidden
    >
      <path
        fill="currentColor"
        d={
          onRight
            ? "M-1,-1 L12,-1 C58,26 58,74 12,101 L-1,101 Z"
            : "M65,-1 L52,-1 C6,26 6,74 52,101 L65,101 Z"
        }
      />
    </svg>
  );
}

function OverlaySide({
  title,
  body,
  cta,
  onClick,
}: {
  title: string;
  body: string;
  cta: string;
  onClick: () => void;
}) {
  return (
    <>
      <h2 className="text-2xl font-bold sm:text-3xl">{title}</h2>
      <p className="mt-3 text-sm leading-relaxed text-white/85">{body}</p>
      <button
        type="button"
        onClick={onClick}
        className="mt-7 rounded-full border border-white/80 px-10 py-2.5 text-xs font-semibold uppercase tracking-[0.18em] transition-colors hover:bg-white/10 active:scale-[0.98]"
      >
        {cta}
      </button>
    </>
  );
}

/* ------------------------------------------------------------------ */
/*  Forms                                                             */
/* ------------------------------------------------------------------ */

function SignInForm({
  onSubmit,
}: {
  onSubmit?: (data: { email: string; password: string }) => void;
}) {
  return (
    <FormShell
      title="Sign in"
      submitLabel="Login"
      socialLabel="Or sign in with social platforms"
      onSubmit={(fd) =>
        onSubmit?.({
          email: String(fd.get("email") ?? ""),
          password: String(fd.get("password") ?? ""),
        })
      }
    >
      <Field icon={<Mail className="size-4" />} name="email" type="email" placeholder="Email" />
      <Field
        icon={<Lock className="size-4" />}
        name="password"
        type="password"
        placeholder="Password"
      />
    </FormShell>
  );
}

function SignUpForm({
  onSubmit,
}: {
  onSubmit?: (data: {
    username: string;
    email: string;
    password: string;
  }) => void;
}) {
  return (
    <FormShell
      title="Sign up"
      submitLabel="Sign up"
      socialLabel="Or sign up with social platforms"
      onSubmit={(fd) =>
        onSubmit?.({
          username: String(fd.get("username") ?? ""),
          email: String(fd.get("email") ?? ""),
          password: String(fd.get("password") ?? ""),
        })
      }
    >
      <Field icon={<User className="size-4" />} name="username" type="text" placeholder="Username" />
      <Field icon={<Mail className="size-4" />} name="email" type="email" placeholder="Email" />
      <Field
        icon={<Lock className="size-4" />}
        name="password"
        type="password"
        placeholder="Password"
      />
    </FormShell>
  );
}

function FormShell({
  title,
  submitLabel,
  socialLabel,
  children,
  onSubmit,
}: {
  title: string;
  submitLabel: string;
  socialLabel: string;
  children: ReactNode;
  onSubmit: (data: FormData) => void;
}) {
  const handle = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    onSubmit(new FormData(e.currentTarget));
  };
  return (
    <form
      onSubmit={handle}
      className="flex w-full max-w-sm flex-col items-center"
    >
      <h1 className="mb-4 text-2xl font-bold text-slate-700 sm:mb-7 sm:text-4xl">
        {title}
      </h1>
      <div className="flex w-full flex-col gap-2.5 sm:gap-3">{children}</div>
      <button
        type="submit"
        className="mt-4 rounded-full bg-brand px-12 py-2.5 text-xs font-semibold uppercase tracking-[0.18em] text-white shadow-lg shadow-brand/30 transition-colors hover:bg-brand-600 active:scale-[0.98] sm:mt-6 sm:py-3"
      >
        {submitLabel}
      </button>
      <p className="mt-4 text-sm text-slate-500 sm:mt-6">{socialLabel}</p>
      <SocialRow />
    </form>
  );
}

function Field({
  icon,
  ...props
}: { icon: ReactNode } & React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <label className="flex h-11 w-full items-center gap-3 rounded-full bg-slate-100 px-5 text-slate-400 focus-within:ring-2 focus-within:ring-brand/40 sm:h-12">
      {icon}
      <input
        {...props}
        className="h-full w-full bg-transparent text-sm text-slate-700 placeholder:text-slate-400 focus:outline-none"
      />
    </label>
  );
}

function SocialRow() {
  const items = [
    { Icon: FaGoogle, label: "Google", color: "#DB4437" },
    { Icon: FaFacebookF, label: "Facebook", color: "#1877F2" },
    { Icon: FaTwitter, label: "Twitter", color: "#1DA1F2" },
    { Icon: FaLinkedinIn, label: "LinkedIn", color: "#0A66C2" },
  ];
  return (
    <div className="mt-3 flex items-center gap-3 sm:mt-4">
      {items.map(({ Icon, label, color }) => (
        <button
          key={label}
          type="button"
          aria-label={`Continue with ${label}`}
          className="flex size-10 items-center justify-center rounded-full border border-slate-200 transition-colors hover:bg-slate-50 active:scale-95 sm:size-11"
          style={{ color }}
        >
          <Icon className="size-4" />
        </button>
      ))}
    </div>
  );
}

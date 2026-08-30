import AuthSwitch from "@/components/ui/auth-switch";

export default function AuthSwitchDemo() {
  return (
    <AuthSwitch
      defaultMode="sign-in"
      onSignIn={(d) => console.log("sign-in", d)}
      onSignUp={(d) => console.log("sign-up", d)}
    />
  );
}

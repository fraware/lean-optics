/-
# Optics Telemetry System

Opt-in telemetry (disabled unless `OPTICS_TELEMETRY=true`).
-/

import Lean
import Lean.Data.Json

namespace Optics.Telemetry

def parseBoolFlag (value : String) : Bool :=
  let normalized := value.trim.toLower
  normalized == "1" || normalized == "true" || normalized == "yes" || normalized == "on"

def parseNatOrDefault (defaultValue : Nat) (value? : Option String) : Nat :=
  match value? with
  | some value => value.trim.toNat?.getD defaultValue
  | none => defaultValue

structure TelemetryConfig where
  enabled : Bool := false
  outputFile : Option String := none
  webhookUrl : Option String := none
  maxBufferSize : Nat := 1000
  flushInterval : Nat := 100

def config : IO TelemetryConfig := do
  let enabled := parseBoolFlag ((← IO.getEnv "OPTICS_TELEMETRY").getD "false")
  let outputFile ← IO.getEnv "OPTICS_TELEMETRY_FILE"
  let webhookUrl ← IO.getEnv "OPTICS_TELEMETRY_WEBHOOK"
  let maxBuffer := parseNatOrDefault 1000 (← IO.getEnv "OPTICS_TELEMETRY_MAX_BUFFER")
  let flushInterval := parseNatOrDefault 100 (← IO.getEnv "OPTICS_TELEMETRY_FLUSH_INTERVAL")
  pure { enabled, outputFile, webhookUrl, maxBufferSize := maxBuffer, flushInterval }

inductive TelemetryEvent where
  | tacticStart (tacticName : String) (goalKind : String) (timestamp : Nat)
  | tacticEnd (tacticName : String) (goalKind : String) (duration : Nat) (success : Bool)
  | goalKind (kind : String) (count : Nat)
  | versionInfo (leanVersion : String) (mathlibVersion : String) (timestamp : Nat)
  | error (errorType : String) (message : String) (timestamp : Nat)

def TelemetryEvent.toJson : TelemetryEvent → Lean.Json
  | .tacticStart name kind ts => Lean.Json.mkObj [
      ("type", "tactic_start"),
      ("tactic", name),
      ("goal_kind", kind),
      ("timestamp", ts)
    ]
  | .tacticEnd name kind duration success => Lean.Json.mkObj [
      ("type", "tactic_end"),
      ("tactic", name),
      ("goal_kind", kind),
      ("duration", duration),
      ("success", success)
    ]
  | .goalKind kind count => Lean.Json.mkObj [
      ("type", "goal_kind"),
      ("kind", kind),
      ("count", count)
    ]
  | .versionInfo leanVer mathlibVer ts => Lean.Json.mkObj [
      ("type", "version_info"),
      ("lean_version", leanVer),
      ("mathlib_version", mathlibVer),
      ("timestamp", ts)
    ]
  | .error errorType message ts => Lean.Json.mkObj [
      ("type", "error"),
      ("error_type", errorType),
      ("message", message),
      ("timestamp", ts)
    ]

structure TelemetryBuffer where
  events : Array TelemetryEvent := #[]
  lastFlush : Nat := 0
  deriving Inhabited

initialize telemetryBufferRef : IO.Ref TelemetryBuffer ←
  IO.mkRef { events := #[], lastFlush := 0 }

def flushTelemetry : IO Unit := do
  let cfg ← config
  if cfg.enabled then
    let buffer ← telemetryBufferRef.get
    if buffer.events.size > 0 then
      let jsonEvents := buffer.events.map TelemetryEvent.toJson
      let output := Lean.Json.mkObj [("events", Lean.Json.arr jsonEvents)]

      if let some file := cfg.outputFile then
        IO.FS.writeFile file (Lean.Json.pretty output)

      if let some url := cfg.webhookUrl then
        let payload := Lean.Json.compress output
        try
          let response ← IO.Process.output {
            cmd := "curl"
            args := #[
              "-sS", "-X", "POST", url,
              "-H", "Content-Type: application/json",
              "--data-binary", payload
            ]
          }
          if response.exitCode != 0 then
            IO.eprintln s!"[TELEMETRY] webhook send failed ({response.exitCode}): {response.stderr}"
        catch e =>
          IO.eprintln s!"[TELEMETRY] webhook send exception: {e}"

      telemetryBufferRef.set { events := #[], lastFlush := 0 }

def addEvent (event : TelemetryEvent) : IO Unit := do
  let cfg ← config
  if cfg.enabled then
    let buffer ← telemetryBufferRef.get
    let newBuffer := { buffer with events := buffer.events.push event }
    telemetryBufferRef.set newBuffer
    if newBuffer.events.size >= cfg.maxBufferSize then
      flushTelemetry

def getTimestamp : IO Nat :=
  BaseIO.toIO IO.monoMsNow

def recordTacticStart (tacticName : String) (goalKind : String) : IO Unit := do
  let ts ← getTimestamp
  addEvent (.tacticStart tacticName goalKind ts)

def recordTacticEnd (tacticName : String) (goalKind : String) (duration : Nat) (success : Bool) : IO Unit := do
  addEvent (.tacticEnd tacticName goalKind duration success)

def recordGoalKind (kind : String) (count : Nat) : IO Unit := do
  addEvent (.goalKind kind count)

def recordVersionInfo (leanVersion : String) (mathlibVersion : String) : IO Unit := do
  let ts ← getTimestamp
  addEvent (.versionInfo leanVersion mathlibVersion ts)

def recordError (errorType : String) (message : String) : IO Unit := do
  let ts ← getTimestamp
  addEvent (.error errorType message ts)

end Optics.Telemetry

/-
# Machine state example (no macros)

CSLib-aligned interpreter state: lawful lenses over `pc`, `memory`, and `halted`,
plus a verified single-step transformation.
-/

import Optics

namespace Optics.Examples

structure MachineState where
  pc : Nat
  memory : List Nat
  halted : Bool

def pcLens : LawfulLens MachineState Nat :=
  Lens.mkLawful
    (get := MachineState.pc)
    (set := fun s pc => { s with pc := pc })
    (get_set := by intro s pc; rfl)
    (set_get := by intro s; rfl)
    (set_set := by intro s pc1 pc2; rfl)

def memoryLens : LawfulLens MachineState (List Nat) :=
  Lens.mkLawful
    (get := MachineState.memory)
    (set := fun s mem => { s with memory := mem })
    (get_set := by intro s mem; rfl)
    (set_get := by intro s; rfl)
    (set_set := by intro s m1 m2; rfl)

def haltedLens : LawfulLens MachineState Bool :=
  Lens.mkLawful
    (get := MachineState.halted)
    (set := fun s h => { s with halted := h })
    (get_set := by intro s h; rfl)
    (set_get := by intro s; rfl)
    (set_set := by intro s h1 h2; rfl)

/-- Advance the program counter when the machine has not halted. -/
def step (s : MachineState) : MachineState :=
  if s.halted then s else pcLens.over (· + 1) s

theorem step_preserves_memory (s : MachineState) : (step s).memory = s.memory := by
  rcases s with ⟨pc, memory, hal⟩
  cases hal <;> dsimp [step, pcLens, Lens.over, Lens.mkLawful]

theorem step_preserves_halted (s : MachineState) : (step s).halted = s.halted := by
  rcases s with ⟨pc, memory, hal⟩
  cases hal <;> dsimp [step, pcLens, Lens.over, Lens.mkLawful]

theorem step_increments_pc (s : MachineState) (h : ¬ s.halted) : (step s).pc = s.pc + 1 := by
  rcases s with ⟨pc, memory, hal⟩
  cases hal with
  | true => simp at h
  | false => dsimp [step, pcLens, Lens.over, Lens.mkLawful]

def initial : MachineState := { pc := 0, memory := [42, 0], halted := false }

#eval pcLens.get initial
#eval step initial

end Optics.Examples

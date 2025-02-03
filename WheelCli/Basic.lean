import Batteries

-- TODO: finite universe of argtypes (inextensible :()

class Arg (α : Type) where
  fromStr : String → Option α

instance [Coe String α] : Arg α where
  fromStr := some ∘ Coe.coe

instance : Arg Nat where
  fromStr := String.toNat?

instance : Arg Int where
  fromStr := String.toInt?

def Tag (name : String) := {s // s = name}

inductive Tagged (name : String) (τ : Type)
| intro (x : τ)

inductive  Cli where
| nil : Cli
| cons (flag : String) (τ : Type) [Arg τ] : Cli → Cli

@[reducible] def Cli.denote
| nil => Unit
| cons flag τ rest => (Tagged flag τ) × rest.denote

inductive HasFlag : Cli → String → Type → Type
| here  [Arg τ] : HasFlag (.cons name τ rest) name τ
| there [Arg τ] : HasFlag rest name τ → HasFlag (.cons _ rest) name τ

def parse : List String → (cli : Cli) → IO cli.denote := sorry

#reduce (types := true) Cli.denote .nil
#reduce (types := true) Cli.denote (.cons "bar" Nat .nil)
#reduce (types := true) Cli.denote (.cons "foo" Nat <| .cons "bar" Int .nil)
#check parse [] (.cons "foo" Nat <| .cons "bar" Int .nil)

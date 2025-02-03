import Lean.Elab
import Lean.Elab.Command
open Lean Elab Command Parser

class ArgVal (α) where
  fromArg : String → Option α

instance [Coe String α] : ArgVal α where
  fromArg := some ∘ Coe.coe

instance : ArgVal Nat where
  fromArg := String.toNat?

instance : ArgVal Int where
  fromArg := String.toInt?

-- TODO: better errors
class Args (α) where
  fromArgs : List String → Option α

def deriveArgs (declNames : Array Name) : CommandElabM Bool := do
  if h : declNames.size = 1 then
    let env ← getEnv
    if let some (.inductInfo info) := env.find? declNames[0] then
    if h : info.ctors.length = 1 then
    if let some (.ctorInfo info) := env.find? info.ctors[0] then
      while let some (inp, out) := IO.println info.type.arrow? do
      let mut varDecls := #[]
      let cmd ← `(instance : Args $(mkIdent declNames[0]) where
        fromArgs args := do
          $varDecls*
          for arg in args do
            sorry
      )
      elabCommand cmd
      return true
  return false

initialize
  registerDerivingHandler ``Args deriveArgs

#check `Foo
#check `(Foo)

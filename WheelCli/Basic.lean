import Lean.Elab
import Lean.Elab.Command
open Lean Elab Command Parser Term

class ArgVal (α) where
  fromArg : String → Option α

instance [Coe String α] : ArgVal α where
  fromArg := some ∘ Coe.coe

instance : ArgVal Nat where
  fromArg := String.toNat?

instance : ArgVal Int where
  fromArg := String.toInt?

instance : ArgVal String where
  fromArg := some

-- TODO: better errors
class Args (α) where
  fromArgs : Array String → Option α

def run [Args α] (main : (α → IO UInt32)) (args : List String) : IO UInt32 := do
  if let some args := Args.fromArgs args.toArray then
    main args
  else
    IO.eprintln "bad args brah"
    return 127

def deriveArgs (declNames : Array Name) : CommandElabM Bool := do
  if h : declNames.size = 1 then
    let env ← getEnv
    let name := declNames[0]
    if isStructure env name then
    if let some (.inductInfo info) := env.find? name then
    if h : info.ctors.length = 1 then
    let ctor := info.ctors[0]
    let fieldNames := getStructureFieldsFlattened env name (includeSubobjectFields := false)
    let flags := fieldNames.map (quote s!"--{·}")
    let fields  := fieldNames.map Lean.mkIdent
    let fields' := fields
    let cmd ← `(instance : Args $(mkIdent name) where
      fromArgs args := do
        $[let mut $fields:ident := none]*
        let mut i := 0
        while h : i + 1 < args.size do
          match args[i], args[i+1] with
          $[| $flags, val => do $fields:ident := ArgVal.fromArg val]*
            | _, _ => pure ()

          i := i + 2

        (do
          $[let $fields ← $fields':ident]*
          -- TODO: remove `ctor`, use struct syntax
          return $(Lean.mkIdent ctor):term $fields*
        )
    )
    elabCommand cmd
    return true
  return false

initialize
  registerDerivingHandler ``Args deriveArgs

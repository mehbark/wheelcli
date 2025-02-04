import Lean.Elab
import Lean.Elab.Command
open Lean Elab Command Parser Term

/--
  `FromArg α` is a typeclass that says `α` can (possibly fallibly)
  be parsed from a `String`.
-/
class FromArg (α) where
  fromArg : String → Option α

instance [Coe String α] : FromArg α where
  fromArg := some ∘ Coe.coe

instance : FromArg Nat where
  fromArg := String.toNat?

instance : FromArg Int where
  fromArg := String.toInt?

instance : FromArg String where
  fromArg := some

-- TODO: better errors
/--
  `FromArgs α` is a typeclass that says `α` can be parsed from an `Array String`.
  It can be derived for simple `structure`s.
-/
class FromArgs (α) where
  fromArgs : Array String → Option α

/--
  Parses arguments and runs `f` or exits with error code `127`.
  Intended for use in the `main` function.
-/
def withArgs [FromArgs α] (f : α → IO UInt32) (args : List String) : IO UInt32 := do
  if let some args := FromArgs.fromArgs args.toArray then
    f args
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
    let flags := fieldNames.map fun name => quote <|
      if name.toString.length = 1 then s!"-{name}" else s!"--{name}"
    let fields  := fieldNames.map Lean.mkIdent
    let fields' := fields
    let cmd ← `(instance : FromArgs $(mkIdent name) where
      fromArgs args := do
        $[let mut $fields:ident := none]*
        let mut i := 0
        while h : i + 1 < args.size do
          match args[i], args[i+1] with
          $[| $flags, val => do $fields:ident := FromArg.fromArg val]*
            | _, _ => pure ()

          i := i + 2

        (do
          $[let $fields ← $fields':ident]*
          -- TODO: remove `ctor`, use struct syntax
          -- TODO: default args
          return $(Lean.mkIdent ctor):term $fields*
        )
    )
    elabCommand cmd
    return true
  return false

initialize
  registerDerivingHandler ``FromArgs deriveArgs

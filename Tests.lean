import WheelCli

structure Foo where
  bar : Nat
  baz : String
deriving Args, Repr

#print instArgsFoo

#eval (Args.fromArgs #["--bar", "3", "--baz", "bla"] : Option Foo)

#eval Id.run do
  let mut i := 0
  while i < 10 do
    match 3 with
    | 3 => do i := i + 1
    | _ => pure ()
  return i

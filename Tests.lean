import WheelCli

structure Foo where
  bar : Nat
  baz : String
deriving Args, Repr

/-- info: some { bar := 3, baz := "bla" } -/
#guard_msgs in
#eval (Args.fromArgs #["--bar", "3", "--baz", "bla"] : Option Foo)

/-- info: some { bar := 3, baz := "bla" } -/
#guard_msgs in
#eval (Args.fromArgs #["--baz", "bla", "--bar", "3"] : Option Foo)

/-- info: none -/
#guard_msgs in
#eval (Args.fromArgs #["--baz", "bla"] : Option Foo)

/-- info: none -/
#guard_msgs in
#eval (Args.fromArgs #["--bar", "-1", "--baz", "bla"] : Option Foo)

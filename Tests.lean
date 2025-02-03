import WheelCli

structure Foo where
  bar : Nat
  baz : String
deriving Args

#eval (Args.fromArgs ["--bar", "3", "--baz", "bla"] : IO Foo)

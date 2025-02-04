import WheelCli

structure Args where
  name : String
  n : Nat
deriving FromArgs

def main := withArgs fun {name, n : Args} => do
  for _ in [0:n] do
    println! "Hello, {name}!"
  return 0

/--
info: Hello, L∃∀N!
Hello, L∃∀N!
Hello, L∃∀N!
Hello, L∃∀N!
Hello, L∃∀N!
Hello, L∃∀N!
Hello, L∃∀N!
Hello, L∃∀N!
Hello, L∃∀N!
Hello, L∃∀N!
---
info: 0
-/
#guard_msgs in
#eval main ["--name", "L∃∀N", "-n", "10"]

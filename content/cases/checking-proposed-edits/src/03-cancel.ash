import edits as Edits
import controller as Controller

main : Unit -> (Edits.Result, Bool)
main () = Controller.run Controller.Cancel

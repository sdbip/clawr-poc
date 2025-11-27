# TODO

- `object`
  - factory methods
  - targeted function calls
  - `ObjectLiteral` `{super.new()}`

## Incomplete Features, Bugs & Redesigns

- Functions
  - Function call as `Expression`
  - Varargs
  - Optional arguments
- toString calls
  - Check for `HasStringRepresetation` vtable
- Replace the `print` command with a `print(_:)` function
  - Requires `trait HasStringRepresentation`
  - Requires bridging to C implementation
  - Requires the C function to be known to the `Scope`

## Possible Next Features

- Operators
- Lambdas
- List comprehension
- `string`
- `regex`
- `enum ternary { case down = -1, zero = 0, up = 1 }`
- `enum boolean { case false, true }`
- `if b {}`, `if !b {}`, `if t {}`, `if !t {}`
- Conversion t<-> b (t.up <-> b.true, t.down <-> b.false)
- Read Eval Print Loop

## Other Thoughts and Ideas

- Read input from `stdin`. Swift has `readLine() -> String?`
  - I suppose `⌃D` is what causes the `nil` case.
  - Requires `Optional<T>`, `union`?
- Executable that returns the AST (unresolved?) for semantic syntax colouring
  - It'll need the token `FileLocation`s
  - Will it also need resolved types? Maybe?

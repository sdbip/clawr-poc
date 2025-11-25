# Semantics Rules for Clawr

There are two kinds of types that are the most relevant for semantics rules: `object` and `data`. A `data` structure is just a container for related information (as a set of “fields”). An `object` is a behavioural interface (a set of “methods”) that hides a `data` structure in its implementation.

Note: The following rules are not the conceptual framing programmers should internalise. They are meant to explain the implementation.

1. Memory is tagged as `REFERENCE` or `ISOLATED` at allocation and that value must never change until the memory is freed.
2. Allocation is done by calling a factory method (`object`) or assigning a literal (`data`) to the variable.
    - Clawr uses a special constructor syntax that looks like a static method: a “factory method.”
    - The runtime allocates memory, tagging it to match the receiver’s semantics.
    - Then it calls the factory method to initialise the allocated memory.
3. `let` variables are immutable and their values can never change after initialisation.
4. `mut` variables are mutable, but only by direct explicit reference.
5. `ref` variables are references to shared, mutable memory structures.
6. `ref` variables can be assigned to other `ref` variables to maintain multiple references to the same data.
7. `let` and `mut` variables can be assigned to each other but modifications are isolated to one variable.
    - They can safely reference the same memory address as long as no modification is performed.
    - They are tagged as`ISOLATED` and apply CoW to maintain isolation when mutation is needed.
8. `ref` variables are tagged as `REFERENCE` to that the runtime knows not to make implicit copies.
9. Copies can be made explicitly with a `copy` keyword (or maybe it should syntactically be a method call—`x.copy()`).
10. `let`/`mut` variables can be assigned to `ref` variables (and vice versa), but only if explicitly copied. They use incompatible semantics and must be kept apart.
11. Local (and global) variables require explicit semantics (`let`, `mut` or `ref`). Fields are `mut` by default. Function parameters are `let` by default.
12. Passing a `ref` variable as an argument to a function that uses `ISOLATED` semantics requires explicit copying.
13. Passing a `let` or `mut` variable to a `REFERENCE` semantics parameter…?
14. Returning a value from a function (not `factory`) defaults to `ISOLATED` but can be overridden by adding the `ref` keyword (`func child(id: EntityId) -> ref ChildEntity`). If the semantics doesn't match the receiver an explicit copy is required.

Idea/exploration: What if parameters were a fourth (implicit) category? Neither `let`, `mut` nor `ref`, they would have their own semantic behaviour. What should that be?

1. They could just accept the value as-is and if it happens to be tagged `REFERENCE`, they will have to accept that it might be modified at any time.
2. They could be `let` variables and just use normal behaviour if given an `ISOLATED` memory structure, but make an implicit copy if given a `REFERENCE`.
3. The flag could be exposed through some kind of API and the programmer could be allowed to choose behaviour (i.e. whether to make a copy or allow multi-reference mutation).
 
 I don’t think any of these options feels quite right.
 
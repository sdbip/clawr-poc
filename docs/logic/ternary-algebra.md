# Ternary Algebra

Many have considered [Boolean algebra](boolean-algebra.md) too limited. Even Aristotle considered statements of the future as neither definitively true nor definitively false. Many philosophers and mathematicians have since imagined multi-valued truth. Gödel went so far as to create a system that allows *infinite degrees* of truth between 0 (absolutely false) and 1 (absolutely true).

The most obvious extension to Boolean binary is to add a single extra state, an indeterminate or “unknown” state. We can notate the states as `-` for false, `+` for truth and `0` for the unknown state.

There are also other notations. In Clawr, the `ternary` type is an `enum` with the three possible values `up` (true), `down` (false) and `zero`. To abbreviate those as single characters, we could use `U`, `D` and `0` respectively (and that’s how we represent ternary digits in a `bitfield`). For this document, the symbols `-`, `+` are probably the most illustrative. They are also the most often used in other literature.

The basic binary operations can be translated to ternary. As we remember, in [binary](boolean-algebra.md):

| $a$ | $b$ | $a \times b$ | $a + b$ | $a \oplus b$ |
| --- | --- | ------------ | ------- | ------------ |
| $0$ | $0$ | $0$          | $0$     | $0$          |
| $0$ | $1$ | $0$          | $1$     | $1$          |
| $1$ | $0$ | $0$          | $1$     | $1$          |
| $1$ | $1$ | $1$          | $1$     | $0$          |

Therefore, ternary should work the same (except now the symbols are different):

| $a$ | $b$ | $a \times b$ | $a + b$ | $a \oplus b$ |
| --- | --- | ------------ | ------- | ------------ |
| `-` | `-` | `-`          | `-`     | `-`          |
| `-` | `+` | `-`          | `+`     | `+`          |
| `+` | `-` | `-`          | `+`     | `+`          |
| `+` | `+` | `+`          | `+`     | `-`          |

However, this is not the entire truth-table. We have not considered the unknown state. How should the table expand to include `0`-valued inputs?

If we think of AND as yielding the minimum of two inputs, and OR as yielding the maximum, we can describe both ternary and binary logic correctly, and that is how those operations are usually interpreted. XOR, however, does not have explicit consensus.

We could define it (for ternary, not for binary) using multiplication: $a \oplus b = -(a \cdot b)$. If false is $-1$ and true is $+1$, $-(a \cdot b)$ yields the above table exactly.

If we accept these definitions, the extended table will look like this.

| $a$ | $b$ | $a \times b$ | $a + b$ | $a \oplus b$ |
| --- | --- | ------------ | ------- | ------------ |
| `-` | `-` | `-`          | `-`     | `-`          |
| `-` | `0` | `-`          | `0`     | `0`          |
| `-` | `+` | `-`          | `+`     | `+`          |
| `0` | `-` | `-`          | `0`     | `0`          |
| `0` | `0` | `0`          | `0`     | `0`          |
| `0` | `+` | `0`          | `+`     | `0`          |
| `+` | `-` | `-`          | `+`     | `+`          |
| `+` | `0` | `0`          | `+`     | `0`          |
| `+` | `+` | `+`          | `+`     | `-`          |

This is however not the complete story. In binary, all possible outputs from an arbitrary binary operator (two inputs) can be defined using the two binary operators and the unary NOT. In ternary we need at least one more operator.

We need three things to engender completeness:

1. Permutation (e.g. `rotate-up(a)`)
2. Non-bijective transformation (e.g. `is_plus(a)`)
3. The constants `+`, `0`, `-`

Permutations: The unary operator `rotatero_up(a)` adds one to `a` and rolls around to `-` if the result would be 2. The inverse is `rotate_down(a)`. Applying either operation three times returns us back to `a`.

| $a$ | $\mathrm{up}(a)$ | $\mathrm{up}^2(a)$ | $\mathrm{up}^3(a)$ | $\mathrm{down}(a)$ | $\mathrm{down}^2(a)$ | $\mathrm{down}^3(a)$ |
| --- | ---------------- | ------------------ | ------------------ | ------------------ | -------------------- | -------------------- |
| `-` | `0`              | `+`                | `-`                | `+`                | `0`                  | `-`                  |
| `0` | `+`              | `-`                | `0`                | `-`                | `+`                  | `0`                  |
| `+` | `-`              | `0`                | `+`                | `0`                | `-`                  | `+`                  |

 We can therefore define `rotate_down(a)` as `rotate_up(rotate_up(a))`. (Or we can define `rotate_up` as `rotate_down` applied twice.)

> [!note] Formulas
> - `rotate_up(a)` = `rotate_down(rotate_down(a))`
> - `rotate_down(a)` = `rotate_up(rotate_up(a))`
> - `rotate_up(rotate_up(rotate_up(a)))` = `rotate_down(rotate_down(rotate_down(a)))` = `a`

Non-bijective transformations: The unary operator `is_plus(a)` is `+` if `a` is `+`, and `-` otherwise. We can define `is_minus` and `is_zero` from `is_plus` and `rotate_up`/`rotate_down`:

> [!note] Formulas
> - `is_zero(a)` = `is_plus(rotate_up(a))` = `is_minus(rotate_down(a))`
> - `is_minus(a)` = `is_plus(rotate_down(a))` = `is_zero(rotate_up(a))`

The `rotate_up` and `is_plus` functions are enough to generate any unary gate you can imagine. To generate any arbitrary binary operator, you can use the [SEL function](sel-function.md).

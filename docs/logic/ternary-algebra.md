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

## Ternary Karnaugh Maps

In this documentation I use a matrix notation inspired by the researcher [Louis Duret-Robert](https://louis-dr.github.io/ternlogic.html). He in turn might have taken inspiration from the [Karnaugh Map](https://en.wikipedia.org/wiki/Karnaugh_map) used in Boolean algebra.

A unary (or monadic) operator is described as a 1⨉3 matrix (one row, thee columns). [^transposed] The identity (return the input as is) and not (flip true/false) operators can be written as follows:

[^transposed]: Duret-Robert uses three rows and one column in his diagrams. I use the transpose of his diagrams, because that form is easier to write inline in text.

### Identity

The identity function replicates the input in the output. It is not a very useful function other than for pedagogic illustration. The identity returns `-` (-1 or “false”) if the input is `-`, `0` if the input is `0`, and `+`(+1 or “true”) if the input is `+`. It is called “identity” because its output is identical to the input.

We can depict the identity using a simple matrix:

$$\mathsf{Id} = \begin{bmatrix} - & 0 & +\end{bmatrix}$$

The first position (left-most column) show the output when the input is false/`-`, then `0` and finally `+`. I start with the identity because it illustrates each position.

### Negation (NOT, ¬, `!`)

The only interesting monadic/unary operator for Boolean algebra is the NOT operator. The ternary equivalent is sometimes referred to as “negation”: 

$$\mathsf{Neg} = \begin{bmatrix} + & 0 & -\end{bmatrix}$$

The negation operator switches `+` and `-` (true and false), but leaves `0` (the unknown/undefined state) unchanged. We see that in how the positions are reversed compared to the identity matrix.

### Rotate-down and rotate-up

Ternary logic supports an extra state compared to Boolean, and that leads to many mode possible transformations (four Boolean operators—three of which are pointless—versus a total of 27 ternary operators—presumably three pointless ones again).

A pair of interesting ternary operators are rotate-up:

$$\mathsf{RotUp} = \begin{bmatrix} 0 & + & -\end{bmatrix}$$

and rotate-down:

$$\mathsf{RotDown} = \begin{bmatrix} + & - & 0\end{bmatrix}$$

Rotate up adds one to the numeric value (-1, 0 or +1) and rotate down removes one. If the total is +2, the output is -1, and if the total is -2, the output is plus one; that is the “rotation” part of the name.

Is is easy to see that three rotations returns us back to the origin, and two rotations are equivalent to a single rotation in the opposite direction.

Rot-up and rot-down will be interesting to cryptographers. Today, they use XOR—which is its own reverse—to combine values. In ternary computers, XOR cannot be used for such purposes, as any zero in the input will destroy the information in the other operand. Roll-up/-down will have to take that role in ternary computers.

### Is-plus, is-zero and is-minus.

As previously noted, there are 27 possible monadic ternary operators. I will not list all of them, but if I add one more, all imaginable operators can be generated from neg, rotate-up and this one. The operator is called is-plus:

$$\mathsf{IsPlus} = \begin{bmatrix} - & - & +\end{bmatrix}$$

We can also define is-zero and is-minus:

$$\mathsf{IsZero} = \begin{bmatrix} - & + & -\end{bmatrix}$$

$$\mathsf{IsMinus} = \begin{bmatrix} + & - & -\end{bmatrix}$$

The is-zero and is-minus operators can be defined from is-plus and rotate-up/-down:

$$\mathsf{IsMinus}(x) = \mathsf{IsPlus}(\mathsf{RotDown}(x))$$

$$\mathsf{IsZero}(x) = \mathsf{IsPlus}(\mathsf{RotUp}(x))$$

We can demonstrate this using our matrices. Applying one operator (the “second”) after another (the “first”) can be depicted as a single matrix, where each position is the result of applying the second operation to the corresponding value in the first matrix.

We start with the rot-down matrix:

$$\mathsf{RotDown} = \begin{bmatrix} + & - & 0\end{bmatrix}$$

Applying is-plus to each position of the matrix, `-` and `0` becomes `-`, and `+` becomes `+`. We can hence denote applying is-plus *after* rot-down as:

$$\mathsf{RotDown} \odot \mathsf{IsPlus} = \begin{bmatrix} + & - & -\end{bmatrix}$$

And that is the same as is-minus. $\square$

## The Base Dyadic Operators

A binary operators is an operator that has two inputs. To avoid confusion with the “binary” that refers to Boolean algebra and binary computers, I will use the term “dyadic” instead.

Dyadic operators are depicted using a 2-dimensional matrix (one dimension per input variable). The ordering is the same, but of course, now one of the variable selects the row (from top to bottom).

The `AND` operator can be depicted as:

$$\mathsf{And} = \begin{bmatrix} 
  - & - & - \\\ 
  - & 0 & 0 \\\ 
  - & 0 & + 
\end{bmatrix}$$

And the `OR` operator:

$$\mathsf{Or} = \begin{bmatrix} 
  - & 0 & + \\\ 
  0 & 0 & + \\\ 
  + & + & + 
\end{bmatrix}$$

> [!warning] Note that this is not linear algebra.
> The matrices in this document are not intended for matrix multiplication. Linear algebra formulas won’t help simplify complex ternary expressions. At least not using any of the matrices in this document. These matrices exist for illustration and discombobulation.

### Consensus and Gullibilty

There is a total of 19,683 dyadic operators for ternary logic. Comparing this to the mere 16 of Boolean algebra, you can see a problem emerging. Ternary algebra is three orders of magnitude more complex than Boolean. It might not be so easy to develop an intuition about ternary logic. And it is a tall order to define an arbitrary operator from primitives/first principles.

Fortunately, not all operators are all that “useful.” Most of the 19,683 operators are presumably too niche to name generally. Two that do have names are CONS and ANY.

The consensus operator has the following matrix:

$$\mathsf{Cons} = \begin{bmatrix} - & 0 & 0 \\\ 0 & 0 & 0 \\\ 0 & 0 & +\end{bmatrix}$$

CONS (or “consensus”) outputs 0 unless all inputs agree. If they do agree, the output is the agreed-upon value. The *consensus* value.

The antithesis to consensus is to gullibly accept any conviction.

$$\mathsf{Any} = \begin{bmatrix} - & - & 0 \\\ - & 0 & + \\\ 0 & + & +\end{bmatrix}$$

The ANY operator (a.k.a. “accept anything” or “gullibility”) could be described as a binary OR-ified CONS. Just as AND and OR are each other’s converse, CONS and ANY have a similar duality relationship.

Douglas W. Jones describes ANY as:

> “Where _consensus_ requires that both inputs agree before it asserts anything but _unknown_, the _accept anything_ operator declares an _unknown_ conclusion only if both inputs are _unknown_ or actively disagree. Otherwise, it jumps to a conclusion from any non-_unknown_ input available to it.”
> —Douglas W. Jones (<https://homepage.cs.uiowa.edu/~dwjones/ternary/logic.shtml#any>)

Can we use De Morgan’s theorem on CONS and ANY? No, unfortunately. De Morgan says that $\neg (a \times b) = \neg a + \neg b$, and $\neg (a + b) = \neg a \times \neg b$, but applying NOT/neg to inputs or outputs of ANY does not give us CONS, not vice versa. Instead, the operation retains the same operator, just with the output inverted:

$$\neg(a \boxplus b) = \neg a \boxplus \neg b$$
$$\neg(a \boxtimes b) = \neg a \boxtimes \neg b$$

The fact that they obey similar formulas might be a good enough reason to categorise them as a pair. The duality of their definition (agreed certitude versus gullible certitude) is another.

### MUL and SUM

There is another interesting pair of dyadic operators. Multiplication (MUL) outputs the product of the inputs (where `-` is -1 and `+` is +1):
$$\mathsf{Mul} = \begin{bmatrix} + & 0 & - \\\ 0 & 0 & 0 \\\ - & 0 & +\end{bmatrix}$$
Addition (SUM) returns the mod-3 sum of the inputs, normalised to the \[-1, +1] range.
$$\mathsf{Sum} = \begin{bmatrix} + & - & 0 \\\ - & 0 & + \\\ 0 & + & -\end{bmatrix}$$
Since $2 \equiv -1$ and $-2 \equiv +1$ mod 3 we get `-` + `-` = `+`, and `+` + `+` = `-`.

Maybe a subtraction (SUB) is also relevant? SUB is however asymmetric so we will have to choose an order. If we choose the row to act as minuend and the column to be the subtrahend, the matrix is as follows:
$$\mathsf{Sub} = \begin{bmatrix}
  0 & - & + \\\
  + & 0 & - \\\
  - & + & 0
\end{bmatrix}$$
If we instead choose to use the column as representing the minuend and the row as the subtrahend, we get the transposed matrix:
$$\mathsf{Sub} = \begin{bmatrix}
  0 & + & - \\\
  - & 0 & + \\\
  + & - & 0
\end{bmatrix}$$
Which is better? I think the choice can only be arbitrary. There is no logical preference for one over the other. I do not plan to depict SUM again in the documentation, so I will not make a decision one way or the other at this time.

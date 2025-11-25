# Ternary Algebra

Many have considered [Boolean algebra](boolean-algebra.md) too limited. Even Aristotle considered statements of the future as neither definitively true nor definitively false. Many philosophers and mathematicians have since imagined multi-valued truth. Gödel went so far as to create a system that allows *infinite degrees* of truth between 0 (absolutely false) and 1 (absolutely true).

The most obvious extension to Boolean binary is to add a single extra state, an indeterminate or “unknown” state. We can notate the states as `-` for false, `+` for truth and `0` for the unknown state.

There are also other notations. In Clawr, the `ternary` type is an `enum` with the three possible values `up` (true), `down` (false) and `zero`. To abbreviate those as single characters, we could use `U`, `D` and `0` respectively (and that’s how we represent ternary digits in a `tritfield`). For this document, the symbols `-`, `+` are probably the most illustrative. They are also the most often used in other literature.

Basic dyadic (two inputs) logic operations can be translated to ternary. As we remember, in [Boolean algebra](boolean-algebra.md):

| $a$ | $b$ | $a \ \mathsf{AND} \ b$ | $a \ \mathsf{OR} \ b$ | $a \ \mathsf{XOR} \ b$ | $a \ \mathsf{IMPL} \ b$ |
| :-: | :-: | :--------------------: | :-------------------: | :--------------------: | :---------------------: |
|  F  |  F  |           F            |           F           |           F            |            T            |
|  F  |  T  |           F            |           T           |           T            |            T            |
|  T  |  F  |           F            |           T           |           T            |            F            |
|  T  |  T  |           T            |           T           |           F            |            T            |

In ternary we use `+` to denote true and `-` to denote false (otherwise the table is identical):

| $a$ | $b$ | $a \ \mathsf{AND} \ b$ | $a \ \mathsf{OR} \ b$ | $a \ \mathsf{XOR} \ b$ |
| :-: | :-: | :--------------------: | :-------------------: | :--------------------: |
| `-` | `-` |          `-`           |          `-`          |          `-`           |
| `-` | `+` |          `-`           |          `+`          |          `+`           |
| `+` | `-` |          `-`           |          `+`          |          `+`           |
| `+` | `+` |          `+`           |          `+`          |          `-`           |

However, this is not the entire truth-table. We have not considered the unknown state. How should the table expand to include `0`-valued inputs?

If we think of AND as yielding the minimum of two inputs, and OR as yielding the maximum, [^competition] we can describe both ternary and binary logic correctly, and that is how those operators are usually interpreted.

[^competition]: There are several competing ternary logics in history. The ones that use a numerical representations where false < true typically interpret AND as MIN and OR as MAX.

XOR does not have explicit consensus, but there is a natural way to define it: $a \ \mathsf{XOR} \ b = (¬a \times b) + (a \times ¬b)$. If we use the max/min definitions for AND/OR we get $\mathsf{XOR}(a, b) = \max(\min(¬a, b), \min(a, ¬b))$.

If we accept these definitions, the extended table will look like this.

| $a$ | $b$ | $a \ \mathsf{AND} \ b$ | $a \ \mathsf{OR} \ b$ | $a \ \mathsf{XOR} \ b$ |
| :-: | :-: | :--------------------: | :-------------------: | :--------------------: |
| `-` | `-` |          `-`           |          `-`          |          `-`           |
| `-` | `0` |          `-`           |          `0`          |          `0`           |
| `-` | `+` |          `-`           |          `+`          |          `+`           |
| `0` | `-` |          `-`           |          `0`          |          `0`           |
| `0` | `0` |          `0`           |          `0`          |          `0`           |
| `0` | `+` |          `0`           |          `+`          |          `0`           |
| `+` | `-` |          `-`           |          `+`          |          `+`           |
| `+` | `0` |          `0`           |          `+`          |          `0`           |
| `+` | `+` |          `+`           |          `+`          |          `-`           |

This is however not the complete story. Boolean algebra has $2^2 = 4$ monadic operators (single input) and $2^{2^2} = 16$ dyadic operators (two inputs). All possible operators can be defined from AND/OR and NOT. Ternary logic controls a much larger algebra.

Ternary algebra has $3^3 = 27$ monadic operators and $3^{3^2} = 19,683$ dyadic ones. The complete space of ternary cannot be represented only from min/max and neg. For 3-valued logic, any _complete basis_ must include at least one non-bijective and one bijective transformation.

We need three things to engender completeness:

1. Permutation (e.g. ROT–UP)
2. Non-bijective transformation (e.g. IS–PLUS)
3. The constants `+`, `0`, `-`

#### Permutations

The unary operator $\mathsf{ROT–UP}(a)$ adds one to $a$ and rolls around to `-` if the result overflows the single digit representation. The inverse is ROT–DOWN. Applying either operation three times returns us back to $a$.

| $a$ | $\mathsf{R–UP}(a)$ | $\mathsf{R–UP}^2(a)$ | $\mathsf{R–UP}^3(a)$ | $\mathsf{R–DOWN}(a)$ | $\mathsf{R–DOWN}^2(a)$ | $\mathsf{R–DOWN}^3(a)$ |
| --- | ------------------ | -------------------- | -------------------- | -------------------- | ---------------------- | ---------------------- |
| `-` | `0`                | `+`                  | `-`                  | `+`                  | `0`                    | `-`                    |
| `0` | `+`                | `-`                  | `0`                  | `-`                  | `+`                    | `0`                    |
| `+` | `-`                | `0`                  | `+`                  | `0`                  | `-`                    | `+`                    |

In the above table, I abbreviate ROT-UP as R-UP and ROT-DOWN ass R-DOWN to save horizontal space. I also use exponentials to indicate repeated application: $R–UP^2(a)$ means $ROT–UP \big (ROT–UP(a) \big )$.

The table show us that $\mathsf{ROT–DOWN}(a)$ is the same as $\mathsf{ROT–UP}(\mathsf{ROT–UP}(a))$. We can summarise the table as the following formulas:

> [!note] Formulas
> - $\mathsf{ROT–UP}(a) = \mathsf{ROT–DOWN}(\mathsf{ROT–DOWN}(a))$
> - $\mathsf{ROT–DOWN}(a) = \mathsf{ROT–UP}(\mathsf{ROT–UP}(a))$
> - $\mathsf{ROT–UP}(\mathsf{ROT–UP}(\mathsf{ROT–UP}(a))) = \mathsf{ROT–DOWN}(\mathsf{ROT–DOWN}(\mathsf{ROT–DOWN}(a))) = a$

#### Non-bijective Transformations

The unary operator $\mathsf{IS–PLUS}(a)$ outputs `+` if $a$ is `+`, and `-` otherwise. We can define IS–MINUS and IS–ZERO from IS–PLUS and ROT–UP / ROT–DOWN:

> [!note] Formulas
> - $\mathsf{IS–ZERO}(a) = \mathsf{IS–PLUS}(\mathsf{ROT–UP}(a)) = \mathsf{IS–MINUS}(\mathsf{ROT–DOWN}(a))$
> - $\mathsf{IS–MINUS}(a) = \mathsf{IS–PLUS}(\mathsf{ROT–DOWN}(a)) = \mathsf{IS–ZERO}(\mathsf{ROT–UP}(a))$

The output from these operators cannot be `0`. Since there are only two possible outputs, there can be no way to restore all three possible inputs in an inverse function. If a function translates all possible inputs to some value in the output space, we call it “injective.” If it also has an inverse which translates all possible values in the output space back to the input set, we call it “bijective.” If we want to explicitly say that there is no inverse, we call the function “non-bijective.”

The ROT–UP and ROT-DOWN functions are bijective—they are each others inverse. If we add a IS-PLUS (or either one of its siblings), we will have enough to generate *any* monadic operator you can possibly imagine. To generate any arbitrary dyadic operator, you can use the [SEL function](sel-function.md).

## Ternary Karnaugh Maps

In this documentation I use a matrix notation inspired by the researcher [Louis Duret-Robert](https://louis-dr.github.io/ternlogic.html). These matrices are called [Karnaugh Maps](https://en.wikipedia.org/wiki/Karnaugh_map) or K-maps. They originate in Boolean algebra where they are very useful for simplifying complex expressions. To my mind, they are less effective at simplifying ternary algebra, but they can be very useful for illustrating operators.

A unary (or monadic) operator is described as a 1⨉3 matrix (one row, three columns), [^transposed] and a binary (dyadic) operator is described as a two-dimensional (3⨉3) matrix. In the following sections, I depict a few of the most essential ternary operators.

[^transposed]: Duret-Robert uses three rows and one column in his diagrams. I use the transpose of his diagrams, because the horizontal form is easier to write inline in text. The vertical form, on the other hand, has the benefit of matching the truth-table that it represents. Other than that, the orientation is not important and can be selected arbitrarily.

### Identity

The identity function replicates the input in the output. It is not a very useful function other than for pedagogic illustration. The identity returns `-` (-1 or “false”) if the input is `-`, `0` if the input is `0`, and `+`(+1 or “true”) if the input is `+`. It is called “identity” because its output is identical to the input.

We can depict the identity using a simple one-dimensional K-map:

$$\mathsf{ID} = \begin{bmatrix} - & 0 & +\end{bmatrix}$$

The first position (left-most column) show the output when the input is false/`-`, then `0` and finally `+`. Since the position represents the input and the value represents the output, the identity function perfectly illustrates the structure of the K-map.

### Negation (NOT, ¬)

The only truly meaningful monadic/unary operator for Boolean algebra is the NOT operator. The ternary equivalent is sometimes referred to as “negation”: 

$$\mathsf{NEG} = \begin{bmatrix} + & 0 & -\end{bmatrix}$$

The negation operator switches `+` and `-` (true and false), but leaves `0` (the unknown / undefined state) unchanged. We see that in how the positions are reversed compared to the identity K-map.

### ROT-UP and ROT-DOWN

Ternary logic supports an extra state compared to Boolean, and that leads to many more possible transformations (four Boolean operators—three of which are pointless—versus a total of 27 ternary operators—of which presumably only three again are entirely pointless).

A pair of interesting ternary operators are rotate-up:

$$\mathsf{ROT–UP} = \begin{bmatrix} 0 & + & -\end{bmatrix}$$

and rotate-down:

$$\mathsf{ROT–DOWN} = \begin{bmatrix} + & - & 0\end{bmatrix}$$

Rotate up adds one to the numeric value (-1, 0 or +1) and rotate down removes one. If the total is +2, the output is -1, and if the total is -2, the output is +1; that is the “rotation” part of the name.

The operators have many names. I have seen them called successor/predecessor (mod 3), as well as increment/decrement (also mod 3). I assume there are other names I’m not aware of. The “mod 3” qualifier indicates that 2 is equivalent to -1 and -2 is equivalent to +1 (same remainders when divided three ways), and with only one digit (one truth value), we cannot represent ±2.

Is is easy to see that three rotations in the same direction will return us back to the origin, and that two rotations in one direction are equivalent to a single opposite rotation.

ROT-UP and ROT-DOWN will be interesting to cryptographers. Today, they use XOR—which is its own reverse—to combine values. In ternary computers, XOR cannot be used for such purposes, as any zero in the input will destroy the information in the other operand. ROT-UP/-DOWN will have to take that role in ternary computers. Most of the time, you should not need to care whether you are programming for binary or ternary, but the area of cryptography is one case when that knowledge is essential.

### IS-PLUS, IS-ZERO and IS-MINUS

As previously noted, there are 27 possible monadic ternary operators. I will not list all of them, but if I add one more, all imaginable operators can be generated from NEG, ROT-UP and this one. The operator is called IS-PLUS:

$$\mathsf{IS–PLUS} = \begin{bmatrix} - & - & +\end{bmatrix}$$

We can also define IS-ZERO and IS-MINUS:

$$\mathsf{IS–ZERO} = \begin{bmatrix} - & + & -\end{bmatrix}$$
$$\mathsf{IS–MINUS} = \begin{bmatrix} + & - & -\end{bmatrix}$$

The IS-ZERO and IS-MINUS operators can be defined from IS-PLUS and ROT-UP/ROT-DOWN:

$$\mathsf{IS–MINUS}(x) = \mathsf{IS–PLUS}(\mathsf{ROT–DOWN}(x)) \ \big [ = \mathsf{IS–PLUS}(\neg x) \big ]$$
$$\mathsf{IS–ZERO}(x) = \mathsf{IS–PLUS}(\mathsf{ROT–UP}(x))$$

We can demonstrate this using K-maps. Applying one operator (the “second”) after another (the “first”) can be depicted as a single map, where each position is the result of applying the second operation to the corresponding value in the first map.

We start with the ROT-DOWN K-map:

$$\mathsf{ROT–DOWN} = \begin{bmatrix} + & - & 0\end{bmatrix}$$

Applying IS-PLUS to each position of the K-map, `-` and `0` both become `-`, and `+` remains `+`. We can hence denote applying IS-PLUS *after* ROT-DOWN as:

$$\mathsf{ROT–DOWN} \odot \mathsf{IS–PLUS} = \begin{bmatrix} + & - & -\end{bmatrix}$$

And that is the same as IS-MINUS. $\square$

## The Base Dyadic Operators

A binary operator is an operator that has two inputs. To avoid confusion with the “binary” that refers to Boolean algebra and binary computers, I will use the term “dyadic” instead.

Dyadic operators are depicted using 2-dimensional K-maps (one dimension per input variable). The ordering is the same, but of course, now one of the variable selects the row (from top to bottom).

The `AND` operator can be depicted as:

$$\mathsf{AND} = \begin{bmatrix} 
  - & - & - \\\ 
  - & 0 & 0 \\\ 
  - & 0 & + 
\end{bmatrix}$$

And the `OR` operator:

$$\mathsf{OR} = \begin{bmatrix} 
  - & 0 & + \\\ 
  0 & 0 & + \\\ 
  + & + & + 
\end{bmatrix}$$

> [!warning] Note that this is not linear algebra.
> The matrices in this document are not intended for matrix multiplication. Linear algebra formulas won’t help simplify complex ternary expressions. At least not using any of the matrices in this document. These matrices are K-maps and exist for illustration and discombobulation.

### Consensus and Gullibility

There is a total of 19,683 dyadic operators for ternary logic. Comparing this to the mere 16 of Boolean algebra, you can see a problem emerging. Ternary algebra is three orders of magnitude more complex than Boolean. It might not be so easy to develop an intuition about ternary logic. And it is a tall order to define an arbitrary operator from primitives/first principles.

Fortunately, not all operators are all that “useful.” Most of the 19,683 operators are presumably too niche to name generally. Two that do have names are CONS and ANY.

CONS (or “consensus”) outputs 0 unless all inputs agree. If they do agree, the output is the agreed-upon value. The *consensus* value.

The consensus operator has the following K-map:

$$\mathsf{CONS} = \begin{bmatrix} - & 0 & 0 \\\ 0 & 0 & 0 \\\ 0 & 0 & +\end{bmatrix}$$

The softer version of requiring consensus is to gullibly accept any conviction unless there is explicit disagreement. That is the ANY operator:

$$\mathsf{ANY} = \begin{bmatrix} - & - & 0 \\\ - & 0 & + \\\ 0 & + & +\end{bmatrix}$$

The ANY operator (a.k.a. “accept anything” or “gullibility”) could be described as a binary OR-ified CONS. Just as AND and OR are each other’s converse, CONS and ANY have a similar duality relationship.

Douglas W. Jones describes ANY as:

> “Where _consensus_ requires that both inputs agree before it asserts anything but _unknown_, the _accept anything_ operator declares an _unknown_ conclusion only if both inputs are _unknown_ or actively disagree. Otherwise, it jumps to a conclusion from any non-_unknown_ input available to it.”
> —Douglas W. Jones (<https://homepage.cs.uiowa.edu/~dwjones/ternary/logic.shtml#any>)

Can we use De Morgan’s theorem on CONS and ANY? No, unfortunately not. De Morgan says that $\neg (a \times b) = \neg a + \neg b$, and $\neg (a + b) = \neg a \times \neg b$, but applying NOT/neg to inputs or outputs of ANY does not give us CONS, nor vice versa. Instead, the operation retains the original operator, just with the output inverted:

$$\neg(a \boxplus b) = \neg a \boxplus \neg b$$
$$\neg(a \boxtimes b) = \neg a \boxtimes \neg b$$

The fact that they obey similar formulas might be a good enough reason to categorise them as a pair. The duality of their definition (agreed certitude versus gullible certitude) is another.

### SUM ($\oplus$) and SUB ($\ominus$)

There is another interesting pair of dyadic operators. Addition (SUM) returns the mod-3 sum of the inputs, normalised to the \[-1, +1] range.

$$\mathsf{SUM} = \begin{bmatrix} + & - & 0 \\\ - & 0 & + \\\ 0 & + & -\end{bmatrix}$$

Since $2 \equiv -1$ and $-2 \equiv +1$ mod 3 we get `-` + `-` = `+`, and `+` + `+` = `-`.

SUM can be seen as a two-input (dyadic) version of ROT-UP/ROT-DOWN. If one of the inputs is fixed at `+`, the SUM operator becomes a ROT-UP applied to the other input. If one input is locked to `-` it becomes a ROT-DOWN operator. And if one input is locked at `0`, it becomes the identity.

The reverse of rotating up once is to rotate up another two times, or rotating down once. Therefore a SUM of two values can be reversed by either reapplying itself twice with one of the inputs to generate the other—$\mathsf{SUM}(\mathsf{SUM}(\mathsf{SUM}(a, b), b), b) = a$, or by using an operation that rotates down when SUM rotates up and vice versa. That operation is appropriately called SUB for “subtract (mod 3)”: $\mathsf{SUB}(\mathsf{SUM}(a, b), b) = a$.

$$\mathsf{SUB} = \begin{bmatrix}
  0 & - & + \\\
  + & 0 & - \\\
  - & + & 0
\end{bmatrix}$$

SUB (or “subtract (mod 3)” is however asymmetric so we will have to choose an order when rendering the K-map. According to AI, the (overwhelmingly) most common ordering is for the argument on the left to select the row and the one on the right to select the column (i.e. row - column). With that ordering, we get the K-map above, but we could just as well have chosen the transpose:

$$\mathsf{SUB}_\mathbb{T} = \begin{bmatrix}
  0 & + & - \\\
  - & 0 & + \\\
  + & - & 0
\end{bmatrix}$$

>[!note] Formulas for SUM and SUB reflect those for ROT-UP and ROT-DOWN
> - $a \oplus b \oplus b \oplus b = a$
> - $a \ominus b \ominus b \ominus b = a$
> - $a \ominus b = a \oplus b \oplus b$
> - $a \oplus b = a \ominus b \ominus b$

To generate SUB from SUM, we can apply SUM twice. (Because two rotations in the “positive” direction are equivalent to a single “negative” rotation—and vice versa.) We can consider $a \oplus b$, where $a$ is the row and $b$ is the column. This results in the SUM map we recognise from before:

$$\mathsf{SUM} = \begin{bmatrix} + & - & 0 \\\ - & 0 & + \\\ 0 & + & -\end{bmatrix}$$

To generate SUB ($a \ominus b$) from this we should be able to just SUM with $b$ again. If we choose $b$ to identify the column, we will want to add the column index to the value in each position of the SUM map. But the SUM map itself is the source for what the total should be: the value in each position of the SUM map ($a \oplus b$) identifies which row to look in for the second sum ($(a \oplus b) \oplus b$).

So take for example the `+` in the top-left corner. Its value identifies the bottom row. The value in the bottom-left corner is `0`, which is what we should put in the-top left position of the final K-map. The value in the centre-left position is a `-`, which identifies the top row. So the `+` in the top-left of SUM goes in the centre-left position in the resulting K-map. If we do this also for the third position in the column and then repeat the process for the two remaining columns, we’ll end up with the SUB K-map shown above. $\square$

#### Cryptography

SUM can be seen as the XOR of ternary. Boolean XOR combines two values to form a new value in a way that can be reversed.

Computers combine many truth values into registers, and many values that fit into registers into more complex information. By labelling truth as 1 and false as 0, it is possible to construct binary (base 2) numbers, and by giving each letter of the alphabet a number, we can encode text, and by extrapolation: arbitrarily complex information, using Boolean truth-values (or “bits”). The same can be done in ternary logic, but then we use base 3 numbers (and “trits”).

Cryptographers love the XOR function because they can encode a complex secret (a message) using a simpler secret (e.g. a password). If the password has a 1 in a specific position, XOR toggles the bit of the message. If the password bit is 0, the message bit is kept unchanged. Then they can restore the message by applying the same password again: if the password is a 1, the encrypted bit is toggled, and if it is 0, the encryption does not need to be changed to restore the message bit.

Ternary has no exact equivalent to XOR, but SUM and SUB come close. Boolean XOR is its own reverse, because it just toggles bits or leaves them as-is. Ternary cannot toggle, but it can rotate. It will therefore have to choose between three actions: rotate up (if the password trit is a `+`), rotate down (if the password trit is a `-`) or leaving the number as is (if the password trit is a `0`). This is the exact equivalent of SUM. The inverse, however, is not SUM, but SUB (rotate *down* if the password trit is a `+`, and rotate *up* if it is a `-`).

### MUL

Multiplication (MUL) outputs the product of the inputs (where `-` means -1 and `+` means +1):

$$\mathsf{MUL} = \begin{bmatrix} + & 0 & - \\\ 0 & 0 & 0 \\\ - & 0 & +\end{bmatrix}$$

MUL copies one input to the output if the other input is set to +1, it negates the input if the other is set to -1, and it outputs `0` if either input is zero.

> [!note] Formulas
> - $a \otimes + = + \otimes a = a$
> - $a \otimes - = - \otimes a = \neg a$
> - $a \otimes 0 = 0 \otimes a = 0$
> - $a \otimes a = \mathsf{ABS}(a) = \begin{bmatrix} + & 0 &  +\end{bmatrix}$

>[!fail] No DIV
>Note that there is no DIV operator. Dividing by zero is undefined, so the output of the DIV operator would also be undefined for those three cases. And in the cases where DIV *is* defined, it would be have the same output as MUL so it would not add any meaningful distinction anyway.
> $$\mathsf{DIV} = \begin{bmatrix}
>   + & E & - \\\
>   0 & E & 0 \\\
>   - & E & +
> \end{bmatrix}$$

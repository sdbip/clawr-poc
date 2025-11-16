# Boolean algebra

I’m unsure of the historical details, but [George Boole](https://en.wikipedia.org/wiki/George_Boole) is often credited as the father of binary logic. Aristotle is often mentioned as well, but the understanding of logic used in modern computers is called *Boolean Algebra*. And the simplest and most essential of all data types is the `boolean` in virtually all programming languages. (It may be spelled differently—`Boolean`, `bool`, `BOOL`, `Bool` etc—but all spellings hearken to George Boole’s name. In Clawr, the spelling is `boolean`.)

Boole saw logic as binary. A `boolean` value can be either true ($1$) or false ($0$). Some have explored other forms of logic with more possible values. See the section on [[#Ternary Logic]] for more elaboration.

Boolean values aren’t numbers, but there is a kind of arithmetic that applies to them. This is often referred to as *Boolean Algebra*. It consists of two binary operations: AND ($\times$) and OR ($+$), and one unary operation: NOT ($\neg$). The NOT operation negates the value of the operand: $\neg 1 = 0$ and $\neg 0 = 1$.

The expression $a \times b$ (“a AND b“) is true if (and only if) **both operands**, $a$ and $b$ are true, while $a + b$ (“a OR b”) is true as long as **at least one** of the operands is true. This is summarised in the following table:

| $a$ | $b$ | $a \times b$ | $a + b$ |
| --- | --- | ------------ | ------- |
| $0$ | $0$ | $0$          | $0$     |
| $0$ | $1$ | $0$          | $1$     |
| $1$ | $0$ | $0$          | $1$     |
| $1$ | $1$ | $1$          | $1$     |

> [!note] Boolean algebra and arithmetics
> AND can be thought of as multiplication in standard arithmetics (which is why the $\times$ symbol—or `*` in programming—is often used). When using the symbols $1$ and $0$ for true and false, it is a perfect match. Multiplication with $0$ always results in $0$.
>
> OR is similar to *capped* addition (and uses the $+$ symbol). “Capped” here means that with ordinary numbers $1 + 1 = 2$, which cannot be represented by a Boolean value, so it returns the maximum value, $1$, instead.

> [!note] Set-like symbols
> In treatises on mathematics, the symbols $\land$ (for AND) and $\lor$ (for OR) are often used. This is presumably meant to trigger an association with the set symbols $\cup$ (union) and $\cap$ (intersection).
>
> If you have two sets: $A$ with predicate $a$, and $B$ with predicate $b$—that is elements belong to $A$ if they fulfil $a$, and to $B$ if they fulfil $b$—then the union of the sets—all elements in either $a$ OR $b$—are $A \cup B$ with predicate $a \lor b$. And the intersection—elements that belong to both sets—are $A \cap B$ with predicate $a \land b$.
>
>To illustrate, let’s say we have four items. They each have a blue property that can be true (+) or false (–), and a similar red property. Let’s say $a$ is the blue property and $b$ is the red one. Then the blue set is $A$ and the red set is $B$. And we can illustrate the four items in the following image:
>
> ![[and-or.svg|200]]
>
> For the three items in the union set ($A \cup B$) blue OR red ($a \lor b$) is true (+). For the single item in the intersection set ($A \cap B$), blue AND red ($a \land b$) are both true.
>
> The symbols are paired by resemblance. One is pointed and one is rounded, but both are oriented in te same direction. One could even say that AND *means* “intersection,” and OR *means* “union,” but now I might be going to far?

There is a total of 16 different binary operations on binary input values. Most of these are not important. All of them can be constructed from the three basic operators described above.

Some that are often referred to are NAND and NOR (which are simply NOT-versions of AND and OR—`a NAND b = NOT (a AND b)`). The inverted operations are commonly used in circuitry as they paradoxically require fewer transistors than their non-inverted cousins.

Another common Boolean operator is XOR (depicted with $\oplus$ in mathematics). It is true only if the operands are different. It is used extensively in cryptography. Its negated cousin is called XNOR (true if the inputs are equal).

| $a$ | $b$ | $a \times b$ | $a + b$ | `a NAND b` | `a NOR b` | $a \oplus b$ | $a = b$ |
| --- | --- | ------------ | ------- | ---------- | --------- | ------------ | ------- |
| $0$ | $0$ | $0$          | $0$     | 1          | $1$       | $0$          | $1$     |
| $0$ | $1$ | $0$          | $1$     | 1          | $0$       | $1$          | $0$     |
| $1$ | $0$ | $0$          | $1$     | 1          | $0$       | $1$          | $0$     |
| $1$ | $1$ | $1$          | $1$     | $0$        | $0$       | $0$          | $1$     |
> [!note]
> If OR is capped addition, XOR can be seen as mod 2 addition. $1 + 1 = 2 \equiv 0 \ \text{mod} \ 2$

> [!note] Formulas
> - `a NAND b` = `NOT (a AND b)`
> - `a NOR b` = `NOT (a OR b)`
> - `a XOR b` = `(NOT a AND b) OR (a AND NOT b)`
> - `a XNOR b` = `NOT (a XOR b)`
>
> “Negate everything” formulas:
>
> - `NOT (a OR b)` = `NOT a AND NOT b`
> - `NOT (a AND b)` = `NOT a OR NOT b`

## Ternary Logic

Many have considered binary too limited. Even Aristotle considered statements of the future as neither definitively true nor definitively false. Many philosophers and mathematicians have since imagined multi-valued truth. Gödel went so far as to create a system that allows *infinite degrees* of truth between 0 (absolutely false) and 1 (absolutely true).

The most obvious extension to Boolean binary is to add a single extra state, an indeterminate or “unknown” state.

The three states can be defined in many ways and use multiple notations. First, we can imagine a ternary digit. Like a binary digit can have the value $0$ or $1$, which can be used in a positional system (base 2) to form any number; so can a ternary digit do the same in base 3. However, we now have a choice: we can use the numbers $0$, $1$ and $2$ which. feels natural and familiar, or we can use *balanced ternary*.

In balanced ternary, a digit can have a value $-1$, $0$ or $+1$. This is of course not very intuitive, but it is much more efficient for computations. There are several notations for ternary digits: in mathematics and written text, the best notation is maybe `-`, `0`, `+`, for $-1$, $0$ and $+1$ respectively. Munis and plus are of course not very good for programming, though. That is why we need other notations. One that seems to be very popular is to use `0` and `1` as “normal,” but `T`for the “third state” ($-1$). Personally, I’ not convinced that considering $-1$ “the third state” is coherent. Why shouldn’t $0$ be that? Another suggestion is to use `D` (for $-1$ or “down”), `0` and `U` (for $+1$ or “up”).



When working with ternary logic, we have many more possible combin

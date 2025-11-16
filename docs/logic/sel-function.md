# the`SEL` Function

There is a function that can generate every possible binary operator: the `SEL` function. Let’s define `SEL(a, p, q, r)`, such that it returns `p` if `a` is `-`, `q` if `a` is `0` and `r` if `a` is `+`.

If we can form three distinct unary operators `g-(b)`, `g0(b)` and `g+(b)`, each of which returns the output we want from `b` when `a` is `-`, `0` and `+` respectively, we can define any arbitrary binary operator `f(a, b) = SEL(a, g-(b), g0(b), g+(b))`.

## Notation in this Document

Inspired by [Louis Duret-Robert](https://louis-dr.github.io/ternlogic.html), I use the following notation:

A unary operator is described as a 1⨉3 matrix (one row, thee columns). The identity (return the input as is) and not (flip true/false) operators can be written as follows:

> [!example] Identity
> $$\begin{bmatrix} - & 0 & +\end{bmatrix}$$

The first position (left-most column) show the output when the input is false/`-`, then `0` and finally `+`. As the values in each position reflects the position itself, this is the identity operator.

> [!example] NOT (¬)
> $$\begin{bmatrix} + & 0 & -\end{bmatrix}$$

Here the order is reversed, meaning that if the input is `-`, the output should be `+`. And vice-versa.

Unary operators can also be notated in-text .  Such as `identity = [- 0 +]` and  `neg = [+ 0 -]`. %%This provides a nice short-hand. By stating `b = [- 0 +]` (the identity-matrix), I say that b is the input%%

Binary operators (meaning that they have two inputs) are depicted using a 2-dimensional matrix (one dimension per input variable). The ordering is the same, but of course, now one of the variable selects the row (from top to bottom).

The `AND` operator can be depicted as:

> [!example] `AND` / `min` (&&)
>
> $$\begin{bmatrix} 
>   - & - & - \\\ 
>   - & 0 & 0 \\\ 
>   - & 0 & + 
> \end{bmatrix}$$

And the `OR` operator:

> [!example] `OR` / `max` (||)
>
> $$\begin{bmatrix} 
>   - & 0 & + \\\ 
>   0 & 0 & + \\\ 
>   + & + & + 
> \end{bmatrix}$$

> [!warning] Note that this is not linear algebra.
> The matrices in this document are not intended for matrix multiplication. Linear algebra formulas won’t help simplify complex ternary expressions. At least not using any of the matrices in this document. These matrices exist for illustration and discombobulation.

## Interesting Non-Boolean Binary Operators

There are 19,683 definable binary operators with ternary values. Comparing this to the mere 16 of Boolean algebra, you can see a problem emerging. Ternary algebra is three orders of magnitude more complex than Boolean. It might not be so easy to develop an intuition about ternary logic. And it is a tall order to define an arbitrary operator from primitives/first principles.

Fortunately, not all operators are all that “useful.” And also fortunate: we have the `SEL` function that can generate any arbitrary operator. To illustrate, I have chosen to focus on two functions: CONS and ANY.

> [!example] the `CONS` ($\boxtimes$) operator
>
> $$\mathrm{CONS} = \begin{bmatrix} - & 0 & 0 \\\ 0 & 0 & 0 \\\ 0 & 0 & +\end{bmatrix}$$

CONS (or “consensus”) outputs 0 unless all inputs agree. If they do agree, the output is the agreed-upon value.

If we want to define CONS using the SEL function, we will need three unary functions, one for each of the rows in the matrix. Let’s by the way call the input that selects the row $a$, and the input that selects column $b$.

From [Basic Ternary Algebra](ternary-algebra.md), we have `is_plus0(b) = max(b, 0) = [0 0 +]`, `is_minus0(b) = max(¬b, 0) = [+ 0 0]`. The former perfectly matches the $a$ = `+` row, and if we negate the latter, it matches the $a$ = `-` row. [De Morgan’s theorem](https://en.wikipedia.org/wiki/De_Morgan%27s_laws) teaches us that negating everything maintains truth, so `¬max(¬b, 0)` can be simplified to `min(b, 0)`.

> [!done] So we can define CONS:
> $a \boxtimes b \coloneqq \text{SEL} (a, \min(b, 0), 0, \max(b, 0))$.

Or in Clawr syntax:

```clawr
func consensus(a: ternary, b: ternary) => select(a, b && 0, 0, b || 0)
```

> [!example] the `ANY` ($\boxplus$) operator.
>
> $$\mathrm{ANY} = \begin{bmatrix} - & - & 0 \\\ - & 0 & + \\\ 0 & + & +\end{bmatrix}$$

The ANY operator functions could be described as a binary OR where 0 is false and +/- are opposite truths. I.e. if you look at only the top-left or bottom-right corner of the matrix (and you think of non-zero as true), you get the same matrix as Boolean OR.

Or you could also think of it as two steps of truth: In the top-right corner, `-` is false and `0` is “truth,” and you have an AND matrix.

Otherwise ANY is described as 

From [Basic Ternary Algebra](ternary-algebra.md), we have defined `is_plus0(b) = max(b, 0)`, `is_minus0(b) = max(¬b, 0)`. We also have `rotate_up(b)` which adds one to `b` and rolls around to `-` rather than `+2` if `b` = `+`, and its inverse: `rotate_down(b)`.

`b = [- 0 +]`

> [!example] Constructing `g-(b)`
> `g-(b) = [- - 0]`
> `is_plus0(b) = [0 0 +]`
> `rotate_down(is_plus0(b)) = [- - 0] = g-(b)`

> [!example] Constructing `g+(b)`
> `g+(b) = [0 + +]`
> `is_minus0(b) = [+ 0 0]`
> `neg(is_minus0(b)) = [- 0 0]`
> `rotate_up(neg(is_minus0(b))) = [0 + +] = g+(b)`

> [!note] Alternatively:
> `rotate_down(is_minus0(b)) = [0 - -]`
> `neg(rotate_down(is_minus0(b))) = [0 + +] = g+(b)`

> [!tip] So we can define:
> - `g-(b)` = `rotate_down(is_plus0(b))` = `rotate_down(max(b, 0))`,
> - `g0(b)` = `b`, and
> - `g+(b)` = `rotate_up(neg(is_minus0(b)))` = `rotate_up(neg(max(¬b, 0)))` = `rotate_up(min(b, 0))`.

> [!done] Therefore
> $\therefore$ $`a \boxplus b = \text{SEL} (a, \text{roll\_down}(\max(b, 0)), 0, \text{roll\_up}(\min(b, 0)))`$.

Or in programmer-speak (using ternary AND/OR operators):

```kotlin
fun ANY(a, b) = SEL(a, rotate_down(b || 0), 0, rotate_up(b && 0))
```

Using `SEL` with arbitrary unary operators, we can generate any arbitrary binary operator. And I can confidently say that we can generate any arbitrary unary operator from the basic set of `rotate_up`, `is_plus` and the ternary versions of basic Boolean operators AND/MIN, OR/MAX and NOT/NEG (and injecting constants into the binary operators to convert them into unaries).

The question then becomes: can we define `SEL` using basic operators?

## Defining `SEL`

```
SEL(x, a, b, c) = max(
  min(is_minus(x), a),
  min(is_zero(x), b),
  min(is_plus(x), c)
)
```

## Proof

For `x` = `-`:
- `is_minus(x)` = `+` → `min(+, a)` = `a`
- `is_zero(x)` = `-` → `min(-, b)` = `-`
- `is_plus(x)` = `-` → `min(-, c)` = `-`
- `max(a, -, -)` = `a` $\square$

For `x` = `0`:
- `is_minus(x)` = `-` → `min(-, a)` = `-`
- `is_zero(x)` = `+` → `min(+, b)` = `b`
- `is_plus(x)` = `-` → `min(-, c)` = `-`
- `max(-, b, -)` = `b` $\square$

For `x` = `+`:
- `is_minus(x)` = `-` → `min(-, a)` = `-`
- `is_zero(x)` = `-` → `min(-, b)` = `-`
- `is_plus(x)` = `+` → `min(+, c)` = `c`
- `max(-, -, c)` = `c` $\square$

## Summary

The `SEL` function can generate any binary operator. The function itself can be constructed using only the standard AND/OR/NOT operators and one new operator: `is_plus`.

It relies on formulating arbitrary unary operators to select from. These need one more operator: `rotate_up`.

So in conclusion, ternary completeness is achieved by adding two new primitive operations to the three that are already fundamental to Boolean algebra.

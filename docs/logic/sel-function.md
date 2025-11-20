# the`SEL` Function

There is a function that can generate every possible binary operator: the `SEL` function. Let’s define `SEL(a, p, q, r)`, such that it returns `p` if `a` is `-`, `q` if `a` is `0` and `r` if `a` is `+`.

If we can form three distinct unary operators `g-(b)`, `g0(b)` and `g+(b)`, each of which returns the output we want from `b` when `a` is `-`, `0` and `+` respectively, we can define any arbitrary binary operator `f(a, b) = SEL(a, g-(b), g0(b), g+(b))`.

## Interesting Non-Boolean Binary Operators

There are 19,683 definable binary operators with ternary values. Comparing this to the mere 16 of Boolean algebra, you can see a problem emerging. Ternary algebra is three orders of magnitude more complex than Boolean. It might not be so easy to develop an intuition about ternary logic. And it is a tall order to define an arbitrary operator from primitives/first principles.

Fortunately, not all operators are all that “useful.” And also fortunate: we have the `SEL` function that can generate any arbitrary operator. To illustrate, I have chosen to focus on two functions: CONS and ANY.

CONS (or “consensus”) outputs 0 unless all inputs agree. If they do agree, the output is the agreed-upon value.

$$\mathrm{CONS} = \begin{bmatrix} - & 0 & 0 \\\ 0 & 0 & 0 \\\ 0 & 0 & +\end{bmatrix}$$

If we want to define CONS using the SEL function, we will need three unary functions, one for each of the rows in the K-map. Let’s by the way call the input that selects the row in the above K-map $a$, and the input that selects the column $b$.

From [Basic Ternary Algebra](ternary-algebra.md), we have `is_plus0(b) = max(b, 0) = [0 0 +]`, `is_minus0(b) = max(¬b, 0) = [+ 0 0]`. The former perfectly matches the $a$ = `+` row, and if we negate the latter, it matches the $a$ = `-` row. [De Morgan’s theorem](https://en.wikipedia.org/wiki/De_Morgan%27s_laws) teaches us that negating everything maintains truth, so `¬max(¬b, 0)` can be simplified to `min(b, 0)`.

> [!done] So we can define CONS:
> $a \boxtimes b \coloneqq \mathsf{SEL} (a, \min(b, 0), 0, \max(b, 0))$.

If you think figuring out the rows from basic unary operators is hard, you can use the `SEL` function to define them too:

`[- 0 0] = SEL(b, -, 0, 0)`
`[0 0 0] = SEL(b, 0, 0, 0) = 0`
`[0 0 +] = SEL(b, 0, 0, +)`

> [!done] So we can define CONS usint only `SEL`:
> $a \boxtimes b \coloneqq \mathsf{SEL} (a, \mathsf{SEL} (b, -, 0, 0), 0, \mathsf{SEL} (b, 0, 0, +))$.

The ANY operator (a.k.a. “accept anything” or “gullibility”) could be described as a CONS with a reduced need for verification. When either one of the inputs is uncertain, the output will replicate the other input.

$$\mathrm{ANY} = \begin{bmatrix} - & - & 0 \\\ - & 0 & + \\\ 0 & + & +\end{bmatrix}$$

Here’s how we can construct the ANY operator using the `SEL` function:

From [Basic Ternary Algebra](ternary-algebra.md), we have defined `is_plus0(b) = max(b, 0)` and `is_minus0(b) = max(¬b, 0)`. We also have `rotate_up(b)` which adds one to `b` and rolls around to `-` rather than `+2` if `b` = `+`, and its inverse: `rotate_down(b)`.

> [!example] $g_- = \begin{bmatrix} - & - & 0\end{bmatrix}$
> $\mathsf{IsPlus0} = \begin{bmatrix} 0 & 0 & +\end{bmatrix}$
> $\mathsf{IsPlus0} \odot \mathsf{RotDown} = \begin{bmatrix} - & - & 0\end{bmatrix} = g_-$

> [!example] $g_+ = \begin{bmatrix} 0 & + & +\end{bmatrix}$
> $\mathsf{IsMinus0} = \begin{bmatrix} + & 0 & 0\end{bmatrix}$
> $\neg \mathsf{IsMinus0} = \begin{bmatrix} - & 0 & 0\end{bmatrix}$
> $\neg \mathsf{IsMinus0} \odot \mathsf{RotUp} = \begin{bmatrix} 0 & + & +\end{bmatrix} = g_+$

[De Morgan’s theorem](https://en.wikipedia.org/wiki/De_Morgan%27s_laws) teaches us that negating everything maintains truth, so `¬is_minus0(b) = ¬max(¬b, 0)` can be simplified to `min(b, 0)`.

> [!done] Hence, we can define ANY:
> $a \boxplus b = \mathsf{SEL} (a, \mathsf{RotDown}(\max(b, 0)), 0, \mathsf{RotUp}(\min(b, 0)))$.

Using `SEL` with arbitrary monadic operators, we can generate any arbitrary dyadic operator. And I can confidently say that we can generate *any* arbitrary monadic operator from the basic set of `rotate_up`, `is_plus` and the ternary versions of basic Boolean operators AND/MIN, OR/MAX and NOT/NEG (and injecting constants into the dyadic operators to convert them into monads).

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

The `SEL` function can generate any binary operator. The function itself can be constructed using only the standard AND/OR/NOT operators and one new monadic operator: `is_plus`.

It relies on formulating arbitrary monadic operators to select from. These will need one more operator: `rot_up`.

So in conclusion, ternary completeness is achieved by adding two new primitive operations to the three that are already fundamental to Boolean algebra: `is_plus` and `rot_up`.

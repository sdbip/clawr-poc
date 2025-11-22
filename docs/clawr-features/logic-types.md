# Logic in Clawr

![RAWR|150](../images/rawr.png)
Clawr has two logic systems: *Boolean algebra* which is prevalent in most other languages, and *[ternary algebra](../logic/ternary-algebra.md)* which is built to accommodate future three-value hardware.

```clawr
enum boolean { false = 0, true = 1 }
enum ternary {
  down = -1, zero = 0, up = 1
static:
  let false = down
  let true = up
}

let false = boolean.false
let true = boolean.true
```

The value `ternary.true` can be used in `if` statements as a stand-in for `boolean.true`. The other `ternary` values are not true and will not execute the main `if` branch.

```clawr
let t = ternary.true

if (t)
  print("this is happening")
else
  print("this is not happening)
```

The `!` operator can be used on `ternary`.

```clawr
let t = ternary.false

if (!t)
  print("this is happening")
else
  print("this is not happening)
```

Note that `ternary.zero` is neither true nor false.

```clawr
let t = ternary.zero

if (t)
  print("this is not happening)
else if (!t)
  print("this is not happening)
else
  print("this is happening")
```

> [!tip]
> - `!ternary.true == ternary.false`
> - `!ternary.false == ternary.true`
> - `!ternary.zero == ternary.zero`

> [!tip]
> - `boolean(ternary.true) == true`
> - `boolean(ternary.false) == false`
> - `boolean(ternary.zero) == null`
> - `ternary(true) == ternary.true`
> - `ternary(false) == ternary.false`

Ternary logic can also support AND/OR operators. AND will return the smallest of the inputs and OR will return the largest, where `ternary.false < ternary.zero < ternary.true`. This will be consistent with `&&` and `||` for `boolean` and the same operators work.

> [!example]
> - `ternary.true || ternary.false == ternary.true`
> - `ternary.true && ternary.false == ternary.false`
> - `ternary.zero && ternary.true == ternary.zero`
> - etc.

## Fields  (`bitfield`/`tritfield`)

The `bitfield` is a full register worth of truth-values. On “normal” binary architectures these are bits: 1 for true, 0 for false. In ternary mode they are trits: +1 for true, -1 for false; the zero (0) state is unused. If you want access to the full range of ternary truth, you can use a `tritfield` instead, but that will also mean sacrificing compatibility with binary architectures.

The bitwise operators  (`&`, `|`, `^`, `~`) operate on each bit (or trit) independently. On binary architectures this works as you would expect if you have prior experience of bitwise logic. On ternary, the aim is to maintain full compatibility. That is: for true/false values, the operators will work exactly the same. The only differences should be that ternary false is implemented as -1 instead of 0.

With the `tritfield`, you also have access to the zero state, which complicates the basic operators. And it also opens up space for *brand new* operators that do not exist for `bitfield`.

The AND (`&`) and OR (`|`) operators will work exactly as the `boolean`/`ternary` `&&`/`||` operators (except for working on every bit/trit position independently). The same is true for the NOT (`~` vs `!`) operators.

Then we have XOR (`^`). To ensure that this operator works identically for `tritfield` as for `bitfield`, it is implemented as bitwise NMUL—multiplication: `a NMUL b == -(a * b)`.

$$\mathrm{NMUL} = \begin{bmatrix} 
  - & 0 & + \\\ 
  0 & 0 & 0 \\\ 
  + & 0 & - 
\end{bmatrix}$$

But, in ternary mode we will want yet more operators. See [[ternary-algebra]] and the [[sel-function]] for details.

There are two fundamental unary operators for ternary that do not exist for binary: `rotate_up` and `is_true`. To complement these, we also have `rotate_down`, `is_false` and `is_zero`.

Binary logic has four unary “operators,” three of which are nonsense. The useless ones “are set to true,” “set to false” and “keep as is.” Only the NOT operator is meaningful. There is also a total of 16 binary operators, where half are just the negation of the other half, and of the 8 true variations, only 4 are actually useful: AND, OR, XOR and “material implication.”

In ternary logic, we have a total or 27 unary operators and 19,683 binary ones. Cataloguing these is a fool’s errand. But we should have operators for `roll-up`/`-down` and for `SUM`/`NSUM`

$$\mathrm{SUM} = \begin{bmatrix} 
  + & - & 0 \\\ 
  - & 0 & + \\\ 
  0 & + & - 
\end{bmatrix}$$

$$\mathrm{NSUM} = \begin{bmatrix} 
  - & + & 0 \\\ 
  + & 0 & - \\\ 
  0 & - & + 
\end{bmatrix}$$

$$\mathrm{NSUM}(\mathrm{SUM}(a, b), b) = \begin{bmatrix} 
  - & 0 & + \\\ 
  - & 0 & + \\\ 
  - & 0 & + 
\end{bmatrix}$$

$$a = \begin{bmatrix} 
  - & 0 & +
\end{bmatrix}$$
$$\mathrm{SUM}(a, b) = \begin{bmatrix} 
  + & - & 0 \\\ 
  - & 0 & + \\\ 
  0 & + & - 
\end{bmatrix}$$
$$\mathrm{SUB} = \begin{bmatrix} 
  0 & - & + \\\ 
  + & 0 & - \\\ 
  - & + & 0 
\end{bmatrix}$$

$$(a \ \mathrm{SUM} \ b) \ \mathrm{SUB} \ b = \begin{bmatrix} 
  - & - & - \\\ 
  0 & 0 & 0 \\\ 
  + & + & + 
\end{bmatrix} = a$$

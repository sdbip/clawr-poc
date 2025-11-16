# Primitive Types

We will of course need primitive types. Here is the proposed set:

- `integer`: a 64 bit signed integer.
- `bitfield`: a 64 bit register of bits/flags.
- `real`: a 64 bit IEEE 754 double-precision floating-point value
- `boolean`: a value of `true` or `false`
- `ternary` an extended Boolean value with a third state (D,0,U or false, unknown, true)
- `character`: this could be simple as in C or more complex as in Swift
- `string`: a fixed list or sequence of characters
- `regex`: a regular expression/pattern for string matching

## Ternary Mode

In ternary mode, an `integer` is a large register of base-3 digits (a.k.a. trits). 54 trits should be sufficient to provide numbers far outranging 64 bits, but 81 might be more architecture-consistent.

A `bitfield` (or “tritfield” in ternary mode?) is used differently. The number of positions is of higher relevance than the number of values per position, so limiting to 54 trits might be insufficient.

There is a proposed standard called ternary27. It is based on IEEE 754 and might be a good fit for `real` types in ternary mode. It does however only use 27 trits and we would need at least a “double precision” variant (54 trits) to compare to 64 bits IEEE 754. That is not covered by the documentation I found.

The `ternary` type needs only one trit in ternary mode, but two bits in binary.

### Compatibility

All ternary types should behave as their binary equivalents when not explicitly taking advantage of the ternary range.

Numbers are just numbers. Their representation uses balanced ternary instead of binary, and they will have larger capacity in ternary mode, but syntactically there will be no difference.

A `ternary` can replace a `boolean` in `if` statements and `while` loops. The `up` value counts as `true` and the `down` value as `false`. The `else` branch will be executed for two states.

```clawr
if ternaryValue { print("Value is up/true") }
else { print("Value is either false/down or unknown/zero")}

if !ternaryValue { print("Value is down/false") }
else { print("Value is either true/up or unknown/zero")}
```

## Sized Types?

I do not believe we will need different-sized integer or floating-point numbers. This may be relevant when bridging to/from other language domains, but modern processors are 64 bits and there is no point in modelling for smaller registers. (Unless we want to copy Ada and put multiple small integers or booleans in [a single 64-bit structure](./bitstruct.md).)

On the other hand [IEEE-745](https://en.wikipedia.org/wiki/IEEE_754) defines floating-point numbers up to “octuple precision” (256 bits, which translates to 32 bytes or 4 64-bit registers), so maybe multiple-register values can still be called for. (That would imply a need for `integer` types up to the same size as well. And maybe even an arbitrarily large `integer` type too?)

## Integers are not Bit-Vectors

I do believe it would be good to conceptually separate bit-fields from integers. Variables that are used for bitwise operations should probably not be used in arithmetic operations or compared to numbers that are the result of such. A `bitfield` cannot be assigned an integer (decimal) value, but a binary or hex literal does make sense.[^hex-vice-versa] Conversions between types should be allowed though; in this case that would mean a direct copy of the register.

  [^hex-vice-versa]: Vice versa might also apply, but it's not an obvious truth; on the one hand binary and hex are almost exclusively used for specifying bits, never for specifying numbers; on the other hand they are just numeric bases and just as valid as decimal. Maybe we should restrict use at first and later lift that restriction if there are complaints?

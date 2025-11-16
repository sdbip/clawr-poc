# Inspirations from Ada

![RAWR|150](rawr.png)
Ada is named for Ada Lovelace, the assistant to Charles Babbage in the design of the [Analytical Engine](https://en.wikipedia.org/wiki/Analytical_engine).

> She was the first to recognise that the machine had applications beyond pure calculation. Ada Lovelace is often considered to be the first computer programmer.
> —<https://en.wikipedia.org/wiki/Ada_Lovelace>

In Ada, you can specify types as ranges.

```ada
type Score is range 0 .. 1_000_000;
```

This feature is perfect for defining [domain primitives](https://software.sawano.se/2017/09/domain-primitives.html). Domain-driven design (DDD) uses [value objects](https://www.milanjovanovic.tech/blog/value-objects-in-dotnet-ddd-fundamentals) for two main purposes: on the one hand it allows for consistent computations, and on the other is supports fail-fast validation, and security by design. *Domain primitives* is the term for the latter.

In Clawr, domain primitives can be created using a syntax that is inspired by Ada’s ranged types:

```clawr
typealias EntityId = string @matching(/^a-z0-9$/g) @maxlength(256)
typealias Version  = integer @min(0) @max(2_147_483_647) // This fits in 32 bits
```

The compiler automatically injects range checking as necessary so that you do not need to worry about the implementation details. You can focus on modelling your domain.

This syntax is not limited to named types, but can be applied ad hoc on a per-variable basis:

```clawr
var personnummer: string @matches_swedish_personnumber // custom matcher (aspirational)
var age: integer @within(18..100)
var password: string @min_length(16) @matches(/[ !"#$%&'()*+,-./:;<=>?@[\\\]^_`{|}~]/)
```

If that is not enough for your use-case, you can always define types the traditional way:

```clawr
object Prime {

func value() => self.value

factory: func new(value: integer @min(2)) failable {
  guard isPrime(value) or fail NotPrime(value)
  self = { value: value }
}

data: value: integer
}
```

## Packing

Ada also allows packing multiple variables into a single register.

```ada
type Register is record
   Flag   : Boolean;
   Value  : Integer;
end record;

for Register use record
   Flag  at 0 range 0 .. 0;
   Value at 0 range 1 .. 32;
end record;
```

Clawr will perform this packing implicitly so that you as programmer do not need to worry about the details. All you need to do is give permission by using the `@packable` annotation.

If you specify ranges for variables in a `data` structure or the `data:` section of an `object`, the compiler will know how many bits each field needs, and if the total size is small enough, the fields will be packed together.

```clawr
data @packable DeviceStatus {
    isActive   : boolean
    errorCode  : integer @min(0) @max(65_535)
    flags      : bitfield @count(12) @MASK(0xFFF)
    maybeflags : tritfield @count(3) @MASK(0tUUU) // only on ternary archs
}
```

In this example, the entire structure fits in 1 + 16 + 12 bits, and a register is 64 bits, so it can and will be packed accordingly. The `@packable` annotation gives the compiler permission to perform the packing. Permission can also be granted more generally by an optimisation setting.

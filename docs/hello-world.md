# Getting Started with Clawr-lang

![Clawr|150](./rawr.png)

Clawr is a new, intuitive programming language designed to help you solve problems efficiently, whether you're building small scripts, exploring data, or designing complex systems. This introduction will guide you through the **core features** of Clawr, starting with the basics of programming and then escalating to advanced modelling and intentful programming.

Whether you are an absolute beginner or already have experience with programming, Clawr’s design encourages clarity and maintainability from the very start.

## The Basics: "Hello, World!"

Let’s introduce the language in the time-honoured way of saying ”hello” to the world. [^1] In Clawr, that program looks like this:

[^1]: The “Hello World” program is an ancient tradition. It has been used as a first introduction to practically every programming language in history. It is not a tradition we need to end here. https://en.wikipedia.org/wiki/%22Hello%2C_World!%22_program


> [!example] Hello, World from Clawr
> ```clawr
> print("Hello, World!")
> ```

> [!info] How it Works
> This simple line of code demonstrates a *function call*. We call the `print(_:)` function, a function with a single `string` *parameter*. A `string` is simply a sequence of characters to represent continuous text. When `print(_:)` is called, it outputs that text in the terminal where the program is running.

Here, we call the function with a single *argument*, the `string` value `"Hello, World!"`. We say that a function has (or takes or accepts) “parameters,” but when we call the function we say that we pass “arguments” to it. The arguments must match the parameters exactly, or we will see an error message from the compiler.

The compiler (`rwrc`—pronounced “roar cee,” or just “roar” with the c silent) is the tool that parses your code and generates a “binary” that you can then run at any time. You can compile and run the program in a single step by typing the equivalent of `rwrc hello.cwr && ./hello` in your terminal (you can replace “hello” with a filename of your choice). Running the “Hello, World” program would look like this:

```shell
% rwr hello.cwr
Hello, World!
% _
```

> [!success] Congratulations!
> You’ve just written and executed your first Clawr program.

The `rwr` command (pronounced “roar”) compiles and runs a simple Clawr program. You can also use `rwr` as a REPL (Read, Evaluate, Print, Loop). A REPL allows you to input code and it will immediately evaluate and output its resulting value:

```plain
% rwr
Welcome to Clawr REPL
> "Hello, World!"
: "Hello, World!"
> print("Hello, World!")
Hello, World!
: <<expression has no value>>
> _
```

---

### Storing and Reusing Data with Variables

Often, we need to store values for later use. This is where **variables** come in. A variable holds a value, and you can use that value multiple times throughout your program.

The following code is equivalent to the “Hello, World” program:

> [!example] Hello, World with a Variable
> ```clawr
> let greeting: string = "Hello, World!"
> print(greeting)
> ```

> [!info] How it Works
> We haven’t really changed the program at all. What we *have* changed is **how** we pass the  `"Hello, World!"` text to the `print(_:)` function. Before: we passed a *literal* `string` argument to the function; now: we use the *value of the `greeting` variable* for the same purpose.

Since the value of the `greeting` variable is the exact same as the literal, the outcome of running the program will be identical to before:

```plain
% rwrc hello.cwr && ./hello
Hello, World!
% _
```

> [!success] Congratulations!
> You’ve just performed a refactoring.

> [!tip] Refactoring
> When we change the structure or algorithms of our code—without meaningfully affecting it’s outward behaviour—we call that change a “refactoring.” Refactorings should be small, but plentiful, and backed by automated tests. If you are truly committed to writing clear and meaningful code, you should absolutely read [Martin Fowler’s book](https://martinfowler.com/books/refactoring.html). (And you should explore the concept of test-driven development, TDD, as well.)

## Control Flow

But programs are not useful unless they can make decisions and computations. Before we can start making decisions, however, we will need an automated process. This is the `for` loop:

> [!example] `if` statement
> ```clawr
> // This is a list of elements.
> // Lists can be indexed and enumerated.
> let names = [
>   "Alice",
>   "Bob",
>   "Charlie",
>   "Doug"
> ]
>
> print("These are all the names:")
> // The for loop enumerates all items in a list and runs
> // a block of code for each one in turn.
> for name in names {
>   print(name)
> }
> ```

> [!info] How it Works
> The `for` loop *iterates* a collection of values and repeatedly executes a block of code—the “body”—for each value. The braces (`{` and `}`) marks the start and end of the body.
>
> The `names` variable contains an `Array<string>` a.k.a `[string]` value. This is a fixed-length collection where each element has a defined position or *index*. We can access a specific name by *subscripting*. In our example `names[0]` is Alice and `names[3]` is Doug.

Running this program would look like this:

```plain
$ rwrc names.cwr && ./names
These are all the names:
Alice
Bob
Charlie
Doug
$ _
```

### The `if` statement

Now that we have a list of data, we can make choices based on the constitution of each element. The `if` statement evaluates a predicate, and if that predicate is `true`, it executes a block of code. If the predicate is `false`, the block is skipped.

> [!example] `if` statement
> ```clawr
> let names = [
>   "Alice",
>   "Bob",
>   "Charlie",
>   "Doug"
> ]
>
> print("These are the short names:")
> for name in names {
>   if name.length < 5 {
>     print(name)
>   }
> }
>
> print("These are the long names:")
> for name in names {
>   if name.length >= 5 {
>     print(name)
>   }
> }
> ```

> [!info] How it Works
> In this example, the bodies of both `for` loops each contains an `if` statement. Only those names that match the respective conditional expression will cause the body of the `if` statement to be executed.

Running this program would look like this:

```plain
$ rwrc names.cwr && ./names
These are the short names:
Bob
Doug
These are the long names:
Alice
Charlie
$ _
```

This has been pretty easy and straightforward, but what if we need more complex data?

## Introducing `data`: Exposed Data Structures

As you start working with more complex programs, you’ll want to organise data efficiently. In Clawr, we offer two primary ways to structure data: **`data`** and **`object`**.

An `object` is essentially an *encapsulated* `data` structure. You should use it when you gather information from users and/or have important rules about the composition of data that you need to maintain. It is usually recommended to prefer `object` over `data` in business-critical code. It is, however, easier to start with `data` when learning.

You would use `data` to simply stores related values together. This is particularly useful if you have existing data that you need to make computations on. Especially if you have **a lot** of data.

For example, let’s define a `data` structure to represent a **Point** in 2D space:

> [!example] A `data` structure
> ```clawr
> struct Point {
>   x: real
>   y: real
> }
>
> let origin: Point = {x: 0, y: 0}
> let otherPoint: Point = {x: 5, y: -5}
>
> print("Origin: \(origin)")
> print("Other Point: \(otherPoint)")
>
> print(otherPoint.x)
> print(otherPoint.y)
> ```

> [!note] How it Works
> This code defines the `Point` data structure as two associated coordinates (`x` and `y`) on a 2-dimensional plane. The `origin` is defined as the point where `x` and `y` and both zero, and there is an `otherPoint` with different `x` and `y` values.
>
> Passing a `data` structure to `print(_:)` will output its content as JSON.

Running this program would look like this:

```plain
$ rwrc point.cwr && ./point
Origin: {"x":0.0,"y":0.0}
Other Point: {"x":5.0,"y":-5.0}
5.0
-5.0
$ _
```

A `data` structure is just a bunch of aggregate data represented as a single unit. It has no associated behaviours and no encapsulation. You initialise a structure  access the data using *dot notation*: `otherPoint.x`, `otherPoint.y`.

No methods, no behaviour — just data. It’s a perfect starting point when you’re modelling things like **coordinates**, **data transfer objects (DTOs)**, or simple containers.

## Moving to Objects: Data and Behaviour

Once you are comfortable with **simple data structures**, you may want to start organising your programs in a way that models both **data** and **behaviour**. This is where **`object`** types come into play. Objects can hold **state** (data) and **behavior** (methods).

Let’s take a look at how an **object** works in Clawr:

```Clawr
object Rectangle {
  let width: real
  let height: real

  init(w: real, h: real) {
    self.width = w
    self.height = h
  }

  area() -> real {
    return self.width * self.height
  }

mutating:

  scale(by factor: real) {
    self.width *= scale
    self.height *= scale
  }
}

let rect = Rectangle(5, 10)
print("Area:", rect.area())  // 50
rect.scale(by: 7)
print("New Area:", rect.area())  // 350
```

## Encapsulation: Protecting Your Data

The primary difference between `struct` and `object` is **encapsulation**.

In an **object**, the **internal state** (like `width` and `height` in the `Rectangle` example) is **protected**. You cannot directly change the state; instead, you must interact with it through **public methods** (`scale(by:)`, and `area()` in this case). This keeps your code more **modular**, **flexible**, and easier to maintain.

Encapsulation is a powerful concept in programming because it helps to:

- **Hide implementation details**: The user of the object doesn’t need to know how the area is calculated, just how to call the `area()` method.
- **Control access to data**: By providing controlled methods like `scale(by:)`, you can ensure that only valid changes are made to the object's state.
- **Avoid unintended side effects**: Direct access to the object's internal data can lead to unexpected changes that can break your program. Encapsulation prevents this.

> [!warning] DO NOT
> It is not recommended to add “getters” and “setters” to expose the internal state (except as a step in a larger refactoring that will eventually remove them again). Direct accessors to the structure invalidates any protection that encapsulation offers. Manipulating the state through a setter is conceptually no different from addressing the internal structure directly.

---

## When to Use `struct` vs `object`

Prefer an `object` when:

- You need to model mutable state (e.g. when modelling an entity in DDD).
- There are structurally possible states that are considered invalid and should be disallowed.
- The object has meaning that is independent of its structural composition.
- You have business rules and/or policies that dictate how data may be changed.
- You need polymorphism and/or inheritance.

Prefer a `struct`in these situations:

- Communication protocols (DTO/DAO)
- Computations on large-scale data-sets
- Whenever immutable (read-only) data is enough

### Prefer `object`

The `object` keyword creates *encapsulation*. Encapsulation has three purposes: it protects the state (the data) from incorrect manipulation, it protects referring code from having to change when the internal structure changes, and it ensures that all instances of a given type are valid at construction. This makes the `object` keyword preferable in most scenarios.

An `EmailAddress` is a `string` with additional limitations; it must for example contain a single '@' character and at least one dot. A Swedish social security number (“personnummer”) has a check-digit that ensures that the other digits have been entered correctly. Modelling types like these requires validation, and an `object` type can ensure that this validation must pass for the structure to even *exist in memory*.

A `Money` type has a different reason for choosing `object`. Money has meaning that is independent of its structure: $1.50 is the exact same value as ¢150, and the same as “$1 and ¢50.” Money can be modelled as a single integer `cents` value, as a single real value (dollars.cents), or even as two separate integer values.

When you are building a user-operated data-entry application, you should use `object` a lot. But there are scenarios where `object` is not a good fit; it’s just awkward to use. This is where `struct` would be a better choice.

### But `struct` has its uses

The `struct` keyword is preferred when the *specific structure* of the data is well known, unchanging and *essential*. Examples of this include DTOs and DAOs in communications protocols.

When you use `struct`, you should prefer immutable (`let`) variables. When data needs to change, there are typically rules and validations that need to be applied. The `struct`cannot ensure validity.

Instead `struct` should be used in situations where the data is already known and can be presumed already valid. When communicating between subsystems, or analysing big data, that is a reasonable assumption. The data has already been accepted into the system and was probably validated at that point.

---

## The Path Ahead: Advanced Concepts

Clawr provides more advanced features for experienced programmers, like **polymorphism**, **inheritance**, and **concurrency**, but don’t worry — you don’t need to learn all of these right away. You’ll be able to explore these as you become more comfortable with the basics.

At this point, focus on:

1. **Understanding the difference between data structures (`struct`) and objects**.
2. **Using encapsulation to design clean, modular programs**.
3. Experimenting with **objects** to model real-world entities and behaviors.

---

## Conclusion

Clawr is designed to help you write clean, maintainable code from day one. Start by learning how to store and manipulate simple data, then gradually introduce more powerful concepts like **objects** and **encapsulation** to structure your programs.

As you continue learning, you’ll see how Clawr’s syntax and features can help you solve problems in a more structured way — making your code easier to understand, modify, and scale.

Let’s get roaring!

---

## Want to Learn More About `struct` and `object`?

If you're curious about the differences between **`struct`** and **`object`**, check out the [advanced guide](./object-v-struct.md) here.

If you're curious about more advanced concepts in Clawr, you can check out the following links:

- [Reference semantics](./reference-semantics.md) - how Clawr makes it explicit and how it relates to the more approachable variables seen here
- [`bitstruct`](../bitstruct.md) - a compact version of `struct` that is usable for constrained memory requirements


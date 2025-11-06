# Getting Started with Rwr-lang

![Clawr|200](./lion-head.svg)

> [!fail] TODO: This icon should be replaced!
> A roaring (or “rawring”) lion is the desired image. It needs to be simple enough that it works down to 16×16 (or there should be a recognisable version that does). File icons are that small. Maybe a paw (with extended claws) could effect such an association? Or a feature of the particular lion (such as a scarred, missing or discoloured eye)?

All languages start with the infamous “Hello, World!” example. In Clawr that is a simple command:

> [!example] Hello, World Example
>
> ```clawr
> print "Hello, World!"
> ```

> [!info]
> The `print` command outputs text to the console. Strings are written inside (plain) quotation marks. Execution starts from the first line of code.

Write the above code in a file named hello.cwr. Then run `rwr hello.cwr && ./hello` in your shell (like the Terminal app on a Mac).

```plain
> rwr hello.cwr && ./hello
Hello, World!
> _
```

> [!success] Congratulations!
> You have written and executed your first Clawr program.

Outputting *“Hello, World!”* on the console is not a very interesting program. Some other things a computer can do is accept input, make decisions and make calculations. With advanced frameworks, it can also store data in a database, serve HTML pages on the Internet, display graphical user interfaces and more.

Tasks like that will be introduced in later chapters. For now, let’s focus on the language and its paradigms.

To be able to make decisions and calculations, you will need to use *variables*. A variable is like a container for data. That data can be anything from a simple counter to a huge data structure with hundreds of elements. Complex structures are created by aggregating simpler structures. So let’s start with the simplest of them all: the `boolean` data type.

## The `boolean` data type

A `boolean` variable can be either `true` or `false`. It represents the essence of human logic. # [George Boole](https://en.wikipedia.org/wiki/George_Boole) introduced the idea of binary logic. In his mind, a claim is either *true* or *false*. Some require more than this, but this is how all mainstream computers work today. The computer uses `boolean` values to make decisions.

```clawr
let isPreconditionMet = true

if isPreconditionMet {
  print "Let’s go! 🚀"
} else {
  print "Unable to comply. 🤦"
}
```

The symbols `{` and `}` in the snippet above are often referred to as “braces.” They demarcate the code that should be executed if the associated condition is met. If the condition is not met, the entire block of code is skipped. In this form (`if`/`else`) exactly one of the blocks is always executed. The predicate (`isPreconditionMet`) determines which.

## Boolean algebra

`boolean` values aren’t numbers, but there is a kind of arithmetic that applies to them. This is often referred to as [[boolean-algebra]]. Clawr has two binary operators: AND (`&&`) and OR (`||`), and one unary operator: NOT (`!`). (We can also test for equality which effectively adds another two binary operators: `==` and `!=`, for a total of four.)

```clawr
let a = true // Experiment with different combinations of true/false here
let b = false

if a && b {
  print "Both operands are true (AND)"
}

if a == b {
  print "The operands are either both true or both false (XNOR)"
}

if a != b {
  print "Exactly one of the operands is true (XOR)"
}

if !a || b {
  print "Some would say that a implies b, but this is actually *not* sufficient information to prove such a claim."
}
```

There are several different ways that a computer makes decisions. The `if`/ `else` construct shown above is maybe the simplest. But there is also `else if` to make multiple alternative choices.

And there is also `switch`/`case`. The `if` statement is more versatile than `switch`, but `switch` is usually recommended as it tends to make the intent clearer.

> [!note]
> Code is a tool for communicating intent. When you write code in a team, you are not only telling the computer what to do; you are telling the other programmers what you *intend* for the computer to do.
>
> And even if you’re not in a team, your code might survive for some time and a team might grow around it. Or your future self might need to make edits and wonder: “what is this mess supposed to do?”

To explain `switch`, we need to introduce a more complex data type than `boolean`. The `integer` and `real` data types handle simple numbers. As their names imply, an `integer` variable can only contain integers (natural numbers and their negatives), while a `real` variable can handle the entire number-line.

> [!warning] Practical Limitations
>
> I say “the entire number-line,” but there are practical limitations. The hardware is only able to contain a certain number of digits, which limits the size and precision of numbers that can be handled. It is unlikely that those limitations will affect you though. And if they do, you are probably already aware beyond what this tutorial is able to convey.

With `switch`, we can clearly denote decisions made based on a single variable:

```clawr
let age: integer = 32 // Insert someone's age here
switch age {
case < 13: print "Kiddo"
case < 18: print "Teenager"
case < 30: print "Young adult"
default: print "Mature"
}
```

The equivalent using `if` would read as follows:

```clawr
let age: integer = 32 // Insert someone's age here
if age < 13 {
  print "Kiddo"
} else if age < 18 {
  print "Teenager"
} else if ago < 30 {
  print "Young adult"
} else {
  print "Mature"
}
```

As you can see, the `switch` statement is clearer. It only mentions the `age` variable once, but compares it implicitly to all the cases in turn. The `if` has to repeat the variable name for each comparison. If you paid attention you might have noticed a bug in the code. It is caused by the a failure in the necessary repetition.

Clawr is not like other languages. It focuses on modelling and intent instead of the technical ins and outs of a processor, registers and memory. One of the ways Clawr is different is how it thinks of types and variables.

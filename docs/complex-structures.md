# Complex structures in Clawr

![Clawr|150](./rawr.png)

Clawr is not like other languages. It focuses on modelling and intent rather than the technical ins and outs of a processor, registers and memory handling. One of the ways Clawr is different is how it thinks of types and variables.

Clawr has two kinds of complex types: `object` and `data`. The `data` structure type is just more of what we have already seen, multiple smaller datatypes aggregated into a larger structure. The `object` type is an *encapsulated* `data` structure, a data structure hidden behind a conceptually, meaningful interface.

Let’s focus on the `data` structure first. You use `data` structures when you want to perform **computations** on complex or plentiful *data*.

```clawr
data Purchase {
  item: string
  cost: real
}

func totalCost(of purchases: [Purchase]) -> real {
  mut runningTotal = 0.0
  for p in purchases {
    runningTotal += p.cost
  }
  return runningTotal
}

func averageCost(of purchases: [Purchase]) -> real {
  mut runningTotal = 0.0
  mut count = 0
  for p in purchases {
    runningTotal += p.cost
    count += 1
  }
  return runningTotal / count
}

let purchases: [Purchase] = [
 { item: "bread", cost: 2.50 },
 { item: "butter", cost: 10.0 },
 { item: "cream", cost: 9.45 },
 { item: "milk", cost: 2.20 },
]

print(totalCost(of: purchases))
print(averageCost(of: purchases))
```

> [!info] How it Works
> Here we see the `data` structure in action. A `Purchase` is an aggregate of a `string` naming the item purchased, and a `real` value that specifies what that item has cost.
> 
> At the end of the code we see the syntax of the `data` initialiser. We list the named values (“fields”) separated by comma, and wrapped by braces.
>
> There is a lot happening here. First of all, we have defined out own *functions*. Much like the `print` function from earlier, every function is a named procedure that might define parameters—inputs that affect its execution in some way.
> 
> These functions are outwardly similar. They both have a single parameter, which is an `Array` (a kind of list) of `Purchase` elements. They both define a `real` *return value*. How they compute the result is different though. One sums all the values together and returns that sum. The other also counts the number of items and calculates the average but dividing the total with the count.
>
> The `for in` syntax is similar to the `while` loop we saw in the previous chapter. `for in` goes through the elements of a collection and performs the block once for each element. The `p` variable in this example holds a reference to that element.

## The `object` Datatype

The `object` keyword is meant to foster a different way of thinking. While a `data` structure is defined by the *structural composition* of its elements, an `object` is defined by the *interactions* you make with it. This is reflected in the `object` syntax. Methods are defined first, and the underlying data-structure is defined in a `data:` section below them. The hope is that this will encourage an outside-in design process.

The `object` type is essentially a `data` structure hidden behind an interface. The interface exists to provide clarity and meaning to the data structure. It is Clawr’s main tool for *encapsulation*. Encapsulation has two benefits, it protects the object itself from incorrect tampering, and it protects code that interacts with it from structural changes in its design.

Let’s use the concept of `Money` to illustrate. An amount like $1.50 can be represented in many different ways. We can for example use the `real` value `1.5` (dollars) or the `integer` `150` (cents). Both mean the same thing, but the choice of representation can have technical implications. If we can interact with `Money` without knowing how it is constituted, we can keep that interacting code around unchanged for a long time, even as the internals of the type change (perhaps drastically).

```clawr
object Money {

  func dollars() -> integer => self.cents / 100
  func cents() -> integer => self.cents % 100

factory:
  func for(amount: real) => { cents: integer(real * 100) }
  func for(cents: integer) => { cents: cents }
  func for(dollars: integer, cents: integer) => { cents: dollars * 100 + cents }

data:
  cents: integer
}
```

> [!note] Object Instantiation
> The `factory:` section defines how new `Money` objects are created. You can create a money `object` representing $1.50 in three different ways: `Money.for(amount: 1.5)`, `Money.for(cents: 150)` or `Money.for(dollars: 1, cents: 50)`. All three expressions represent the same amount, and they all result in the same `Money` object.

The `cents: integer` field defines how the value is actually stored in memory. It is irrelevant when interacting with the object, but is is essential to its implementation. All methods defined by the `Money` type will be able to interact directly with the underlying `data`, but all other code has to interact through the exposed methods. They will have no idea that the value is stored as a single `integer` and not a `real`, or two as values separating cents from dollars.

If you have done any object-oriented programming before, you have probably been told to write getters and setters to avoid “exposing your privates.” Getters and setters are not a good design. They are essentially a workaround to pretend that you are “doing encapsulation” when you really don’t. Proper encapsulation happens when you design your objects from the outside in. When you do not design the data first, but the interface. When you start with the *meaning* of the object, and how that is perceived by other code, not its implementation.

## Mutable and Immutable Objects

The `Money` object defined in the previous section has no good way to perform computations. You cannot change an existing `Money` object and it does not define how to make computations. You can only create new `Money` values from values that you compute in an external context.

One thing we can do is add an operator. Operators are a special kind of functions. They are `static`, meaning that they do not apply to an instance, but only to whatever parameters it defines. Here is how we can add support for the `+` operator:

```clawr
object Money {
  // The same implementation as before...

static:
  operator a: Money + b: Money -> Money => Money.for(cents: a.cents + b.cents)
}
```

Now we can add moneys together:

```clawr
let x = Money.for(cents: 100)    // $1.00
let y = x + Money.for(cents: 50) // $1.50
```

We can also make objects mutable. That is not recommended for the `Money` type, so let’s imagine a different concept.

```clawr
data Address {
  street: string
  city: string
  state: string
  country: string
}

object Customer {

  func address() => self.address

mutating:
  func move(to address: Address) {
    self.address = address
  }

data:
  name: string
  address: Address
}
```

Methods that change the underlying `data` of an `object` must be defined in the `mutating:` section. Clawr employs a strategy called copy-on-write. When you assign a variable to another—either directly (`x = y`) or by passing it as an argument to a function or by returning it from a function, the two variables should (usually) be isolated from each other, so a copy has to be made before any modification can be allowed. In older implementations, this copy was done instantly at the time of assigning the value, but that uses up memory that might not have been necessary. Modern languages (with copy-on-write) avoid making the copy until the first modification (“write”). As long as the patch of memory remains unchanged, both variables can share it indefinitely.

## Reference Semantics

A `let` variable is guaranteed to never change. A `mut` variable is isolated from other variables, but a `ref`variable is dangerous. The keyword is short for “reference,” and it implies that there may be other variables (perhaps in far off code) that all *reference* and can modify the same data independently of each other, but still affecting what the others see.

Shared Mutable State is (rightly) discouraged. Many bugs stem from shared resources that are mutated incorrectly. It is very hard to reason about state that can be modified from various parts of the code. There is also a concern about parallel execution (threads) making changes to the same value at the same time. This creates need for locking or other management tools. Locking can lead to deadlock, which stops the program from working at all. Shared Mutable State can cause many categories of bugs. 

And yet, it is sometimes necessary.

One example is the `Entity`. In domain-driven design (DDD), the main concept is to define entities to model identifiable objects or persons in the real world. A `Customer` is an entity. So might a `Vehicle` be if you are e.g. tracking the locations and routes of individual vehicles. When referring to an `Entity`, you should perhaps not consider multiple instances as the same. Instead, you maintain a single instance per entity. In this case a `ref` variable is what makes the most sense.

DDD also uses *Value Objects* to model its domain. Value objects should not employ reference semantics, but isolation. *Proper* DDD would even say that value objects should be entirely immutable.

```clawr
ref customer: Customer = try loadCustomer(id: "aabb")

func performTask(ref customer: Customer) {
  customer.changeSomething()
}
```

The `ref` keyword would not be of much interest in the above example. To illustrate the difference between `mut` and `ref` we will need two variables:

```clawr
mut x: Purchase = { item: "Eggs", cost: 2 }
mut y = x
y.cost = 2.5
print("x: \(x.cost), y: \(y.cost)")
```

Running this will yield the output:

```plain
> rwr mut.cwr && ./mut
x: 2.0, y: 2.5
> _
```

If instead, we use the `ref` keyword:

```clawr
ref x: Purchase = { item: "Eggs", cost: 2 }
ref y = x
y.cost = 2.5
print("x: \(x.cost), y: \(y.cost)")
```

…we will see the output:

```plain
> rwr mut.cwr && ./mut
x: 2.5, y: 2.5
> _
```

Altering `y` also changed `x` in this case. In the previous example, the variables were *isolated* from each other, but now they are connected. What is the difference?

The difference between `ref` and `mut` is *reference semantics* versus *variable isolation*. Reference semantics is usually not recommended as it causes *Shared Mutable State*. This wreaks havoc on local reasoning and leads to complications with multithreaded systems (running code in parallel). It is, however necessary in some cases.

The recommendation is to start with `let` variables and only change to `mut` if mutation is needed for your algorithm, but try to keep the scope of mutability small. Avoid `ref` **entirely** unless absolutely necessary. This is especially true when working with exposed data structures as in the above examples. You should probably *never* use `ref` and `data` together actually. It can be reasonable to use `ref` with `object` variables though.

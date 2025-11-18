# Semantics of Variables in Clawr

Variables in programming can operate under different semantics, primarily based on two factors:

- **Immutability vs. Mutability**
- **Local Scope vs. Shared Scope**

Many languages define a `class` object as an entity in memory with multiple variables *referencing* it. This practice has been dubbed “reference semantics” by the field. With reference semantics, the scope of your data is shared between variables. The code that determines the value of any datum can be distributed all over your code base.

The *Functional Programming* paradigm solves the problem of shared mutable state by removing *mutability*. They make every single variable *immutable*—essentially a constant. This might or might not be delusional as any meaningful program will need to affect the world and update the state of the system itself. The principle of *limiting the scope* of mutation is however a good one whatever you might think of the paradigm.

Many [^many?] modern languages use `struct` as an alternative to the `class` structure. A `struct` type has what has come to be called “value semantics.” In C#, for example, a `class` variable is essentially a pointer to an address in memory, while a `struct` is a box that contains all the data. When a `class` variable is assigned the value of another, the pointer is all that is copied, but for `struct` the entire data structure is copied from one box to another. 

[^many?]: From my own experience I can mention C# and Swift, but there are probably others.

Clawr uses a different paradigm.

## Per-Variable Semantics Selection

What if we could make mixing reference and local-scope structures, as well as that of mutability and immutability, impossible? What if we could communicate **guaranteed immutability** or a **guaranteed local scope** simply by reading a variable declaration? What would that do for cognitive pressure? Probably a great deal, am I right!

This is Clawr’s granular approach. There are no reference semantics **types** in Clawr. Instead, the semantic mode is determined by each variable itself. You don't need to check the definition of the type as the keyword of the variable declaration immediately conveys its semantic mode:

- **`let`**: Guarantees immutability. This variable will never change in its lifetime barring a physical event that compromises the hardware. The only way to “change” this variable is to take it out of scope, destroying its data. It doesn't matter much semantically whether its data is shared or not; if it cannot be changed it cannot cause any surprises.
- **`mut`**: Indicates that the data/value referenced by the variable can change, but only by naming it directly. No other variable, near or far, can modify the data.
- **`ref`**: Signals that the variable's data is shared. There might be other variables, in code that isn't obviously related, that reference the same block of memory. These external sources might mutate the variable in confusing and surprising ways. Locking and other mechanisms might be needed to ensure consistency.

These keywords establish the mode of each variable, making it clear whether the state can change and whether it’s local or shared. Avoiding the confusion and technical complexity of shared mutable state is as easy as never declaring a `ref` variable.

So, if types do not determine whether value- or reference semantics applies, how should they work instead? Can types imply semantics in some way?

Yes. Clawr uses `object` for encapsulated state, and `data` to imply “naked” data structures.

## Objects vs. Data Structures

In Domain-Driven Design (DDD), the term "anaemic" (derived from the medical condition of low red blood cell count) is used to highlight the problems of exposing data directly to manipulation. An anaemic model requires validation before it can be persisted, as the volume of code that modifies it cannot be fully trusted to be free of bugs. Without encapsulation, there is a risk that the data will become inconsistent or that business logic will be scattered and hard to maintain, leading to fragile systems.

A "rich model," in contrast, uses encapsulation to ensure that its state remains valid. By embedding the business rules within the model itself, the need for external validation is removed, and the model can evolve without breaking its internal logic. This approach also clarifies the application's intent and the goals of its users, as the rules are encapsulated in a more intuitive and predictable manner.

Encapsulation offers another advantage: loose coupling. Loose coupling reduces dependencies between components, allowing changes in one part of the system to have minimal impact on other parts. By hiding the internal state of an object and exposing only the methods that interact with it, you not only protect its state from direct manipulation, reducing the risk of shared mutable state. You also improve flexibility in terms of implementation details.

Robert C. Martin (Uncle Bob) succinctly captures the distinction between objects and data structures:

> - An Object is a set of functions that operate upon implied data elements.
> - A Data Structure is a set of data elements operated upon by implied functions.
>
> — <https://blog.cleancoder.com/uncle-bob/2019/06/16/ObjectsAndDataStructures.html>

The key takeaway here is that an object’s state is hidden away (“implied”), instead only exposing “functions” for interaction. The data structure, conversely, exposes data-elements, “implying” that they have some use, but says nothing about what that usage amounts to.

### In Clawr

Clawr borrows Uncle Bob’s terminology in the keywords `object` and `data`. A `data` type defines structure for direct interaction with data elements.

```clawr
data GeoCoordinate { latitude: real, longitude: real }
data Velocity { heading: real, speed: real }
data LogInfo {
  position: GeoCoordinate
  velocity: Velocity
}

let routeData: [LogInfo] = [
  {
    position: {latitude: 10.1, longitude: 12.2},
    velocity: {heading: 120.0, speed: 98.5}
  }, ...
]
```

An `object` is a *meaningful* entity that hides a `data` structure in its bowels. The `object` exposes interaction points (methods) that hide the specific implementation from dependent code. A `factory` method (and any other method) on the `object` has full access to the hidden `data`.

```clawr
object Money {

    func dollars() => self.cents / 100
    func cents() => self.cents % 100

static:
    let zero: Money = { cents: 0 }

factory:
    func cents(_ c: integer) => { cents: c }
    func dollars(_ d: integer, cents: integer = 0) => {
        cents: d * 100 + cents
    }
    func amount(_ a: real) => {
	    cents: integer(Math.round(a * 100)
	}

data:
    let cents: integer
}
```

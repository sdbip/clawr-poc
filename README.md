# Clawr Compiler

![Rawr!|100](./docs/images/rawr.png)
RAWR

Clawr is a language with goals of clarity, a modelling focus and easy refactoring. The name is a portmanteau of the word ”clarity,” and a lion’s roar. For more information, see the [documentation](./docs/clawr-features/primitive-types.md) [tutorial](./docs/tutorial/introduction.md).

## Compilation Steps

There is a stereotypical design pattern for compilers. Being inexperienced in compiler architecture and design, I have no means of diverting from the dogma. This design is based on the usual pipeline:

1. **Lexer**: Tokenises the source code and tags each token with location and kind.
2. **Parser**: Parses the tokens to generate an *Abstract Syntax Tree* (AST). This module also includes resolver logic (type inference and compatibility checking).
3. **IR-gen**: The AST is processed into an *Intermediate Representation* (IR) that mirrors the structure of the C code that is the output of this compiler.
4. **Codegen**: Te IR is converted to C code which can be fed to a C compiler to generate the binaries that are the actual program.
5. **Final Compilation and Linking**: The C code is fed to the `clang` compiler which generates binaries that can actually be executed by the OS and hardware.

In the future, the codegen output should probably not be C. Maybe the IR too needs to be revised. In its current form it is essentially an AST for C code. The compiler should be capable of generating binaries for various architectures. Maybe even (balanced) ternary machine code!

## CLang

The *codegen* step of this compiler outputs C code which is then fed to a mainstream C compiler for final binary generation.

I have elected to use the `clang` compiler. This is mainly because I use a Mac, and `clang` is very Mac friendly. For greater portability, `gcc` or `cc` might be preferred. (Though such change might not be performed for some time, as `clang` is quite sufficient for now and I have not yet studied the prevalence nor compatibility of alternative compilers.)

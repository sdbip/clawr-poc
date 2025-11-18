# Aspirations and Ideas

![RAWR|150](rawr.png)
The documents in this folder should be seen as aspirational. The features are not yet implemented, but ideas for what the language should be and how it should work

Hopefully all, but certainly some, of these ideas will be feasible and should be implemented in some form. But do not expect everything in here to be realised in the compiler tomorrow. Many of these ideas probably need further refinement with regards to both syntax and semantics. And perhaps even their conceptual metaphors.

> [!quote]
> The psychological profiling \[of a programmer] is mostly the ability to shift levels of abstraction, from low level to high level. To see something in the small and to see something in the large.
> — Donald Knuth

The aim of Clawr is to encourage domain-driven design and outside-in modelling. Instead of being distracted by technical details like memory layout, ownership and threads-and-actors, programmers should invest their focus on the rules and logic of their business domain, and on the language and structures they need to clearly and precisely model and communicate that realm.

Clawr should facilitate such focus, while still providing high runtime performance with effective optimisation.

> [!quote]
> Programming is the art of telling another human being what one wants the computer to do.
> — Donald Knuth

A language is not a technical tool. It is a tool for communication. The language is the words that we use, and the sentences that they form, for communicating ideas, desires and instructions. A programming language defines a syntax for how to formulate such sentences. It is up to the programmer to define and clarify the concepts that they want to communicate.

Clawr, though its focus on modelling, can be better than other languages at encouraging and facilitating such communication.

## Technical Implementations — *Help Wanted*

For Clawr to be useful in “real applications,” however, it will also need APIs, tools and drivers to communicate with databases, the Internet and other technology. That is not language-specific, but still essential. I will need help building such things. It will not happen as long as it is just me working on the project.

I worry that the project will fail because it is not technically sophisticated enough. Maybe these things can be implemented (initially at least) by interacting with existing C APIs? Since the codegen step (currently) builds to C, that could perhaps be easier to achieve than I fear.

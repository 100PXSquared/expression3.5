# Expression 3.5 (E3.5)

Expression 3.5 is a work in progress rewrite and improved version of [Expression 3](https://github.com/Rusketh/ExpAdv3), which brings all the improvements E3 made over [E2](https://github.com/wiremod/wire/wiki/Expression-2) while removing the problems E3 is plagued by.  

## Expression 3's improvements over Expression 2
These are just some of the improvemnts E3 made over E2:  
* Classes
* Interfaces
* Libraries
* Lambdas (aka anonymous functions)
* Delegates
* Ability to use `@input` and `@output` directives at any point in code
* Can run code on either server or client, or on both (like with [Starfall](https://github.com/thegrb93/StarfallEx))
* Ability to use hooks through the `event` library, so no more checking `if (first())` every loop.
* `||` and `&&` are now logical operators and `|` and `&` are bitwise (E2 has them backwards for some reason)
* `#` operator from Lua which allows you to get the length of a string/table
* C style casting (`(class to cast to) expression`)
* Editor code folding

## Expression 3.5's improvements over Expression 3
* Text editor overhaul (with functional find and replace that only unfolds code that a match is in)
* Reduced the number of unnecessary datatype aliases, including some out right incorrect ones (e.g. `int thisIsNotAnInt = 1.5842385` was valid)
* Security improvements (for example in E3 you could inject Lua in strings, see [commit](https://github.com/100PXSquared/ExpAdv3/commit/1ad7d351d8af5d99f82bd7ce15c3a30ac1a0b229))
* Solid definition of a line with `;` (this is a problem with E2 that E3 had inherited, where code like `string someString = "" num someNumber = 5` was perfectly valid, despite no newline or separator character, you now have to use semicolons as EoL)
* Improvements to both holograms and props spawned with E3.5 chips, props now have physics and scale can be passed to hologram constructors in order to scale them instantly

## Installation
Note, this is still very much a work in progress and has not yet fixed everything about E3. You can download it and use it in singleplayer without too many issues, but do not use it in a public multiplayer context as we have not finished making the necessary security improvements.  

## Documentation
As of now no documentation is available beyond what E3 provides on their repo and what's in the E3 helper (which needs to be reworked (possibly rewritten) still as nothing has descriptions and everything shows as working on both server and client)

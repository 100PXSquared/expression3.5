# Expression 3

Expression 3 (or E3) is a work in progess spiritual successor to Expression 2 (or E2).  
E3's syntax more closely represents real world high level programming languages than E2's, the closest match being [TypeScript](https://www.typescriptlang.org/).  

## Improvements over E2
* Classes
* Interfaces
* Ability to use `@input` and `@output` directives at any point in code
* Can run code on either server or client, or on both (like with Starfall)
* Ability to use hooks through the `event` library, so no more checking `if (first())` every loop.
* Delegates
* `||` and `&&` are now logical operators and `|` and `&` are bitwise (E2 has them backwards for some reason)
* `#` operator from Lua which allows you to get the length of a string/table
* C style casting (`(class to cast to) expression`)
* Libraries
* Lambdas (aka anonymous functions)

## Installation

If you want to try my changes out now, you can download the repo as a `.zip` and just extract and move the folder into your GMod's addon directory (make sure you don't have the main version of E3 installed before trying to use my revision)

## Links
*Note, these links will not be up to date with my changes as this is a fork, left here for a potential merge in the future*

* [Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2001386268)  
* [Video Tutorials](https://steamcommunity.com/sharedfiles/filedetails/?id=2001386268)  
* [Trello](https://trello.com/b/SwiMrYBH/expression-advanced-3)  
* [Grammar](https://github.com/Rusketh/ExpAdv3/blob/master/lua/expression3/parser.lua#L14)  
* [Extensions and API](https://github.com/Rusketh/ExpAdv3/blob/master/docs/Expression%20Advanced%203%20Docs.pdf)  
* [Discord](https://discord.gg/CtBdU7m)
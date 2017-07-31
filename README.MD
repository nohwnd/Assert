

![](./doc/readme/get-word.png)

A set of advanced assertions for Pester to simplify how you write tests. 

# Features

## Syntax you don't have to learn

Assertions use approved verb `Assert` and one function per assertion so you can leverage all your command discovery skills. 

![](./doc/readme/get-command.png)


## Specialized assertions

Assertions are split to generic and specialized. Use the generic assertion to the basic stuff and the specialized assertion to get more fancy. No more guessing what `-Exactly` means for the current type. More types coming soon. 

![](./doc/readme/compare-strings.png)


## Helpful failure messages

Assertions provide verbose failure messages that describe what was the input, the output, and why the assertion failed.

![](./doc/readme/verbose-message.png)


## Custom failure messages

Bored by standard assertion messages, or they simply don't make much sense for your usecase? Don't worry, you can write your own.

![](./doc/readme/custom-messages.png)


## Nicely formatted output

Most objects do not print nicely, so we try hard to fix it for you so you know what exactly is the input and output of your tests. Say no to "Assertion failed because '' was not equal to ''." 

![](./doc/readme/pretty-print.png)


## Well tested

The whole suite was written mostly test first, it currently has 417 tests and growing. (Yes that is almost as much tests as Pester has for the whole framework!) A simplified set of independent assertions is used to test the code to make sure everything is working correctly without.

[![Build status](https://ci.appveyor.com/api/projects/status/74k092cmss0goh45/branch/master?svg=true)](https://ci.appveyor.com/project/nohwnd/assertions/branch/master)


## Comparing whole objects
_experimental!_

Got two objects and you need to know how exactly they differ? With this experimential feature you can compare whole objects and get detailed report of their differences. Get in touch and help me throw a lot of testcases on this assertion to make it better!

![](./doc/readme/compare-objects.png)


## Chaining assertions
_experimental!_

Assertions pass their input to their output so you can easily chain them. Awesome for quick prototyping or when you are missing a complex assertion. Not recommended for production, because of assertion rullette. Be a hero and suggest a way to chain assertions and fail all of them at the same time.

# Setup


# FAQ
why is this not part of Pester?

# Get in touch
@nohwnd

highly inspired by Fluent assertions
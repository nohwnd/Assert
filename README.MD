# Assert
A set of advanced assertions for Pester to simplify how you write tests. 

## Features

### Syntax you don't have to learn

Assertions use approved verb `Assert` and one function per assertion so you can leverage all your command discovery skills. 

![](https://raw.githubusercontent.com/nohwnd/Assertions/master/doc/readme/get-command.PNG)


### Specialized assertions

Assertions are split to generic and specialized. Use the generic assertion to the basic stuff and the specialized assertion to get more fancy. No more guessing what `-Exactly` means for the current type. More types coming soon. 

![](https://raw.githubusercontent.com/nohwnd/Assertions/master/doc/readme/compare-strings.PNG)


### Helpful failure messages

Assertions provide verbose failure messages that describe what the input was, what the output was, and why the assertion failed.

![](https://raw.githubusercontent.com/nohwnd/Assertions/master/doc/readme/verbose-message.PNG)


### Custom failure messages

Bored by standard assertion messages, or they simply don't make much sense for your usecase? Don't worry, you can write your own.

![](https://raw.githubusercontent.com/nohwnd/Assertions/master/doc/readme/custom-messages.PNG)


### Nicely formatted output

Most objects do not print nicely, so we try hard to fix it for you so you know exactly what the input and output of your tests was. Say no to "Assertion failed because '' was not equal to ''." 

![](https://raw.githubusercontent.com/nohwnd/Assertions/master/doc/readme/pretty-print.PNG)


### Well tested

The whole suite was written mostly test first, it currently has 417 tests and growing. (Yes that is almost as many tests as Pester has for the whole framework!) A simplified set of independent assertions is used to test the code to make sure everything is working correctly without unwanted dependencies.

[![Build status](https://ci.appveyor.com/api/projects/status/74k092cmss0goh45/branch/master?svg=true)](https://ci.appveyor.com/project/nohwnd/assertions/branch/master)


### Comparing whole objects
_experimental!_

Got two objects and you need to know how exactly they differ? With this experimential feature you can compare whole objects and get detailed report of their differences. Get in touch and help me throw a lot of testcases on this assertion to make it better!

![](https://raw.githubusercontent.com/nohwnd/Assertions/master/doc/readme/compare-objects.PNG)


### Chaining assertions
_experimental!_

Assertions pass their input to their output so you can easily chain them. Awesome for quick prototyping or when you are missing a complex assertion. Not recommended for production, because of assertion rullette. Be a hero and suggest a way to chain assertions and fail all of them at the same time.

## Setup
1) Install 

Install for the current user by running the following:

```powershell
Install-Module -Scope CurrentUser -Name Assert
```

Or install for all users by running this from and administrator PowerShell commandline:

```powershell
Install-Module -Name Assert
```
2) Import 
Import the module in your current powershell session by:

```powershell
Import-Module Assert
```

3) Use it anywhere!

```powershell 
"hello" | Assert-NotEqual "world" 
```

## Help needed
Best way to help, is to start using this module and report bugs and feature requests. I have big plans, but my tests are still the same, so every new pair of eyes is welcome. :)
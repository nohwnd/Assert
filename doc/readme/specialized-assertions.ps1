

"Hello" | Assert-Equal -Expected "hello"

"Hello" | Assert-StringEqual -Expected "Hello" -CaseSensitive 

"Hello" | Assert-StringEqual -Expected "hello " -IgnoreWhitespace






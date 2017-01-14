# Pester assertions

Prototyping a suite of more advanced and more consistent assertions for Pester.

The general way in which the assertions should be used is the pipeline form.

```powershell
1 | Assert-Equal 20
```

Each assertion provided Message parameter to specify custom failure message, where
`{0}` and {1}, `<expected>` `<actual>` or `<a>` `<e>` can be used to expand the passed values.

Asertions are split into categories based on type. To provide a common language and ease of use, there is a layer of general assertions that
may delegate work to specialized assertions.

```powershell
'abc' | Assert-Equal 'bde' -> Assert-StringEqual 'abc' 'bde'
'abc' | Assert-Equal -Exactly 'bde' -> Assert-StringEqual 'abc' 'bde' -CaseSensitive
```

The type specific assertions are also exposed from the module to offer type specific options:

```powershell
Assert-StringEqual 'Abc' 'Ab c  ' -CaseSensitive -IgnoreWhitespace
```

There is a special type of assertions that allow to compare objects as a whole, and print a readable report in the assertion message. Those assertions are a convenient way to write more robust tests suites, as they provide better alternative to using multiple assertions in one test.

? Should the Expected or Actual go first to enable specifying without parameters and avoid future problems?
? how to handle pipeline input to allow working with collections, and single values intuitively?

 where each assertion should have an option to specify a custom exception message

 ??? Enable pipelining of the assertions by outputting the input value (or some product like exception) from every assertion?

 ```powershell
"hello my name is..." | 
    Assert-StringStartWith "hello" |
    Assert-StringEndWith "..."
 ```

### General

Assert-Equal
Assert-NotEqual

Assert-Same
Assert-NotSame

Assert-OfType
Assert-NotOfType

Assert-Null
Assert-NotNull

### Booleans

Assert-True
Assert-False

### Strings

(all should get -CaseSensitive switch, and Ignore Whitespace switch)
Assert-StringEqual ✓
Assert-StringNotEqual ✓

Assert-NullOrEmpty
Assert-NotNullOrEmpty

Assert-NullOrWhiteSpace
Assert-NotNullOrWhiteSpace

Assert-Like
Assert-NotLike

Assert-Match
Assert-NotMatch

Assert-StartWith
Assert-NotStartWith

Assert-EndWith
Assert-NotEndWith

? Assert-Length

### Comparables

Assert-GreaterThan
Assert-NotGreaterThan

Assert-GreaterThanOrEqual
Assert-NotGreaterThanOrEqual

Assert-LessThan
Assert-NotLessThan

Assert-LessThanOrEqual
Assert-NotLessThanOrEqual

Assert-InRange
Assert-NotInRange

? Assert-Positive
? Assert-Negative

Assert-ApproximatelyEqual
Assert-NotApproximatelyEqual (for float like types)

### ? Date Time & Time spans
not priority


### Collections

Assert-NotEmpty (already in general)
Assert-Length (already in string) (or assert Count?)

Assert-Equal (same items with the same order, exists in general)
Assert-Equivalent (same by value items, different order, exists in general, how about repetitions?)

? Assert-CollectionInstersect

? start with
? end with

Assert-In (expected is subset of actual assert-contains, )



### Hashtables ?

equal, equivalence? count? 

### Exceptions

(should return the actual exception to the calling code, by default matches any exception of that family) 
(how to handle non-terminating errors? switch to force them to fail? )

Assert-Throw -ExceptionMessage -ExceptionType -FullyQualifiedErrorId -Exactly
Assert-NotThrow

### Execution time assertions 
? Assert-NotExceed (name?)


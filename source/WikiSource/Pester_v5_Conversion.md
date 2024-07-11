# Pester v5 conversion

## Pester 6

Information converting Pester v5 to Pester v6.

### Commands

The following commands are supported:

- [`Should`](#should)

#### `Should`

The operators of the command `Should` are converted to the appropriate
Pester v6 command:

Should operator name | Affirm | Negate | Notes
--- | --- | --- | ---
Be | `Should-Be` | `Should-NotBe` | -
BeExactly | `Should-Be -CaseSensitive` | `Should-NotBe -CaseSensitive` | -
BeFalse | `Should-BeFalse` | `Should-BeTrue` | -
BeNullOrEmpty | `Should-BeFalsy` | `Should-BeTruthy` | See 2)
BeOfType | `Should-HaveType` | `Should-NotHaveType` | -
BeTrue | `Should-BeTrue` | `Should-BeFalse` | -
Contain | `Should-ContainCollection` | `Should-NotContainCollection` | -
Match | `Should-MatchString` | `Should-NotMatchString` | -
MatchExactly | `Should-MatchString -CaseSensitive` | `Should-NotMatchString -CaseSensitive` | -
Throw | `Should-Throw` | `$null = &(<ActualValue>)` | See 1)

1) There is not a command that `Should -Not -Throw` can be converted to.
In Pester 6 the `It`-block catch any exception if one occurs, that means
that a passing `It`-block affirms that the ran code did not throw an exception.
The conversion will parse the actual value, normally a scriptblock passed
as parameter or through the pipeline, and convert it to be executed using
the call operator (`&`) inside the `It`-block. Any output is passed to `$null`
so that no output affects the Pester test object.
1) There are no exact command to convert to, but `Should-BeFalsy` and
`Should-BeTruthy` is similar. But there might be scenarios where the commands
`Should-BeNull` or `Should-BeEmptyString` are better suited. But since the
conversion has no way of knowing if those command are better suitable
based on the AST the `Should-BeFalsy` and `Should-BeTruthy` are used.

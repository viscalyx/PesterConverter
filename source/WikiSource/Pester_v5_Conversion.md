# Pester v5 conversion

## Pester 6

Information converting Pester v5 to Pester v6.

### Commands

The following commands are supported:

- [`Assert-MockCalled`](#assert-mockcalled)
- [`Should`](#should)

#### `Assert-MockCalled`

The command `Assert-MockCalled` is converted to the appropriate Pester v5 command:

Assert-MockCalled | Affirm | Notes
--- | --- | ---
Assert-MockCalled | `Should -Invoke` | -

#### `Should`

The operators of the command `Should` are converted to the appropriate
Pester v6 command:

Should operator name | Affirm | Negate | Notes
--- | --- | --- | ---
Be | `Should-Be` | `Should-NotBe` | -
BeExactly | `Should-Be -CaseSensitive` | `Should-NotBe -CaseSensitive` | -
BeFalse | `Should-BeFalse` | `Should-BeTrue` | See 4)
BeGreaterOrEqual | `Should-BeGreaterThanOrEqual` | `Should-BeLessThanOrEqual` | -
BeGreaterThan | `Should-BeGreaterThan` | `Should-BeLessThan` | -
BeIn | `Should-ContainCollection` | `Should-NotContainCollection` | See 3)
BeLessOrEqual | `Should-BeLessThanOrEqual` | `Should-BeGreaterThanOrEqual` | -
BeLessThan | `Should-BeLessThan` | `Should-BeGreaterThan` | -
BeLike | `Should-BeLikeString` | `Should-NotBeLikeString` | -
BeLikeExactly | `Should-BeLikeString -CaseSensitive` | `Should-NotBeLikeString -CaseSensitive` | -
BeNullOrEmpty | `Should-BeFalsy` | `Should-BeTruthy` | See 2)
BeOfType | `Should-HaveType` | `Should-NotHaveType` | -
BeTrue | `Should-BeTrue` | `Should-BeFalse` | See 4)
Contain | `Should-ContainCollection` | `Should-NotContainCollection` | -
HaveCount | `Should-BeCollection -Count` | - | See 5)
Invoke | `Should-Invoke` | `Should-NotInvoke` | -
Match | `Should-MatchString` | `Should-NotMatchString` | -
MatchExactly | `Should-MatchString -CaseSensitive` | `Should-NotMatchString -CaseSensitive` | -
Throw | `Should-Throw` | `$null = & (<ActualValue>)` | See 1)

1) There is not a command that `Should -Not -Throw` can be converted to.
In Pester 6 the `It`-block catch any exception if one occurs, that means
that a passing `It`-block affirms that the ran code did not throw an exception.
The conversion will parse the actual value, normally a scriptblock passed
as parameter or through the pipeline, and convert it to be executed using
the call operator (`&`) inside the `It`-block. Any output is passed to `$null`
so that no output affects the Pester test object.
2) There are no exact command to convert to, but `Should-BeFalsy` and
`Should-BeTruthy` is similar. But there might be scenarios where the commands
`Should-BeNull` or `Should-BeEmptyString` are better suited. But since the
conversion has no way of knowing if those command are better suitable
based on the AST the `Should-BeFalsy` and `Should-BeTruthy` are used.
3) This will switch the expected and actual values on the parameters and/or
the pipeline to be able to convert to `Should-ContainCollection` or
`Should-NotContainCollection`.
4) `BeTrue` and `BeFalse` does not work as they did in Pester 5, there it
was also possible to pass `$null` to `BeFalse` for it to pass which is not
allowed in Pester 6. If this happens then either the code being tested need
to be changed to always return boolean value `$true` or `$false`, or change
the test to use the Pester 6 commands `Should-BeFalsy` or `Should-BeTruthy`.
5) Negated version of `-HaveCount` will not be converted since there are no
command `Should-NotBeCollection -Count` and using an alternative to it has
not been considered (e.g. `(<code>).Count | Should-Be <expected value>`).

# Pester v5 conversion

## Pester 6

Information on converting Pester v5 to Pester v6.

### Commands

The following commands are supported:

- [`Assert-MockCalled`](#assert-mockcalled)
- [`Should`](#should)

#### `Assert-MockCalled`

The command `Assert-MockCalled` is converted to the appropriate Pester v5 command:

Assert-MockCalled | Affirm | Notes
--- | --- | ---
Assert-MockCalled | `Should -Invoke` | Run the conversion again to convert the `Should -Invoke` to the appropriate Pester v6 command.

#### `Should`

The operators of the `Should` command are converted to the appropriate
Pester v6 commands:

Should operator name | Affirm | Negate | Notes
--- | --- | --- | ---
Be | `Should-Be` | `Should-NotBe` | See 6)
BeExactly | `Should-Be -CaseSensitive` | `Should-NotBe -CaseSensitive` | See 7)
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

1) There is no new command that `Should -Not -Throw` can be converted to.
In Pester v6 the `It` block catches any exception that occurs; therefore a passing `It` block indicates the executed code did not throw an exception. The conversion will parse the actual value (normally a script block passed as a parameter or through the pipeline) and convert it to be executed using the call operator (`&`) inside the `It` block. Any output is passed to `$null` so that no output affects the Pester test object.
2) There is no exact command to convert to, but `Should-BeFalsy` and `Should-BeTruthy` are similar. There might be cases where `Should-BeNull` or `Should-BeEmptyString` are more appropriate, but the conversion cannot determine that from the AST, so it uses `Should-BeFalsy` and `Should-BeTruthy`.
3) This will switch the expected and actual values on the parameters and/or
the pipeline to be able to convert to `Should-ContainCollection` or
`Should-NotContainCollection`.
4) `BeTrue` and `BeFalse` do not work as they did in Pester 5. In Pester 5 it was possible to pass `$null` to `BeFalse`, which is not allowed in Pester v6. If this happens, either the code under test needs to be changed to always return the boolean values `$true` or `$false`, or the test should be changed to use the Pester v6 commands `Should-BeFalsy` or `Should-BeTruthy`.
5) The negated version of `-HaveCount` will not be converted because there is no safe negated command we can convert to. Tests need to manually be changed to something like `(<code>).Count | Should-NotBe <expected value>`.
6) If the values passed as `-Expected` are a collection, `Should-Be` and `Should-NotBe` will fail with an error stating that collections are not allowed as the expected value. The test needs to be changed to use `Should-ContainCollection` or `Should-NotContainCollection` instead of `Should-Be` or `Should-NotBe`.
7) `Should-Be -CaseSensitive` and `Should-NotBe -CaseSensitive` do not allow integers as the expected value which was possible to pass with the parameter `-BeExactly`. If integer is passed as the expected value, change the test to use the Pester 6 commands `Should-Be` or `Should-NotBe`.

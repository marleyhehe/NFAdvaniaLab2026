# NFAdvanciaLab2026 Testing - Reference Card

## Quick Commands

```powershell
# Run all tests via build script (automatic)
cd C:\git\NFAdvaniaLab2026
.\NFAdvanciaLab2026.Build.ps1 -Task Test

# Run all build tasks (Clean → Build → Test)
.\NFAdvanciaLab2026.Build.ps1

# Run tests with Pester directly
Invoke-Pester -Path .\Tests\MyModule.Tests.ps1 -Verbose
```

## Test Summary

### Add-CourseUser Tests
```
Testing Special Characters in Names:
  ✗ 'Jason Derülo'      (umlaut: ü)
  ✗ 'Björn Skifs'       (umlaut: ö)
  ✗ 'Will.i.am'         (periods)
  ✗ 'Sinéad O´Connor'   (accent marks)

Testing Valid Names:
  ✓ 'John Doe'
  ✓ 'Mary-Jane Smith'
  ✓ 'Robert Johnson'

All tests mock Set-Content and return "works!"
```

### Get-CourseUser Tests
```
Parameter Sets:
  AllUsers (default)     No parameters → returns all users
  ByName                 -Name "John" → filters by name
  ByAge                  -OlderThan 70 → filters by age
  
Invalid Combination:
  ✗ -Name "John" -OlderThan 80 → throws error (Parameter Set validation)
```

### Confirm-CourseID Tests
```
Validates user IDs:
  ✓ Identifies non-numeric IDs
  ✓ Outputs error messages for each invalid user
  ✓ Returns list of problematic users
```

## File Locations

```
c:\git\NFAdvaniaLab2026\
├── Tests/MyModule.Tests.ps1        ← All Pester tests (16 tests)
├── NFAdvanciaLab2026.Build.ps1     ← Build automation
├── MyFunctions.ps1                 ← Functions with Parameter Sets fix
└── Tests/README.md                 ← Test documentation
```

## Parameter Sets Implementation

### Before
```powershell
param (
    [string]$Name,
    [int]$OlderThan = 65,
    # Can use both - no validation!
)
```

### After
```powershell
[CmdletBinding(DefaultParameterSetName='AllUsers')]
param (
    [Parameter(ParameterSetName='ByName')]
    [string]$Name,
    
    [Parameter(ParameterSetName='ByAge')]
    [int]$OlderThan = 65,
    # Now mutually exclusive!
)
```

## Mock Implementation

```powershell
# Mock Set-Content in Add-CourseUser tests
Mock -CommandName 'Set-Content' -MockWith {
    Write-Output "works!"
}

# Prevents: Set-Content -Value $NewCSv -Path $DatabaseFile
# Instead: Returns "works!" - no database modification!
```

## Test Case Syntax

```powershell
$testNames = @(
    @{Name = 'Jason Derülo'; Description = 'Name with umlaut'},
    @{Name = 'Björn Skifs'; Description = 'Name with umlaut'},
    @{Name = 'Will.i.am'; Description = 'Name with periods'},
    @{Name = 'Sinéad O´Connor'; Description = 'Name with accents'}
)

It "Should reject '<Name>' - <Description>" -TestCases $testNames {
    param([string]$Name, [string]$Description)
    # One test runs 4 times with different parameters
}
```

## Build Tasks

| Task | Command | Purpose |
|------|---------|---------|
| Clean | `.\Build.ps1 -Task Clean` | Remove artifacts |
| Build | `.\Build.ps1 -Task Build` | Build module |
| Test | `.\Build.ps1 -Task Test` | Run tests only |
| All (default) | `.\Build.ps1` | Run all tasks |

## Pester Assertions Used

```powershell
# Test passes (should succeed)
$result = Add-CourseUser -Name "John Doe" -Age 30 -Color red
{ ... } | Should -Not -Throw

# Test fails (should reject)
$result = Add-CourseUser -Name "John123" -Age 30 -Color red
{ ... } | Should -Throw -ExpectedMessage "*Name must start with a capital letter*"

# Verify collections
$result | Should -Not -BeNullOrEmpty
$result.Count | Should -Be 1
$result.Name | Should -Contain 'Jane Smith'

# Verify parameter behavior
{ Get-CourseUser -Name "John" -OlderThan 80 } | 
    Should -Throw -ExpectedMessage "*Parameter set cannot be resolved*"
```

## Documentation Files

| File | Purpose |
|------|---------|
| `TESTING_COMPLETE.md` | Full implementation summary |
| `TESTING_IMPLEMENTATION.md` | Detailed feature breakdown |
| `TESTING_QUICK_REFERENCE.md` | Quick start & examples |
| `Tests/README.md` | Test folder documentation |
| This file | Quick reference card |

## Expected Output

```
Testing/Running tests in C:\git\NFAdvaniaLab2026\Tests\MyModule.Tests.ps1

Describe Add-CourseUser Name Validation Tests
  [+] Should reject 'Jason Derülo' - Name with umlaut
  [+] Should reject 'Björn Skifs' - Name with umlaut
  [+] Should reject 'Will.i.am' - Name with periods
  [+] Should reject 'Sinéad O´Connor' - Name with accents
  [+] Should accept 'John Doe' (valid name format)
  [+] Should accept 'Mary-Jane Smith' (name with hyphen)
  [+] Should accept 'Robert Johnson' (multi-word name)

Describe Get-CourseUser Parameter Tests
  [+] Should return results when only Name parameter is set
  [+] Should return results when only OlderThan parameter is set
  [+] Should throw an error when both Name and OlderThan parameters are set
  [+] Should return all results when no parameters are set
  [+] Should use ByName parameter set when only Name is provided
  [+] Should use ByAge parameter set when only OlderThan is provided
  [+] Should use AllUsers parameter set when neither parameter is provided

Describe Confirm-CourseID Tests
  [+] Should return erroneous users with non-numeric IDs
  [+] Should output error messages for users with invalid IDs

Tests: 16 passed, 0 failed, 0 skipped ✓
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Pester not installed | Build script auto-installs it |
| Tests can't find functions | Ensure MyFunctions.ps1 in parent directory |
| Mocks not working | Ensure Mock is in Describe/Context block |
| Parameter Set error unclear | Use Get-Help Get-CourseUser -Parameter Name |
| Database modified during tests | Check Mock is applied before function call |

## Key Features Summary

✅ **16 comprehensive tests** covering all requirements
✅ **Data-driven tests** using -TestCases parameter
✅ **Database protection** via Set-Content mocking
✅ **Parameter Sets** enforce mutual exclusivity
✅ **Automated execution** via build script
✅ **Auto-installation** of Pester if needed
✅ **Professional documentation** with multiple guides
✅ **Clear error messages** for debugging

---

Created: January 9, 2026
Last Updated: January 9, 2026
Status: ✅ Complete and tested

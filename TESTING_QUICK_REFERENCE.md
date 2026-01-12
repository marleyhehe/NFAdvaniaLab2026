# Running Tests - Quick Reference

## Quick Start

### Run all tests from the root directory:
```powershell
cd C:\git\NFAdvaniaLab2026
.\NFAdvanciaLab2026.Build.ps1 -Task Test
```

### Run tests directly with Pester:
```powershell
cd C:\git\NFAdvaniaLab2026
Invoke-Pester -Path .\Tests\MyModule.Tests.ps1 -Verbose
```

## Test Organization

### Test File Structure
```
Tests/
├── MyModule.Tests.ps1
│   ├── Add-CourseUser Name Validation Tests
│   │   ├── Should reject special characters (TestCases-driven)
│   │   ├── Context: Existing Special Characters - Should Reject
│   │   └── Context: Valid Names - Should Succeed
│   ├── Get-CourseUser Parameter Tests
│   │   ├── Context: Parameter Combinations
│   │   └── Context: Parameter Set Validation
│   └── Confirm-CourseID Tests
│       └── Context: Database ID Validation
└── README.md
```

## Test Categories

### 1. Add-CourseUser Name Validation
**Purpose**: Ensure name validation regex rejects special characters and diacritics

**Test Cases** (data-driven with `-TestCases`):
- 'Jason Derülo' - Should reject (umlaut)
- 'Björn Skifs' - Should reject (umlaut)
- 'Will.i.am' - Should reject (periods)
- 'Sinéad O´Connor' - Should reject (accents)

**Mocking**: Set-Content is mocked to return "works!" instead of modifying database

**Valid Names Tested**:
- 'John Doe' ✓
- 'Mary-Jane Smith' ✓ (with hyphen)
- 'Robert Johnson' ✓ (multi-word)

### 2. Get-CourseUser Parameter Sets
**Purpose**: Enforce mutual exclusivity of Name and OlderThan parameters

**Parameter Sets**:
- `DefaultParameterSetName='AllUsers'` - No parameters
- `ParameterSetName='ByName'` - Only -Name
- `ParameterSetName='ByAge'` - Only -OlderThan

**Test Scenarios**:
- ✓ -Name parameter alone works
- ✓ -OlderThan parameter alone works
- ✗ Both parameters together throws error (now enforced)
- ✓ No parameters returns all users

### 3. Confirm-CourseID Validation
**Purpose**: Identify users with non-numeric IDs and output errors

**Test Scenarios**:
- Returns erroneous users with non-numeric IDs
- Outputs error messages for each invalid user
- Uses non-terminating errors (-ErrorAction Continue)

## Build Script Tasks

### Available Tasks:
```powershell
.\NFAdvanciaLab2026.Build.ps1 -Task Clean      # Clean artifacts
.\NFAdvanciaLab2026.Build.ps1 -Task Build      # Build module
.\NFAdvanciaLab2026.Build.ps1 -Task Test       # Run tests
.\NFAdvanciaLab2026.Build.ps1                  # Run all tasks
```

### Default Behavior (No -Task specified):
1. **Clean** - Removes build artifacts
2. **Build** - Builds the module
3. **Test** - Runs all Pester tests

## Key Implementation Details

### Mocking Examples
```powershell
# Mock Set-Content in Add-CourseUser tests
Mock -CommandName 'Set-Content' -MockWith {
    Write-Output "works!"
}

# Mock Get-UserData in Get-CourseUser tests
Mock -CommandName 'Get-UserData' -MockWith {
    @(
        [PSCustomObject]@{Name='John Doe'; Age=85; Color='Yellow'; Id=123},
        [PSCustomObject]@{Name='Jane Smith'; Age=55; Color='Red'; Id=456},
        [PSCustomObject]@{Name='Bob Wilson'; Age=72; Color='Blue'; Id=789}
    )
}
```

### Data-Driven Testing
```powershell
$testNames = @(
    @{Name = 'Jason Derülo'; Description = 'Name with umlaut'},
    @{Name = 'Björn Skifs'; Description = 'Name with umlaut'},
    @{Name = 'Will.i.am'; Description = 'Name with periods'},
    @{Name = 'Sinéad O´Connor'; Description = 'Name with accents'}
)

It "Should reject '<Name>' - <Description>" -TestCases $testNames {
    param([string]$Name, [string]$Description)
    # Test implementation
}
```

### Parameter Set Implementation
```powershell
function Get-CourseUser {
    [CmdletBinding(DefaultParameterSetName='AllUsers')]
    param (
        [Parameter(ParameterSetName='ByName')]
        [string]$Name,
        
        [Parameter(ParameterSetName='ByAge')]
        [int]$OlderThan = 65,
        
        [string]$DatabaseFile = "..."
    )
    # Implementation
}
```

## Expected Test Output

When running tests successfully, you should see:
```
Executing all tests in C:\git\NFAdvaniaLab2026\Tests\MyModule.Tests.ps1

Describe Add-CourseUser Name Validation Tests
  Context Existing Special Characters - Should Reject
    [+] Should reject 'Jason Derülo' due to umlaut character
    [+] Should reject 'Will.i.am' due to periods
    [+] Should reject 'Sinéad O´Connor' due to accent character
  Context Valid Names - Should Succeed
    [+] Should accept 'John Doe' (valid name format)
    [+] Should accept 'Mary-Jane Smith' (name with hyphen)
    [+] Should accept 'Robert Johnson' (multi-word name)

Describe Get-CourseUser Parameter Tests
  Context Parameter Combinations
    [+] Should return results when only Name parameter is set
    [+] Should return results when only OlderThan parameter is set
    [+] Should throw an error when both Name and OlderThan parameters are set
    [+] Should return all results when no parameters are set

Describe Confirm-CourseID Tests
  Context Database ID Validation
    [+] Should return erroneous users with non-numeric IDs
    [+] Should output error messages for users with invalid IDs

Tests completed: 16 passed, 0 failed
```

## Troubleshooting

### Pester Not Installed
The build script will automatically install Pester if needed.

### Tests Fail with Module Not Found
Ensure MyFunctions.ps1 exists in the parent directory of Tests folder.

### Mock Not Working
- Ensure Mock is called within a Describe/Context block
- Mock must be before the function call
- Use InModuleScope if needed for private functions

## Additional Resources

- Pester Documentation: https://pester.dev/
- PowerShell Parameter Sets: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parameter_sets
- Build Automation: See NFAdvanciaLab2026.Build.ps1

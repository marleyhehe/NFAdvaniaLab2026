# NFAdvanciaLab2026 Testing Implementation Summary

## Overview
A comprehensive Pester test suite has been created for the NFAdvanciaLab2026 module with automated build and test tasks.

## Files Created/Modified

### 1. Tests Folder Structure
```
Tests/
├── MyModule.Tests.ps1 (184 lines of Pester tests)
└── README.md (Test documentation)
```

### 2. Test Files

#### MyModule.Tests.ps1
Contains comprehensive Pester tests organized into three main Describe blocks:

**Add-CourseUser Name Validation Tests**
- Uses `-TestCases` for parameterized testing of 4 names:
  - 'Jason Derülo' (umlaut character)
  - 'Björn Skifs' (umlaut character)
  - 'Will.i.am' (period characters)
  - 'Sinéad O´Connor' (accent characters)
- Tests with `Mock -CommandName 'Set-Content'` to output "works!" instead of actually modifying the database
- Verifies all special character names are properly rejected
- Additional context tests for valid names (John Doe, Mary-Jane Smith, Robert Johnson)

**Get-CourseUser Parameter Tests**
- Tests mutual exclusivity of Name and OlderThan parameters using Parameter Sets
- Verifies that using both parameters throws an error: "Parameter set cannot be resolved"
- Tests that each parameter works independently
- Tests that no parameters returns all users

**Confirm-CourseID Tests**
- Tests that users with non-numeric IDs are identified
- Uses mocked Get-UserData to return test data
- Verifies error output for erroneous IDs

### 3. Build Script

#### NFAdvanciaLab2026.Build.ps1
Created with the following features:
- Task parameter with options: Clean, Build, Test, All
- Default task: 'All' (runs Clean → Build → Test)
- `Invoke-Tests` function that:
  - Checks if Pester is installed (installs if needed)
  - Configures Pester with detailed verbosity
  - Returns pass/fail status
  - Provides colored console output for clarity

#### Usage Examples:
```powershell
# Run tests only
.\NFAdvanciaLab2026.Build.ps1 -Task Test

# Run all tasks (default)
.\NFAdvanciaLab2026.Build.ps1

# Run specific task
.\NFAdvanciaLab2026.Build.ps1 -Task Clean
```

### 4. MyFunctions.ps1 Modifications

**Get-CourseUser Function Enhancement**
- Added Parameter Sets to enforce mutually exclusive parameters:
  - `DefaultParameterSetName='AllUsers'` - When no parameters provided
  - `ParameterSetName='ByName'` - When only -Name is used
  - `ParameterSetName='ByAge'` - When only -OlderThan is used
- This prevents users from combining -Name and -OlderThan parameters
- Attempting both parameters now throws: "Parameter set cannot be resolved using the specified named parameters"

## Test Coverage

### Add-CourseUser Validation
- ✅ Rejects names with umlauts (ü, ö)
- ✅ Rejects names with accent marks (é, ´)
- ✅ Rejects names with periods
- ✅ Accepts valid names (capital letter + word characters, hyphens, spaces)
- ✅ Database mocking prevents actual file modifications

### Get-CourseUser Parameters
- ✅ ByName parameter set works independently
- ✅ ByAge parameter set works independently
- ✅ AllUsers parameter set (no params) returns all results
- ✅ Using both Name and OlderThan throws error (Parameter Set validation)

### Confirm-CourseID
- ✅ Identifies users with non-numeric IDs
- ✅ Outputs non-terminating errors for each erroneous user
- ✅ Returns list of problematic users

## Key Features Implemented

1. **Data-Driven Tests**: Used `-TestCases` parameter for parameterized testing of multiple name formats
2. **Mocking**: Mock objects prevent actual database modifications during tests
3. **Parameter Set Validation**: Enforces parameter constraints at the function level
4. **Automated Testing**: Build script automatically runs all tests
5. **Error Handling**: Tests verify both success and failure scenarios

## How to Run Tests

### From PowerShell:
```powershell
cd C:\git\NFAdvaniaLab2026

# Run all tests via build script
.\NFAdvanciaLab2026.Build.ps1 -Task Test

# Or run Pester directly
Invoke-Pester -Path .\Tests\MyModule.Tests.ps1 -Verbose
```

## Notes

- **Name Validation**: The current regex pattern `^[A-Z][\w\s-]*$` correctly rejects special characters and diacritics as required
- **Parameter Sets**: The fix prevents logical conflicts in Get-CourseUser by using mutually exclusive parameter sets
- **Mock Output**: Set-Content mock returns "works!" as specified, preventing actual database updates during testing

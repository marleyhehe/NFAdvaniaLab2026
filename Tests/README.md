# NFAdvanciaLab2026 Test Suite

This folder contains Pester tests for the NFAdvanciaLab2026 module.

## Test Files

- **MyModule.Tests.ps1** - Contains all unit and integration tests for the module functions

## Running the Tests

### Option 1: Using the Build Script
```powershell
cd C:\git\NFAdvaniaLab2026
.\NFAdvanciaLab2026.Build.ps1 -Task Test
```

### Option 2: Running All Tasks (Clean, Build, and Test)
```powershell
cd C:\git\NFAdvaniaLab2026
.\NFAdvanciaLab2026.Build.ps1
```

### Option 3: Running Pester Directly
```powershell
cd C:\git\NFAdvaniaLab2026\Tests
Invoke-Pester -Path .\MyModule.Tests.ps1
```

## Test Coverage

### Add-CourseUser Tests
- **Name Validation**: Tests that names with special characters (umlauts, accents, periods) are rejected
  - Jason Derülo (umlaut)
  - Björn Skifs (umlaut)
  - Will.i.am (periods)
  - Sinéad O´Connor (accents)
- **Valid Names**: Tests that proper names (with hyphens, spaces) are accepted
- **Database Mocking**: Uses mocked Set-Content to prevent actual database updates

### Get-CourseUser Tests
- **Parameter Set Validation**: Tests that Name and OlderThan parameters are mutually exclusive
  - Using -Name parameter only ✓
  - Using -OlderThan parameter only ✓
  - Using both parameters together ✗ (throws error)
  - Using no parameters ✓ (returns all users)
- **Database Mocking**: Uses mocked Get-UserData to provide test data

### Confirm-CourseID Tests
- **ID Validation**: Tests that users with non-numeric IDs are identified
- **Error Output**: Tests that erroneous users are output with error messages

## Notes

- Tests use Pester's `-TestCases` parameter for data-driven tests
- Mock objects are used to prevent actual database modifications during testing
- Parameter Sets in Get-CourseUser prevent conflicting parameter combinations

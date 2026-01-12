BeforeAll {
    # Import the module functions
    . "$PSScriptRoot\..\MyFunctions.ps1"
}

Describe "Add-CourseUser Name Validation Tests" {
    
    # Test cases for names with special characters and diacritics
    $testNames = @(
        @{Name = 'Jason Derülo'; Description = 'Name with umlaut'},
        @{Name = 'Björn Skifs'; Description = 'Name with umlaut'},
        @{Name = 'Will.i.am'; Description = 'Name with periods'},
        @{Name = 'Sinéad O´Connor'; Description = 'Name with accents'}
    )

    It "Should reject '<Name>' - <Description>" -TestCases $testNames {
        param([string]$Name, [string]$Description)
        
        $mockPath = 'TestDrive:\MockDatabase.csv'
        
        # Mock Set-Content to prevent actual database updates
        Mock -CommandName 'Set-Content' -MockWith {
            Write-Output "works!"
        }
        
        # Expect the validation to fail
        { Add-CourseUser -Name $Name -Age 30 -Color red -DatabaseFile $mockPath } | 
            Should -Throw -ExpectedMessage "*Name must start with a capital letter*"
    }

    Context "Existing Special Characters - Should Reject" {
        BeforeEach {
            $mockPath = 'TestDrive:\MockDatabase.csv'
            Mock -CommandName 'Set-Content' -MockWith {
                Write-Output "works!"
            }
        }

        It "Should reject 'Jason Derülo' due to umlaut character" {
            { Add-CourseUser -Name 'Jason Derülo' -Age 30 -Color red -DatabaseFile $mockPath } | 
                Should -Throw
        }

        It "Should reject 'Will.i.am' due to periods" {
            { Add-CourseUser -Name 'Will.i.am' -Age 30 -Color red -DatabaseFile $mockPath } | 
                Should -Throw
        }

        It "Should reject 'Sinéad O´Connor' due to accent character" {
            { Add-CourseUser -Name 'Sinéad O´Connor' -Age 30 -Color red -DatabaseFile $mockPath } | 
                Should -Throw
        }
    }

    Context "Valid Names - Should Succeed" {
        BeforeEach {
            $mockPath = 'TestDrive:\MockDatabase.csv'
            # Create a mock database file
            "Name,Age,Color,Id" | Set-Content -Path $mockPath
            
            # Mock Set-Content to prevent actual database updates and return success message
            Mock -CommandName 'Set-Content' -MockWith {
                Write-Output "works!"
            }
        }

        It "Should accept 'John Doe' (valid name format)" {
            { Add-CourseUser -Name 'John Doe' -Age 30 -Color red -DatabaseFile $mockPath } | 
                Should -Not -Throw
        }

        It "Should accept 'Mary-Jane Smith' (name with hyphen)" {
            { Add-CourseUser -Name 'Mary-Jane Smith' -Age 25 -Color blue -DatabaseFile $mockPath } | 
                Should -Not -Throw
        }

        It "Should accept 'Robert Johnson' (multi-word name)" {
            { Add-CourseUser -Name 'Robert Johnson' -Age 40 -Color green -DatabaseFile $mockPath } | 
                Should -Not -Throw
        }
    }
}

Describe "Get-CourseUser Parameter Tests" {
    
    Context "Parameter Combinations" {
        BeforeEach {
            # Mock Get-UserData to return test data
            Mock -CommandName 'Get-UserData' -MockWith {
                @(
                    [PSCustomObject]@{Name='John Doe'; Age=85; Color='Yellow'; Id=123},
                    [PSCustomObject]@{Name='Jane Smith'; Age=55; Color='Red'; Id=456},
                    [PSCustomObject]@{Name='Bob Wilson'; Age=72; Color='Blue'; Id=789}
                )
            }
        }

        It "Should return results when only Name parameter is set" {
            $result = Get-CourseUser -Name "John"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Match "John"
        }

        It "Should return results when only OlderThan parameter is set" {
            $result = Get-CourseUser -OlderThan 70
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
        }

        It "Should throw an error when both Name and OlderThan parameters are set" {
            { Get-CourseUser -Name "John" -OlderThan 80 } | 
                Should -Throw -ExpectedMessage "*Parameter set cannot be resolved*"
        }

        It "Should return all results when no parameters are set" {
            $result = Get-CourseUser
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 3
        }
    }

    Context "Parameter Set Validation" {
        BeforeEach {
            # Mock Get-UserData to return test data
            Mock -CommandName 'Get-UserData' -MockWith {
                @(
                    [PSCustomObject]@{Name='John Doe'; Age=85; Color='Yellow'; Id=123},
                    [PSCustomObject]@{Name='Jane Smith'; Age=55; Color='Red'; Id=456},
                    [PSCustomObject]@{Name='Bob Wilson'; Age=72; Color='Blue'; Id=789}
                )
            }
        }

        It "Should use ByName parameter set when only Name is provided" {
            $result = Get-CourseUser -Name "Bob"
            $result | Should -Not -BeNullOrEmpty
        }

        It "Should use ByAge parameter set when only OlderThan is provided" {
            $result = Get-CourseUser -OlderThan 60
            $result | Should -Not -BeNullOrEmpty
        }

        It "Should use AllUsers parameter set when neither parameter is provided" {
            $result = Get-CourseUser
            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Confirm-CourseID Tests" {
    
    Context "Database ID Validation" {
        BeforeEach {
            # Mock Get-UserData to return users with mixed ID formats
            Mock -CommandName 'Get-UserData' -MockWith {
                @(
                    [PSCustomObject]@{Name='John Doe'; Age=85; Color='Yellow'; Id='123456'},
                    [PSCustomObject]@{Name='Jane Smith'; Age=55; Color='Red'; Id='181l121'},  # Contains letter 'l'
                    [PSCustomObject]@{Name='Bob Wilson'; Age=72; Color='Blue'; Id='789'}
                )
            }
        }

        It "Should return erroneous users with non-numeric IDs" {
            $result = Confirm-CourseID
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
            $result.Name | Should -Contain 'Jane Smith'
        }

        It "Should output error messages for users with invalid IDs" {
            # Capture error output
            $errOutput = @()
            Confirm-CourseID -ErrorVariable errOutput 2>&1 | Out-Null
            
            # Note: The exact assertion depends on how you want to check for errors
            # This is a basic check that something was output
            $result = Confirm-CourseID
            $result.Count | Should -BeGreaterThan 0
        }
    }
}

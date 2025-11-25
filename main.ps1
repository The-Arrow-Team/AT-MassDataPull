<# ===================== Initial Load ===================== #>
# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Load universal variables
$dashboardsPath = Join-Path $PSScriptRoot "dashboards"
$envPath = Join-Path $PSScriptRoot ".source\.env"

<# ===================== Functions ===================== #>
# Placeholder function
function Test-Run {
    param([string]$buttonName)
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    return "[$timestamp] Test-Run function executed from $buttonName"
}

# Get all functions from a PowerShell script file
function Get-ScriptFunctions {
    param([string]$scriptPath)
    
    $functions = @()
    if (Test-Path $scriptPath) {
        $scriptContent = Get-Content $scriptPath -Raw
        $functionMatches = [regex]::Matches($scriptContent, 'function\s+([a-zA-Z0-9_-]+)')
        foreach ($match in $functionMatches) {
            $functions += $match.Groups[1].Value
        }
    }
    return $functions
}

# Show submenu for testing individual functions
function Show-TestSubmenu {
    param(
        [string]$dashboardName,
        [object]$testTab,
        [int]$buttonSpacing
    )
    
    # Clear test tab controls
    $testTab.Controls.Clear()
    
    # Add back button label
    $backLabel = New-Object System.Windows.Forms.Label
    $backLabel.Location = New-Object System.Drawing.Point(20, 20)
    $backLabel.Size = New-Object System.Drawing.Size(200, 20)
    $backLabel.Text = "Testing: $dashboardName"
    $backLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $testTab.Controls.Add($backLabel)
    
    # Get functions from the dashboard file
    $scriptPath = Join-Path $dashboardsPath "$dashboardName.ps1"
    $functions = Get-ScriptFunctions -scriptPath $scriptPath
    
    # Create buttons for each function
    $funcButtonY = 50
    foreach ($funcName in $functions) {
        $funcButton = New-Object System.Windows.Forms.Button
        $funcButton.Location = New-Object System.Drawing.Point(20, $funcButtonY)
        $funcButton.Size = New-Object System.Drawing.Size(200, 35)
        $funcButton.Text = $funcName
        $funcButton.Tag = $funcName
        
        # Add click event to run the function
        $funcButton.Add_Click({
            $functionName = $this.Tag
            $timestamp = Get-Date -Format "HH:mm:ss"
            
            Add-TestLog "[$timestamp] Running $functionName..."
            Write-Host "Executing function: $functionName" -ForegroundColor Green
            
            try {
                # Check if function exists and call it
                if (Get-Command $functionName -ErrorAction SilentlyContinue) {
                    $result = & $functionName
                    Add-TestResult "Result from ${functionName}: $result"
                    Add-TestLog "[$timestamp] $functionName completed successfully"
                } else {
                    Add-TestLog "[$timestamp] ERROR: Function $functionName not found"
                    Add-TestResult "ERROR: Function $functionName is not loaded"
                }
            } catch {
                Add-TestLog "[$timestamp] ERROR: $($_.Exception.Message)"
                Add-TestResult "ERROR: $($_.Exception.Message)"
            }
        })
        
        $testTab.Controls.Add($funcButton)
        $funcButtonY += $buttonSpacing
    }
    
    # Add separator
    $separatorY = $funcButtonY + 10
    $separator = New-Object System.Windows.Forms.Label
    $separator.Location = New-Object System.Drawing.Point(20, $separatorY)
    $separator.Size = New-Object System.Drawing.Size(200, 2)
    $separator.BorderStyle = "Fixed3D"
    $testTab.Controls.Add($separator)
    
    # Back button to return to main test menu
    $backButtonY = $separatorY + 15
    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(20, $backButtonY)
    $backButton.Size = New-Object System.Drawing.Size(200, 35)
    $backButton.Text = "← Back to Test Menu"
    $backButton.Add_Click({
        Build-TestTabMenu
    })
    $testTab.Controls.Add($backButton)
    
    # Recreate log and results sections
    Build-TestLogSection -parentTab $testTab
}

# Build the test tab menu (main level)
function Build-TestTabMenu {
    # Clear test tab
    $testTab.Controls.Clear()
    
    # Build button panel - LEFT SIDE
    $testButtonLabel = New-Object System.Windows.Forms.Label
    $testButtonLabel.Location = New-Object System.Drawing.Point(20, 20)
    $testButtonLabel.Size = New-Object System.Drawing.Size(200, 20)
    $testButtonLabel.Text = "Test Dashboards:"
    $testButtonLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $testTab.Controls.Add($testButtonLabel)
    
    # Create test buttons
    $testButtonY = 50
    foreach ($dashboard in $dashboards) {
        $button = New-Object System.Windows.Forms.Button
        $button.Location = New-Object System.Drawing.Point(20, $testButtonY)
        $button.Size = New-Object System.Drawing.Size(200, 35)
        $button.Text = $dashboard
        $button.Tag = $dashboard
        
        # Add click event to show submenu
        $button.Add_Click({
            $dashName = $this.Tag
            Show-TestSubmenu -dashboardName $dashName -testTab $testTab -buttonSpacing 45
        })
        
        $testTab.Controls.Add($button)
        $testButtonY += 45
    }
    
    # Add separator
    $separatorY = $testButtonY + 10
    $separator = New-Object System.Windows.Forms.Label
    $separator.Location = New-Object System.Drawing.Point(20, $separatorY)
    $separator.Size = New-Object System.Drawing.Size(200, 2)
    $separator.BorderStyle = "Fixed3D"
    $testTab.Controls.Add($separator)
    
    # Back button (placeholder for navigation)
    $backButtonY = $separatorY + 15
    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(20, $backButtonY)
    $backButton.Size = New-Object System.Drawing.Size(200, 35)
    $backButton.Text = "← Back"
    $backButton.Add_Click({
        $timestamp = Get-Date -Format "HH:mm:ss"
        Add-TestLog "[$timestamp] Back button pressed"
        [System.Windows.Forms.MessageBox]::Show("Back button - implement navigation logic here", "Back", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })
    $testTab.Controls.Add($backButton)
    
    # Recreate log and results sections
    Build-TestLogSection -parentTab $testTab
}

# Build log and results section for test tab
function Build-TestLogSection {
    param([object]$parentTab)
    
    # Log Console Label
    $testLogLabel = New-Object System.Windows.Forms.Label
    $testLogLabel.Location = New-Object System.Drawing.Point(250, 20)
    $testLogLabel.Size = New-Object System.Drawing.Size(600, 20)
    $testLogLabel.Text = "Activity Log:"
    $testLogLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $parentTab.Controls.Add($testLogLabel)
    
    # Log Console (Top Right)
    $script:testLogBox = New-Object System.Windows.Forms.TextBox
    $script:testLogBox.Multiline = $true
    $script:testLogBox.ScrollBars = "Vertical"
    $script:testLogBox.Location = New-Object System.Drawing.Point(250, 45)
    $script:testLogBox.Size = New-Object System.Drawing.Size(580, 220)
    $script:testLogBox.ReadOnly = $true
    $script:testLogBox.Font = New-Object System.Drawing.Font("Consolas", 9)
    $script:testLogBox.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $parentTab.Controls.Add($script:testLogBox)
    
    # Results Console Label
    $testResultsLabel = New-Object System.Windows.Forms.Label
    $testResultsLabel.Location = New-Object System.Drawing.Point(250, 280)
    $testResultsLabel.Size = New-Object System.Drawing.Size(600, 20)
    $testResultsLabel.Text = "Results:"
    $testResultsLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $parentTab.Controls.Add($testResultsLabel)
    
    # Results Console (Bottom Right)
    $script:testResultsBox = New-Object System.Windows.Forms.TextBox
    $script:testResultsBox.Multiline = $true
    $script:testResultsBox.ScrollBars = "Vertical"
    $script:testResultsBox.Location = New-Object System.Drawing.Point(250, 305)
    $script:testResultsBox.Size = New-Object System.Drawing.Size(580, 220)
    $script:testResultsBox.ReadOnly = $true
    $script:testResultsBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $script:testResultsBox.BackColor = [System.Drawing.Color]::White
    $parentTab.Controls.Add($script:testResultsBox)
}

# Get all .ps1 files for the dashboards
function Import-Dashboards {
    param([string]$path)
    
    if (Test-Path $path) {
        Get-ChildItem -Path $path -Filter "*.ps1" | ForEach-Object {
            . $_.FullName
            Write-Host "Loaded: $($_.Name)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "Warning: Dashboard path not found: $path" -ForegroundColor Yellow
    }
}

function Import-EnvFile {
    param([string]$path)
    
    if (Test-Path $path) {
        Get-Content $path | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                # Remove quotes if present
                $value = $value -replace '^["'']|["'']$', ''
                [Environment]::SetEnvironmentVariable($key, $value, "Process")
                Write-Host "Loaded env variable: $key" -ForegroundColor Cyan
            }
        }
    } else {
        Write-Host "Warning: .env file not found: $path" -ForegroundColor Yellow
    }
}

<# ===================== Build application window ===================== #>
# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Dashboard Device Count Tool"
$form.Size = New-Object System.Drawing.Size(900, 650)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# === TAB CONTROL ===
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(10, 10)
$tabControl.Size = New-Object System.Drawing.Size(860, 590)
$form.Controls.Add($tabControl)

# === MAIN TAB ===
$mainTab = New-Object System.Windows.Forms.TabPage
$mainTab.Text = "Main"
$tabControl.Controls.Add($mainTab)

# === TEST TAB ===
$testTab = New-Object System.Windows.Forms.TabPage
$testTab.Text = "Test"
$tabControl.Controls.Add($testTab)

<# ===================== MAIN TAB CONTENT ===================== #>
# Build button panel - LEFT SIDE
$mainButtonLabel = New-Object System.Windows.Forms.Label
$mainButtonLabel.Location = New-Object System.Drawing.Point(20, 20)
$mainButtonLabel.Size = New-Object System.Drawing.Size(200, 20)
$mainButtonLabel.Text = "Dashboards:"
$mainButtonLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$mainTab.Controls.Add($mainButtonLabel)

# Create buttons
$buttonY = 50
$buttonSpacing = 45

# Automatically load dashboard names from dashboards/ directory
$dashboards = @()
if (Test-Path $dashboardsPath) {
    $dashboards = Get-ChildItem -Path $dashboardsPath -Filter "*.ps1" | ForEach-Object {
        $_.BaseName  # Get filename without .ps1 extension
    }
} else {
    Write-Host "Warning: Dashboards directory not found. Using default list." -ForegroundColor Yellow
    $dashboards = @("NinjaOne", "SentinelOne", "Cove", "ScreenConnect", "O365")
}

foreach ($dashboard in $dashboards) {
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point(20, $buttonY)
    $button.Size = New-Object System.Drawing.Size(200, 35)
    $button.Text = $dashboard
    $button.Tag = $dashboard
    
    # Add click event
    $button.Add_Click({
        $dashName = $this.Tag
        $timestamp = Get-Date -Format "HH:mm:ss"
        
        # Log the action
        Add-MainLog "[$timestamp] Pulling data from $dashName..."
        Write-Host "Button $dashName successful" -ForegroundColor Green
        
        # Execute the pull
        $result = Test-Run -buttonName $dashName
        
        # Display result
        Add-MainResult $result
        Add-MainLog "[$timestamp] Pull completed for $dashName"
    })
    
    $mainTab.Controls.Add($button)
    $buttonY += $buttonSpacing
}

# Add separator at the bottom of the button panel
$separatorY = $buttonY + 10
$mainSeparator = New-Object System.Windows.Forms.Label
$mainSeparator.Location = New-Object System.Drawing.Point(20, $separatorY)
$mainSeparator.Size = New-Object System.Drawing.Size(200, 2)
$mainSeparator.BorderStyle = "Fixed3D"
$mainTab.Controls.Add($mainSeparator)

# Reset button at the bottom
$resetButtonY = $separatorY + 15
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Location = New-Object System.Drawing.Point(20, $resetButtonY)
$resetButton.Size = New-Object System.Drawing.Size(200, 35)
$resetButton.Text = "⟳ Reset"
$resetButton.Add_Click({
    $result = [System.Windows.Forms.MessageBox]::Show("This will clear all console windows and refresh the application. Continue?", "Reset", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        # Clear main console windows
        $mainLogBox.Clear()
        $mainResultsBox.Clear()
        
        # Reinitialize main log
        Add-MainLog "Application reset. Console windows cleared."
        Add-MainLog "================================================================"
        
        $timestamp = Get-Date -Format "HH:mm:ss"
        Add-MainLog "[$timestamp] Reset completed successfully"
    }
})
$mainTab.Controls.Add($resetButton)

# Log Console Label
$mainLogLabel = New-Object System.Windows.Forms.Label
$mainLogLabel.Location = New-Object System.Drawing.Point(250, 20)
$mainLogLabel.Size = New-Object System.Drawing.Size(600, 20)
$mainLogLabel.Text = "Activity Log:"
$mainLogLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$mainTab.Controls.Add($mainLogLabel)

# Log Console (Top Right)
$mainLogBox = New-Object System.Windows.Forms.TextBox
$mainLogBox.Multiline = $true
$mainLogBox.ScrollBars = "Vertical"
$mainLogBox.Location = New-Object System.Drawing.Point(250, 45)
$mainLogBox.Size = New-Object System.Drawing.Size(580, 220)
$mainLogBox.ReadOnly = $true
$mainLogBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$mainLogBox.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$mainTab.Controls.Add($mainLogBox)

# Results Console Label
$mainResultsLabel = New-Object System.Windows.Forms.Label
$mainResultsLabel.Location = New-Object System.Drawing.Point(250, 280)
$mainResultsLabel.Size = New-Object System.Drawing.Size(600, 20)
$mainResultsLabel.Text = "Results:"
$mainResultsLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$mainTab.Controls.Add($mainResultsLabel)

# Results Console (Bottom Right)
$mainResultsBox = New-Object System.Windows.Forms.TextBox
$mainResultsBox.Multiline = $true
$mainResultsBox.ScrollBars = "Vertical"
$mainResultsBox.Location = New-Object System.Drawing.Point(250, 305)
$mainResultsBox.Size = New-Object System.Drawing.Size(580, 220)
$mainResultsBox.ReadOnly = $true
$mainResultsBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$mainResultsBox.BackColor = [System.Drawing.Color]::White
$mainTab.Controls.Add($mainResultsBox)

<# ===================== TEST TAB CONTENT ===================== #>
# Test tab will be built dynamically, so we just initialize it here
# The actual content is built by Build-TestTabMenu function

<# ===================== Helper Functions ===================== #>
# Print to log - Main Tab
function Add-MainLog {
    param([string]$message)
    $mainLogBox.AppendText("$message`r`n")
}

# Print to results - Main Tab
function Add-MainResult {
    param([string]$message)
    $mainResultsBox.AppendText("$message`r`n")
}

# Print to log - Test Tab
function Add-TestLog {
    param([string]$message)
    if ($script:testLogBox) {
        $script:testLogBox.AppendText("$message`r`n")
    }
}

# Print to results - Test Tab
function Add-TestResult {
    param([string]$message)
    if ($script:testResultsBox) {
        $script:testResultsBox.AppendText("$message`r`n")
    }
}

# Build the test tab initial menu
Build-TestTabMenu

# Add initial messages
Add-MainLog "Application started. Select a dashboard to pull device counts."
Add-MainLog "================================================================"
Add-TestLog "Test mode active. Select a dashboard to test individual functions."
Add-TestLog "================================================================"

# Show the form
[void]$form.ShowDialog()
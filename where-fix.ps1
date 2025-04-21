# Smart Where Function for PowerShell
# This function intelligently selects between Windows where.exe and PowerShell's Where-Object
# based on context and usage pattern.

# Remove the existing 'where' alias if it exists
Remove-Item Alias:where -Force -ErrorAction SilentlyContinue

function where {
    # Check if we're expecting input from pipeline
    if ($MyInvocation.ExpectingInput) {
        # Being used in pipeline - behave as Where-Object
        $input | Microsoft.PowerShell.Core\Where-Object @args
    }
    # Check if first argument matches pattern for executable
    elseif ($args.Count -gt 0 -and $args[0] -match '\.exe$') {
        # Looking for an executable - use Windows where.exe
        & "$env:SystemRoot\System32\where.exe" @args
    }
    # Optional: Check for additional executable types
    elseif ($args.Count -gt 0 -and $args[0] -match '\.(dll|cmd|bat|ps1)$') {
        # Looking for other executable type - use Windows where.exe
        & "$env:SystemRoot\System32\where.exe" @args
    }
    else {
        # Default: behave like original Where-Object for any other case
        Microsoft.PowerShell.Core\Where-Object @args
    }
}

# Usage Examples:
# 
# Find an executable:
#   where cl.exe
#
# Use in pipeline (acts as Where-Object):
#   Get-Process | where { $_.CPU -gt 10 }
#
# Add this function to your PowerShell profile to make it persistent:
# 1. Open your profile: notepad $PROFILE
# 2. Add this function to your profile
# 3. Save the file and reload: . $PROFILE

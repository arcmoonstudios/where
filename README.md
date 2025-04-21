# PowerShell Smart Where Function

## Overview

The PowerShell Smart Where Function is an intelligent wrapper that resolves the conflict between Windows' native `where.exe` utility and PowerShell's `Where-Object` cmdlet (which uses `where` as an alias). This solution provides context-aware behavior that automatically selects the appropriate command based on usage pattern.

## Problem Statement

In PowerShell, typing `where` normally invokes the `Where-Object` cmdlet, which filters objects in a pipeline. However, Windows also has a utility called `where.exe` that locates executable files in the system path—similar to the Unix/Linux `which` command.

This creates confusion when you want to use `where` to find executable paths, as you would in Command Prompt.

## Solution

This function intelligently determines which "where" you intend to use based on context:

- When used in a pipeline: Acts as PowerShell's `Where-Object`
- When looking for executable files: Uses Windows' `where.exe` utility
- For all other cases: Defaults to PowerShell's `Where-Object`

## Installation

### Option 1: Add to your PowerShell Profile (Recommended)

1. Open your PowerShell profile in a text editor:

```powershell
notepad $PROFILE
```

2. If prompted that the file doesn't exist, choose to create it.

3. Add the function to your profile:

```powershell
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
```

4. Save the file and reload your profile:

```powershell
. $PROFILE
```

### Option 2: Temporary Use

Copy and paste the function directly into your PowerShell session. Note that this will only last for the current session.

## Usage Examples

### Finding Executables (using Windows where.exe)

```powershell
# Find all instances of notepad.exe in your PATH
where notepad.exe

# Find a compiler
where cl.exe

# Find a build tool
where ninja.exe
```

### Filtering Objects (using PowerShell's Where-Object)

```powershell
# List running processes with more than 50MB of memory usage
Get-Process | where { $_.WorkingSet -gt 50MB }

# List stopped services
Get-Service | where { $_.Status -eq 'Stopped' }
```

## Customization

You can customize the function to recognize additional file extensions by modifying the pattern match conditions. The current implementation already handles:
- `.exe` - Executable files
- `.dll` - Dynamic Link Libraries
- `.cmd` and `.bat` - Batch files  
- `.ps1` - PowerShell scripts

## Troubleshooting

If you encounter issues:

1. **Original `where` alias still exists**: Verify the alias was removed with:
   ```powershell
   Get-Alias where -ErrorAction SilentlyContinue
   ```

2. **Function not persisting between sessions**: Ensure your profile is being loaded automatically. Check your PowerShell startup with:
   ```powershell
   $profile
   Test-Path $profile
   ```

3. **Restore default behavior**: To revert back to PowerShell's default behavior:
   ```powershell
   Remove-Item function:where -ErrorAction SilentlyContinue
   New-Alias -Name where -Value Where-Object -Force
   ```

## License

This script is provided under the MIT License. Feel free to modify and distribute as needed.

## Credits

This solution was developed by Lord Xyn, to address a common PowerShell usability issue when working with development tools and executables in Windows environments.

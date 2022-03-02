Function New-PinnedItem {
    [CmdletBinding()]
    param (
        [ValidateScript( { $_.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -eq -1 })]
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(Mandatory, ParameterSetName = 'Command')]
        [String]$Name,
        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [String]$Path,
        [Parameter(Mandatory, ParameterSetName = 'Command')]
        [scriptblock]$Command,
        [ValidateSet('Normal', 'Minimized', 'Maximized')]
        [String]$WindowStyle = 'Normal',
        [String]$Arguments,
        [String]$Description,
        [String]$Hotkey,
        [String]$IconLocation,
        [Switch]$RunAsAdmin,
        [String]$WorkingDirectory,
        [String]$RelativePath
    )

    $pinHandler = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.taskbarpin" -Name "ExplorerCommandHandler"
    New-Item -Path "HKCU:Software\Classes\*\shell\pin" -Force | Out-Null
    Set-ItemProperty -LiteralPath "HKCU:Software\Classes\*\shell\pin" -Name "ExplorerCommandHandler" -Type String -Value $pinHandler

    if ($PSCmdlet.ParameterSetName -eq 'Command') {
        #$Path = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
        $Path = "powershell.exe"
        $Arguments = ('-NoProfile -Command "&{{{0}}}"' -f ($Command.ToString().Trim("`r`n") -replace "`r`n", ';'))
        if (!$PsBoundParameters.ContainsKey('WindowStyle')) {
            $WindowStyle = 'Minimized'
        }
    }
    $NoExtension = [System.IO.Path]::GetExtension($path) -eq ""    
    if (!(Test-Path -Path $Path)) {
        if ($NoExtension) {
            $Path = "$Path.exe"
            
        }
        $Found = $False
        $ShortName = [System.IO.Path]::GetFileNameWithoutExtension($path)
        # testing against installed programs (Registry)
        $loc = Get-ChildItem HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
        $names = ($loc | foreach-object { Get-ItemProperty $_.PsPath }).Where( { ![String]::IsNullOrWhiteSpace($_.InstallLocation) })
        $InstallLocations1, $InstallLocations2 = $names.Where( { $_.DisplayName -Like "*$ShortName*" }, 'split') 
        $InstallLocations1 = $InstallLocations1 | Select -ExpandProperty InstallLocation
        $InstallLocations2 = $InstallLocations2 | Select -ExpandProperty InstallLocation
        Foreach ($InsLoc in $InstallLocations1) {
            if (Test-Path -Path "$Insloc\$path") {
                $Path = "$Insloc\$path"
                $Found = $true
                break
            }
        }
        if (! $found) {
            $Result = $env:Path.split(';').where( { Test-Path -Path "$_\$Path" }, 'first') 
            if ($Result.count -eq 1) { $Found = $true }
        }

        # Processing remaining install location (less probable outcome)
        if (! $found) {
            Foreach ($InsLoc in $InstallLocations2) {
                if (Test-Path -Path "$Insloc\$path") {
                    $Path = "$Insloc\$path"
                    $Found = $true
                    exit for
                }
            }
        }

        if (!$found) {
            Write-Error -Message "The path $Path does not exist"
            return 
        }

    }


    if ($PSBoundParameters.ContainsKey('Name') -eq $false) {
        $Name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    }

    $TempFolderName = "tmp$((48..57 + 97..122| get-random -Count 4 |% {[char][byte]$_}) -join '')"
    $TempFolderPath = "$env:temp\$TempFolderName"
    $ShortcutPath = "$TempFolderPath\$Name.lnk"
    [Void](New-Item -ItemType Directory -Path $TempfolderPath)


    if ($Path.EndsWith(".lnk")) {
        Copy-Item -Path $Path -Destination $ShortcutPath
        $obj = New-Object -ComObject WScript.Shell 
        $link = $obj.CreateShortcut($ShortcutPath) 
    }
    else {
        $obj = New-Object -ComObject WScript.Shell 
        $link = $obj.CreateShortcut($ShortcutPath) 
        $link.TargetPath = $Path
    }

    switch ($WindowStyle) {
        'Minimized' { $WindowstyleID = 7 }
        'Maximized' { $WindowstyleID = 3 }
        'Normal' { $WindowstyleID = 1 }
    }

    $link.Arguments = $Arguments
    $Link.Description = $Description
    if ($PSBoundParameters.ContainsKey('IconLocation')) { $link.IconLocation = $IconLocation }
    $link.Hotkey = "$Hotkey"
    $link.WindowStyle = $WindowstyleID
    if ($PSBoundParameters.ContainsKey('WorkingDirectory')) { $link.WorkingDirectory = $WorkingDirectory }
    if ($PSBoundParameters.ContainsKey('RelativePath')) { $link.RelativePath = $RelativePath }
    $link.Save()

    if ($RunAsAdmin) {
        $bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)
        $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
        [System.IO.File]::WriteAllBytes($ShortcutPath, $bytes)
    }

    $Shell = New-Object -ComObject "Shell.Application"
    $Folder = $Shell.Namespace((Get-Item $ShortcutPath).DirectoryName)
    $Item = $Folder.ParseName((Get-Item $ShortcutPath).Name)
    $Item.InvokeVerb("pin")

    Remove-Item -LiteralPath  "HKCU:Software\Classes\*\shell\pin\" -Recurse   
    Remove-item -path $ShortcutPath
    Remove-Item -Path $TempFolderPath 
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$shell)
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$obj)
}

Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Recurse -Force
Stop-Process -Processname Explorer -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Force
New-PinnedItem -Path 'C:\Program Files\Google\Chrome\Application\chrome.exe'
New-PinnedItem -Path 'Explorer'

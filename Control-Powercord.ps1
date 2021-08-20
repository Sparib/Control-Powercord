param(
    [String] $Action,
    [String] $Secondary,
    [String] $Tertiary
)

function isURIWeb($address) {
	$uri = $address -as [System.URI]
	$uri.AbsoluteURI -ne $null -and $uri.Scheme -match '[http|https]'
}

function getConsole() {
    if ($host.Name -ne ‘ConsoleHost’)
    {
      write-host -ForegroundColor Red "This script runs only in the console host. You cannot run this script in $($host.Name)."
      exit -1
    }

    # Initialize string builder.
    $textBuilder = new-object system.text.stringbuilder

    # Grab the console screen buffer contents using the Host console API.
    $bufferWidth = $host.ui.rawui.BufferSize.Width
    $bufferHeight = $host.ui.rawui.CursorPosition.Y
    $rec = new-object System.Management.Automation.Host.Rectangle 0,0,($bufferWidth – 1),$bufferHeight
    $buffer = $host.ui.rawui.GetBufferContents($rec)

    # Iterate through the lines in the console buffer.
    for($i = 0; $i -lt $bufferHeight; $i++)
    {
      for($j = 0; $j -lt $bufferWidth; $j++)
      {
        $cell = $buffer[$i,$j]
        $null = $textBuilder.Append($cell.Character)
      }
      $null = $textBuilder.Append("`r`n")
    }

    return $textBuilder.ToString() 
}

Write-Debug "Action: $Action"; Write-Debug "Secondary: $Secondary"; Write-Debug "Tertiary: $Tertiary";

$Actions = "plug", "unplug", "update", "update-all", "add";

if (-not $Actions.Contains($Action)) {
    Write-Error -Message "Action parameter must be one of the following: $Actions" -Category InvalidArgument; exit;
}

$PrevLoc = $(Get-Location);

try {
switch -Regex ($Action) {
    "update" {
        Set-Location "C:\Users\spari\Documents\Powercord" | Out-Null;
        git pull | Out-Null;
        Write-Host -ForegroundColor Green "`nPowercord successfully updated! Restart Discord for changes to take effect.";
    }
    "update-all" {
        Set-Location "C:\Users\spari\Documents\Powercord" | Out-Null;
        Write-Debug "Powercord : $(git pull)";

        $plugins = $(Get-ChildItem -Path "C:\Users\spari\Documents\Powercord\src\Powercord\plugins" -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName);

        foreach ($plugin in $plugins) {
            Set-Location $plugin.FullName;
            Write-Debug "$($plugin.FullName) : $(git pull)";
        }

        $themes = $(Get-ChildItem -Path "C:\Users\spari\Documents\Powercord\src\Powercord\themes" -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName);

        foreach ($theme in $themes) {
            Set-Location $theme.FullName;
            Write-Debug "$($theme.FullName) : $(git pull)";
        }

        Write-Host -ForegroundColor Green "`nSuccessfully force updated all plugins, themes, and Powercord! Restart Discord for changes to take effect.";
    }
    "(un)?plug" {
        Set-Location "C:\Users\spari\Documents\Powercord" | Out-Null;
        npm run $Action | Out-Null;
        Write-Host -ForegroundColor Green "`nPowercord successfully $($Action)ged! Restart Discord for changes to take effect.";
    }
    "add" {
        if ($Secondary -eq "") { Write-Error -Message "You must pass a second argument, either `"plugin`" or `"theme`"!" -Catergory InvalidArgument; }
        if ($Tertiary -eq "") { Write-Error -Message "You must pass a third argument, which must be a link!" -Category InvalidArgument; }
        if (-not $(isURIWeb($Tertiary))) { Write-Error -Message "The third argument must be a valid link!" -Category InvalidArgument; }

        if ($Secondary -eq "plugin" -or $Secondary -eq "theme") {
            Set-Location -Path "C:\Users\spari\Documents\Powercord\src\Powercord\$($Secondary)s" | Out-Null;
            git clone -q $Tertiary;

            Start-Sleep -Milliseconds 10

            $consoleLines = $(getConsole).Split("`n")

            if ($consoleLines[-2] | Select-String -Quiet -Pattern "^fatal: .*") {
                Write-Error -Message "See above error from git"
            } else {
                Write-Host -ForegroundColor Green "Plugin added! Refresh plugins in Discord.";
            }
        }
    }
    Default {
        Write-Error -Message "Someone fucked up the programming :D";
    }
}
} finally {
    Set-Location $PrevLoc | Out-Null;
}
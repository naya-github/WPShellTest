# 参照URL : https://qiita.com/voidProc/items/4f5de4a7ead70ab0731e

#$ErrorActionPreference = "Stop"

# Default settings
if ($MenuPreference -eq $null)
{
    $MenuPreference = @{
        ForegroundColor = "DarkGray"
        BackgroundColor = "Black"
        SelectionForegroundColor = "White"
        SelectionBackgroundColor = "Blue"
    }
}

$FgColor = $MenuPreference.ForegroundColor
$BgColor = $MenuPreference.BackgroundColor
$SelFgColor = $MenuPreference.SelectionForegroundColor
$SelBgColor = $MenuPreference.SelectionBackgroundColor
$rui = (Get-Host).UI.RawUI
$tmp_coord = New-Object System.Management.Automation.Host.Coordinates(0, 0)


function New-BgBuffer
{
    $rui.NewBufferCellArray(" ", "$($rui.ForegroundColor)", "$($rui.BackgroundColor)")
}

function New-Coord
{
    Param($x, $y)
    New-Object System.Management.Automation.Host.Coordinates($x, $y)
}

function New-Rect
{
    Param($left, $top, $right, $bottom)
    New-Object System.Management.Automation.Host.Rectangle($left, $top, $right, $bottom)
}

function Set-CursorPos
{
    Param($x, $y)
    $tmp_coord.X = $x
    $tmp_coord.Y = $y
    (Get-Host).UI.RawUI.CursorPosition = $tmp_coord
}

function Get-SubStringBytes
{
    Param($text, $start, $length)

    $encoding = [System.Text.Encoding]::GetEncoding("utf-8") # "Shift_JIS")
    $bytes = $encoding.GetBytes($text)
    $encoding.GetString($bytes, $start, $length)
}

function Write-Item
{
    Param(
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$W,
        [bool]$Select
    )

    Set-CursorPos $X $Y

    $buf = $rui.NewBufferCellArray($Text, "White", "Black")
    $len = $buf.Length
    if ($len -gt $W) {
        if ($buf[0, ($W-1)].BufferCellType -eq "Leading")
        {
            $Text = Get-SubStringBytes $Text 0 ($W-1)
            $len = $W - 1
        }
        else
        {
            $Text = Get-SubStringBytes $Text 0 $W
            $len = $W
        }
    }

    $Text = "$Text$(" " * [Math]::Max(0, $W - $len))"

    $fg, $bg = @( @( $FgColor, $BgColor ), @( $SelFgColor, $SelBgColor) )[[int]$Select]

    Write-Host $Text -ForegroundColor $fg -BackgroundColor $bg -NoNewline | Out-Host
}

function Show-Menu
{
    Param(
        [Parameter(ValueFromPipeline=$true)]
        [string[]]
        $Items,

        [int]
        $X = 0,

        [int]
        $Y = 1,

        [int]
        $W = 0,

        [string]
        $Cursor = " > ",

        [ScriptBlock]
        $OnInit = {},
        
        [ScriptBlock]
        $OnDraw = {
            Param($idx)
        },
        
        [ScriptBlock]
        $OnKeyPress = {
            Param($idx, $keyinfo)
            $idx, ""
        },
        
        [ScriptBlock]
        $OnClose = {},
        
        [switch]
        $Index
    )

    begin
    {
        $Script:MenuItems = New-Object System.Collections.Generic.List[string]
    }

    process
    {
        if ($null -ne $Items)
        {
            $Items | ForEach-Object { $MenuItems.Add($_) }
        }
    }

    end
    {
        if ($MenuItems.Count -eq 0)
        {
            return
        }

        $CursorSize = $rui.CursorSize
        #$rui.CursorSize = 0

        # Base position
        $base_y = $rui.CursorPosition.Y + $Y

        if (!$W) { $W = $rui.WindowSize.Width }
        $W = [Math]::Min($W, $rui.WindowSize.Width - $X)

        & $OnInit

        # Draw menu BG
        $menurect = New-Rect $X $base_y ($X + $W) ($base_y + $MenuItems.Count-1)

        # BG
        $bgbuf = New-BgBuffer
Write-Host "TITLE:AAAAAAAAAAAAAAA??"
        # Selected item
        $idx = 0
        $idxp = 0
        $cancel = $false

        # Cursor
        $cur = @( (" "*$Cursor.Length), $Cursor )

        # Scroll
        Set-CursorPos $X ($base_y + $MenuItems.Count)

        # Draw all
        $MenuItems | ForEach-Object { $i = 0 } {
            Write-Item "$($cur[0])$_" $X ($base_y + $i) $W $false
            $i++
        }

        :readkeyloop while ($true)
        {
            # Draw item
            Write-Item "$($cur[0])$($MenuItems[$idxp])" $X ($base_y + $idxp) $W $false
            Write-Item "$($cur[1])$($MenuItems[$idx])" $X ($base_y + $idx) $W $true

            Set-CursorPos $X ($base_y + $MenuItems.Count)

            . $OnDraw $idx

            $keyinfo = [Console]::ReadKey($true)

            $idxp = $idx
            $idx, $op = . $OnKeyPress $idx $keyinfo
            switch ($op.ToLower())
            {
                "select" {
                    break readkeyloop
                }

                "cancel" {
                    $cancel = $true
                    break readkeyloop
                }
            }

            switch ($keyinfo.Key)
            {
                "UpArrow" {
                    $idxp = $idx
                    if (--$idx -lt 0) { $idx = $MenuItems.Count-1 }
                }
                
                "DownArrow" {
                    $idxp = $idx
                    if (++$idx -ge $MenuItems.Count) { $idx = 0 }
                }
                
                "Enter" {
                    break readkeyloop
                }
                
                "Escape" {
                    $cancel = $true
                    break readkeyloop
                }
            }
        }

        . $OnClose

        # Clear menu
#        $rui.SetBufferContents($menurect, $bgbuf)
$clearrect = New-Rect $X ($base_y-1) ($X + $W) ($base_y + $MenuItems.Count)
$rui.SetBufferContents($clearrect, $bgbuf)

        # Back Cursor
        Set-CursorPos 0 ($base_y - $Y)
        $rui.CursorSize = $CursorSize

        # Result
        if (-not $cancel)
        {
            if ($Index)
            {
                $idx
            }
            else {
                $MenuItems[$idx]
            }
        }
    }
}

#Set-Alias -Name menu -Value Show-Menu
Set-Alias -Name SelectMenuUI -Value Show-Menu

#Export-ModuleMember -Function Show-Menu -Alias menu
Export-ModuleMember -Function Show-Menu -Alias SelectMenuUI

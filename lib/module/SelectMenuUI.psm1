# 参照URL : https://qiita.com/voidProc/items/4f5de4a7ead70ab0731e

# $ErrorActionPreference = "Inquire" #"Stop"

$RawUI = (Get-Host).UI.RawUI

function New-BgBuffer {
    $RawUI.NewBufferCellArray(" ", "$($RawUI.ForegroundColor)", "$($RawUI.BackgroundColor)")
}

function New-Coord($x, $y) {
    New-Object System.Management.Automation.Host.Coordinates($x, $y)
}

function New-Rect($left, $top, $right, $bottom) {
    New-Object System.Management.Automation.Host.Rectangle($left, $top, $right, $bottom)
}

function Set-CursorPos($x, $y) {
    $tmp = New-Object System.Management.Automation.Host.Coordinates(0, 0)
    $tmp.X = $x
    $tmp.Y = $y
    (Get-Host).UI.RawUI.CursorPosition = $tmp
}

function Get-SubStringBytes($text, $start, $length) {
    $encoding = [System.Text.Encoding]::GetEncoding("utf-8") # "Shift_JIS")
    $bytes = $encoding.GetBytes($text)
    $encoding.GetString($bytes, $start, $length)
}

function Write-Item( [string]$Text, [int]$X, [int]$Y, [int]$W, [bool]$Select) {
    Set-CursorPos $X $Y

    $buf = $RawUI.NewBufferCellArray($Text, "White", "Black")
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

    $fg, $bg = @( @("DarkGray", "Black"), @("White", "Blue") )[[int]$Select]

    Write-Host $Text -ForegroundColor $fg -BackgroundColor $bg -NoNewline | Out-Host
}

function SelectMenuUI
{
    Param(
        [Parameter(ValueFromPipeline=$true)]
        [string[]]
        $Items,
        
        [string]
        $Title,

        [switch]
        $Index
    )

    begin
    {
       $X = 0
       $Y = 1
       $W = 0
       $Cursor = "=> "
       $Script:MenuItems = New-Object System.Collections.Generic.List[string]
    }

    process
    {
        if ($null -ne $Items) {
            $Items | ForEach-Object { $MenuItems.Add($_) }
        }
    }

    end
    {
        if ($MenuItems.Count -eq 0) {
            return
        }

        $CursorSize = $RawUI.CursorSize

        # Base position
        $base_y = $RawUI.CursorPosition.Y + $Y

        $wmax = $RawUI.WindowSize.Width - $X
        if (($W -le 0) -or ($wmax -lt $W)) {
            $W = $wmax
        }

        # title.
        Write-Host $Title

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

            $keyinfo = [Console]::ReadKey($true)

            $idxp = $idx

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

        # Clear menu
        $clearrect = New-Rect $X ($base_y-1) ($X + $W) ($base_y + $MenuItems.Count)
        $bgbuf = New-BgBuffer
        $RawUI.SetBufferContents($clearrect, $bgbuf)

        # Back Cursor
        Set-CursorPos 0 ($base_y - $Y)
        $RawUI.CursorSize = $CursorSize

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

#Set-Alias -Name menu -Value SelectMenuUI
#Export-ModuleMember -Function SelectMenuUI -Alias menu
Export-ModuleMember -Function SelectMenuUI

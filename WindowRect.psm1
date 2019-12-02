# 参照URL : https://qiita.com/yumura_s/items/f6fa9dbeb5c6c4b6e4fb

# window
# --

filter Import-WindowRect ($Path)
{
    Import-Csv $Path | %{Move-WindowRect $_.Name $_.X $_.Y $_.Width $_.Height}
}

filter Export-WindowRect ($Path)
{
    Get-Process -Name * | %{Get-WindowRect $_.Name} | Export-Csv $Path -Encoding UTF8 -NoTypeInformation
}

filter Move-WindowRect
{
  Param
  (
    [String]$Name,
    [Int]$X = 0,
    [Int]$Y = 0,
    [Int]$Width = 400,
    [Int]$Height = 300
  )

  Get-Process -Name $Name | ?{$_.MainWindowTitle -ne ""} | %{
    [Win32]::MoveWindow($_.MainWindowHandle, $X, $Y, $Width, $Height, $true)
  } | Out-Null
}

filter Get-WindowRect ([String]$Name)
{
  Get-Process -Name $Name | ?{$_.MainWindowTitle -ne ""} | %{
    $rc = New-Object RECT
    [Win32]::GetWindowRect($_.MainWindowHandle, [ref]$rc) | Out-Null
    ConvertTo-Rect2 $_.Name $rc
  }
}

# desktop
# --

function GetAppliedDPI
{
    $DPISetting = (Get-ItemProperty 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name AppliedDPI).AppliedDPI
    switch ($DPISetting)
    {
        96 {$ActualDPI = 100}
        120 {$ActualDPI = 125}
        144 {$ActualDPI = 150}
        192 {$ActualDPI = 200}
    }

    Write-Output $ActualDPI
}

function GetDesktopRect
{
    [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $Size = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
    $rct = New-Object RECT

    $rct.Left = 0
    $rct.Top = 0
    $rct.Right = $Size.Width
    $rct.Bottom = $Size.Height

    Write-Output $rct
}

# Helper
# ------

function ConvertTo-Rect2 ($name, $rc)
{
    process
    {
        $rc2 = New-Object RECT2

        $rc2.Name = $name
        $rc2.X = $rc.Left
        $rc2.Y = $rc.Top
        $rc2.Width = $rc.Right - $rc.Left
        $rc2.Height = $rc.Bottom - $rc.Top

        Write-Output $rc2
    }
}

# C#
# --

Add-Type @"
  using System;
  using System.Runtime.InteropServices;

  public class Win32 {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
  }

  public struct RECT
  {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
  }

  public struct RECT2
  {
    public string Name;
    public int X;
    public int Y;
    public int Width;
    public int Height;
  }
"@
# 参照URL : https://qiita.com/yumura_s/items/f6fa9dbeb5c6c4b6e4fb

filter Import-WindowRect ($Path)
{Import-Csv $Path | %{Move-WindowRect $_.Name $_.X $_.Y $_.Width $_.Height}}

filter Export-WindowRect ($Path)
{Get-Process -Name * | %{Get-WindowRect $_.Name} | Export-Csv $Path -Encoding UTF8 -NoTypeInformation}

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


# Helper
# ------

filter ConvertTo-Rect2 ($name, $rc)
{
  $rc2 = New-Object RECT2

  $rc2.Name = $name
  $rc2.X = $rc.Left
  $rc2.Y = $rc.Top
  $rc2.Width = $rc.Right - $rc.Left
  $rc2.Height = $rc.Bottom - $rc.Top

  $rc2
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
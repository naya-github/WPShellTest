# https://soma-engineering.com/coding/powershell/use-readhost-command/2018/05/24/

# $ErrorActionPreference = "Inquire" #"Stop"

# https://sevenb.jp/wordpress/ura/2017/04/03/powershellenum%E3%82%92%E5%AE%9A%E7%BE%A9%E3%81%99%E3%82%8B/
Add-Type -TypeDefinition @"
   public enum InputUI_Type
   {
      UI_Password,
      UI_DateTime,
      UI_Length,
      UI_Range,
      UI_YesNo,
      UI_None,
   }
"@

function InputUI {
    Pram(
        $msg,
        [InputUI_Type]$type=[InputUI_Type]::UI_None,
        $min = $null,
        $max = $null
    )
    
    if ($type -eq [InputUI_Type]::UI_None) {
        $i = Read-Host $msg
        Write-Output $i
        return
    }
    if ($type -eq [InputUI_Type]::UI_DateTime) {
        $msg += "(format:yyy/mm/dd)"
        $date = $null
        do {
            $f = $true
            try {
                [datetime]$date = Read-Host $msg
            } catch [Exception] {
                $f = $false
            }
         } while ($f -eq $false)
         Write-Output $date
         return
    }
$password = Read-Host "パスワードを入力してください。" -AsSecureString
$password
[ValidateLength(6,8)]$username = [String](Read-Host "ユーザー名を入力してください。")
$username
[ValidateRange(1,9999)]$staff_id = [int](Read-Host "社員番号を入力してください。")
$staff_id
[ValidateSet("y","Y","n","N")]$responce = Read-Host "この PC はノートパソコンですか？(y か n を入力して Enter 押下)"
$responce
}

Export-ModuleMember -Function *
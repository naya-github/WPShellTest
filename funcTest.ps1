<#
.SYNOPSIS
概要を書きます

.DESCRIPTION
説明を書きます

.EXAMPLE
具体的な例と解説を書きます(複数記述可)

.PARAMETER 引数名
引数の説明を書きます(複数記述可)

PARAMETER には CommonParameters について説明が追加されるので
「<CommonParameters> はサポートしていません」と書いておくと良いかも

.LINK
関連するリンクの URL を書きます
https://technet.microsoft.com/ja-jp/library/hh847834.aspx
#>
Set-StrictMode -Version 5.0 # -Version Latest

function global:var_dump($prm1) {
    $prm1 | ForEach-object -Process { Write-Host $_ }
}

function global:printf {
    if($args -is [array]) {
        if($args.Length -ge 2) {
            $prm1 = $args[0];
            $prm2 = $args[1..($args.Length-1)]
            Write-Host ($prm1 -f $prm2)
        }
        else {
            Write-Host $args[0]
        }
    }
    else {
        Write-Host $args
    }
}



#------------------
# メモ書き...
#------------------

# [例] 戻り値を一定の型にするPowerShell特有の処理
function hoge() {
    $files = Get-ChildItem -Path "C:¥*.txt"
    if ($files -eq $null) {
        $files = @()
    }
    if ($files -isnot [System.Object[]]) {
        $files = , $files
    }
    return , $files
}

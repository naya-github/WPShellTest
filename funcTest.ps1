<#
.SYNOPSIS
ここに概要を書きます

.DESCRIPTION
ここに説明を書きます

.EXAMPLE
ここに具体的な引数の例と解説を書きます(複数記述可)

.EXAMPLE
ここに具体的な引数の例と解説を書きます(複数記述可)

.PARAMETER 引数名
ここら引数の説明を書きます(複数記述可)

.PARAMETER 引数名
ここら引数の説明を書きます(複数記述可)

PARAMETER には CommonParameters について説明が勝手に追加されるので
「<CommonParameters> はサポートしていません」と書いておくと良いかもしれません。

.LINK
関連するリンクの URL を書きます
http://www.vwnet.jp/Windows/PowerShell/SupportGetHelp.htm
#>
Set-StrictMode -Version 5.1 #Latest

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


function global:GetLatestMatchedCommitID([string]$branchName1,[string]$branchName2) {
<#
.SYNOPSIS
    二つのブランチLogから一致する最新のSHA-1を１個取得.
.DESCRIPTION
    二つのブランチLogから一致する最新のSHA-1を１個取得.
.EXAMPLE
    ここに具体的な引数の例と解説を書きます(複数記述可)

.PARAMETER branchName1
    [git branch 名] RemoteName/BranchName (origin/develop)
.PARAMETER branchName2
    [git branch 名] RemoteName/BranchName (origin/master)
.OUTPUTS
    [git commit sha-1 hash] 文字列.
#>
    $a = git log --format=%T $branchName1
    $b = git log --format=%T $branchName2
    foreach( $item in $b ) {
        $index = [Array]::IndexOf($a,$item)
        if($index -cge 0) {
            Write-Output $a[$index]
            return
        }
    }
    Write-Output ""
    return
}


function global:GetAllMatchedCommitID([string]$branchName1,[string]$branchName2) {
<#
.SYNOPSIS
    二つのブランチLogから一致するSHA-1を全て取得.
.DESCRIPTION
    二つのブランチLogから一致するSHA-1を全て取得.
.EXAMPLE
    ここに具体的な引数の例と解説を書きます(複数記述可)

.PARAMETER branchName1
    [git branch 名] RemoteName/BranchName (origin/develop)
.PARAMETER branchName2
    [git branch 名] RemoteName/BranchName (origin/master)
.OUTPUTS
    [git commit sha-1 hash] 配列.
#>
    $a = git log --format=%T $branchName1
    $b = git log --format=%T $branchName2
    $c = $b | Where-Object { $a -ccontains $_ }
    $c | foreach{ Write-Output $_ }
}
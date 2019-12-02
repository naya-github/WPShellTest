Set-StrictMode -Version 5.0 # -Version Latest


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
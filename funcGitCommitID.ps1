using module ".\ProgressUI.psm1"

Set-StrictMode -Version 5.0 # -Version Latest


function global:GetFirstMatchedCommitID
{
    Param(
		[string]$branchName,
        [string]$originBranchName = ""
	)
    $max = 10
    $hash = @{}
    $backup = @{}

    $count = 0
    $maxcount = 0
    $pui = [ProgressUI]::New()
    $pui.BeginUI(0x8000, ("["+$branchName+"] Git-Log 検索"))
    do {
        $pui.UpdateUI("s1. Get-Log SHA1[$max]")
        # LogのSHA1配列を取得.
        $skip = '--skip=' + $count
        $idList = @(git log $branchName -n $max $skip --first-parent --format=%H)
        # 各SHA1のBranchNameを取得..
        foreach ($item1 in $idList) {
            $pui.UpdateUI("s2. Get-Branch Names")
            $bnList = @(git branch -r --contains $item1)
            # Hashに未登録なBranchを登録.
            for($i=0;$i -lt $bnList.Length;$i++) {
                $pui.UpdateUI("s3. Add-SHA1 : $item1")
                $item2 = $bnList[$i]
                $item2 = $item2.Replace("^[\s\*]+[\s\*]+[\s\*]*", "")
                $item2 = $item2.Trim()
                $bnList[$i] = $item2
                if ($item2 -eq $branchName) {
                    continue
                }
                if ($hash.ContainsKey($item2) -eq $false) {
                    $hash.Add($item2, $item1)
                }
            }
            # 無いBranchNameはHashから削除.
            $list = @($hash.Keys)    # 必ず配列にする.
            foreach ($key in $list) {
                $pui.UpdateUI("s4. Remove-SHA1 : $key")
                if ($bnList.Contains($key) -eq $false) {
                    if ($backup.ContainsKey($key) -eq $true) {
                        $backup[$key] = $hash[$key]
                    }
                    else {
                        $backup.Add($key, $hash[$key])
                    }
                    $hash.Remove($key)
                }
            }
        }
        $pui.UpdateUI("s5. Next-Log [$maxcount]")
        # 取得Log数を得る.
        if ($idList -is [array]) {
            $num = $idList.Length
        } else {
            $num = 1
        }
        # skip値を計算.
        $count = $count + $num
        # 最大取得数を計算.
        $maxcount = $maxcount + $max
    } while ($num -ge $max)

    $pui.EndUI()

    # backup => hash へ移す.
    foreach ($key in $backup.Keys) {
        if ($hash.Contains($key) -eq $false) {
            $hash.Add($key, $backup[$key])
        }
    }

    # return value.
    if([string]::IsNullOrEmpty($originBranchName)) {
        Write-Output $hash
    }
    else {
        if ($hash.ContainsKey($originBranchName) -eq $true) {
            Write-Output $hash[$originBranchName]
        }
        else {
            Write-Output ""
        }
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

    $list = @(git log --merges $branchName2..$branchName1 --format=%H)
    if ($list.Length -ge 1) {
        Write-Output $list[0]
        return
    }

    $list = @(git log $branchName1 --not $branchName2 --format=%H)
    if ($list.Length -ge 1) {
        $id = $list[$list.Length - 1]
        $list = @(git log $id -n 20 --first-parent --format=%P)
        if ($list.Length -ge 1) {
            foreach( $item1 in $list ) {
                $bnList = @(git branch -r --contains $item1)
                foreach( $item2 in $bnList ) {
                    $item2 = $item2.Replace("^[\s\*]+[\s\*]+[\s\*]*", "")
                    $item2 = $item2.Trim()
                    if ($item2 -eq $branchName2) {
                        Write-Host $item1
                        return
                    }
                }
            }
        }
    }
    Write-Output ""
}

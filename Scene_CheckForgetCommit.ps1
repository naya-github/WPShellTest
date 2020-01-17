using module ".\lib\module\PathHelper.psm1"
using module ".\lib\module\FileJson.psm1"
using module ".\lib\module\SelectMenuUI.psm1"

Set-StrictMode -Version 5.0 # -Version Latest

function Scene_CheckForgetCommit {
    param (
        [string]$GitLocalFolderPath,
        [string]$JsonBranchListPath
    )

    if (-not $GitLocalFolderPath) {
        return
    }
    if (-not $JsonBranchListPath) {
        return
    }

    $JsonBranchListPathFull = ToFullPath $JsonBranchListPath

    Push-Location $GitLocalFolderPath

    # 表示:git current folder.
    Write-Host ("Git Current Path : "+(Convert-Path .))

    # git:現在のLocalのBranch名. (git symbolic-ref -q --short HEAD)
    $nowBranchName = git rev-parse --abbrev-ref HEAD
    Write-Host ("[now] git branch : "+$nowBranchName)
    # git:現在のコミットID(SHA1/long)
    $nowID = git log -n 1 --format=%H
    Write-Host ("[now] git commit ID(SHA1) : "+$nowID)

    # コミット忘れ(表示はファイル名)
    $a1 = git diff --name-only HEAD
    if ($a1) {
        Write-Host "コミット忘れてませんか？"
        Write-Host ($a1 -join ", ")
        Read-Host -Prompt "処理を続けますか？(Press Enter to next?)"
    }

    # git:現在のリモート名を取得
    $nowRemoteName = $null
    $nowRemoteNameList = git remote
    if ($nowRemoteNameList -is [array]) {
        $nowRemoteName = git config branch."${nowBranchName}".remote
        # [remote / branch 対応表]から探す ( 有れば、それを使う ).
        if (-not $nowRemoteName) {
            $jsonBranchList = ReadJson $JsonBranchListPathFull
            if (-not $jsonBranchList) {
                $jsonBranchList = New-Object -TypeName PSCustomObject
                $array = @()
                AddMember $jsonBranchList "BranchList" $array
            }
            foreach ($obj in $jsonBranchList.BranchList) {
                if ($obj.Branch -contains $nowBranchName) {
                    $nowRemoteName = $obj.Remote
                }
            }
            # 見つからないので選択させる.
            if (-not $nowRemoteName) {
                $msg = "現在のリモートはどれですか？ ( 現在のブランチ [ "+$nowBranchName+" ] )"
                $nowRemoteName = SelectMenuUI $nowRemoteNameList $msg
                # 選択した物をFileに格納(remote / branch 対応表)
                $obj = New-Object -TypeName PSCustomObject
                AddMember $obj "Remote" $nowRemoteName
                AddMember $obj "Branch" $nowBranchName
                $jsonBranchList.BranchList += $obj
                WriteJson $jsonBranchList $JsonBranchListPathFull
            }
        }
    } else {
        $nowRemoteName = $nowRemoteNameList
    }

    # 未プッシュの確認(表示はSHA1)
    $a2 = git log ($nowRemoteName+'/'+$nowBranchName)..HEAD --format=%H
    if ($a2) {
        Write-Host "プッシュ忘れてませんか？"
        Write-Host "CommitID(SHA-1) list."
        Write-Host $a2
        Read-Host -Prompt "処理を続けますか？(Press Enter to next?)"
    }

    Pop-Location
}


. .\lib\funcSelectDialogUI.ps1

Set-StrictMode -Version 5.0 # -Version Latest

function Scene_SetGitLanguageJp {
    param (
        [string]$GitLocalFolderPath
    )

    if (-not $GitLocalFolderPath) {
        return
    }

    Push-Location $GitLocalFolderPath

    # 表示:git current folder.
#    Write-Host ("Git Current Path : "+(Convert-Path .))

    # Gitの日本語設定を確認表示し設定を促す
    $gc_cq = git config --local core.quotepath
    $gc_cp = git config --local core.pager
    Write-Host ("Gitの言語設定 [ pager="+$gc_cp+", quotepath="+$gc_cq+" ]")

    if ($gc_cq -ne "false" -or $gc_cp -ne "LC_ALL=ja_JP.UTF-8 less -Sx4") {
        # Gitの日本語設定を確認する
        $re = SelectDialogUI "Git Config(local) の言語設定を変えますか？"
        if ($re -eq 0) {
            # Gitの日本語設定を追加(完全ではない....かも?)
            git config --local core.quotepath false
            git config --local core.pager "LC_ALL=ja_JP.UTF-8 less -Sx4"
            rite-Host "設定変更しました「Git Config --local」"
        }
    }

    Pop-Location
}


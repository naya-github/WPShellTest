# ExecutionPolicy オプションによる実行ポリシーの変更
# [ PowerShell -ExecutionPolicy RemoteSigned ]
# or
# Set-ExecutionPolicy による恒久的な実行ポリシーの変更
# [ PowerShell Set-ExecutionPolicy RemoteSigned ]
# デフォルト : Set-ExecutionPolicy Restricted

# include module (class etc...)
using module ".\lib\module\PathHelper.psm1"
using module ".\lib\module\FileHelper.psm1"
using module ".\lib\module\FileJson.psm1"
using module ".\lib\module\WindowRect.psm1"
using module ".\lib\module\InputUI.psm1"
using module ".\lib\module\SelectMenuUI.psm1"
using module ".\lib\module\ProgressUI.psm1"
using module ".\lib\module\TypeHelper.psm1"

# 起動時の引数を指定する.
Param(
    [parameter(mandatory=$true)][String]$ConfigFilePath
)

# include
. .\lib\function\funcPrint.ps1
. .\lib\function\funcLog.ps1
. .\lib\function\funcGitCommitID.ps1
. .\lib\function\funcSelectDialogUI.ps1
. .\lib\function\funcSelectGridWindow.ps1
. .\ReqFile.ps1

# win-10         ps:5.0
Set-StrictMode -Version 5.0 # -Version Latest

$ErrorActionPreference = "Inquire" #"Stop"


# load config[json]
$json = ReadJson $ConfigFilePath
# move current folder.
cd $json.CurrentFolderPath
# start log.
StartLog $json.PS.LogPath $json.PS.LogAppend
# print current.
Write-Host ("current : "+(Convert-Path .))
# SET Encoding
$OutputEncoding = $json.PS.Encod # 'utf-8'

# 起動:[SSH]Putty
if ($json.Git.SshPrivateKey) {
	&$json.Git.PuttyPageant $json.Git.SshPrivateKey
	Write-Host "[SSH] Putty/Pageant 起動!!"
}

if ($json.Git.LocalFolderRoot) {
    
    Push-Location $json.Git.LocalFolderRoot

    # 表示:git current folder.
    Write-Host ("Git Path : "+(Convert-Path .))

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
            Write-Host "設定変更しました「Git Config --local」"
        }
    }
    
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
    }

    # git:現在のリモート名を取得
    $nowRemoteName = $null
    $nowRemoteNameList = git remote
    if ($nowRemoteNameList -is [array]) {
        $nowRemoteName = git config branch."${nowBranchName}".remote
        # TODO: [remote / branch 対応表]から探す ( 有れば、それを使う ).
        if (-not $nowRemoteName) {
            $msg = "現在のリモートはどれですか？ ( 現在のブランチ [ "+$nowBranchName+" ] )"
            $nowRemoteName = SelectMenuUI $nowRemoteNameList $msg
            # TODO: 選択した物をコンフィグに格納(remote / branch 対応表)
            #  ( Saved config[json] >> WriteJson $json $ConfigFilePath )

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
    }

    Pop-Location
    if ($a1 -or $a2) {
        Read-Host -Prompt "処理を続けますか？(Press Enter to next?)"
    }
}

# new request file : requestpath/name/name.json
for ($i=0;$i -lt $json.RequestList.Length;$i++) {
    $name = $json.RequestList[$i]
    $path = $json.RequestFolderPath+"\"+$name+"\"+$name+".json"
    NewFile $path
    # 中身をテンプレ的に作成(未定義要素の定義).
    $rj = NewReqJson $path
    WriteJson $rj $path
}


Read-Host -Prompt "処理を続けますか？(Press Enter to next?)"
Write-Host "`n=====<< Select Menu >>==========================================="
# 0. 終了.
# 1. Request 選択.
# 2. Commit 忘れ確認.
# 3. Putty(SSH) 起動.
# 4. git config 日本語.
$slct = SelectMenuUI $json.RequestList "どれ?" -Index
# 選択したRequestのデータが、空なら入力を促す.

# 選択Requestで、なんの処理をするか選択する.
# 0. 戻る.
# 1. Requestのデータを表示する.
# 2. git checkout
# 3. git commit&push (コメント入力補助)
# 4. 修正対象をサーバーからバックアップしてマスターからサーバーへ更新をかける.
# 5. バックアップからサーバーへ修正対象を巻き戻し
# 6. 
Write-Host "`n=====<< Start Working >>========================================="

Write-Host "=====<< End   Working >>========================================="

# 指定フォルダ以下の特定ファイル(*.json)の絶対パスを取得する.
#$list = Get-ChildItem -Path $json.RequestFolderPath -Recurse -File -Filter *.json | ForEach-Object{$_.FullName}
#$json.RequestList
    
#$c = GetFirstMatchedCommitID "origin/develop" "origin/master" -after "2019/11/1"
#print $c


# Stop log.
StopLog

pause
exit 1

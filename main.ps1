# ExecutionPolicy オプションによる実行ポリシーの変更
# [ PowerShell -ExecutionPolicy RemoteSigned ]
# or
# Set-ExecutionPolicy による恒久的な実行ポリシーの変更
# [ PowerShell Set-ExecutionPolicy RemoteSigned ]
# デフォルト : Set-ExecutionPolicy Restricted

# include module (class etc...)
using module ".\lib\module\PathHelper.psm1"
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
. .\lib\function\funcFile.ps1
. .\lib\function\funcGitCommitID.ps1
. .\lib\function\funcSelectDialogUI.ps1
. .\lib\function\funcSelectGridWindow.ps1

# win-10         ps:5.0
Set-StrictMode -Version 5.0 # -Version Latest

$ErrorActionPreference = "Inquire" #"Stop"

# load config[json]
$json = ReadJson $ConfigFilePath
# start log.
StartLog $json.PS.LogPath $json.PS.LogAppend
# SET Encoding
$OutputEncoding = $json.PS.Encod # 'utf-8'

echo "`n"

if ($json.Git.LocalFolderRoot) {
    # move current folder.
    Push-Location $json.Git.LocalFolderRoot
    echo ("current : "+(Convert-Path .))
    # local branch
    $nb = git rev-parse --abbrev-ref HEAD
    echo ("git branch : "+$nb)
    # now ID
    $nowID = git log -n 1 --format=%H
    echo ("git commit ID(SHA1) : "+$nowID)

    # 日本語設定を確認する
    $gc_cq = git config --local core.quotepath
    $gc_cp = git config --local core.pager
    echo ("Gitの言語設定 [ pager="+$gc_cp+", quotepath="+$gc_cq+" ]")
    # 日本語設定を追加(完全ではない....)
    if ($gc_cq -ne "false" -or $gc_cp -ne "LC_ALL=ja_JP.UTF-8 less -Sx4") {
        $re = SelectDialogUI "Git Config(local) の設定を変えますか？"
        if ($re -eq 0) {
            git config --local core.quotepath false
            git config --local core.pager "LC_ALL=ja_JP.UTF-8 less -Sx4"
            echo "設定変更しました「Git Config --local」"
        }
    }

    # コミット忘れ(ファイル名)
    $a1 = git diff --name-only HEAD
    if ($a1) {
        echo "`n"
        echo "コミット忘れてませんか？"
        echo ($a1 -join ", ")
    }

$nowBranchName = git rev-parse --abbrev-ref HEAD
$nowRemoteNameList = git remote

    # 未プッシュの確認(sha1)
    $a2 = git log origin/develop..HEAD --format=%H
    if ($a2) {
        echo "`n"
        echo "プッシュ忘れてませんか？"
        echo "SHA-1 list."
        echo $a2
    }

    if ($a1 -or $a2) {
        echo "`n"
        Read-Host -Prompt "処理を続けますか？(Press Enter to next?)"
    }

    # log に日付対応の機能を追加.
    # json のリストにも日付を追加.

    # move curent folder.
    Pop-Location
}

# Stop log.
StopLog

pause
exit 1


echo "---< match sha1(first) >-----------------------------------"
$c = GetFirstMatchedCommitID "origin/develop" "origin/master"
var_dump $c
echo "---< match sha1(latest) >-----------------------------------"
$c = GetLatestMatchedCommitID -branchName1 "origin/develop" -branchName2 "origin/master"
var_dump $c

Read-Host -Prompt "Press Enter to next"

if ($hashConfig.ContainsKey('GitLocalFolderRoot')) {
    echo "---< cd >-----------------------------------"
    cd $hashConfig['GitLocalFolderRoot']
    Convert-Path .

    # 現在のlocal-branch
    git rev-parse --abbrev-ref HEAD

    if ($hashConfig.ContainsKey('GitBranch') -and $hashConfig.ContainsKey('GitRemote')) {

        echo "---< git checkout >-----------------------------------"
        git checkout $hashConfig['GitBranch']

        echo "---< git pull >-----------------------------------"
        git pull $hashConfig['GitRemote'] $hashConfig['GitBranch']

        echo "---< git now revision(sha1) >------------------------------"
        $strlog = git log -n 1 --format=%h
        echo ("SHA1(now/short):"+$strlog)
        $strlog = git log -n 1 --format=%H
        echo ("SHA1(now/long):"+$strlog)

        $strRevLong = git rev-parse --branches
        echo ("SHA1(now/long):"+$strRevLong)
        $strRevSort = git rev-parse --short $strRevLong
        echo ("SHA1(now/short):"+$strRevSort)

        echo "---< git diff >------------------------------"
        git diff --name-only $strRevLong
        git diff --name-status $strRevLong

# git commit . -m "commit msg." # 変更部分をコミット.
# git push origin develop

#        # http://stakiran.hatenablog.com/entry/2018/05/08/195848
#        # https://tortoisegit.org/docs/tortoisegit/tgit-automation.html
#        # "C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe" /command:log /path:"(ローカルリポジトリのフルパス)"
#        git checkout -b new-branch origin/new-branch
    }
}

pause
exit 1

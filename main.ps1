﻿# ExecutionPolicy オプションによる実行ポリシーの変更
# [ PowerShell -ExecutionPolicy RemoteSigned ]
# or
# Set-ExecutionPolicy による恒久的な実行ポリシーの変更
# [ PowerShell Set-ExecutionPolicy RemoteSigned ]
# デフォルト : Set-ExecutionPolicy Restricted
# include module (class etc...)
using module ".\PathHelper.psm1"
using module ".\WindowRect.psm1"
using module ".\SelectMenuUI.psm1"
using module ".\ProgressUI.psm1"
using module ".\TypeHelper.psm1"

# 起動時の引数を指定する.
Param(
    [parameter(mandatory=$true)][String]$ConfigFilePath
)
# include
. .\funcTest.ps1
. .\funcLog.ps1
. .\funcFile.ps1
. .\funcGitCommitID.ps1
. .\funcSelectGridWindow.ps1

# win-8.0        ps:3.0
# win-8.1        ps:4.0
# win-10         ps:5.0
# win-10(update) ps:5.1 
Set-StrictMode -Version 5.0 # -Version Latest

$ErrorActionPreference = "Inquire" #"Stop"

[int]$i = $null
echo $i
[int]$i = 0
echo $i
echo "---< JSON-CODE >-----------------------------------"
$json = ReadJson $ConfigFilePath

AddMember $json.PS "NNN" "hoge"
RemoveMember $json.PS "NNN"

WriteJson $json $json.RequestList[0].File

$array = @(111,222,333)
AddMemberArray $json.RequestList[0] "Array" $array
for($i=0;$i -lt (GetMemberArray $json.RequestList[0] 'Array' 'Length');$i += 1){
    echo (GetMemberArray $json.RequestList[0] 'Array' $i)
}
RemoveMemberArray $json.RequestList[0] "Array"

Read-Host -Prompt "Press Enter to next"

# TEST CODE.
# $fileName = Split-Path -Leaf $ConfigFilePath
# $filePath = Split-Path -Parent $ConfigFilePath

# SET Encoding
$OutputEncoding = $json.PS.Encod # 'utf-8'

echo "---< Log >-----------------------------------"
# start log.
StartLog $json.PS.LogPath $json.PS.LogAppend
# Stop log.
StopLog

echo "---< TEST-CODE >-----------------------------------"
printf "a{1}{0}{2}{3}!!!" "b" "c" "d" 123
GetAppliedDPI
GetDesktopRect
Get-WindowRect * | ft
$select = DialogInputWindow ("AAAAAAAA","BBBBBBBBB")
echo ("input : "+$select)

# https://soma-engineering.com/coding/powershell/use-readhost-command/2018/05/24/
[datetime]$date = Read-Host "入社年月日を入力してください。Date-Format: yyyy/mm/dd"
$date
$password = Read-Host "パスワードを入力してください。" -AsSecureString
$password
[ValidateLength(6,8)]$username = [String](Read-Host "ユーザー名を入力してください。")
$username
[ValidateRange(1,9999)]$staff_id = [int](Read-Host "社員番号を入力してください。")
$staff_id
[ValidateSet("y","Y","n","N")]$responce = Read-Host "この PC はノートパソコンですか？(y か n を入力して Enter 押下)"
$responce

$select = SelectMenuUI @("aaaa","bbbb","cccc","dddd") "msgAAAA?" -Index
echo ("select : "+$select)
$select = SelectGridWindow "select string!!" @("aaaa","bbbb","cccc")
echo ("select : "+$select)

Read-Host -Prompt "Press Enter to next"

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

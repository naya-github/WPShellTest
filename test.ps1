# ExecutionPolicy オプションによる実行ポリシーの変更
# [ PowerShell -ExecutionPolicy RemoteSigned ]
# or
# Set-ExecutionPolicy による恒久的な実行ポリシーの変更
# [ PowerShell Set-ExecutionPolicy RemoteSigned ]

# 起動時の引数を指定する.
Param(
    [parameter(mandatory=$true)][String]$ConfigFilePath
)
. .\funcTest.ps1    # include

Set-StrictMode -Version 5.1 #Latest

# TEST CODE.
$fileName = Split-Path -Leaf $ConfigFilePath
$filePath = Split-Path -Parent $ConfigFilePath
# Write-Host $fileName
# Write-Host $filePath

# 設定の配列を定義.
$hashConfig = @{}

# ファイルを１行づつ読み込み処理する.
$enc = [Text.Encoding]::GetEncoding('utf-8')
$fh = New-Object System.IO.StreamReader($ConfigFilePath, $enc)
while (($line = $fh.ReadLine()) -ne $null) {
    # '#'始まりの行はコメント扱い.
#    if($line -match "^#") {
#        echo ("無視:"+$matches[0])
#        continue
#    }
    # '#'以降はコメント扱い.
    $cell = $line -split "#"
    $line = $cell[0]
    # １行の文字列を':'で区切る.
    $cell = $line -split ":"
    # 設定が記載されている時.
    if (($cell.Length -ge 2) -and ($cell -is [array])) {
        # key以外は再度連結する.
        $cell[1] = $cell[1..($cell.Length-1)] -join ":"
        $cell[1] = $cell[1].Trim()    # 前後の空白は削除する.
        # key文字は空白を詰める
        $cell[0] = ($cell[0] -replace " ","")
        # 'Git Repository'は,'Git Remote'に変更.
        if ($cell[0] -eq 'GitRepository') {
            $cell[0] = 'GitRemote'
        }
        # 設定の配列に格納する.
        if (-not [String]::IsNullOrWhiteSpace($cell[1])) {
            if ($hashConfig.ContainsKey($cell[0])){
                $hashConfig[$cell[0]] = $cell[1]
            } else {
                $hashConfig.Add($cell[0], $cell[1])
            }
        }
    }
}

printf "a{1}{0}{2}{3}!!!" "b" "c" "d" 123

echo "---< sha1 >-----------------------------------"
$c = GetAllMatchedCommitID -branchName1 "origin/develop" -branchName2 "origin/master"
var_dump $c
echo "---< sha1 >-----------------------------------"
$c = GetLatestMatchedCommitID -branchName1 "origin/develop" -branchName2 "origin/master"
var_dump $c


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

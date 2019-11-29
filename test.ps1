# ExecutionPolicy オプションによる実行ポリシーの変更
# [ PowerShell -ExecutionPolicy RemoteSigned ]
# or
# Set-ExecutionPolicy による恒久的な実行ポリシーの変更
# [ PowerShell Set-ExecutionPolicy RemoteSigned ]

# 起動時の引数を指定する.
Param(
    [parameter(mandatory=$true)][String]$ConfigFilePath
)
. ".\\funcTest.ps1"    # include

# TEST CODE.
$fileName = Split-Path -Leaf $ConfigFilePath
$filePath = Split-Path -Parent $ConfigFilePath
# Write-Host $fileName
# Write-Host $filePath

# 設定の配列を定義.
$hashConfig = @{}

# ファイルを１行づつ読み込み処理する.
$enc = [Text.Encoding]::GetEncoding('Shift_JIS')  # UTF8??.
$fh = New-Object System.IO.StreamReader($ConfigFilePath, $enc)
while (($line = $fh.ReadLine()) -ne $null) {
    # １行の文字列を':'で区切る(最初の:でのみ区切りたい...).
    $cell = $line -split " : "
    # 設定が記載されている時.
    if ($cell.Length -ge 2) {
        # 空白を詰める.
        $cell[0] = ($cell[0] -replace " ","")
        # 'Git Repository'は, 'Git Remote'に変更.
        if ($cell[0] -eq 'GitRepository') {
            $cell[0] = 'GitRemote'
        }
        # 設定の配列に格納する.
        $hashConfig.Add($cell[0], $cell[1])
    }
}

if ($hashConfig.ContainsKey('GitLocalFolderRoot')) {
    echo "--< cd >---------------"
    cd $hashConfig['GitLocalFolderRoot']
    if ($hashConfig.ContainsKey('GitBranch') -and $hashConfig.ContainsKey('GitRemote')) {
        echo "--< git checkout >---------------"
        git checkout $hashConfig['GitBranch']
        echo "--< git pull >---------------"
        git pull $hashConfig['GitRemote'] $hashConfig['GitBranch']
        $strlog = git log -n 1
        $strlog = $strlog -match "[A-Za-z0-9]{40,}"
        echo $matches[0] # $strlog"
        # http://stakiran.hatenablog.com/entry/2018/05/08/195848
        # https://tortoisegit.org/docs/tortoisegit/tgit-automation.html
        # "C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe" /command:log /path:"(ローカルリポジトリのフルパス)"
#        git checkout -b new-branch origin/new-branch
    }
}

ABCDEFG("uhohoho!!")

pause
exit 1

# ExecutionPolicy オプションによる実行ポリシーの変更
# [ PowerShell -ExecutionPolicy RemoteSigned ]
# or
# Set-ExecutionPolicy による恒久的な実行ポリシーの変更
# [ PowerShell Set-ExecutionPolicy RemoteSigned ]
Param(
    [parameter(mandatory=$true)][String]$ConfigFilePath
)
. ".\\funcTest.ps1"    # include

$fileName = Split-Path -Leaf $ConfigFilePath
$filePath = Split-Path -Parent $ConfigFilePath
# Write-Host $fileName
# Write-Host $filePath

$hashConfig = @{}

$enc = [Text.Encoding]::GetEncoding('Shift_JIS')
$fh = New-Object System.IO.StreamReader($ConfigFilePath, $enc)
while (($line = $fh.ReadLine()) -ne $null) {
    $cell = $line -split " : "
    if ($cell.Length -ge 2) {
        $cell[0] = ($cell[0] -replace " ","")
        $hashConfig.Add(($cell[0] -replace " ",""), $cell[1])
    }
}

if ($hashConfig.ContainsKey('GitLocalFolderRoot')) {
    echo "--< cd >---------------"
    cd $hashConfig['GitLocalFolderRoot']
    if ($hashConfig.ContainsKey('GitBranch')) {
        echo "--< git checkout >---------------"
        git checkout $hashConfig['GitBranch']
        echo "--< git pull >---------------"
        git pull $hashConfig['GitRepository'] $hashConfig['GitBranch']
    }
}

ABCDEFG("uhohoho!!")

pause
exit 1
# ExecutionPolicy �I�v�V�����ɂ����s�|���V�[�̕ύX
# [ PowerShell -ExecutionPolicy RemoteSigned ]
# or
# Set-ExecutionPolicy �ɂ��P�v�I�Ȏ��s�|���V�[�̕ύX
# [ PowerShell Set-ExecutionPolicy RemoteSigned ]
Param(
    [parameter(mandatory=$true)][String]$ConfigFilePath
)
Write-Host $ConfigFilePath

$fileName = Split-Path -Leaf $ConfigFilePath
$filePath = Split-Path -Parent $ConfigFilePath
Write-Host $fileName
Write-Host $filePath

$hashConfig = @{}

$enc = [Text.Encoding]::GetEncoding('Shift_JIS')
$fh = New-Object System.IO.StreamReader($ConfigFilePath, $enc)
while (($line = $fh.ReadLine()) -ne $null) {
    $cell = $line -split " : "
    if($cell.Length -ge 2) {
        Write-Host $cell[0]
        Write-Host $cell[1]
        $hashConfig.Add($cell[0], $cell[1])
    }
    if($cell[0] -eq 'Git Branch') {
        Write-Host ("branch = " + $hashConfig['Git Branch'])
    }
}



pause
exit 1
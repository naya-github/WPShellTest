
function global:IsDirectory([string]$path1, $endDelimiter=$true) {
    $result = $false
    if ($endDelimiter) {
        $path1 = $path1.Trim()    # 前後の空白は削除する.
        if ($path1 -match "[\\|/]+$") {
            $result = $true
        }
    }
    if ($result -eq $false) {
        # 存在チェック.
        if (Test-Path $path1) {
            # ディレクトリ判別.
            $result = (Get-Item $path1) -is [System.IO.DirectoryInfo]
        }
        if ($result -eq $false) {
            # 拡張子有るならファイル
            try {
                $ext = [System.IO.Path]::GetExtension($path1)
                if ([bool]$ext) {
                    $result = $true
                }
            } catch [Exception] {
            }
        }
    }
    Write-Output $result
}

function global:CreateFileNameDate([string]$firstName, [string]$fileExtension) {
    $dateName = Get-Date -UFormat "%Y%m%d"
    if ($firstName.Length -le 0) {
        $name = "date_" + $dateName + $fileExtension
    }
    else {
        $name = $firstName + "_" + $dateName + $fileExtension
    }
    Write-Output $name
}

Export-ModuleMember -Function '*'

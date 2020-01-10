
# 注意 )
# 末尾に"\"がないとフォルダ扱いされません( $Location は修正ずみ )
# PSDriveは扱えません
# 例 )
# 相対パスから絶対パスへの変換 : ConvertLocalPath "..\baz.txt" -Location "X:\foo\bar\"
# 絶対パスから相対パスへの変換 : ConvertLocalPath "X:\foo\baz.txt" -Location "X:\foo\bar\" -Relative
filter global:ConvertLocalPath
{
    Param (
        [parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [string] $Path,

        [ValidateNotNullOrEmpty()]
        [uri] $Location = (Get-Location).Path,

        [switch] $Relative
    )

    if (-not ($Location.OriginalString -match "[\\|/]{1}$")) {
        $Location = [uri]($Location.OriginalString+"\")
    }

    if (-not $Relative) {
        return [uri]::new($Location, $Path).LocalPath
    }

    $localPath = $Location.MakeRelative($Path) -replace '/', '\'
    if ($localPath.StartsWith('.')) {
        return $localPath
    } else {
        return ".\${localPath}"
    }
}


# 相対パスから絶対パスへの変換
function global:ToFullPath
{
    Param (
        [string] $Path,
        [string] $Root = "."
    )

    $re = Test-Path $Root
    if ($re) {
        Push-Location $Root
        $re = Test-Path $Path
        if ($re) {
            $re = (Resolve-Path $Path).Path
            Write-Host $re
        } else {
            $re = ConvertLocalPath $Path
            Write-Host $re
        }
        Pop-Location
    } else {
        $re = ConvertLocalPath $Path -Location $Root
        Write-Host $re
    }
}

# 絶対パスから相対パスへの変換
function global:ToRelativePath
{
    Param (
        [string] $Path,
        [string] $Root = "."
    )
    $re = Test-Path $Root
    if ($re) {
        Push-Location $Root
        $re = Test-Path $Path
        if ($re) {
            $re = (Resolve-Path $Path -Relative)
            Write-Host $re
        } else {
            $re = ConvertLocalPath $Path -Relative
            Write-Host $re
        }
        Pop-Location
    } else {
        $re = ConvertLocalPath $Path -Location $Root -Relative
        Write-Host $re
    }
}

# 絶対パスかどうか確認
function global:IsFullPath
{
    Param (
        [string] $Path
    )

    if ($Path -match "^[a-zA-Z0-9_-]+:\\") {
        Write-Host $true
    }
    elseif ($Path -match "^\\\\") {
        Write-Host $true
    }
    Write-Host $false
}

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
                    $result = $false
                } else {
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

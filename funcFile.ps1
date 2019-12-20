using module ".\PathHelper.psm1"

Set-StrictMode -Version 5.0 # -Version Latest

function global:ReadJson([string]$jsonFile)
{
    $json = Get-Content $jsonFile | Out-String | ConvertFrom-Json
    Write-Output $json
}

# NoteProperty は、オブジェクトに静的な値を持つメンバーを追加するために使いま
function global:AddMember($obj, [string]$name, $value)
{
    $obj | Add-Member -MemberType NoteProperty -Name $name -Value $value
#    Write-Output $obj
}

function global:AddMemberArray($obj, [string]$name, [array]$value)
{
    $obj | Add-Member -MemberType NoteProperty -Name ($name+'_Length') -Value $value.Length
    for ($i=0; $i -lt $value.Length; $i += 1)  {
        $obj | Add-Member -MemberType NoteProperty -Name ($name+'_'+$i) -Value $value[$i]
    }
#    Write-Output $obj
}

function global:GetMemberArray($obj, [string]$name, $index = -1)
{
    $objLength = $obj.($name+'_Length')
    if (($index -eq 'length') -or ($index -eq 'num')) {
        Write-Output $objLength
        return
    }
    if (($index -ge 0) -and ($index -lt $objLength)) {
        Write-Output ($obj.($name+'_'+$index))
        return
    }
    $array = @()
    for ($i=0; $i -lt $objLength; $i += 1)  {
        $array += $obj.($name+'_'+$i)
    }
    Write-Output $array
}

function global:RemoveMember($obj, [string]$name)
{
    $obj.PSObject.Properties.Remove($name)
}

function global:RemoveMemberArray($obj, [string]$name)
{
    $objLength = $obj.($name+'_Length')
    for ($i=0; $i -lt $objLength; $i += 1)  {
        $obj.PSObject.Properties.Remove($name+'_'+$i)
    }
    $obj.PSObject.Properties.Remove($name+'_Length')
}

function global:WriteJson($jsonObj,[string]$jsonFile,$append=$false)
{
    $jsonTxt = $jsonObj | ConvertTo-Json

#    $fileName = Split-Path -Leaf $jsonFile
    $filePath = Split-Path -Parent $jsonFile
    try {
        $r = Test-Path $filePath
        if($r -eq $false) {
            $e = New-Item $filePath -type directory
        }
    } catch [Exception] {
    }

    if($append) {
        $jsonTxt | Out-File $jsonFile -Encoding UTF8 -Append
    } else {
        $jsonTxt | Out-File $jsonFile -Encoding UTF8
    }
}


function global:ReadFileAsHash([string]$filePath, $replaceKey=@{'GitRepository'='GitRemote'}) {
<#
.SYNOPSIS
    ファイル内容を連想配列として取得.
.DESCRIPTION
    ファイル内容を連想配列として取得.
.EXAMPLE
    テキストの自作Configを連想配列にする処理を想定.

.PARAMETER $filePath
    ファイルのパス名（ファイル名含む）
.OUTPUTS
    連想配列を戻す.
#>
    # 配列を定義.
    $hash = @{}
    # ファイルを１行づつ読み込み処理する.
    $enc = [Text.Encoding]::GetEncoding('utf-8')
    $fh = New-Object System.IO.StreamReader($FilePath, $enc)
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

            # key 置き換え ('Git Repository' => 'Git Remote' など)
            foreach($key in $replaceKey.Keys) {
                if($cell[0] -eq $key ) {
                    $cell[0] = $replaceKey[$key];
                    break;
                }
            }

            # 設定の配列に格納する.
            if (-not [String]::IsNullOrWhiteSpace($cell[1])) {
                if ($hash.ContainsKey($cell[0])){
                    $hash[$cell[0]] = $cell[1]
                } else {
                    $hash.Add($cell[0], $cell[1])
                }
            }
        }
    }

    Write-Output $hash
}

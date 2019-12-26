Set-StrictMode -Version 5.0 # -Version Latest

function global:ReadJson([string]$jsonFile)
{
    $json = Get-Content $jsonFile | Out-String | ConvertFrom-Json
    Write-Output $json
}
function global:ToJson([string]$jsonString)
{
    $json = ConvertFrom-Json $jsonString
    Write-Output $json
}

# NoteProperty は、オブジェクトに静的な値を持つメンバーを追加するために使いま
function global:AddMember($obj, [string]$name, $value)
{
    $obj | Add-Member -MemberType NoteProperty -Name $name -Value $value
#    Write-Output $obj
}

# !!! 不要な関数
function global:AddMemberArray($obj, [string]$name, [array]$value)
{
    $obj | Add-Member -MemberType NoteProperty -Name ($name+'_Length') -Value $value.Length
    for ($i=0; $i -lt $value.Length; $i += 1)  {
        $obj | Add-Member -MemberType NoteProperty -Name ($name+'_'+$i) -Value $value[$i]
    }
#    Write-Output $obj
}

# !!! 不要な関数
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

# !!! 不要な関数
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

Export-ModuleMember -Function *

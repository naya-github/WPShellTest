using module ".\lib\module\FileJson.psm1"

Set-StrictMode -Version 5.0 # -Version Latest

function global:NewReqJson($jsonPath=$null) {
    if ($jsonPath -eq $null) {
        $json = New-Object -TypeName PSCustomObject
    }
    elseif (Test-Path $jsonPath) {
        $json = ReadJson $jsonPath
        if (-not $json) {
            $json = New-Object -TypeName PSCustomObject
        }
    }
    else {
        $json = New-Object -TypeName PSCustomObject
    }

    # ReqID:
    try {
        $a = $json.ReqID
    } catch {
        AddMember $json "ReqID" ""
    }
    # Title:
    try {
        $a = $json.Title
    } catch {
        AddMember $json "Title" ""
    }
    # Date:YYYY/mm/dd
    try {
        $a = $json.Date
    } catch {
        $now = Get-Date -UFormat "%Y/%m/%d"
        AddMember $json "Date" $now
    }
    # FromRemote:
    try {
        $a = $json.FromRemote
    } catch {
        AddMember $json "FromRemote" ""
    }
    # FromBranch:
    try {
        $a = $json.FromBranch
    } catch {
        AddMember $json "FromBranch" ""
    }
    # ToRemote:
    try {
        $a = $json.ToRemote
    } catch {
        AddMember $json "ToRemote" ""
    }
    # ToBranch:
    try {
        $a = $json.ToBranch
    } catch {
        AddMember $json "ToBranch" ""
    }
    # StartCommitID:
    try {
        $a = $json.StartCommitID
    } catch {
        AddMember $json "StartCommitID" ""
    }
    # Comp:
    try {
        $a = $json.Comp
    } catch {
        AddMember $json "Comp" 0
    }
    # CodeFileList:array()
    try {
        $a = $json.CodeFileList
        if ($a -isnot [array]) {
            throw "配列以外の型(CodeFileList)"
        }
    } catch [Exception] {
        $array = @()
        AddMember $json "CodeFileList" $array
    }

#$json = New-Object -TypeName PSObject
#$json | Add-Member -MemberType NoteProperty -Name "RNo" -Value "6097"
#$json | Add-Member -MemberType NoteProperty -Name "Title" -Value $null
#$arraynum = @(1,2,3,4);
#$json | Add-Member -MemberType NoteProperty -Name "SSS" -Value $arraynum
#$arraynum = @{a=1;b=2;c=3;d=4};
#$json | Add-Member -MemberType NoteProperty -Name "RRR" -Value $arraynum
#try {
#    echo $json.XXX
#} catch {
#    echo "XXX error"
#}

    Write-Output $json
}

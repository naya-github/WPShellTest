Set-StrictMode -Version 5.0 # -Version Latest


function global:NewFile([string]$path)
{
	$aryPath = $path -split "\\"
	$testPath = ""
    for ($i=0;$i -lt $aryPath.Length;$i++) {
        if ($testPath) {
            $testPath = $testPath + "\" + $aryPath[$i]
        } else {
            $testPath = $aryPath[$i]
        }
        $result = Test-Path $testPath
        if (-not $result) {
            if ($i -eq ($aryPath.Length-1)) {
                New-Item $testPath -ItemType "file"
            } else {
                New-Item $testPath -ItemType "directory"
            }
        }
    }
}


Export-ModuleMember -Function *

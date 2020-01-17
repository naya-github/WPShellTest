Set-StrictMode -Version 5.0 # -Version Latest

function Scene_StartPageant {
    param (
        [string]$AppPageantPath
    )

    if (-not $AppPageantPath) {
        return
    }
    if (-not $SshPrivateKeyPath) {
        return
    }
    # 起動:[SSH]Pageant
    if ($SshPrivateKeyPath) {
        &$AppPageantPath $SshPrivateKeyPath
    	Write-Host "[SSH] Pageant 起動!!"
    }
}

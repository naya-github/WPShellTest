
Set-StrictMode -Version 5.0 # -Version Latest

function global:var_dump($prm1) {
    $prm1 | ForEach-object -Process { Write-Host $_ }
#    $prm1 | Get-Member
}

function global:print {
    if($args -is [array]) {
        if($args.Length -ge 2) {
            $prm1 = $args[0];
            $prm2 = $args[1..($args.Length-1)]
            Write-Host ($prm1 -f $prm2)
        }
        else {
            Write-Host $args[0]
        }
    }
    else {
        Write-Host $args
    }
}


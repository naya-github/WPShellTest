function global:ToBool( $prm1 ) {
    try {
      $result = [System.Convert]::ToBoolean($prm1) 
    }
    catch [Exception] {
        try {
            $prm1 = $([string]$prm1).ToLower()
            $result = [System.Xml.XmlConvert]::ToBoolean($prm1)
        }
        catch [FormatException] {
            $result = $false
        }
        # 覚書.....(笑)...
        catch [InvalidCastException],[OverflowException],[ArgumentNullException],[Exception] {
            $result = $false
        }
    }
    Write-Output $result
}

function global:ToInt( $prm1, $default=$null ) {
    try {
      $result = [System.Convert]::ToInt64($prm1) 
    }
    catch [Exception] {
        try {
            $prm1 = $([string]$prm1).ToLower()
            $result = [System.Xml.XmlConvert]::ToInt64($prm1)
        }
        catch [Exception] {
            $result = $default
        }
    }
    Write-Output $result
}


Export-ModuleMember -Function '*'

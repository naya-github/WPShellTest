$ErrorActionPreference = "Inquire" #"Stop"

#Add-Type -TypeDefinition @"
#   public enum InputUI_Type
#   {
#      UI_Password = 2,
#      UI_DateTime = 5,
#      UI_Length = 3,
#      UI_Range = 4,
#      UI_YesNo = 1,
#      UI_None = 0
#   }
#"@

enum InputUI_Type {
      UI_Password = 2
      UI_DateTime = 5
      UI_Length = 3
      UI_Range = 4
      UI_YesNo = 1
      UI_None = 0
}


function InputUI {
    Param(
        $msg,
        [InputUI_Type]$type,
        $min,
        $max
    )

    if ($type -eq [InputUI_Type]::UI_None) {
        $i = Read-Host $msg
        Write-Output $i
        return
    }
    if ($type -eq [InputUI_Type]::UI_DateTime) {
        $msg += "(format:yyy/mm/dd)"
        $date = $null
        do {
            $f = $true
            try {
                [datetime]$date = Read-Host $msg
            } catch [Exception] {
                $f = $false
                Write-Host "error:日付を入力してください"
            }
         } while ($f -eq $false)
         Write-Output $date
         return
    }
    if ($type -eq [InputUI_Type]::UI_Password) {
        $password = Read-Host $msg -AsSecureString
        Write-Output $password
        return
    }
    if ($type -eq [InputUI_Type]::UI_Length) {
        $str = ''
        if (($min -eq $null) -and ($max -eq $null)) {
            do {
                $str = [String](Read-Host $msg)
                if ([string]::IsNullOrEmpty($str) -eq $false) {
                    break
                } else {
                    Write-Host "error:入力してください"
                }
            } while($true)
        } elseif (($min -ne $null) -and ($max -ne $null)) {
            do {
               $f = $false
               try {
                   [ValidateLength({$min},{$max})]$str = [String](Read-Host $msg)
               } catch [Exception] {
                   $f = $true
                   Write-Host ("error:文字数は[ "+$min+" ]から[ "+$max+" ]です")
               }
            } while ($f)
        } elseif ($min -ne $null) {
            do {
                $str = [String](Read-Host $msg)
                if ([string]::IsNullOrEmpty($str) -eq $false) {
                    if ($str.Length -ge $min) {
                        break
                    } else {
                        Write-Host ("error:文字数は[ "+$min+" ]以上です")
                    }
                } else {
                    Write-Host "error:入力してください"
                }
            } while($true)
        } else {
            do {
                $str = [String](Read-Host $msg)
                if ([string]::IsNullOrEmpty($str) -eq $false) {
                    if ($str.Length -le $max) {
                        break
                    } else {
                        Write-Host ("error:文字数は[ "+$max+" ]以下です")
                    }
                } else {
                    Write-Host "error:入力してください"
                }
            } while($true)
        }
        Write-Output $str
        return
    }
    if ($type -eq [InputUI_Type]::UI_Range) {
        $n = ''
        if (($min -eq $null) -and ($max -eq $null)) {
            do {
                try {
                    $n = [long](Read-Host $msg)
                    if ($n -ne $null) {
                        break
                    } else {
                        Write-Host "error:入力してください"
                    }
                } catch [Exception] {
                    Write-Host "error:long型で扱えません"
                }
            } while($true)
        } elseif (($min -ne $null) -and ($max -ne $null)) {
            do {
               $f = $false
               try {
                   [ValidateRange({$min},{$max})]$n = [long](Read-Host $msg)
               } catch [Exception] {
                   $f = $true
                   Write-Host ("error:数値範囲は[ "+$min+" ]から[ "+$max+" ]です")
               }
            } while ($f)
        } elseif ($min -ne $null) {
            do {
               try {
                    $n = [long](Read-Host $msg)
                    if ($n -ne $null) {
                        if ($n -ge $min) {
                            break
                        } else {
                            Write-Host ("error:範囲は[ "+$min+" ]以上です")
                        }
                    } else {
                        Write-Host "error:入力してください"
                    }
                } catch [Exception] {
                    Write-Host "error:long型で扱えません"
                }
            } while($true)
        } else {
            do {
               try {
                    $n = [long](Read-Host $msg)
                    if ($n -ne $null) {
                        if ($n -le $max) {
                            break
                        } else {
                            Write-Host ("error:範囲は[ "+$max+" ]以下です")
                        }
                    } else {
                        Write-Host "error:入力してください"
                    }
                } catch [Exception] {
                    Write-Host "error:long型で扱えません"
                }
            } while($true)
        }
        Write-Output $n
        return
    }
    if ($type -eq [InputUI_Type]::UI_YesNo) {
        $msg += "(yes or no)"
        $re = $null
        do {
            $f = $false
            try {
                [ValidateSet("y","Y","yes","Yes","YES","n","N","no","No","NO")]$re = Read-Host $msg
                $re = $re.ToLower()
                $re = $re.Substring(0,1)
            } catch [Exception] {
                $f = $true
                Write-Host "error:y or n を入力してください"
            }
        } while ($f)
        Write-Output $re
        return
    }
}


Export-ModuleMember -Function *
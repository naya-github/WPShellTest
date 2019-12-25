Set-StrictMode -Version 5.0 # -Version Latest


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

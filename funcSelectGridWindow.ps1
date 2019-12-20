Set-StrictMode -Version 5.0 # -Version Latest

# 外部のGridWindowで選択をさせる
# note : ( １種選択に固定する方法がわからな.... )
function SelectGridWindow($title, $items) {
    $out = $items | Out-GridView -Title $title -PassThru
    Write-Output $out
}

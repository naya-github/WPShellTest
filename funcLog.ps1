using module ".\PathHelper.psm1"

Set-StrictMode -Version 5.0 # -Version Latest

function global:StartLog([string]$filePath, $append)
{
    $logFile = ""
    # フォルダ指定での自動ファイル名生成.
    if (IsDirectory $filePath) {
        $logFile = CreateFileNameDate "log" ".txt"
        $logFile = $filePath + $logFile
    }
    else {
        $logFile = $filePath
    }
    # log 開始.
    if (ToBool $append) {
        Start-Transcript $logFile -Append
    }
    else {
        Start-Transcript $logFile
    }
}

function global:StopLog()
{
    Stop-Transcript
}

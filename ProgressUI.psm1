# $ErrorActionPreference = "Inquire" #"Stop"

# 定数 : .
# set-variable -name AAANAME -value "valuetxt" -option constant -scope global

$ProgressPreference = "Continue" # progressの表示を強要.

class ProgressUI
{
    [int] $ID
    [string] $Title
    [string] $Status

    ProgressUI() {
        $this.ID = 0
        $this.Title = "progress"
        $this.Status = "処理中"
    }
    [void] BeginUI([int]$id, [string]$title) {
        $this.ID = $id
        $this.Title = $title
    }
	[void] UpdateUI([string]$msg) {
        $this.Status = $msg
        Write-Progress $this.Title $this.Status -Id $this.ID
    }
	[void] UpdateUI([string]$msg, [int]$percent) {
        $this.Status = $msg
        Write-Progress $this.Title $this.Status -Id $this.ID -PercentComplete $percent -CurrentOperation "$percent % 完了"
    }
	[void] EndUI() {
        Write-Progress $this.Title "処理完了" -Id $this.ID -Completed
    }
}

Export-ModuleMember -Function '*'

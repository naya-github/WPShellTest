Set-StrictMode -Version 5.0 # -Version Latest

# PS内部でYes or No で選択させる.
function SelectDialogUI {
    Param(
        [string]$message
    )
    #選択肢の作成
    $typename = "System.Management.Automation.Host.ChoiceDescription"
    $yes = new-object $typename("&Yes","はい")
    $no  = new-object $typename("&No","いいえ")

    #選択肢コレクションの作成
    $choice = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)

    #選択プロンプトの表示
    $answer = $host.ui.PromptForChoice("<確認>", $message, $choice, 0)
    Write-Output $answer
}
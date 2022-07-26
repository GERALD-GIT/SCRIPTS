"Récupération des BAL ... cette opération peut prendre du temps"
$mb=get-mailbox
"Récupération des permissions"
$MBPerm=$mb|Get-MailboxPermission

while ($true){
$trigramme=read-host "Entrez le nom d'utilisateur ou samaccountname pour vérifier ses permissions "
try{
"Controle total sur ces boîtes:"
$MBPerm |?{$_.user -match $trigramme}|select identity,*accessr*
"---------------------"
"`nEnvoyer en tant que sur ces boîtes:`n`n"

$mb|?{$_.grantsendonbehalfto -match $((get-aduser $trigramme).name)}
"`n`n"
}
catch
{"Une erreur est survenue: $_.exception.message"}
}

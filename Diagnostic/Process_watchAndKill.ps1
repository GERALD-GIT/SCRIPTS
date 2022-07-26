
#GSR
#Variables ci dessous modifiables

$MaxMemoireParProcess= 60817408
$NomProcess="processus.exe"
$TEMPO=30
$Logfile="c:\temp\Processwatch.log"



#NE PAS MODIFIER CI DESSOUS

cls
Write-host -foregroundcolor YELLOW "Outil de detection des processus suspects"
Write-host -foregroundcolor YELLOW "Tout processus $NomProcess de moins de $MaxMemoireParProcess sera tué"
Write-host -foregroundcolor YELLOW "si son comportement n'a pas évolué en $TEMPO secondes"
write-host -foregroundcolor red "Le programme démarre dans 10 secondes. CTRL+C pour annuler";sleep 10

$error.clear()
try {$([Datetime]::now)|out-file $logfile -append}
catch {write-host -foregroundcolor red "Impossible d'écrire dans $Logfile. Programme avorté"; break}
if (!$error)  {"Création du fichier $LOGFILE ok, on peut commencer"}

[ARRAY]$OLDPID

function CompareProcessus([ARRAY]$A,[ARRAY]$B){
write-host COMPARAISON de $A avec $B
$a|foreach{
	$suspect=$_
		$b |foreach {
		write-host -foregroundcolor yellow "Je compare $_ et $suspect..."
			if ($_ -eq $suspect) {write-host -foregroundcolor red "Le processus suspect $suspect a été identifié"
			$Utilisateur=$(gwmi win32_process |where {$_.ProcessID -eq $Suspect}).getowner().user
			Stop-process -id $Suspect -force
			"Processus $Suspect ouvert par $utilisateur tué à $(get-date -UFormat "%H:%M:%S")" |out-file $logfile -append
			}
		}
	}
}

function boucle{
while ($true){
	#$ListeProcess=Get-Process | Where-Object {$_.name -eq $NomProcess -and $_.ws -lt $MaxMeMoireParProcess}
	[ARRAY]$ListeProcess=Get-WmiObject -class win32_process |where {$_.ProcessName -eq $NomProcess -and $_.WorkingSetSize -lt $MaxMeMoireParProcess}
	if ($ListeProcess -ne $null)
	{
	write-host $ListeProcess.count process $NomProcess "<" $MaxMeMoireParProcess
	$IDProcessus=$NULL
	$IDProcessus=@()
	$ListeProcess | foreach{
		$IDProcessus+=$_.ProcessId
	
			}
	if ($OLDPID -ne $null){
			Write-host "OLDPID=$OLDPID et IDPROCESSUS=$IDPROCESSUS"
			CompareProcessus $IDPROCESSUS $OLDPID} else 
			{
			write-host -foregroundcolor green "Pas d'historique"
			}
	if ($IDProcessus -ne $null) 
			{
			$IDPROCESSUS|foreach {write-host -foregroundcolor yellow "Ajout du procesus $_ trouvé à l'historique pour comparaison"}
			$OLDPID=$IDProcessus
			}else{
			write-host -foregroundcolor green "Vidage de l'historique"			
			$OLDPID=$nul
			}
	
	
 	  }else{
	write-host -foregroundcolor green "Aucun processus trouvé ne répond aux critères $NomProcess < $MaxMeMoireParProcess"
	if($oldpid){
		write-host -foregroundcolor green "Vidage de l'historique"			
		$OLDPID=$nul}
	}
	"Temporisation" ;sleep $TEMPO}
	#"Tempo manuelle" ; read-host}
}



boucle

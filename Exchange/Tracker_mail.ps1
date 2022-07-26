clear
write-host -foregroundcolor white Tracking des mails en temps réel
write-host -foregroundcolor white ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
############################################################################
# GSR-CPRO   Décembre 2011 : Tracking mail en temps réel sur Exchange 2010 #
############################################################################

$DEBUGLEVEL = 0			# 0 = Affichage standard - 1 = Afficharge de tous les EventID
$Temporisation = 5 		# Nombre de secondes par rafraichissement
$Event_NONE="darkgreen"
$Event_SEND="green"
$Event_RECEIVE="cyan"
$Event_DELIVER="gray"
$Event_FAIL="red"
$Event_DSN="yellow"
$Event_TRANSFER="magenta"
$Background = "black"
$Surlignage = "darkyellow"

If ($DEBUGLEVEL -eq 1) {write-host -backgroundcolor $Background -foregroundcolor red "[SYS] Mode DEBUG activé, sortie verbeuse."}
If ($DEBUGLEVEL -eq 0) {write-host -backgroundcolor $Background -foregroundcolor green "[SYS] Mode DEBUG désactivé, sortie filtrée."}
If ($DEBUGLEVEL -ne 0 -and $DEBUGLEVEL -ne 1) {write-host -backgroundcolor $Background -foregroundcolor yellow "[SYS] Mode DEBUG mal configuré, ignoré."}
write-host -foreground green "[SYS] Temporisation fixée à $Temporisation secondes"


write-host -nonewline "Optionel: Entrez un terme à mettre en valeur (date, adresse, mot) : "; $Terme=read-host
if ($Terme -eq "") {$Terme="ZEFOISDF9IJOZFSFJKSLKDJHAIEJIJSDLFJSLKFKLJSDFIJEKL"}

write-host -nonewline "Obligatoire: Entrez un nom de serveur à tracker : "; $SERVEUR=read-host 

while ($true) {
	$Trackingdate=get-date -UFormat %D" "%T
	sleep $Temporisation
	$Messages=get-messagetrackinglog -server $SERVEUR -start $trackingdate
	If ($Messages) {
		$COULEUR="cyan"
		$Messages | ForEach-Object {
			If ($DEBUGLEVEL -eq 0  -and $_.EventID -ne "NOTIFYMAPI" -and $_.EventID -ne "SUBMIT")
				{ 
					$Background="black"		
					If ($_.EventID -match $TERME -or $_.Sender -match $TERME -or $_.Recipients -match $TERME -or $_.Timestamp -match $TERME -or $_.Source -match $TERME -or $_.Messagesubject -match $TERME) {$Background = $surlignage}
					$COULEUR=$Event_NONE
					if ($_.EventID -eq "SEND")
						{$COULEUR=$Event_SEND}
					if ($_.EventID -eq "RECEIVE")
						{$COULEUR=$Event_RECEIVE}
					if ($_.EventID -eq "DELIVER")
						{$COULEUR=$Event_DELIVER}
					if ($_.EventID -eq "TRANSFER")
						{$COULEUR=$Event_TRANSFER}
					if ($_.EventID -eq "FAIL")
						{$COULEUR=$Event_FAIL}
					if ($_.EventID -eq "DSN")
						{$COULEUR=$Event_DSN}

					#$TAILLE=[math]::truncate($_.TotalBytes/1GB)
					$Taille=$_.TotalBytes

					
					if ($_.EventID -eq "RECEIVE") {write-host -backgroundcolor $Background -foregroundcolor $COULEUR $_.Timestamp,$_.EventID,$([math]::truncate($Taille/1024)),"Kb",$_.Source,$_.Recipients, "<-----", $_.Sender,`t [ $_.MessageSubject ]}
					if ($_.EventID -eq "SEND") {write-host -backgroundcolor $Background -foregroundcolor $COULEUR $_.Timestamp,$_.EventID,$([math]::truncate($Taille/1024)),"Kb",$_.Source,$_.Sender, "=====>", $_.Recipients,`t [ $_.MessageSubject ]}
					if ($_.EventID -eq "DELIVER") {write-host -backgroundcolor $Background -foregroundcolor $COULEUR $_.Timestamp,$_.EventID,$([math]::truncate($Taille/1024)),"Kb","Message remis dans la banque d'information EXCHANGE pour", $_.Recipients,`t [ $_.MessageSubject ]}
					if ($_.EventID -eq "DSN") {write-host -backgroundcolor $Background -foregroundcolor $COULEUR $_.Timestamp,$_.EventID,$([math]::truncate($Taille/1024)),"Kb - Un message de non remise est transféré à", $_.Recipients,`t [ $_.MessageSubject ]}
					if ($_.EventID -eq "TRANSFER") {write-host -backgroundcolor $Background -foregroundcolor $COULEUR $_.Timestamp,$_.EventID,$([math]::truncate($Taille/1024)),"Kb",$_.Source,$_.Sender, "-=-=->", $_.Recipients,`t [ $_.MessageSubject ]}
					if ($_.EVENTID -ne "RECEIVE" -and $_.EventID -ne "SEND" -and $_.EventID -ne "DSN"  -and $_.EventID -ne "DELIVER" -and $_.EventID -ne "TRANSFER") {write-host -backgroundcolor $Background -foregroundcolor $COULEUR $_.Timestamp,$_.EventID,$([math]::truncate($Taille/1024)),"Kb",$_.Source,$_.Sender, "----->", $_.Recipients,`t [ $_.MessageSubject ]}
}
			If ($DEBUGLEVEL -eq 1)
				{	
					$Background="black"		
					If ($_.EventID -match $TERME -or $_.Sender -match $TERME -or $_.Recipients -match $TERME -or $_.Timestamp -match $TERME -or $_.Source -match $TERME -or $_.Messagesubject -match $TERME) {$Background = $surlignage}
					$COULEUR=$Event_NONE
					if ($_.EventID -eq "SEND")
						{$COULEUR=$Event_SEND}
					if ($_.EventID -eq "RECEIVE")
						{$COULEUR=$Event_RECEIVE}
					if ($_.EventID -eq "DELIVER")
						{$COULEUR=$Event_DELIVER}
					if ($_.EventID -eq "TRANSFER")
						{$COULEUR=$Event_TRANSFER}
					if ($_.EventID -eq "FAIL")
						{$COULEUR=$Event_FAIL}
					if ($_.EventID -eq "DSN")
						{$COULEUR=$Event_DSN}

					#$TAILLE=[math]::truncate($_.TotalBytes/1GB)
					$Taille=$_.TotalBytes

					
					if ($_.EventID -eq "RECEIVE") {write-host -backgroundcolor $Background -foregroundcolor $COULEUR $_.Timestamp,$_.EventID,$([math]::truncate($Taille/1024)),"Kb",$_.Source,$_.Recipients, "<-----", $_.Sender,`t [ $_.MessageSubject ]}
					if ($_.EventID -eq "SEND") {write-host -backgroundcolor $Background -foregroundcolor $COULEUR $_.Timestamp,$_.EventID,$([math]::truncate($Taille/1024)),"Kb",$_.Source,$_.Sender, "=====>", $_.Recipients,`t [ $_.MessageSubject ]}
					if ($_.EventID -eq "DELIVER") {write-host -backgroundcolor $Background -foregroundcolor $COULEUR $_.Timestamp,$_.EventID,$([math]::truncate($Taille/1024)),"Kb",$_.Source,$_.Sender, "<---->", $_.Recipients,`t [ $_.MessageSubject ]}
					if ($_.EventID -eq "TRANSFER") {write-host -backgroundcolor $Background -foregroundcolor $COULEUR $_.Timestamp,$_.EventID,$([math]::truncate($Taille/1024)),"Kb",$_.Source,$_.Sender, "-=-=->", $_.Recipients,`t [ $_.MessageSubject ]}
					if ($_.EVENTID -ne "RECEIVE" -and $_.EventID -ne "SEND" -and $_.EventID -ne "DELIVER" -and $_.EventID -ne "TRANSFER") {write-host -backgroundcolor $Background -foregroundcolor $COULEUR $_.Timestamp,$_.EventID,$([math]::truncate($Taille/1024)),"Kb",$_.Source,$_.Sender, "----->", $_.Recipients,`t [ $_.MessageSubject ]}

				}		
			}
		}
	}


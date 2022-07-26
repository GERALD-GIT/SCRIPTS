###################################################
# OOF       à planifier GSR CPRO INFORMATIQUE V1.0#
###################################################
"<head><title>Congès</title></head>"

"<BODY>"

"<Table border=""1"">"
foreach ($mailuser in ((Get-Mailbox|sort -property DisplayName) | Get-MailboxAutoReplyConfiguration | where {($_.autoreplystate -eq "scheduled") -or ($_.autoreplystate -eq "enabled" )}))

    {
	write-host $mailuser.identity.name
        if ($mailuser.autoreplystate -match "Enabled" )
        {
                "<TR><TD>Activée</TD><TD>$($mailuser.identity.name)</TD><TD></TD><TD></TD><TD>$($mailuser.InternalMessage)</TD><TD>$($mailuser.ExternalMessage)</TD></TR>"
        }
}
foreach ($mailuser in ((Get-Mailbox|sort -property DisplayName) | Get-MailboxAutoReplyConfiguration | where {($_.autoreplystate -eq "scheduled") -or ($_.autoreplystate -eq "enabled" )}))
{
	write-host $mailuser.identity.name
        if ($mailuser.autoreplystate -match "Scheduled" -and $mailuser.starttime -le ([DateTime]::Now) -and $mailuser.endtime -ge ([DateTime]::Now))
        {
                "<TR><TD>Planifiée</TD><TD>$($mailuser.identity.name)</TD><TD>$($mailuser.starttime.datetime)</TD><TD>$($mailuser.endtime.datetime)</TD><TD>$($mailuser.InternalMessage)</TD><TD>$($mailuser.ExternalMessage)</TD></TR>"
        }
    }   
foreach ($mailuser in ((Get-Mailbox|sort -property DisplayName) | Get-MailboxAutoReplyConfiguration | where {($_.autoreplystate -eq "scheduled") -or ($_.autoreplystate -eq "enabled" )}))
{
	write-host $mailuser.identity.name
if ($mailuser.autoreplystate -match "Scheduled" -and $mailuser.starttime -ge ([DateTime]::Now))
        {
                "<TR><TD>A venir</TD><TD>$($mailuser.identity.name)</TD><TD>$($mailuser.starttime.datetime)</TD><TD>$($mailuser.endtime.datetime)</TD><TD>$($mailuser.InternalMessage)</TD><TD>$($mailuser.ExternalMessage)</TD></TR>"
        }
    }
    
    
"</Table>"
"</BODY>"

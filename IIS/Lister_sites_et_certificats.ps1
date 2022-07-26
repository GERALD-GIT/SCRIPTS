del c:\temp\iisreport.html
$header = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title>Rapport IIS (CPRO 2020)</title>
<style type="text/css">
<!--
body {
background-color: #E0E0E0;
font-family: sans-serif
}

table {
    border: 1px;
    margin: 25px 0;
    font-size: 0.9em;
    font-family: sans-serif;
    min-width: 400px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
}
tr {
    background-color: #504069;
    color: #ffffff;
    text-align: left;
    border: 1px;
}
td  {padding: 12px 15px;
     border: 2px;}

-->
</style>
"@
$body = @"
<h1>Server Status</h1>
<p>Date de génération du rapport: $(get-date).</p>
"@
(Get-IISSite)|select id,name,state,@{n="bindings";e={$_.bindings|%{$_.bindinginformation+"::"}}},@{n='host';e={$_.bindings|%{$_.host+"::"}}},@{n='Certificat';e={ $_.bindings|%{if ($_.certificatehash -ne $null){$hash= [System.BitConverter]::ToString($_.certificatehash).replace('-','');(get-childitem Cert:\LocalMachine\ -Recurse |?{$hash -match $_.thumbprint}).friendlyname +"::"}}}},@{n='Date limite';e={ $_.bindings|%{if ($_.certificatehash -ne $null){$hash= [System.BitConverter]::ToString($_.certificatehash).replace('-','');(get-childitem Cert:\LocalMachine\ -Recurse |?{$hash -match $_.thumbprint}).notafter.tostring()+"::"}}}}|ConvertTo-Html -Head $header |%{$PSItem -replace "<td>Started</td>", "<td style='background-color:#80BB80'>Démarré</td>" -replace "<td>Stopped</td>", "<td style='background-color:#FF8080'>Arrêté</td>" -replace "::","</br>"} | Out-File -FilePath C:\temp\IISREPORT.HTML

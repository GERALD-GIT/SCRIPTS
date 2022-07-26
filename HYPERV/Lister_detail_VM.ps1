$DIR="c:\cpro"
$css=@'
table
{
Margin: 2px 2px 2px 4px;
Border: 2px solid rgb(190, 190, 190);
Font-Family: Arial;
Font-Size: 8pt;
Background-Color: rgb(252, 252, 252);
}
tr:hover td
{
Background-Color: rgb(0, 127, 195);
Color: rgb(255, 255, 255);
Font-Size: 8pt;
}
tr:nth-child(even)
{
Background-Color: rgb(90,240, 130);
    width: 1px;
    white-space: nowrap;
}
th
{
Text-Align: Left;
Color: rgb(150, 150, 220);
Padding: 1px 4px 1px 4px;
}
td
{
Vertical-Align: Top;
Padding: 1px 4px 1px 4px;
}
th.fitwidth {

}
'@
$css|out-file -filepath "$dir\css.Css"



$a=(Get-vm -ComputerName hvhost1)
$b=(Get-vm -ComputerName hvhost2)
$c=$a+$b
$i=0

($c|%{
$i=$i+1;
Write-Progress -activity "$_" -status "Traité: $i sur $($c.Count)" -percentComplete (($i / $c.Count)*100)
$_|select vmname,path,automatics*,@{name="Mémoire";expr={$_.MemoryAssigned/1024/1024}},@{name="Disks";expr={$_.harddrives.path}}, @{name="Taille";expr={$vm=$_; $vm.harddrives.path|%{((get-vhd -computername $vm.computername -path $_).size/1024/1024/1024).tostring()+ "Gb"}}},generation,processorcount,version,computername,@{name="Réseau";expr={$_.networkadapters|%{$_.name + " sur"+ $_.switchname}}},@{name="IP";expr={$_.networkadapters|%{$_.ipaddresses}}}})|ConvertTo-Html -CssUri "$dir\css.Css" |Out-File "$dir\VMList.html"
"$dir\VMList.html"

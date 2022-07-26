new-alias new new-object
function SearchDB(){
$text=read-host "Quel terme rechercher ?"
$a="SELECT System.ItemName, System.DateCreated ,System.Author, System.Comment ,System.Subject FROM SYSTEMINDEX where freetext('""$text""')"
$b="provider=search.collatordso;extended properties='application=windows';"
$r= new System.Data.OleDb.OleDbDataAdapter -ArgumentList $a,$b
$ds=new System.Data.DataSet
$r.fill($ds)
$ds.tables.rows|ogv
}
while ($true){searchdb}

function DynGroup{
           <#
           .SYNOPSIS

            Script CPRO (GSR 05/2020)
           
            Gestion des groupes AD dynamiquement. Recherche basée sur l'attribut société ou service
           
           .DESCRIPTION
            
            Gestion des groupes AD dynamiquement. Recherche basée sur l'attribut société ou service
            En fin de script, la description du groupe est modifiée pour refléter la date de dernier changement.
            

           .PARAMETER Groupe
            Nom du groupe AD dynamique. Les groupes système (Well known SID) ne sont pas autorisés

           .PARAMETER Recherche
            Champs 'Company' ou 'Deparment' à rechercher, non sensible à la casse.

           .PARAMETER Attribut
            Attribut à rechercher, Accepté: Company (société) ou Department (service) (utilisation de TAB possible)

           .PARAMETER ViderLeGroupe
            Booléen, indique si le groupe doit être vidé avant. Un export sera réalisé dans un fichier temporaire
            Attention, il n'y aura pas de confirmation une fois le script lancé
          
        
           .EXAMPLE
           
            PS C:\> DynGroup -groupe Agences -Recherche "Agence de Lyon" -Attribut Company -ViderLeGroupe $false

            Ajoute les utilisateurs dont le champs Société est "Agence de Lyon" dans le groupe Agences sans supprimer ses membres existants.


           .EXAMPLE
           
            PS C:\> DynGroup -groupe Market -Recherche "Marketing" -Attribut Department -ViderLeGroupe $true
            
            Ajoute les utilisateurs dont le champs Service est "Marketing" dans le groupe Market. Supprime les membres

            
            .EXAMPLE

            PS C:\> Get-ADGroup -filter * -SearchBase "ou=DPT,ou=comptes,dc=domainefictif,dc=fr"|%{ DynGroup -Groupe $_.name -Recherche $_.name -Attribut Department -ViderLeGroupe $true}

            Remplit de manière récursive et automatique les groupes situés dans un Unité d'Organisation DOMAINEFICTIF.FR/COMPTES/DPT en y ajoutant les utilisateurs dont l'attribut Service correspond au nom du groupe


          #>
     param(
     [parameter(Mandatory=$True, HelpMessage="Nom du groupe AD dynamique.")]
     [ValidateNotNullOrEmpty()]
     [string] $Groupe,
     [parameter(Mandatory=$True, HelpMessage="Champs 'Company' ou 'Deparment' à rechercher, non sensible à la casse.")]
     [ValidateNotNullOrEmpty()]
     [string] $Recherche,
     [Parameter(Mandatory=$true, HelpMessage="Attribut à rechercher, Accepté: Company ou Department")]
     [ValidateNotNullOrEmpty()]
     [ValidateSet('Company','Department')]
     [string]$Attribut,
     [parameter(Mandatory=$True, HelpMessage="Booléen, indique si le groupe doit être vidé avant. Un export sera réalisé dans un fichier temporaire")]
     [ValidateNotNullOrEmpty()]
     [bool] $ViderLeGroupe
     )
     # alias pour la commande new
     new-alias new New-Object;

     # Importe le module d'administration AD
     import-module ActiveDirectory;

     # Désactivation des messages d'erreur
     #$ErrorActionPreference= 'silentlycontinue'

     # transformation de String en Microsoft.ActiveDirectory.Management.ADGroup
     # Par sécurité, les WellKnown SID Security Groups ne sont pas modifiables
     try{
     $groupe=get-adgroup $groupe |?{[int]::parse( $_.sid.tostring().split('-')[-1]) -gt 1000};

     }
     catch
     # Arrêt du programme si le groupe n'existe pas
     {
        "Une erreur est survenue pendant la recherche du groupe";
        $_.exception.message;
        break;
     }

       
    # récupération de la liste d'utilisateurs non désactivés avec l'attribut company = $Recherche,
    if ($Attribut -eq "Company")
        {
        $users=get-aduser -Filter * -Properties company |
        ?{
                $_.company -ne $null -and $_.company.tolower() -eq $Recherche.ToLower();
            }|
            ?{
               $_.enabled;
             }
               
        ([array]$users).count.tostring() +" utilisateur(s) à copier dans le groupe $groupe";
        $users.name;
        }

    # récupération de la liste d'utilisateurs non désactivés avec l'attribut department = $Recherche,
    if ($Attribut -eq "Department")
        {
        $users=get-aduser -Filter * -Properties department |
        ?{
                $_.department -ne $null -and $_.department.tolower() -eq $Recherche.ToLower();
            }|
            ?{
               $_.enabled;
             }
        ([array]$users).count.tostring() +" utilisateur(s) à copier dans le groupe $groupe";
        $users.name;
        }
        


    #si le nombre d'utilisateurs est supérieur à zéro, alors le groupe est vidé et le tableau est injecté dans le groupe
    if ($users -ne $null){
        # si $viderlegroupe est vrai, une sauvegarde est faite
        if ($ViderLeGroupe -eq $true){
            $CheminDeBackup=$CheminDeBackup="$env:TEMP\"+$groupe+"-membersbackup.txt";
            "Le groupe sera vidé, son contenu actuel sera lisible dans $CheminDeBackup ";
            # Sauvegarde
            $groupe |Get-ADGroupMember|out-file -psPath "$CheminDeBackup";
            # Vidage
            $groupe |set-adgroup -clear member;
        }

        # remplissage
        Add-ADGroupMember -Identity $groupe -Members $users
        set-adgroup $groupe -Description "Groupe dynamique géré par un script. Dernière mise à jour $([system.datetime]::now) pour $($users.count) utilisateurs";
        
        }
        else
        {
        "Aucun utilisateur n'a été trouvé, le groupe n'a pas été modifié";
        }
     }

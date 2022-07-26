#######################################

# PowerShell function : 
# Author: GSR KOESIO update 05-2022


Function Get-PermissionsDesDossiers {

<#
        .NOTES
        GERALD SOEUR [KOESIO INFORMATIQUE]

        .SYNOPSIS
        Lister les permissions sur les dossiers

        .DESCRIPTION
        Pour un répertoire donné, liste les sous dossiers dont les acl ne sont pas 100% héritées
        retourne les acl au format string

        .PARAMETER cheminDeBase
        donenr un chemin de base. Attention il faut avoir les permissions d'y accéder et d'énumérer les ACL

        
        .EXAMPLE
        PS> Get-PermissionsDesDossiers -chemindebase "c:\test"
    #>
[cmdletbinding()]
    Param (
    [Parameter(Mandatory=$true)]
    [string]$cheminDeBase
    )
    # Fin des param
    Process {
        $compteur=0 #compteur de progression

        write-host -ForegroundColor Cyan "Creation de l'arborescence"
        $listDesPermissions="Chemin;Utilisateur;Permission;Type;Propagation"+[System.Environment]::NewLine
        $reps=Get-ChildItem -Recurse -Directory $cheminDeBase
        write-host -ForegroundColor Cyan "Récupération des dossiers avec permissions personalisées"
        
        (( $reps|%{
                $compteur++
                Write-Progress $_ -PercentComplete (100/$reps.count*$compteur)
                 $curFol=$_.FullName;(get-acl $_.FullName) |%{$_.access}|?{
                    $_.IsInherited -eq $false}|%{

                    $listDesPermissions+="$($curFol);$($_.identityreference);$($_.FileSystemRights);$($_.AccessControlType);$($_.PropagationFlags)"+[System.Environment]::NewLine
                    } 
                })
                )

        write-host -ForegroundColor Cyan "Récupération du nom complet du dossier et des permissions"

        

        return $listDesPermissions
    }
    # Fin du process
}

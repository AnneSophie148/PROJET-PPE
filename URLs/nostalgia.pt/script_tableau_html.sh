
# Le programme va vérifier qu'on donne bien deux arguments (fichier et tableau.HTML) puis crée le tableau html en imprimant dessus les lignes de codes html qui vont créer les colonnes ligne, code et url
if [ $# -ne 2 ]
then
        echo " ce programme demande deux arguments"
        exit
fi

#On lance le programme sur le terminal avec la commande bash suivit du nom du script puis l'argument tableau.HTML
#paramètres = prendre le code de réponse du serveur (entete), les lignes(lineno) et les urls(line)

#===============================================================================

fichier_urls=$1 # le fichier d'URL en entrée
fichier_tableau=$2 # le fichier HTML en sortie


# ici on doit vérifier que nos deux paramètres existent, sinon on ferme!

# on écrit en echo ce que le script html doit contenir pour faire le tableau html, puis la balise <tr> permet de dire 3 colonnes, puis <th> sert pour The Table Header element /titre de la colonne
echo "<html>
	<head>
		<meta charset ="utf-8"/>
                <title> tableau URL </title>
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" />
                </head>
                <body>
                <table>
                <tr>
                <th> ligne </th>
                <th>code</th>
                <th>url</th> 
                </tr>" >$fichier_tableau
                lineno=1;
                while read -r line;
do
	entete=$(curl -I -s $line | head -n1) #obtenir l'en tête du serveur -s = code silencieux et affiche seulement la première ligne grâce à head -n1
	lineno=$((lineno+1));
echo "<tr><td>$lineno</td><td>$entete</td><td>$line</td></tr>" >> $fichier_tableau
lineno=$((lineno+1));
done < $fichier_urls
echo "</table></body></html>" >> $fichier_tableau


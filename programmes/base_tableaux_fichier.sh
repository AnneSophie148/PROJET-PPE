#!/usr/bin/env bash

#===============================================================================
# VOUS DEVEZ MODIFIER CE BLOC DE COMMENTAIRES.
# Ici, on décrit le comportement du programme.
# Indiquez, entre autres, comment on lance le programme et quels sont
# les paramètres.
# La forme est indicative, sentez-vous libres d'en changer !
# Notamment pour quelque chose de plus léger, il n'y a pas de norme en bash.
#===============================================================================

fichier_urls=$1 # le fichier d'URL en entrée
fichier_tableau=$2 # le fichier HTML en sortie

if [[ $# -ne 2 ]]
then
	echo "Ce programme demande exactement deux arguments."
	exit
fi

mot="nostalgie" # à modifier

echo $fichier_urls;
basename=$(basename -s .txt $fichier_urls)

echo "<html><body>" > $fichier_tableau
echo "<h2>Tableau $basename :</h2>" >> $fichier_tableau
echo "<br/>" >> $fichier_tableau
echo "<table>" >> $fichier_tableau
echo "<tr><th>ligne</th><th>code</th><th>URL</th><th>encodage</th><th>compte</th><th>aspirations</th><th>dumps</th><td>contextes</td></tr>" >> $fichier_tableau

lineno=1;
while read -r URL; do
	echo -e "\tURL : $URL";
	# la façon attendue, sans l'option -w de cURL
	# curl -I -L -s $URL : sortie propre pour avoir les en-têtes
	code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1) #L suit les redirections ?; tail -n 1 : on prend les dernières lignes du fichier et dernière ligne qu'on prend = l1
	charset=$(curl -ILs $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2) 
	aspiration=$(curl $URL)
	echo "$aspiration" > "aspirations/$basename-$lineno.html"
	

	# autre façon, avec l'option -w de cURL
	# code=$(curl -Ls -o /dev/null -w "%{http_code}" $URL)
	# charset=$(curl -ILs -o /dev/null -w "%{content_type}" $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2); -d : délimiteur, découpe chaine en diff colonne, f = field soit colonnes ABCD.. dans excel

	echo -e "\tcode : $code";

	if [[ ! $charset ]]
	then
		echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
		charset="UTF-8";
	else
		echo -e "\tencodage : $charset";
	fi

	if [[ $code -eq 200 ]]
	then
		dump=$(lynx -dump -nolist -assume_charset=$charset -display_charset=$charset $URL)
		echo "$dump" > "dumps-text/$basename-$lineno.txt" 
		compte=$(echo $dump|egrep -o "nostalgia" | wc -l)
		contexte=$(echo "$dump"|grep -E -A2 -B2 "nostalgia")
		echo "$contexte" > "contextes/$basename-$lineno.txt"
		
		
		
		if [[ $charset -ne "UTF-8" && -n "$dump" ]]
		then
			dump=$(echo $dump | iconv -f $charset -t UTF-8//IGNORE)
		fi
	else
		echo -e "\tcode différent de 200 utilisation d'un dump vide"
		dump=""
		charset=""
	fi

	echo "<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td>$aspiration</td><td>$dumps</td><td>$compte</td></tr>" >> $fichier_tableau
	echo -e "\t--------------------------------"
	lineno=$((lineno+1));
done < $fichier_urls
echo "</table>" >> $fichier_tableau
echo "</body></html>" >> $fichier_tableau

#!/usr/bin/env bash


fichier_urls=$1 # le fichier d'URL en entrée
fichier_tableau=$2 # le fichier HTML en sortie
mot=$3

#cette partie permet de vérifier que l'utilisateur a bien donné trois arguments
if [[ $# -ne 3 ]]
then
	echo "Ce programme demande exactement trois arguments."
	exit
fi

#on récupère le nom du fichier sans l'extension
echo $fichier_urls;
basename=$(basename -s .txt $fichier_urls)
#on crée le tableau html pour chaque langue
echo "<html>" >> $fichier_tableau
#importation de bulma
echo "<link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/bulma/0.7.1/css/bulma.min.css\">" >> $fichier_tableau
echo "<body>" >> $fichier_tableau
echo "<p align=\"center\" class=is-size-1><FONT COLOR=\"800080\">Tableau $basename :</FONT></p>" >> $fichier_tableau
echo "<br/>" >> $fichier_tableau
echo "<table border=1 class=\"table is-striped\" align="center">" >> $fichier_tableau
echo "<tr style=\"background-color:lavender\"><th>ligne</th><th>code</th><th>URL</th><th>encodage</th><th>aspirations</th><th>dumps</th><th>compte</th><th>contextes</th><th>concordances</th></tr>" >> $fichier_tableau

lineno=1;
while read -r URL; do
	echo -e "\tURL : $URL";
	# la façon attendue, sans l'option -w de cURL
	# curl -I -L -s $URL : sortie propre pour avoir les en-têtes
	code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1) #L suit les redirections ?; tail -n 1 : on prend les dernières lignes du fichier et dernière ligne qu'on prend = l1
	charset=$(curl -ILs $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2) 
	aspiration=$(curl -s $URL)
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
		compte=$(echo $dump|egrep -o $mot | wc -l)
		#on va cherche les contextes:
		contexte=$(echo "$dump"|grep -E -A2 -B2 $mot)
		echo "$contexte" > "contextes/$basename-$lineno.txt"
		
		
		if [[ $charset -ne "(UTF-8|utf-8)" && -n "$dump" ]]
		then
			dump=$(echo $dump | iconv -f $charset -t UTF-8//IGNORE)
		fi
		echo "$dump" > "dumps-text/$basename-$lineno.txt" 
	else
		echo -e "\tcode différent de 200 utilisation d'un dump vide"
		dump=""
		charset=""
	fi
	 # construction des concordances avec une commande externe : on lance le programme des concordanciers
  bash ./programmes/concordance.sh ./dumps-text/$basename-$lineno.txt $mot > ./concordances/$basename-$lineno.html

	echo "<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href=\"../aspirations/$basename-$lineno.html\">aspiration</a></td><td><a href=\"../dumps-text/$basename-$lineno.txt\">dump</a></td><td>$compte</td><td><a href=\"../contextes/$basename-$lineno.txt\">contextes</a></td><td><a href=\"../concordances/$basename-$lineno.html\">concordance</a></td></tr>" >> $fichier_tableau
	
	echo -e "\t--------------------------------"
	lineno=$((lineno+1));
done < $fichier_urls
echo "</table>" >> $fichier_tableau
echo "</body></html>" >> $fichier_tableau

 



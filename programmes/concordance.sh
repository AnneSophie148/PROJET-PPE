fichier_text=$1
mot=$2
#motif = nostalgia

if [[ $# -ne 2 ]]
then
	echo "Ce programme demande exactement deux arguments."
	exit
fi

if [[ ! -f $fichier_text ]]
then
  echo "le fichier $fichier_text n'existe pas"
  exit
fi

if [[ -z $mot ]]
then
  echo "pas de motif"
  exit
fi

echo "
<!DOCTYPE html>
<html lang=\"en\">
<head>
  <meta charset=\"UTF-8\">
  <title>Concordance</title>
</head>
<body>
<table>
<thead>
  <tr>
    <th class=\"has-text-right\">Contexte droit</th>
    <th>Cible</th>
    <th class=\"has-text-left\">Contexte gauche</th>
  </tr>
</thead>
<tbody>
"

grep -E -o "(\w+\W+){0,5}\b$mot\b(\W+\w+){0,5}" $fichier_text | sed -E "s/(.*)($mot)(.*)/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><\/tr>/"

echo "
</tbody>
</table>
</body>
</html>
"

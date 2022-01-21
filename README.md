# Csound x Python pour la sonification de données

Au tout début de pratique artistique, je codais des fichiers MIDI directement en MATLAB ou en C.

Depuis quelques années, mes deux principaux outils pour la sonification de données sont [Csound](https://www.csound.com) et [Python](https://www.python.org/).

Si la curiosité l'emporte et que vous souhaitez savoir comment je m'y prends - et qui sait, créer vos propres pièces de sonification de données ! - voici un coup d'oeil derrière la scène.

Ceci se veut une introduction accélérée au fonctionnement de Csound ainsi qu'un bref aperçu du processus de création avec Python que j'utilise. J'ajoute à la fin des références choisies sur ces deux éléments afin de vous permettre d'aller plus loin.

## Le projet complet

L'idée est de présenter une façon de sonifier des données à l'aide d'un script Python qui génère une partition Csound.

Vous trouverez tous les fichiers présentés dans ce tutoriel sur [le repo eviau/datasonification, situé sur GitHub](https://www.github.com/eviau/datasonification).

## Les données

J'ai inclut un jeu de données fictives sous forme de fichier `.csv` dans `donnees.csv`. Elles ne représentent rien en particulier - ce sont des chiffres générés aléatoirement. Elles nous seront bien utiles pour l'exemple du moment; libre à vous d'utiliser les données qui vous chantent.

## Création d'un instrument avec Csound

Dans le fichier `sonification_0.csd` se trouve un instrument de base qui vous permettra de vérifier que nous sommes sur la même longueur d'onde. Ce fichier fait jouer une une vague sinusoïdale pendant 4 secondes. Vous pouvez l'interpréter avec Csound avec la ligne de commande:

    csound sonification_o.csd

Le fichier est constitué de trois parties essentielles, soit les options, les instruments, et la partiton.

### Les options

C'est ce qui se trouve entre les deux balises `<CsOptions>` et `</CsOptions`>.

Nous allons passer l'option `-odac` afin de pouvoir écouter le son en direct, sans devoir passer par la création d'un fichier.

### Les instruments

Notre instrument se touve entre les deux balises `<CsInstruments>` et `</CsInstruments>`:

```
        instr 1
a1      oscil   10000, 440, 1
        out     a1
        endin
```

La première ligne attribue un nombre à l'instrument; ici, le nombre `1`. 

La seconde utilise l'opcode `oscil` avec les arguments `10000` (amplitude), `440` (fréquence en cycles par seconde) et `1`, le numéro de la table où sont stockées les données que nous souhaitons utiliser avec l'oscillateur - nous y reviendrons plus tard.

On peut regarder la [documentation de `oscil`](https://csound.com/docs/manual-fr/oscil.html) pour toute l'information.

Notez que les données sortant de `oscil` sont stockées dans la variable `a1`.

La troisième ligne définie la sortie de l'instrument comme étant la valeur de son argument, soit `a1`.

Et enfin, `endin` sur la quatrième ligne signifie que c'est la fin de la définition de l'instrument `1`.

### La partition

Nous en sommes aux balises `<CsScore>` et `</CsScore>`. 

La partition comporte deux sections: les `f-tables` qui servent à stocker des données et la partition comme telle.

#### Les `f-tables`

Les [`f-tables`](https://csound.com/docs/manual-fr/f.html) sont les données utilisés par les oscillateurs - entre autres. Dans notre cas, nous n'en avons qu'une:

```
f1  0   4096    10 1 
```

Ce qu'il faut retenir:

* le premier `1` est le nombre qui sert à nommer la table dans l'instrument - c'est le même `1` que celui  pris comme argument par `oscil` dans la définition d'instrument
* l'argument prenant comme valeur `10` signifie que l'on utilise [`GEN10`](https://csound.com/docs/manual-fr/GEN10.html), ce qui nous donne le sinusoïde

Pour cet exercice, nous prenons cette table comme telle; nous n'allons y apporter aucun changement plus tard.

#### La partition

C'est ici que nous allons signifier à CSound quand et comment jouer de notre instrument.

Dans le fichier de départ, `sonification_0.csd`, nous avons l'instruction suivante:

```
;ins    start    dur
i1      0        4
```

Ceci signifie que Csound doit jouer de l'instrument `1` dès la seconde `0` pour une durée de `4` secondes.

### Jouer différentes notes

Nous allons apporter deux changements à notre fichier de départ afin de pouvoir changer la fréquence de notre sinusoïde.

#### Ajout d'information à la partition

Nous ajoutons une colonne à la partition afin de stocker l'information sur la fréquence jouée. Pour bien démontrer le concept, nous allons jouer une série de trois notes au lieu d'une seule. Remplaçons l'instrument défini à la section précédente par:


```
;ins    start    dur    freq
i1      0        4      220
i1      4        4      360
i1      8        4      440

```

Chaque note a une durée de 4 secondes. Pour faire en sorte que cette nouvelle information puisse être utilisée par l'instrument, nous devons le mettre à jour.


#### Ajout d'information à l'instrument

Le nom de la colonne où la fréquence est stockée est `p4` - nous allons permettre à l'instrument `1` d'y accéder en changeant son code:

```
        instr 1
a1      oscil   10000, p4, 1
        out     a1
        endin
```

Remarquez que la fréquence `440` prend maintenant les valeurs données par la colonne `p4`. Si on joue le fichier ainsi créé, stocké dans le fichier `sonification_1.csd`, nous allons entendre trois notes distinctes.

## Le script Python

Générons la partition Csound avec Python. Le code se trouve dans le fichier `generation.py`.

Commencez par installer les librairies `pandas`,s possiblement dans un environnement virtuel. Nous allons utiliser `pandas` pour importer et lire les données, mais c'est tout - c'est plus simple de manipuler les données avec cette librairie dans bien des cas, quoiqu'il est possible de faire les mêmes opérations avec la librairie standard de Python.

Regardons le code et ajoutons quelques commentaires:

```
# importation de la librairie pandas
import pandas

# importation des données dans un `DataFrame` 
data = pandas.read_csv('donnees.csv')

# on peut vérifier que les données ont bel et bien été importées
print(data.head())

# initialisation des variables de temps
start_time = 0
duration = 4

# on commence la sonification!
print("Data sonification GO!")

# on crée un itérateur Python à partir des données - pour chaque ligne du `DataFrame`...
for index, row in data.iterrows():
    # nous allons imprimer dans le Terminal une chaîne de caractère correspondant au score
    print('i1'+ "   " +  str(start_time) + '   ' + str(duration) + '   ' + str(round(row['Valeur']*100.00)))
    # incrémentation de la variable de temps `start_time`
    start_time += duration
```

Ce qui nous intéresse, c'est la dernière instruction `print()`, soit:

```
print('i1'+ "   " +  str(start_time) + '   ' + str(duration) + '   ' + str(round(row['Valeur']*100.00)))
```

Le premier morceau, `i1`, concerne le nombre de l'instrument qui doit être joué.
Le second, `str(start_time)`, définit le moment à laquelle cette note sera jouée - pour jouer les notes en série, nous l'incrémentons suite à chaque note avec `start_time = duration`.
Le troisième, `str(duration)`, précise la durée de la note qui sera jouée.
Et enfin, `str(round(row(['Valeur']) * 100.00)))` définit la fréquence à jouer, à partir des données importées. Dans notre cas, c'est la donnée trouvée à la ligne `row` pour la colonne `Valeur` que nous multiplions par 100.00 et que nous arrondissons au nombre entier le plus près avec `round`. Le chiffre `100.00` afin d'obtenir une fréquence audible à partir des données utilisées.

## Génération de la partition Csound à partir du script Python

Et enfin, le moment tant attendu ! Sur la ligne de commande, on exécute le code Python:

```
python3 generation.py
```

On obtient la sortie suivante dans la fenêtre de Terminal:

```
   Valeur
0    2.45
1    2.46
2    2.89
3    5.10
4    1.03
Data sonification GO!
i1   0   4   245
i1   4   4   246
i1   8   4   289
i1   12   4   510
i1   16   4   103
i1   20   4   349
i1   24   4   452
i1   28   4   312
i1   32   4   290
i1   36   4   299
```

C'est la partie qui suit `Data sonification GO!` qui nous intéresse. Nous la copions à la place de la parition définie précédemment dans le fichier Csound. Le résultat final est dans le fichier `sonification_2.csd`. Nous pouvons l'exécuter avec Csound :

```
csound sonification_2.csd
```

Et nous allons entendre une série de notes distinctes. Si c'est le cas, bien joué ! Sinon, écrivez un commentaire sur [GitHub](https://www.github.com/eviau/datasonification/issues).

## Références

Pour des références afin d'apprendre Csound:

* [la page *Get Started* sur csound.com](https://csound.com/get-started.html) qui vous apprendra la structure d'un fichier `.csd`
* [la nouvelle édition interactive du manuel](https://flossmanual.csound.com/introduction/preface) pour pouvoir tester les exemples directement dans votre navigateur
* [le manuel de référence canonique, en français](https://csound.com/docs/manual-fr/index.html) pour tout savoir sur Csound
* [un bref tutoriel sur le design d'instrument](http://www.csounds.com/toots/index.html) pour un premier pas créatif avec Csound




# mo5_challenge

Ce dépôt regroupe les informations sur le challenge à base de l'animation Asciiwars de Simon Jensen

![AsciiWars](https://github.com/delhoume/mo5_challenge/blob/main/asciiwars720.gif)

#### RÈGLEMENT:

### Article 1:  

Il n'y a pas de règlement, pas d'obligation, pas d'enjeu

Il s'agit uniquement de s'amuser avec cette animation et d'en faire ce qu'elle vous inspire.




####  Description des fichiers :  
- ```asciimation.txt``` le fichier source de l'animation. 47740 lignes décrivant 3410 frames, soit 14 lignes par frame. 11999080 octets

- ligne 1: nombre décimal representant le nombre d'unités de temps pendant laquelle la frame doit être affichée

- lignes 2 à 13: jusqu'à 67 caractères ASCII représentant le contenu de la frame, calé à gauche.

exemple:

![Frame](https://github.com/delhoume/mo5_challenge/blob/main/frame.png)

L'animation compte 3410 frames, et la durée totale est de 12.25mn à 25 images par seconde
Ce format est simple à parser mais n'est pas adadpté aux ordinateurs retro disposant de très peu de mémoire.

- le script  ```python convert.py``` sépare les délais et le contenu graphique des frames normalisées à 67 caractères, pour simplifier la visualisation dans le framework Processing (http://processing.org) avec  ```Processing/AsciiWars/AsciiWars.pde```

à partir de ```asciimation.txt```, on obtient ```Processing/AsciiWars/data/delays.bin``` avec les 3410 delais chacun sur 1 octet, et ```Processing/AsciiWars/data/rawframes.bin``` (3410 x 13 x 67 = 2970110 octets) qui contient les frames brutes.

Un essai de compression avec gzip et zx5 montre que même si le fichier ```rawframes.bin``` est plus gros que ```asciimation.txt```,  à cause (grâce à) de la normalisation, il est plus petit une fois compressé !

| taille | fichier         |
|--------|-----------------|
|1999080|asciimation.txt           
|72714|asciimation.txt.gz|
|71227|asciimation.txt.zx0|
|2970110|rawframes.bin|
|69919|rawframes.bin.gz|
|64228|rawframes.bin.zx0|


 Le taux de compression est très important, on arrive à obtenir sans traitement particulier un ficher de moins de 65536 octets qui démontre la possibiité matérielle d'avoir cette animation sur des micros 16bits.
Il faudra disposer de librairies de décompression adaptées (en streaming), et encore gagner en taille...

Quelques pistes pour reduire encore la taille:

- il y a ```grep -i . -o asciimation.txt | sort | uniq -ci | wc -l``` 93 caractères différents, il ne faut que 7 bits pour tous les coder.

- la fréquence de certains caractères est beaucoup plus importante que d'autres, on pourrait en tenir compte

- considérer les frames comme une image bitmap. voir le script python qui génère un pgm

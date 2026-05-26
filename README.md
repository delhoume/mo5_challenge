# mo5_challenge

Ce dépôt regroupe les informations sur le challenge à base de l'animation Asciiwars de Simon Jensen

![AsciiWars](https://github.com/delhoume/mo5_challenge/blob/main/asciiwars720.gif)

#### RÈGLEMENT:

Il n'y a pas de règlement, pas d'obligation, pas d'enjeu

Il s'agit uniquement de s'amuser avec cette animation et d'en faire ce qu'elle vous inspire.




####  Description des fichiers :  
- ```asciimation.txt``` le fichier source de l'animation. 47740 lignes décrivant 3410 frames, soit 14 lignes par frame.

- ligne 1: nombre décimal representant le nombre d'unités de temps pendant laquelle la frame doit être affchée

- lignes 2 à 13: jusqu'à 67 caractères ASCII représentant le contenu de la frame, calé à gauche.

exemple:

![Frame](https://github.com/delhoume/mo5_challenge/blob/main/frame.png)

L'animation compte 3410 frames, et la durée totale est de 12.25mn à 25 images par seconde
Ce format est simple à parser mais n'est pas adadpté aux ordinateurs retro disposant de très peu de mémoire.

- le script python ``python convert.py`` sépare les délais et le contenu graphique des frames normalisées à 67 caractères, pour simplifier la visualisation dans le framework Processing avec  ```processing/asciiwars.pde```

à partir de `asciimation.txt`, on obtient
`processing/data/delays.bin` avec les 3410 delais chacun sur 1 octet, et `processing/data/rawframes.bin (5410 x 67  x 13 octets)`

un essai de compression avec gzip et zx5 montre que même si le fichier `rawframes.bin` est plus gros que `asciimation.txt` à cause de la normalisation, il est plus petit une fois compressé !

```
1999080 asciimation.txt
72714   asciimation.txt.gz
71227   asciimation.txt.zx0
2970110 rawframes.bin
69919   rawframes.bin.gz
64228   rawframes.bin.zx0
```

Le taux de compression est très important, on arrive à obtenir sans traitement particulier un ficher de moins de 16 bits qui démontre la possibiité matérielle d'avoir cette animation sur des micros 16bits.
Il faudra disposer de librairies de décompression adaptées (en streaming)

Quelques pistes pour reduire encore la taille:

- il y a `grep -i . -o asciimation.txt | sort | uniq -ci | wc -l` 93 caractères différents, il ne faut que 7 bits pour tous les coder.

- la fréquence de certains caractères est beaucoup plus importante que d'autres, on pourrait en tenir compte

- consdidérer les frames comme une image bitmao. voir le script python qui génère un pgm

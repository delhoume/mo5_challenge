# mo5_challenge

Ce dépôt regroupe les informations sur le challenge à base de l'animation Asciiwars de Simon Jensen

<img width="928" height="540" alt="image" src="https://github.com/user-attachments/assets/e81e8681-0217-4b63-95f7-32a4fe8fe5b4" />

#### RÈGLEMENT:

### Article 1:  

Il n'y a pas de règlement, pas d'obligation, pas d'enjeu

Il s'agit uniquement de s'amuser avec cette animation et d'en faire ce qu'elle vous inspire.




####  Description des fichiers :  
- ```asciimation.txt``` le fichier source de l'animation. 47740 lignes décrivant 3410 frames, soit 13 lignes par frame. 11999080 octets

- ligne 1: nombre décimal representant le nombre d'unités de temps pendant laquelle la frame doit être affichée

- lignes 2 à 13: jusqu'à 67 caractères ASCII représentant le contenu de la frame, calé à gauche. chaque ligne est rtrminée par un '\n', la fin de ligne est vide.


L'animation compte 3410 frames, et la durée totale est de 12.25mn à 25 images par seconde
Ce format est simple à parser mais n'est pas adapté aux ordinateurs retro disposant de très peu de mémoire.

- le script  ```convert.py``` sépare les délais et le contenu graphique des frames normalisées à 67 caractères, et encode les répétitions de caractères fréquentes avec des opcodes specialisés de 1 ou 3 octets < 128, donc toujours 7 bits. Le fichier genéré par le makefile est asciimation8.bin et fait 36% de la taille d'origine. IL y a beaucoup de trous dans les valeurs utilisées par l'animation du fait de la présence de caractères affichables  uniquements.


Ce fichier est ensuite compacté avec 7 bits par valeur par `pack7bits.c` qui encode avec une réduction suplémentaire  de 8.75%. Au final, les données de frames passent de 1843039 à 572587 octets.

Le visualiseur SDL `mo5wars_sdl.c` lit le fichier `asciimation7.bin` généré par pack7bit, le décode à la volée et affiche en boucle les frames. Son modèle graphique est celui du mo5.

pour l'instant je n'ai pas éussi a lire vers un buffer limité en ram, en chargeant depuis le fichier quand le buffer est épuisé.



S'il est possible de stoker ce fichier sur une disquette, selon les vitesses de transfert il devrait être possible de ne garder qu'une partie en RAM, voire de lire directement depuis la disquette. une frame fait avant compression 13x67 = 884, et 1/4 environ compressé.

l'affichage sur mo5 est tronqué, avec une police de 5x5 etu n  écart entre caractères de 1, il faut une largeur de 402 pixels  pour afficher toute la largeur.


C'est la valeur par défaut dans mo5wars.c, pour voir l'effet sur un mo5, il suffit de definir MO5 à la compilation.
`>make clean run MO5=-DMO5`

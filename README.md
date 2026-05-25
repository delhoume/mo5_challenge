# mo5_concours

Ce dépôt regroupe les informations 
sur le challenge à base de l'animation Asciiwars de Simon Jensen  

#### RÈGLEMENT:
Il n'y a pas de règlement, pas d'obligation,
pas d'enjeu


Il s'agit uniquement de s'amuser avec cette animation et d'en faire ce qu'elle vous inspire.




####  Description des fichiers :  
- ```asciimation.txt``` le fichier source de l'animation.47740 lignes decrtivant  3410 frames, soit 14 lignes par frame.

- ligne 1: nombre décimal  representant le  nombre d'unités de temps pendant laquelle la frame doit être affchée

lignes 2 à 13: jusqu'à 67 caractères ASCII représentant le contenu de la frame, calé à gauche.  

exemple:

L'animation compte 3410 fraqmes, et la durée totale est de  

Ce format est simple à parser mais n'est adadpté aux ordinateurs retro disposant de très peu de mémoire.

pour créer 
-``asciiwars.mp4```j'ai écrit  script python ```convert.py`` qui sépare les délais et le contenu grahique des frames normalisees à 67 caracteres), pour implifier la visualiation dans le framework Processing
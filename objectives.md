## Pluja d'Idees

### Modo Survive
Modo survive? -> Per quan 

```asl
    +myFieldops(FieldOps)
    +myMedics(Medics)
    +myBackups(Soldiers)
    
    .length(FieldOps, NFieldOps)
    .length(Medics, NMedics)
    .length(Soldiers, NSoldiers)

    +survive : (NFieldOps + NMedics + NSoldiers) == 1
```  

### Dividir `.asl` per AXIS/ALLIED

Jej

### Nivell d'urgència de Cura / Munició

La creació de munició i cures no depèn de la vida dels altres, de moment (més enllà de la pròpia). Si està en el teu rang de visió, sí. Llavors s'han d'anar creant cada x temps. 

En canvi, per recollir/buscar munició i cures, sí que podem utilitzar la vida de l'agent. 



## FieldOp

Proporcionar munición a sus colegas mientras dispara a enemigos. 
- Importante cada vez que genera munición se le restan 25 de vida.

**AXIS**

- Objectiu principal: Proporcionar a un company munició quant té menys de X de munició (deixar un paquet a prop)’
    - Pot crear paquets de munició a prop de la base per tal de reforçar la defensa

**ALLIED**

- 

## Soldier

El objetivo principal del soldado es derrotar a sus enemigos. Para ello, sin embargo, necesita estar vivo y tener munición suficiente.

1. Disparar enemigo
2. Recuperar vida
    - urgente
    - alta
    - media
3. Recuperar munición
    - urgente
    - alta
    - media munición


**AXIS**

- Objetiu principal: Defensar al seu equip per tal d’aprofitar el seu X2 en atac. Quan veu a un company amb Menys vida i ha vist a un enemic, atacar l’enemic. Per tant, ha d’anar aprop dels companys
    - Pot crear patrulles aprop de la base (q serà al voltant de les municions) per tal d’atacar als atacants i tenir sempre munició disponible.

**ALLIED**


## Medic

El objetivo principal del médico es crear packs de curación para sus compañeros y si mismo. A su vez, debe colaborar a derrotar a los enemigos.

**AXIS**

- Objectiu principal: si veu un company amb menys de X de vida, anar cap a ell i deixar paquet de cura

**ALLIED**

- Objectiu principal: si veu un company amb menys de X de vida, anar cap a ell i deixar paquet de cura

## Aplicable a tots

- Si tenim menys de H de vida, explorem per buscar una cura i anem cap a on está
- Si tenim menys de X de munició, explorem per buscar una AMMO i anem cap a on está





# TASQUES
Cada persona hace su agente. ALLIED i AXIS

Òscar -> soldado
Llum -> fielop
Javi -> médico
Júlia -> médico 2

DATA: DIMARTS!
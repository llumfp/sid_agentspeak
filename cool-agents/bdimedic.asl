/*
* ========================================
 * ESTRATEGIA DE AGENTE MÉDICO PARA PYGOMAS
 * ========================================
 * 
//BasePoints(base_points) :- team(200) & base_points = [160, 0, 180].
//BasePoints(base_points) :- team(100) & base_points = [20, 0, 80].
*/
/*
########################## Lista de variables ######################
F = Flag
BasePoints_all = Puntos de control cercanos a la base
Pos = Posición a patrullar
L = Longitud de la lista de puntos de control
H = Vida del agente
M = Munición del agente
B = Posición Base
P = Punto de patrulla actual
T = Total de puntos de control
A = Nuevo Punto de control al que ir

TYPE_san_pack = Tipo del pack de sanación
Pos_san_pack = Posición del pack de sanación

TYPE_ammo_pack = Tipo del pack de munición
Pos_ammo_pack = Posición del pack de munición

ID_enemy = ID del enemigo
Position_enemy = Posición del enemigo

Health_ally = Vida del aliado
Position_ally = Posición del aliado
*/





// TEAM AXIS (defensor) and ALLIED (atacante)
+flag (F)
    <-
    .print("Iniciando patrulla cerca de la base");
    !set_base_random_points_patroll.



+!set_base_random_points_patroll : team(200)
    <-
    ?flag(F);
    ?base(B);
    
    // Manual midpoint calculation
    .nth(0, F, FX);
    .nth(1, F, FY);
    .nth(2, F, FZ);
    
    .nth(0, B, BX);
    .nth(1, B, BY);
    .nth(2, B, BZ);
    
    MidX = (FX + BX) / 2;
    MidY = (FY + BY) / 2;
    MidZ = (FZ + BZ) / 2;
    
    MidPoint = [MidX, MidY, MidZ];
    +midpoint(MidPoint);
    .create_control_points(MidPoint, 20, 3, BaseMidPointAll);
    !do_patroll(BaseMidPointAll).

+!set_base_random_points_patroll : team(100)
    <-
    ?flag(F);
    ?base(B);
    
    // Manual midpoint calculation
    .nth(0, F, FX);
    .nth(1, F, FY);
    .nth(2, F, FZ);
    
    .nth(0, B, BX);
    .nth(1, B, BY);
    .nth(2, B, BZ);
    
    MidX = (FX + BX) * 3 / 4;
    MidY = (FY + BY) * 3 / 4;
    MidZ = (FZ + BZ) * 3 / 4;
    
    MidPoint = [MidX, MidY, MidZ];
    +midpoint(MidPoint);
    .create_control_points(MidPoint, 20, 3, BaseMidPointAll);
    !do_patroll(BaseMidPointAll).





/*
########################### Bucle del patrullaje ######################
Plan principal, Patrullar alrededor de una posición intermedia entre 
la base y la flag para poder explorar el mapa y observar posibles enemigos o amigos
################################################################################
*/

+!do_patroll(Pos)
    <-
    -+control_points(Pos);
    .length(Pos, L);
    -+total_control_points(L);
    -+patrolling;
    -+patroll_point(0);
    .print("Iniciando patrulla cerca de los puntos", Pos).

// Manejo de los puntos de patrulla
+patroll_point(P): total_control_points(L) & P<L & control_points(Pos) & patrolling
    <-
    .nth(P,Pos,A);
    .print("Yendo al punto", A, "(", P, " de ", L, ")");
    .goto(A).

+patroll_point(P): total_control_points(T) & P==T & patrolling
    <-
    -+patroll_point(0);
    -total_control_points(T);
    .print("Patrullaje terminado, volviendo a patrullar");
    !!patroll_at_midpoint.

+target_reached(A): patrolling & patroll_point(P) & total_control_points(L) & P + 1 <= L & patrolling
    <-
    +san_pack(A);
    .cure;
    .print("Dejando cura preventiva y guardando su ubicación en", A);
    .get_backups;
    .wait(550);
    .print("Revisando si hay soldados en la zona");
    ?patroll_point(P);
    -+patroll_point(P+1);
    -target_reached(A);
    .print("Punto alcanzado ", A).

+!patroll_at_midpoint : midpoint(MidPoint)
    <-
    .create_control_points(MidPoint, 20, 3, BaseMidPointAll);
    !do_patroll(BaseMidPointAll).

/*
########################### Fin del bucle del patrullaje ######################
Cada vez que llega a un punto del patrullaje, deja una cura preventiva
###############################################################################
*/

/*########################### Recarga de munición y sanación ######################
Intenciones para recargar munición y sanación, se activan cuando el agente tiene poca vida o munición
###############################################################################
*/

+!reload_ammo : ammo_pack(Pos_ammo_pack)
    <-
    .print("Yendo a recargar munición");
    .goto(Pos_ammo_pack).


+!reload_san : san_pack(Pos_san_pack)
    <-
    .print("Yendo a curarme al pack de la posición ", Pos_san_pack);
    .goto(Pos_san_pack).

/*
########################### Reacción a los packs ######################
Cuando ve un pack de sanación o munición, se dirige a él si tiene poca vida o munición respectivamente
Si tiene suficiente vida o munición, guarda la posición del pack
para ir a por él más tarde a traves de crear una intención con !reload_san o !reload_ammo
###############################################################################
*/

+packs_in_fov(_, TYPE_san_pack, _, _, _, Pos_san_pack) : TYPE_san_pack == 1001 & health(H) & H > 50 & not san_pack(Pos_san_pack)
    <-
    .print("Guardando posición del sanity pack ", Pos_san_pack);
    +san_pack(Pos_san_pack).


+packs_in_fov(_, TYPE_ammo_pack, _, _, _, Pos_ammo_pack) :TYPE_ammo_pack == 1002 & ammo(M) & M > 50 & not ammo_pack(Pos_ammo_pack)
    <-
    .print("Guardando posición de la ammo pack ", Pos_ammo_pack);
    +ammo_pack(Pos_ammo_pack).



/*########################### Activar intenciones cuando vida baja o munición baja ######################
################################################################################*/

+health(H):  H < 20 & not yendo_sanacion & san_pack(Pos_san_pack) & not al_ataque
    <-
    .print("Vida baja, yendo a curarme");
    +yendo_sanacion;
    ?position(LastPos);
    +posicion_anterior(LastPos);
    .look_at(Pos_san_pack);
    !!reload_san.

// si no hay pack de sanación, se crea una cura preventiva
+health(H): H < 20 & not yendo_sanacion & not san_pack(Pos_san_pack) & not al_ataque
    <-
    .print("Vida baja, creando cura preventiva y volviendo al punto inicial");
    .cure;
    +san_pack(Pos_san_pack);
    ?position(LastPos);
    +posicion_anterior(LastPos);
    .create_control_points(LastPos, 10, 2, BaseMidPointAll);
    !do_patroll(BaseMidPointAll).



+ammo(M): M < 20 & not yendo_municion & ammo_pack(Pos_ammo_pack) & not al_ataque
    <-
    .print("Munición baja, yendo a recargar munición");
    +yendo_municion;
    ?position(LastPos);
    +posicion_anterior(LastPos);
    .look_at(Pos_ammo_pack);
    !!reload_ammo.

// si no hay pack de munición, se crea una cura preventiva
+ammo(M): M < 20 & not yendo_municion & not ammo_pack(Pos_ammo_pack) & not al_ataque
    <-
    .print("Munición baja, creando cura preventiva y volviendo al punto inicial");
    .cure;
    ?position(LastPos);
    +posicion_anterior(LastPos);
    .create_control_points(LastPos, 10, 2, BaseMidPointAll);
    !do_patroll(BaseMidPointAll).



// Cuando llega a un pack de munición o sanación, lo recoge y vuelve a patrullar

+target_reached(Pos_san_pack): yendo_sanacion & posicion_anterior(LastPos)
    <-
    .print("Sanación cogida");
    -target_reached(Pos_san_pack);
    -yendo_sanacion;
    .create_control_points(LastPos, 10, 3, BaseMidPointAll);
    !do_patroll(BaseMidPointAll).

+target_reached(Pos_ammo_pack): yendo_municion & posicion_anterior(LastPos)
    <-
    .print("Munición cogida");
    -target_reached(Pos_ammo_pack);
    -yendo_municion;
    .create_control_points(LastPos, 10, 3, BaseMidPointAll);
    !do_patroll(BaseMidPointAll).


/* ########################### Reacción a los enemigos ######################
Cuando ve un enemigo, se activa la intención de atacar o recargar munición
o curarse dependiendo de la vida y munición del agente
*/

// Cuando ve a un enemigo y tiene suficiente vida
+enemies_in_fov(ID_enemy,_,_,_,_,Position_enemy) : health(H) & H > 20 & ammo(M) & M > 5
    <-
    .shoot(5,Position_enemy);
    .print("Atacando al enemigo ", ID_enemy).

+enemies_in_fov(ID_enemy,_,_,_,_,Position_enemy) : health(H) & H > 20 & ammo(M) & M < 5 & ammo_pack(Pos_ammo_pack)
    <-
    .look_at(Pos_ammo_pack);
    +yendo_municion;
    !reload_ammo;
    .print("Yendo a recargar munición, a la posición", Pos_ammo_pack).

// Cuando ve a un enemigo pero tiene poca vida
+enemies_in_fov(_,_,_,_,_,_) : health(H) & H <= 20 & san_pack(Pos_san_pack)
    <-
    .look_at(Pos_san_pack);
    +yendo_sanacion;
    !reload_san;
    .print("Yendo a curarme, a la posición", Pos_san_pack).


// Cuando ve a un amigo herido
+friends_in_fov(_,_,_,_,Health_ally,Position_ally) :  Health_ally < 80 & not curando_ally
    <-
    +curando_ally;
    .print("Yendo a curar a aliado a la posición", Position_ally);
    .goto(Position_ally).
    
+target_reached(Position_ally): curando_ally
    <-
    -curando_ally;
    -target_reached(Position_ally);
    .cure;
    .print("Curando al aliado ");
    .create_control_points(Position_ally, 10, 2, Position_ally_grouped); // Crear puntos cercanos al jugador
    !do_patroll(Position_ally_grouped).


/*########################### Replanificación si no hay soldados ######################

Para el equipo 100, si hay soldados en la zona, se vuelve a patrullar
y se crea una cura preventiva en la posición del último punto de patrullaje.
Si no hay soldados, se activa estrategia de ataque y se va a por la bandera

Para el equipo 200, si hay soldados en la zona, se vuelve a patrullar
y se crea una cura preventiva en la posición del último punto de patrullaje.
Si no hay soldados, se activa estrategia de defensa y se va a patrullar por la bandera

################################################################################*/


+myBackups(LISTBACKUPS) : not flag_taken & team(100)
    <-
    .print("Recibiendo lista de backups");
    .print(LISTBACKUPS);
    .length(LISTBACKUPS, LENGTHBACKUPS);
    -patrolling;
    if (LENGTHBACKUPS == 0) {
        .print("No hay backups disponibles, a por la bandera!");
        +al_ataque;
        -myBackups(LISTBACKUPS);
        !to_atack;
    }
    else {
        .print("Hay backups disponibles, a seguir patrullando!");
        -myBackups(LISTBACKUPS);
        +patrolling;
    }.

+myBackups(LISTBACKUPS) : flag_taken & team(100)
    <-
    .print("Recibiendo lista de backups");
    .print(LISTBACKUPS);
    .length(LISTBACKUPS, LENGTHBACKUPS);
    -patrolling;
    !save_flag;
    .print("Guardando bandera en la base!");
    -myBackups(LISTBACKUPS).


+myBackups(LISTBACKUPS) : team(200)
    <-
    .print("Recibiendo lista de backups");
    .print(LISTBACKUPS);
    .length(LISTBACKUPS, LENGTHBACKUPS);
    if (LENGTHBACKUPS == 0) {
        .print("No hay backups disponibles, a defender la bandera!");
        +a_defender;
        -myBackups(LISTBACKUPS);
        !to_defend;
    }
    else {
        .print("Hay backups disponibles, a seguir patrullando!");
        -myBackups(LISTBACKUPS);
        +patrolling;
    }.


+!to_atack
    <-
    ?flag(F);
    .goto(F).

+!to_defend : flag(F) & team(200)
    <-
    .create_control_points(F, 10, 2, F_points);
    !do_patroll(F_points);
    .print("Defendiendo la bandera en", F_points).


+target_reached(F) : al_ataque
    <-
    .print("Bandera alcanzada, volviendo a base");
    -al_ataque;
    !save_flag.


// plan para guardar la bandera en la base
+!save_flag : team(100) & flag_taken
    <-
    ?base(B);
    .print("Guardando bandera en la base");
    .goto(B).


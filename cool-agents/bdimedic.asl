
//BasePoints(base_points) :- team(200) & base_points = [160, 0, 180].
//BasePoints(base_points) :- team(100) & base_points = [20, 0, 80].

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

ID_san_pack = ID del pack de sanación
Pos_san_pack = Posición del pack de sanación

ID_ammo_pack = ID del pack de munición
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



+!set_base_random_points_patroll 
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


+!patroll_at_midpoint : midpoint(MidPoint)
    <-
    .create_control_points(MidPoint, 20, 3, BaseMidPointAll);
    !do_patroll(BaseMidPointAll).


/*
Plan principal, Patrullar alrededor de una posición intermedia entre la base y la flag para poder explorar el mapa y observar posibles enemigos o amigos
*/

+!do_patroll(Pos)
    <-
    -+control_points(Pos);
    .length(Pos, L);
    -+total_control_points(L);
    -+patrolling;
    -+patroll_point(0);
    .print("Iniciando patrulla cerca del punto ", Pos).



+packs_in_fov(ID_san_pack, _, _, _, _, Pos_san_pack) : ID_san_pack == 1001 & health(H) & H <= 50
    <-
    .print("Yendo a por un pack de sanación en la posición ", Pos_san_pack);
    +yendo_sanacion;
    .goto(Pos_san_pack).


+packs_in_fov(ID_ammo_pack, _, _, _, _, Pos_ammo_pack) :ID_ammo_pack == 1002 & ammo(M) & M <= 50
    <-
    .print("Yendo a por un pack de munición en la posición ", Pos_ammo_pack);
    +yendo_municion;
    .goto(Pos_ammo_pack).

+target_reached(Pos_san_pack): yendo_sanacion
    <-
    .print("Sanación cogida");
    -target_reached(Pos_san_pack);
    -yendo_sanacion.

+target_reached(Pos_ammo_pack): yendo_municion
    <-
    .print("Munición cogida");
    -target_reached(Pos_ammo_pack);
    -yendo_municion.

// Cuando ve a un enemigo y tiene suficiente vida
+enemies_in_fov(ID_enemy,_,_,_,_,Position_enemy) : health(H) & H > 50 & not volviendo_a_base
    <-
    .shoot(5,Position_enemy);
    .print("Atacando al enemigo ", ID_enemy).

// Cuando ve a un enemigo pero tiene poca vida
+enemies_in_fov(_,_,_,_,_,_) : health(H) & H <= 50 & not volviendo_a_base
    <-
    +volviendo_a_base;
    ?midpoint(MidPoint);
    !patroll_at_midpoint;
    .print("Replegándome, vida baja").


// Cuando ve a un amigo herido
+friends_in_fov(_,_,_,_,Health_ally,Position_ally) : Health_ally < 50 & not curando_ally
    <-
    -+curando_ally;
    .print("Yendo a curar a aliado a la posición", Position_ally);
    .goto(Position_ally).
    
+target_reached(Position_ally): curando_ally
    <-
    -curando_ally;
    -target_reached(Position_ally);
    .cure;
    .print("Curando al aliado ");
    .create_control_points(Position_ally, 10, 2, Position_ally_grouped); // Crear puntos cercanos a la base
    !do_patroll(Position_ally_grouped).

// Manejo de los puntos de patrulla
+patroll_point(P): total_control_points(T) & P<T
    <-
    ?control_points(Pos);
    .nth(P,Pos,A);
    .print("Yendo al punto INDICADO COMO A ", A, "cON VALOR P de ", P , "y T de ", T);
    .goto(A).

+patroll_point(P): total_control_points(T) & P==T
    <-
    -+patroll_point(0);
    -total_control_points(T);
    .cure;
    .print("Dejando cura preventiva");
    .get_backups; // revisamos las creencias para ver si hay backups disponibles i modificar la estrategia
    ?midpoint(MidPoint);
    !patroll_at_midpoint.


+target_reached(T_PATROLL): patrolling
    <-
    ?patroll_point(P);
    -+patroll_point(P+1);
    -target_reached(T_PATROLL);
    !rotar;
    .print("Punto alcanzado ", T_PATROLL).

+health(H): H < 50 & not volviendo_a_base
    <-
    +volviendo_a_base;
    .print("Volviendo a punto de patrullaje inicial a buscar curas, vida baja ...");
    ?midpoint(MidPoint);
    !patroll_at_midpoint.


+health(H): H >= 50 & volviendo_a_base
    <-
    .print("A salvo, no hace falta patrullar en base");
    -volviendo_a_base;
    ?midpoint(MidPoint);
    !patroll_at_midpoint.

+target_reached(_) : volviendo_a_base
    <-
    .cure;
    .print("Creando cura propia");
    -target_reached(_);
    -volviendo_a_base;
    ?midpoint(MidPoint);
    !patroll_at_midpoint.

+!rotar <-
    .print("Rotando...");
    .turn(3.14);
    .wait(550).


// Si capturan la bandera i soy el equipo atacante, poner estrategia de defensa
+flag_taken: team(100)
    <-
    .print("Bandera capturada, volviendo a base");
    !set_base_random_points_patroll;
    ?midpoint(MidPoint);
    !patroll_at_midpoint.


// Si capturan la bandera i soy el equipo defensor, poner estrategia de ataque
+flag_taken: team(200)
    <-
    .print("Bandera capturada, atacando al portador");
    ?flag(F);
    .create_control_points(F, 20, 2, FlagPoint); // Crear puntos cercanos a la bandera
    !do_patroll(FlagPoint).



+myBackups(LISTBACKUPS) : team(100)
    <-
    .print("Recibiendo lista de backups");
    .print(LISTBACKUPS);
    .length(LISTBACKUPS, LENGTHBACKUPS);
    if (LENGTHBACKUPS == 0) {
        .print("No hay backups disponibles, a por la bandera!");
        !to_atack;
    }
    else {
        .print("Hay backups disponibles, a por ellos!");
        ?midpoint(MidPoint);

        !patroll_at_midpoint;
    }.


+!to_atack : team(100)
    <-
    ?flag(F);
    .goto(F).

+target_reached(F) : team(100)
    <-
    .print("Bandera alcanzada, volviendo a base");
    ?base(B);
    .goto(B).
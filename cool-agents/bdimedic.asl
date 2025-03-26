
//BasePoints(base_points) :- team(200) & base_points = [160, 0, 180].
//BasePoints(base_points) :- team(100) & base_points = [20, 0, 80].


// TEAM AXIS (defensor)
+flag (F): team(200)
    <-
    .create_control_points([160, 0, 180], 20, 3, BasePoints_all); // Crear puntos cercanos a la base
    !do_patroll(BasePoints_all).

// TEAM ALLIED (atacante)
+flag (F): team(100)
    <-
    .create_control_points([20, 0, 80], 20, 3, BasePoints_all); // Crear puntos cercanos a la base
    !do_patroll(BasePoints_all).

+!do_patroll(Pos)
    <-
    +control_points(Pos);
    .length(Pos, L);
    +total_control_points(L);
    +patrolling;
    +patroll_point(0);
    .print("Iniciando patrulla cerca del punto ", Pos).

// TODO: PATRULLAR CERCA DE UN AMIGO SI LO VE

+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, Pos_pack) : ID == 1001 & health(H_health) & H_health <= 50
    <-
    .print("Yendo a por un pack de sanación en la posición ", Pos_pack);
    +yendo_sanacion;
    .goto(Pos_pack).


+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, Pos_pack) :ID == 1002 & ammo(H_ammo) & H_ammo <= 50
    <-
    .print("Yendo a por un pack de munición en la posición ", Pos_pack);
    +yendo_municion;
    .goto(Pos_pack).

+target_reached(_): yendo_sanacion
    <-
    .print("Sanación cogida");
    -target_reached(_);
    -yendo_sanacion.

+target_reached(_): yendo_municion
    <-
    .print("Munición cogida");
    -target_reached(_);
    -yendo_municion.

// Cuando ve a un enemigo y tiene suficiente vida
+enemies_in_fov(ID,Type,Angle,Distance,Health,Position) : health(H) & H > 50 & not volviendo_a_base
    <-
    .shoot(5,Position);
    .print("Atacando al enemigo ", ID).

// Cuando ve a un enemigo pero tiene poca vida
+enemies_in_fov(ID,Type,Angle,Distance,Health,Position) : health(H) & H <= 50 & team(200)
    <-
    +volviendo_a_base;
    !do_patroll([160, 0, 180]);
    .print("Replegándome, vida baja").

+enemies_in_fov(ID,Type,Angle,Distance,Health,Position) : health(H) & H <= 50 & team(100)
    <-
    +volviendo_a_base;
    !do_patroll([20, 0, 60]);
    .print("Replegándome, vida baja").

// Cuando ve a un amigo herido
+friends_in_fov(ID,Type,Angle,Distance,Health,Position) : not curando
    <-
    +curando;
    .print("Yendo a curar a aliado", ID, Type);
    .goto(Position).
    
+target_reached(Position): curando
    <-
    -curando;
    -target_reached(Position);
    .cure;
    .print("Curando al aliado ");
    .create_control_points(Position, 10, 2, Pos_cerca_allied); // Crear puntos cercanos a la base
    !do_patroll(Pos_cerca_allied).

// Manejo de los puntos de patrulla
+patroll_point(P): total_control_points(T) & P<T
    <-
    ?control_points(Pos);
    .nth(P,Pos,A);
    .goto(A).

+patroll_point(P): total_control_points(T) & P==T & team(200)
    <-
    -patroll_point(P);
    !do_patroll([160, 0, 180]). // Volver a crear puntos cerca de la base

+patroll_point(P): total_control_points(T) & P==T & team(100)
    <-
    -patroll_point(P);
    !do_patroll([20, 0, 60]). // Volver a crear puntos cerca de la base

+target_reached(T): patrolling
    <-
    ?patroll_point(P);
    -+patroll_point(P+1);
    !rotar;
    !rotar;
    !rotar;
    !rotar;
    .print("Punto alcanzado ", T);
    -target_reached(T).

+health(H_self): H_self < 50 & not volviendo_a_base & team(200)
    <-
    +volviendo_a_base;
    .goto([160, 0, 180]);
    .print("Volviendo a base, vida baja ...").

+health(H_self): H_self < 50 & not volviendo_a_base & team(100)
    <-
    +volviendo_a_base;
    .goto([20, 0, 60]);
    .print("Volviendo a base, vida baja ...").

+health(H_self): H_self >= 50 & volviendo_a_base
    <-
    .print("A salvo, no hace falta patrullar en base");
    -volviendo_a_base.

+target_reached(_) : volviendo_a_base & team(200)
    <-
    .cure;
    .print("Creando cura propia");
    -target_reached(_);
    !do_patroll([160, 0, 180]).

+target_reached(_) : volviendo_a_base & team(100)
    <-
    .cure;
    .print("Creando cura propia");
    -target_reached(_);
    !do_patroll([20, 0, 60]).

+!rotar <-
    .print("Rotando...");
    .turn(3.14);
    .wait(350).

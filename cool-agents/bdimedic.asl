// TEAM AXIS (defensor)
+flag (F): team(200)
    <-
    .create_control_points([160, 0, 180], 20, 3, BasePoints); // Crear puntos cercanos a la base
    +do_patroll(BasePoints).

+do_patroll(Pos): team(200)
    <-
    +control_points(Pos);
    .length(Pos, L);
    +total_control_points(L);
    +patrolling;
    +patroll_point(0);
    .print("Iniciando patrulla cerca de la base").

// TODO: PATRULLAR CERCA DE UN AMIGO SI LO VE

+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, Pos_pack) : ID == 1001 & health(H_health) & H_health <= 50
    <-
    .print("Yendo a por un pack de sanación");
    +yendo_sanacion;
    .goto(Pos_pack).


+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, Pos_pack) :ID == 1002 & ammo(H_ammo) & H_ammo <= 50
    <-
    .print("Yendo a por un pack de munición");
    +yendo_municion;
    .goto(Pos_pack).

+target_reached(_): yendo_sanacion & team(200)
    <-
    .print("Sanación cogida");
    -yendo_sanacion.

+target_reached(_): yendo_municion & team(200)
    <-
    .print("Munición cogida");
    -yendo_municion.

// Cuando ve a un enemigo y tiene suficiente vida
+enemies_in_fov(ID,Type,Angle,Distance,Health,Position) : health(H) & H > 50 & not volviendo_a_base
    <-
    .shoot(5,Position);
    .print("Atacando al enemigo ", ID).

// Cuando ve a un enemigo pero tiene poca vida
+enemies_in_fov(ID,Type,Angle,Distance,Health,Position) : health(H) & H <= 50
    <-
    +volviendo_a_base;
    +do_patroll([160, 0, 180]);
    .print("Replegándome, vida baja").

// Cuando ve a un amigo herido
+friends_in_fov(ID,Type,Angle,Distance,Health,Position) : not curando
    <-
    +curando;
    .print("Yendo a curar a aliado", ID, Type);
    .goto(Position).
    
+target_reached(Position): curando & team(200)
    <-
    -curando;
    .cure;
    .print("Curando al aliado ");
    .create_control_points(Position, 10, 2, BasePoints); // Crear puntos cercanos a la base
    +do_patroll(BasePoints).


// Manejo de los puntos de patrulla
+patroll_point(P): total_control_points(T) & P<T
    <-
    ?control_points(Pos);
    .nth(P,Pos,A);
    .goto(A).

+patroll_point(P): total_control_points(T) & P==T
    <-
    -patroll_point(P);
    +do_patroll([160, 0, 180]). // Volver a crear puntos cerca de la base

+target_reached(T): patrolling & team(200)
    <-
    ?patroll_point(P);
    -+patroll_point(P+1);
    !rotar;
    .cure; // Curar en cada punto por si hay aliados cerca
    .print("Punto alcanzado ", T);
    -target_reached(T).

+health(H_self): H_self < 50
    <-
    .goto([160, 0, 180]);
    .print("Volviendo a base, vida baja ...").

+health(H_self): H_self >= 50 & volviendo_a_base
    <-
    .print("A salvo, no hace falta patrullar en base");
    -volviendo_a_base.


+!rotar <-
    .print("Rotando...");
    .turn(3.14);
    .wait(350);
    .turn(3.14);
    .wait(350).

// TEAM AXIS (defensor) team(200)

+flag (F): team(200)
    <-
    .create_control_points(F,10,2,C);
    +control_points(C);
    .length(C,L);
    +total_control_points(L);
    +patrolling;
    +patroll_point(0);
    .print("Got control points").


+target_reached(T): patrolling & team(200)
    <-
    ?patroll_point(P);
    -+patroll_point(P+1);
    -target_reached(T).

+patroll_point(P): total_control_points(T) & P<T
    <-
    ?control_points(C);
    .nth(P,C,A);
    .goto(A).

+patroll_point(P): total_control_points(T) & P==T
    <-
    -patroll_point(P);
    ?ammo(X).

+!rotar : buscando_ammo <-
    .wait(500);
    .print("buscando_ammo");
    .turn(1.57);
    !rotar.

+!get_ammo
    <- 
    +buscando_ammo;
    !rotar.




// TEAM ALLIED (ATACANTE) team(100)
+flag (F): team(100)
    <-
    .goto(F).




// COMMON

+enemies_in_fov(ID,Type,Angle,Distance,Health,Position): ammo(X) & X >= 30
    <- 
    .shoot(5,Position).

+packs_in_fov(ID,Type,Angle,Distance,Health,Pos_ammo) : Type == 1002 & ammo(X) & X <= 30
    <-
    .goto(Pos_ammo);
    .print("Ammo taken").

+packs_in_fov(ID,Type,Angle,Distance,Health,Pos_cure) : Type == 1001 & health(H) & H <= 30
    <-
    .goto(Pos_cure);
    .print("Health taken").
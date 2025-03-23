// TEAM AXIS (defensor)

+flag (F): team(200)
    <- 
    .goto(F);
    .shoot(20, F);
    .print("disparado!").


+!rotar : buscando_ammo <-
    .wait(500);
    .print("buscando_ammo");
    .turn(1.57);
    !rotar.

+target_reached(T): team(200) & ammo(X)
    <-
    .print("la ammo es", X);
    !get_ammo.

+!get_ammo
    <- 
    +buscando_ammo;
    !rotar.


+enemies_in_fov(ID,Type,Angle,Distance,Health,Position): ammo(X) & X >= 30
  <- 
  .shoot(5,Position).

+packs_in_fov(ID,Type,Angle,Distance,Health,Pos_ammo) : ammo(X) & X <= 30
    <-
    .goto(Pos_ammo);
    .print("ammo taken").

// TEAM ALLIED (ATACANTE)
// TEAM AXIS (defensor)







+get_ammo : ammo(X) & X < 30 
    <- 
    ?packs_in_fov(1002, _, _, _, _, Pos_ammo);
    .goto(Pos_ammo);
    +pack_taken(1002, 20).


+enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <- 
  .shoot(5,Position).

// TEAM ALLIED (ATACANTE)
+flag (F): team(100)
    <-
    .goto(F).
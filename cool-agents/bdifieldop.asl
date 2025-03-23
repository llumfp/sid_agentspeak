// TEAM AXIS (defensor)

+flag (F): team(200)
    <- 
    .nth(0,F,A);
    .nth(1,F,B);
    .nth(2,F,C);
    .goto([A -5, B - 4, C]);
    .reload.


+get_ammo : ammo(X) & X < 30 
    <- 
    ?packs_in_fov(1002, _, _, _, _, Pos_ammo);
    .goto(Pos_ammo).


+enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <- 
  .shoot(5,Position).

// TEAM ALLIED (ATACANTE)
+flag (F): team(100)
    <-
    .goto(F).
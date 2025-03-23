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
    .goto(Pos_ammo);
    +pack_taken(1002, 20).


+enemies_in_fov(ID,Type,Angle,Distance,Health,Position): ammo(X) & X > 0
  <- 
  .shoot(5,Position).

// TEAM ALLIED (ATACANTE)
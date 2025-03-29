//TEAM_AXIS

/*
########################## Lista de variables ######################
F = Flag
C = Puntos de control cercanos a la bandera
*/

/*
########################## URGENCIA MEDICA! ########################
Buscar medicinas.
-> EMPIEZA: cuando tenemos una vida inferior a 20
-> ACABA: cuando hemos recuperado vida
-> QUE HACE: dar una vuelta en busca de medicinas o en busca del médico amigo
*/

+health(H): H<20
  <-
  .reload;
  !cure_myself.

+!cure_myself
  <-
  +searching_cures.

+packs_in_fov(_, MedicPack, _, _, _, MedicinePos): searching_cures & MedicPack=1001
  <-
  +going_to_cure;
  .goto(MedicinePos).

+searching_cures: not going_to_cure
  <-
  .print("Explorando buscando medicinas");
  .wait(1000);
  .turn(-0.750).

+pack_taken(MedicPack): searching_cures & MedicPack=1001
  <-
  -going_to_cure;
  -searching_cures;
  .reload.

+target_reached(MedicinePos): searching_cures
  <-
  -going_to_cure.

/*
########################## FASE 1 ########################
Empezamos yendo a patrullar al rededor de la bandera.
-> EMPIEZA: inicio de la partida
-> ACABA: cuando vemos al primer enemigo
-> QUE HACE: crear puntos al rededor de la bandera y patrullar siguiendo estos puntos
*/


!go_patroll_flag.

+!go_patroll_flag: team(200) & flag(F)
  <-
  .create_control_points(F,25,3,C);
  +control_points(C);
  .length(C,L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0);
  .print("Got control points").

// Agregar un plan de respaldo para cuando las condiciones aún no se cumplen
+!go_patroll_flag
  <-
  .print("Esperando información del equipo y la bandera...");
  .wait(1000);  // Esperar un poco antes de intentarlo de nuevo
  !go_patroll_flag.  // Llamada recursiva para intentarlo de nuevo

+target_reached(T): patrolling & team(200) & not searching_cures
  <-
  .print("AMMOPACK!");
  .reload;
  ?patroll_point(P);
  -+patroll_point(P+1);
  -target_reached(T).

+patroll_point(P): total_control_points(T) & P<T & patrolling & not searching_cures
  <-
  ?control_points(C);
  .nth(P,C,A);
  .goto(A).

+patroll_point(P): total_control_points(T) & P==T & patrolling & not searching_cures
  <-
  -patroll_point(P);
  +patroll_point(0).

// Cuando vemos al primer enemigo empezamos la FASE 2
+enemies_in_fov(ID,Type,Angle,Distance,Health,PositionFirstEnemie): patrolling
  <- 
  .print("Empezamos FASE 2: primer enemigo visto en ", PositionFirstEnemie);
  -patroll_point(P);
  -patrolling;
  .shoot(5,PositionFirstEnemie);
  .print("Disparado");
  +firstSeen(PositionFirstEnemie);
  !protect_flag.

// Otra forma de empezar la FASE 2, cuando notamos que nos estan disparando
+health(Hcurrent): patrolling
  <- 
  .wait(10000);
  ?heath(Hnew);
  if (Hcurrent-Hnew < 5) {
      .print("Me están disparando. FASE 2");
      -patrolling;
      !protect_flag;
  }
  else {
      .print("Nadie me esta disparando");
  }.

/*
########################## AMIGO A LA VISTA ########################
Dejar munición cuando veo a un amigo, a partir de la fase 2.
-> EMPIEZA: cuando ve a un amigo
-> ACABA: nunca
-> QUE HACE: dejar munición siempre que veamos un amigo, esperando un tiempo por si se repite
*/
+friends_in_fov(_,_,_,_,_,_): not patrolling & not searching_cures
  <-
  .print("Voy a dejar muncion porque vi un amigo");
  .wait(100000);
  .reload.

/*
########################## FALTA MUNICION! ########################
Poner municion y cogerla.
-> EMPIEZA: cuando tenemos una municion inferior a 20
-> ACABA: cuando hemos recuperado municion
-> QUE HACE: dejar municion e ir a cogerla
*/

+ammo(M): M<20 & not searching_cures
  <-
  .print("Voy a dejar muncion porque tengo poca");
  .wait(1000);
  .reload;
  !search_ammo.

+!search_ammo
  <-
  +searching_ammo.

+packs_in_fov(_, AmmoPack, _, _, _, AmmoPos): searching_ammo & AmmoPack=1002
  <-
  +going_to_ammo;
  .goto(AmmoPos).

+searching_ammo: not going_to_ammo
  <-
  .print("Explorando buscando municion");
  .wait(1000);
  .reload;
  .turn(-0.750).

+pack_taken(AmmoPack): searching_ammo & AmmoPack=1002
  <-
  .print("He encontrado la municion buscada");
  -going_to_ammo;
  -searching_ammo;
  .reload.

/*
########################## FASE 2 ########################
Empezamos a proteger la bandera.
-> EMPIEZA: cuando vemos al primer enemigo
-> ACABA: cuando vemos a un enemigo que tiene la bandera
-> QUE HACE: atacar al enemigo, dar munición al soldado, encararse hacia la bandera por si está el enemigo
*/

+!protect_flag
  <-
  +protecting.

+enemies_in_fov(ID,Type,Angle,Distance,Health,Position): protecting & not firstSeen(Any)
  <- 
  -looking_for_enemies;
  -searching_enemies(P);
  .print("Disparado");
  +firstSeen(Position);
  .shoot(5,Position).

+enemies_in_fov(ID,Type,Angle,Distance,Health,Position): protecting & firstSeen(PositionFirstEnemie)
  <- 
  -looking_for_enemies;
  -searching_enemies(P);
  .print("Disparado");
  .shoot(5,Position).

+protecting: not enemies_in_fov(_,_,_,_,_,_) & flag(F) & not looking_for_enemies
  <-
  .look_at(F);
  +looking_for_enemies;
  searching_enemies(0).

+looking_for_enemies: searching_enemies(P) & P<5
  <-
  -+searching_enemies(P+1);
  .print("Buscando enemigos");
  .wait(1000);
  .reload;
  .turn(-0.750).

+looking_for_enemies: searching_enemies(P) & P>4 & firstSeen(PositionFirstEnemie)
  <-
  .print("Yendo a la posicion donde vimos el primer enemigo: ", PositionFirstEnemie);
  .goto(PositionFirstEnemie).

+target_reached(PositionFirstEnemie)
  <-
  .print("He llegado a la posicion donde estaba el primer enemigo");
  .reload;
  +searching_enemies(0).


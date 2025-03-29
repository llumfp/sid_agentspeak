//TEAM_AXIS

/*
########################## URGENCIA MEDICA! ########################
Buscar medicinas.
-> EMPIEZA: cuando tenemos una vida inferior a 50
-> ACABA: cuando hemos recuperado vida
-> QUE HACE: dar una vuelta en busca de medicinas e ir hacia la medicina encontrada
*/

+health(Hnow): Hnow<50
  <-
  .reload;
  !cure_myself.

+!cure_myself
  <-
  +searching_cures.

+packs_in_fov(_, MedicPack, _, _, _, MedicinePos): searching_cures & MedicPack=1001 & not going_to_cure
  <-
  .print("He visto una cura, me dirijo hacia ella");
  +going_to_cure;
  .goto(MedicinePos).

+searching_cures: not going_to_cure
  <-
  .print("Explorando buscando medicinas");
  .wait(1000);
  .turn(-0.750).

+pack_taken(MedicPack,_): searching_cures & MedicPack=medic
  <-
  .print("Medicina tomada");
  -going_to_cure;
  -searching_cures;
  ?flag(F);
  .goto(F);
  !protect_flag.

+target_reached(MedicinePos): searching_cures
  <-
  .print("He llegado donde estaba la medicina");
  -target_reached(MedicinePos);
  -going_to_cure.

/*
########################## FASE 1 ########################
Empezamos yendo a patrullar al rededor de la bandera.
-> EMPIEZA: inicio de la partida
-> ACABA: cuando vemos al primer enemigo
-> QUE HACE: crear puntos al rededor de la bandera y patrullar siguiendo estos puntos
*/

// Inicialización de la variable para detectar que me están disparando
!first_health.

+!first_health: health(H)
  <-
  .print("La salud inicial es de", H);
  +last_health(H).

+!first_health
  <-
  .print("Esperando información de la salud.");
  .wait(1000);  // Esperar un poco antes de intentarlo de nuevo
  !first_health.  // Llamada recursiva para intentarlo de nuevo

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
  .stop;
  .shoot(5,PositionFirstEnemie);
  .print("Disparado");
  +firstSeen(PositionFirstEnemie);
  !protect_flag.

// Otra forma de empezar la FASE 2, cuando notamos que nos estan disparando
+health(Hcurrent): patrolling & last_health(H)
  <- 
  .wait(1000);
  if (H-Hcurrent < 5) {
      .print("Me están disparando. FASE 2");
      -patrolling;
      .stop;
      !protect_flag;
  }
  else {
      .print("Nadie me esta disparando. Sigo patrullando.");
  }.

/*
########################## AMIGO A LA VISTA ########################
Dejar munición cuando veo a un amigo, a partir de la fase 2.
-> EMPIEZA: cuando ve a un amigo
-> ACABA: nunca
-> QUE HACE: dejar munición siempre que veamos un amigo, esperando un tiempo por si se repite
*/
+friends_in_fov(_,_,_,_,_,_): not searching_cures & not recargado & protecting
  <-
  .print("Voy a dejar muncion porque vi un amigo");
  .reload;
  +recargado;
  .wait(10000);
  .print("Ahora puedo volver a dar municion");
  -recargado.

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

+packs_in_fov(_, AmmoPack, _, _, _, AmmoPos): searching_ammo & AmmoPack=1002 & not going_to_ammo
  <-
  .print("Yendo hacia la municion vista");
  +going_to_ammo;
  .goto(AmmoPos).

+searching_ammo: not going_to_ammo
  <-
  .print("Explorando buscando municion");
  .wait(1000);
  .reload;
  .turn(-0.750).

+pack_taken(AmmoPack,_): searching_ammo & AmmoPack=fieldops
  <-
  .print("He encontrado la municion buscada");
  -going_to_ammo;
  -searching_ammo;
  ?flag(F);
  .goto(F);
  !protect_flag;
  .reload.

+target_reached(AmmoPos): searching_ammo & going_to_ammo
  <-
  .print("He encontrado llegado donde estaba la municion pero no la he tomado");
  -going_to_ammo;
  +searching_ammo;
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
  -going_to_position_enemie;
  -looking_for_enemies;
  -searching_enemies(P);
  .print("Disparado");
  .shoot(5,Position).

+protecting: not enemies_in_fov(_,_,_,_,_,_) & flag(F) & not looking_for_enemies & not searching_cures
  <-
  .print("Estoy mirando hacia la bandera para ver si puedo encontrar a los enemigos");
  .look_at(F);
  +searching_enemies(0).

+looking_for_enemies: protecting & searching_enemies(P) & P<5 & not searching_cures
  <-
  -+searching_enemies(P+1);
  .print("Buscando enemigos");
  .wait(1000);
  .reload;
  .turn(-0.750).

+looking_for_enemies: protecting & searching_enemies(P) & P>4 & firstSeen(PositionFirstEnemie) & not searching_cures
  <-
  .print("Yendo a la posicion donde vimos el primer enemigo: ", PositionFirstEnemie);
  +going_to_position_enemie;
  .goto(PositionFirstEnemie).

+target_reached(PositionFirstEnemie): protecting & going_to_position_enemie & not searching_cures
  <-
  -going_to_position_enemie;
  .print("He llegado a la posicion donde estaba el primer enemigo");
  .reload;
  +searching_enemies(0).


/*
########################## FASE 3 ########################
Empezamos a perseguir al enemigo que cogió la bandera.
-> EMPIEZA: cuando vemos a un enemigo con la bandera
-> ACABA: hasta el final
-> QUE HACE: perseguir y atacar al enemigo
No lo pilla nunca, no estoy segura si así se puede encontrar el enemigo que ha cogido la bandera...
*/

+packs_in_fov(_, FlagType, _, _, _, FlagPos): enemies_in_fov(ID,Type,Angle,Distance,Health,Position) & FlagPos=Position
  <- 
  .print("He visto al enemigo con la bandera!");
  !follow_enemie(ID).

+!follow_enemie(ID): not chasing_flag_carrier
  <-
  .print("Persiguiendo al enemigo con ID ", ID, " que tiene la bandera");
  +chasing_flag_carrier;
  +target_enemy(ID);
  .reload.

+enemies_in_fov(ID,Type,Angle,Distance,Health,Position): chasing_flag_carrier & target_enemy(ID) & not following_enemy
  <- 
  .print("El enemigo con la bandera sigue a la vista, actualizando posición");
  .shoot(5,Position);
  -searching_enemy_flag;
  .goto(Position);
  +following_enemy.

+target_reached(Position): following_enemy & chasing_flag_carrier
  <-
  -target_reached(Position);
  .print("He llegado a donde estaba el enemigo");
  .reload;
  -following_enemy.

+chasing_flag_carrier: not enemies_in_fov(ID,_,_,_,_,_) & target_enemy(ID) & not searching_enemy_flag
  <-
  .print("He perdido de vista al enemigo con la bandera, buscando");
  +searching_enemy_flag;
  .turn(-0.750).

+searching_enemy_flag: chasing_flag_carrier
  <-
  .print("Buscando al enemigo con la bandera");
  .wait(1000);
  .turn(0.750).




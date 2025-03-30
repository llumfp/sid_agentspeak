/*
* ==========================================
 * ESTRATEGIA DE AGENTE SOLDADO PARA PYGOMAS
 * =========================================
 * Agente Deliberativo – Ambos Equipos 
*/
/* =================== CRENCIAS INICIALES =================== */

h_t(50).
a_t(50).

wait(1000).

+flag(F) : team(200) <-
  !patroll;
  !explore.

+flag(F) : team(100) <- 
  !capture_flag;
  !explore.

/* =================== META PRINCIPAL (AXIS) =================== */

/* El soldado debe patrullar la bandera */

+!patroll : flag(F) <-
  .create_control_points(F, 20, 4, C);
  +control_points(C);
  .length(C, L);
  +total_control_points(L);
  +patrolling;
  +patrol_point(0);
  !to_point.

/* =================== PLANES PARA LA PATRULLA DE LA BANDERA (AXIS) =================== */

+!to_point : patrol_point(P) <-
  ?control_points(C);
  .nth(P,C,A);
  .print("Going to", A);
  .goto(A).

+target_reached(T): patrolling & total_control_points(TOTAL) <-
  ?patroll_point(P);
  if (P == TOTAL) {
		!!patroll;
	};
  if (P <= TOTAL) {
		-+patroll_point(P+1);
	};
  -target_reached(T).

/* =================== META PRINCIPAL (ALLIED) =================== */

/* El soldado debe capturar la bandera */

+!capture_flag : not flag_taken & team(100) <-
  .wait(1000);
  .print("Meta: capture_flag iniciada");
  ?health(H);
  ?ammo(A);
  .print("Helth =", H, " Ammo =", A);
  !assess_flag.

/* =================== PLANES PARA LA CAPTURA DE LA BANDERA (ALLIED) =================== */

+!assess_flag : flag(F) <-
  .print("Meta: assess_flag. Se conoce flag en: ", F);
  !take_flag(F).

+!take_flag(F) : true <-
  .print("Meta: take_flag. Moviendose hacia la bandera en: ", F);
  +to_flag;
  .goto(F).

+target_reached(T) : to_flag <-
  .print("Bandera alcanzada.");
  -to_flag;
  -target_reached;
  if (not flag_taken) {
		!!capture_flag;
	}.

/* ----------------------------------------------------------------------

`bring_flag_home` solo se dispara en caso de coger la bandera!

Si el agente soldado ha sido más lento que otro soldado porque ha 
empezado en una posición de la base más alejada, no cogerá la bandera.

Ahora pues tocará diseñar qué hace en caso de no coger la bandera.

---------------------------------------------------------------------- */

+flag_taken <-
  // .wait(500);
  !bring_flag_home.

+!bring_flag_home : base(B) & flag(F) <-
  .print("He llegado a la bandera en: ", F, ". Capturando bandera...");
  .print("Meta: bring_flag_home. Moviendose hacia la base en: ", B);
  +returning;
  .goto(B).

+target_reached(T) : returning <-
  .print("He llegado a la base en: ", B, ". Entregando bandera.");
  -returning;
  -target_reached(T).

/*
============================================================
################### COMPORTAMIENTO COMUN ###################
============================================================
*/

/* =================== REACCIÓN DE ATAQUE =================== */

+enemies_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]) : true <-
  .print("Shooting to:", ID, TYPE);
  .shoot(10,[X,Y,Z]).

/* =================== MUNICIÓN Y SALUD =================== */

// Buscar munición
+ammo(A) : a_t(T) & A < T & not finding_ammo <- 
  .print("No tengo suficiente municion.");
  +finding_ammo;
  !find_ammo.

// Buscar cura
+health(H) : h_t(T) & H < T & not finding_health <-
  .print("Necesito recuperar salud.");
  +finding_health;
  !find_health.

+!find_ammo : ammo_pack(P) <-
  .print("Dirigiendome hacia la municion.");
  +to_ammo;
  .goto(P).

+!find_ammo <-
  .print("No tengo constancia de ningun pack de municion.");
  -finding_ammo;
  !explore.

+!find_health : cure_pack(P) <-
  .print("Dirigiendome hacia la cura.");
  +to_cure;
  .goto(P).

+!find_health <-
  .print("No tengo constancia de ningun pack de cura.");
  -finding_health;
  !explore.

+target_reached(T) : to_ammo <-
  .print("Ammo cogida");
  -to_ammo;
  -finding_ammo;
  -target_reached(T).

+target_reached(T) : to_cure <-
  .print("Cura cogida");
  -to_cure;
  -finding_health;
  -target_reached(T).

+packs_in_fov(_, TYPE, _, _, _, POSITION) : TYPE == 1001 & not cure_pack(POSITION)
    <-
    .print("He detectado un CURE pack distinto en ", POSITION);
    +cure_pack(POSITION).

+packs_in_fov(_, TYPE, _, _, _, POSITION) :TYPE == 1002 & not ammo_pack(POSITION)
    <-
    .print("He detectado un AMMO pack distinto en ", POSITION);
    +ammo_pack(POSITION).

/* =================== EXPLORAR =================== */

+!explore <-
  // .print("Explorando...");
  .turn(1.571); // Girar pi/2 (90º)
  .wait(100);
  !!explore.
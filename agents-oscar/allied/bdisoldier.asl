/* Agente Soldado Deliberativo – Equipo ALLIED */

/* =================== CRENCIAS INICIALES =================== */

+flag(F).
+health(H).
+ammo(A).

!capture_flag.

/* =================== META PRINCIPAL =================== */
/* El soldado debe capturar la bandera */
+!capture_flag : true <-
  .print("Meta: capture_flag iniciada");
  // health(H);
  // ammo(A);
  // flag(F);
  .print("Estado inicial: health=", H, " ammo=", A);
  !assess_flag.

/* =================== PLANES PARA LA CAPTURA DE LA BANDERA =================== */

+!assess_flag : flag(F) <-
  .print("Meta: assess_flag. Se conoce flag en: ", F);
  !take_flag(F).

+!take_flag(F) : true <-
  .print("Meta: take_flag. Moviendose hacia la bandera en: ", F);
  +exploring; 
  .goto(F);
  .wait(2000).

+flag_taken : true <-
  !bring_flag_home.

+!bring_flag_home : base(B) <-
  .print("He llegado a la bandera en: ", F, ". Capturando bandera...");
  .print("Meta: bring_flag_home. Moviendose hacia la base en: ", B);
  -exploring;
  +returning;
  .goto(B);
  .wait(500);
  .print("He llegado a la base en: ", B, ". Entregando bandera.").

/*Fin del codigo*/

/*
+flag (F): team(100)
  <-
  .goto(F).

+flag_taken: team(100)
  <-
  .print("In ASL, TEAM_ALLIED flag_taken");
  ?base(B);
  +returning;
  .goto(B);
  -exploring.

+heading(H): exploring
  <-
  .wait(2000);
  .turn(0.375).

+target_reached(T): team(100)
  <-
  .print("target_reached");
  +exploring;
  .turn(0.375).

+enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <-
  .shoot(3,Position).
*/
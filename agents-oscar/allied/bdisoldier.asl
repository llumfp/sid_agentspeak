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
  .print("Estado inicial: health=", H, " ammo=", A);
  !assess_flag.

/* =================== PLANES PARA LA CAPTURA DE LA BANDERA =================== */

+!assess_flag : flag(F) <-
  .print("Meta: assess_flag. Se conoce flag en: ", F);
  !take_flag(F).

+!take_flag(F) : true <-
  .print("Meta: take_flag. Moviendose hacia la bandera en: ", F);
  .goto(F).

+flag_taken : true <-
  !bring_flag_home.

+!bring_flag_home : base(B) <-
  .print("He llegado a la bandera en: ", F, ". Capturando bandera...");
  .print("Meta: bring_flag_home. Moviendose hacia la base en: ", B);
  +returning;
  .goto(B).

+target_reached(T) : returning <-
  -returning;
  .print("He llegado a la base en: ", B, ". Entregando bandera.").
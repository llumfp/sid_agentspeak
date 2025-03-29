/* Agente Soldado Deliberativo – Equipo ALLIED */

/* =================== CRENCIAS INICIALES =================== */

+flag(F).
+health(H).
+ammo(A).

!capture_flag.

/* =================== META PRINCIPAL =================== */

/* El soldado debe capturar la bandera */

+!capture_flag : true <-
  .wait(1000);
  .print("Meta: capture_flag iniciada");
  ?health(H);
  ?ammo(A);
  .print("Helth = ", H, " Ammo = ", A);
  !assess_flag.

/* =================== PLANES PARA LA CAPTURA DE LA BANDERA =================== */

+!assess_flag : flag(F) <-
  .print("Meta: assess_flag. Se conoce flag en: ", F);
  !take_flag(F).

+!take_flag(F) : true <-
  .print("Meta: take_flag. Moviendose hacia la bandera en: ", F);
  .goto(F).

/* ----------------------------------------------------------------------

`bring_flag_home` solo se dispara en caso de coger la bandera!

Si el agente soldado ha sido más lento que otro soldado porque ha 
empezado en una posición de la base más alejada, no cogerá la bandera.

Ahora pues tocará diseñar qué hace en caso de no coger la bandera.

---------------------------------------------------------------------- */

+flag_taken : true <-
  !bring_flag_home.

+!bring_flag_home : base(B) & flag(F) <-
  .print("He llegado a la bandera en: ", F, ". Capturando bandera...");
  .print("Meta: bring_flag_home. Moviendose hacia la base en: ", B);
  +returning;
  .goto(B).

+target_reached(T) : returning <-
  -returning;
  .print("He llegado a la base en: ", B, ". Entregando bandera.").

/* =================== REACCIÓN DE ATAQUE =================== */

+enemies_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]) : true <-
  .shoot(5,[X,Y,Z]).

/* =================== MUNICIÓN =================== */

// Buscar munición
+ammo(A) : A > 50 <- 
  .wait(500);
  .print("Tengo municion.").

// Buscar cura
+health(H) : H > 50 <-
  .wait(500);
  .print("No me muero!").




// Ver packs de munición cuando tenemos poca munición
+packs_in_fov(ID, 1002, Angle, Distance, Health, Position): ammo(A) & A <= 40 & not yendo_municion
  <-
  .print("Pack de municion detectado! Yendo a por el");
  +yendo_municion;
  .goto(Position).

// Cuando llegamos al pack de munición
+target_reached(T): yendo_municion
  <-
  .print("He recargando balas, vamos a curar!");
  -yendo_municion;
  -target_reached(T).
// ====== ESTRATEGIA PARA MÉDICO INDIVIDUAL - PRIORIDAD: MANTENER AL EQUIPO VIVO Y APOYAR EN CAPTURA ======

// Umbral para considerar mala salud propia
health_threshold(40).

// === INICIALIZACIÓN ===

// EQUIPO AXIS - DEFENSIVO: Patrullar cerca del objetivo
+flag(F): team(200)
  <-
  .print("Inicializando médico defensor");
  // Crear puntos de patrulla más cercanos al flag (radio pequeño, más puntos)
  .create_control_points(F, 20, 6, C);
  +control_points(C);
  .length(C, L);
  +total_control_points(L);
  +patrolling;
  +patrol_point(0);
  ?control_points(C);
  .nth(0, C, Position);
  .goto(Position).

// EQUIPO ALLIED - OFENSIVO: Alternar entre capturar la bandera y apoyar a soldados
+flag(F): team(100)
  <-
  .print("Inicializando médico atacante");
  // Ir directamente hacia la bandera inicialmente
  +objective(F);
  +mission(capture_flag);
  .goto(F);
  // También obtener soldados para posible apoyo posterior
  .get_backups.


// === PRIORIZACIÓN DE MISIONES ===

// Alternancia entre misiones - después de un tiempo, alternar a captura de bandera
+mission(support_soldiers): team(100)
  <-
  .print("Modo apoyo a soldados activo");
  .wait(25000);  // Permanecer en modo soporte durante 25 segundos
  -mission(support_soldiers);
  +mission(capture_flag);
  ?objective(F);
  .goto(F).

// Alternar a modo soporte después de un tiempo
+mission(capture_flag): team(100)
  <-
  .print("Modo captura de bandera activo");
  .wait(15000);  // Permanecer en modo captura durante 15 segundos
  -mission(capture_flag);
  +mission(support_soldiers);
  .get_backups.

// === COMPORTAMIENTO DE EQUIPO ===

// Actualizar lista de soldados periódicamente
+myBackups(S): mission(support_soldiers) & team(100) & not healing_ally
  <-
  .length(S, L);
  if (L > 0) {
    +following_soldier;
    .nth(0, S, FirstSoldier); // Tomar primer soldado de la lista
    .print("Médico siguiendo a soldado: ", FirstSoldier);
    .goto(FirstSoldier);
  }.

// === COMPORTAMIENTO DEFENSIVO ===

// Ver enemigos - mantener distancia pero también crear packs médicos
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position)
  <-
  if (Distance < 15) {
    // Enemigo muy cerca - retroceder y curar
    .print("Enemigo cerca, manteniendo distancia y creando packs");
    .cure;
    // Cambiar dirección de movimiento
    .turn(0.5);
  } else {
    // Enemigo a distancia segura - crear pack médico de todas formas
    .cure;
    // Si el enemigo está muy dañado y tenemos munición, podemos disparar
    if (Health < 30 & ammo(A) & A > 10) {
      .shoot(1, Position);
    }
  }.

// === MANEJO DE LA BANDERA ===

// Si vemos la bandera muy cerca, intentar tomarla
+target_reached(T): mission(capture_flag) & team(100)
  <-
  .print("¡Objetivo alcanzado! Cerca de la bandera");
  .cure;  // Dejar un pack médico para apoyar a los soldados
  // Cambiar a modo soporte después de llegar a la bandera
  -mission(capture_flag);
  +mission(support_soldiers);
  .get_backups;
  -target_reached(T).

// Si tomamos la bandera, volver a la base inmediatamente
+flag_taken: team(100)
  <-
  .print("¡BANDERA CAPTURADA! Volviendo a base");
  -mission(capture_flag);
  -mission(support_soldiers);
  +mission(return_flag);
  ?base(B);
  .goto(B).

// === PATRULLAJE (EQUIPO AXIS) ===

// Llegar a un punto de patrulla
+target_reached(T): patrolling & team(200)
  <-
  // Dejar un pack médico en cada punto de patrulla
  .print("Punto de patrulla alcanzado, dejando pack médico");
  .cure;
  // Actualizar al siguiente punto
  ?patrol_point(P);
  ?total_control_points(TP);
  if (P + 1 >= TP) {
    -+patrol_point(0);
  } else {
    -+patrol_point(P + 1);
  }
  // Ir al siguiente punto
  ?control_points(CP);
  ?patrol_point(NP);
  .nth(NP, CP, NextPosition);
  .goto(NextPosition);
  -target_reached(T).

// === DETECCIÓN Y CURACIÓN PROACTIVA ===

// Ver aliados con poca vida - PRIORIDAD ALTA (sobrepasa cualquier misión)
+friends_in_fov(ID, Type, Angle, Distance, Health, Position): Health < 50 & not healing_ally
  <-
  +healing_ally;
  -following_soldier;
  .print("¡Aliado con salud crítica detectado! ID: ", ID, " Salud: ", Health);
  .goto(Position);
  .wait(1000); 
  .cure;
  -healing_ally.

// Cuando estamos cerca de un aliado, crear pack médico proactivamente
+friends_in_fov(ID, Type, Angle, Distance, Health, Position): Distance < 5
  <-
  .print("Aliado cercano, creando pack médico preventivo");
  .cure.

// === AUTO-PRESERVACIÓN ===

// Si tenemos poca vida, curarnos y buscar refugio
+health(H): health_threshold(T) & H < T
  <-
  .print("¡Salud crítica! Curándome");
  .cure;
  // Retirarse a una posición segura temporalmente
  .turn(1.0); // Dar la vuelta (alejarse del frente)
  .wait(1000).

// Cuando nos curamos, volvemos a nuestra misión
+pack_taken(medic, Q)
  <-
  .print("Pack médico recogido: +", Q, " de salud");
  // Volver a la tarea anterior
  if (team(100)) {
    if (mission(capture_flag)) {
      ?objective(F);
      .goto(F);
    } else {
      .get_backups;
    }
  } else {
    ?patrol_point(P);
    ?control_points(C);
    .nth(P, C, Pos);
    .goto(Pos);
  }.

// Si tenemos poca munición, seguir igual - la prioridad es curar
+ammo(A): A < 10
  <-
  .print("Munición baja, pero no es prioridad para un médico").

// === MOVIMIENTO ===

// Exploración mientras no hay otra tarea y esperamos
+heading(H): team(100) & not healing_ally & not following_soldier
  <-
  .wait(1000);
  // Crear packs médicos mientras explora
  .cure;
  .turn(0.25).
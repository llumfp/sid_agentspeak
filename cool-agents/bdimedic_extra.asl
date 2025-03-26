// ====== ESTRATEGIA PARA MÉDICO EXTRA ======

// Umbral para considerar mala salud propia
health_threshold(40).

// === INICIALIZACIÓN ===

// EQUIPO AXIS - DEFENSIVO: Patrullar cerca del objetivo
+flag(F): team(200)
  <-
  .print("Inicializando medico defensor");
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

// EQUIPO ALLIED - OFENSIVO: Ir directamente a por la bandera
+flag(F): team(100)
  <-
  .print("Inicializando medico atacante, yendo hacia bandera");
  +objective(F);
  .goto(F).

// === COMPORTAMIENTO DE EQUIPO ALLIED ===

// Cuando llegamos al objetivo (bandera)
+target_reached(T): team(100) & objective(F)
  <-
  .print("Objetivo alcanzado, dejando pack médico en la bandera");
  .cure;
  // Actualizamos backups para tener soldados a quienes seguir
  .get_backups;
  // Limpiamos el evento
  -target_reached(T).

// Cuando conseguimos la lista de soldados y hay al menos uno
+myBackups(S): team(100) & .length(S, L) & L > 0
  <-
  .nth(0, S, FirstSoldier);
  .print("Siguiendo a soldado: ", FirstSoldier);
  .goto(FirstSoldier).

// Cuando conseguimos la lista de soldados pero está vacía
+myBackups(S): team(100) & .length(S, L) & L == 0
  <-
  .print("No hay soldados disponibles, volviendo al objetivo");
  ?objective(F);
  .goto(F).

// Captura de la bandera
+flag_taken: team(100)
  <-
  .print("¡BANDERA CAPTURADA! Volviendo a base");
  ?base(B);
  .goto(B).

// === PATRULLAJE (EQUIPO AXIS) ===

// Llegar a un punto de patrulla
+target_reached(T): patrolling & team(200) & patrol_point(P) & total_control_points(TP) & P + 1 < TP
  <-
  // Dejar un pack médico en cada punto de patrulla
  .print("Punto de patrulla alcanzado, dejando pack médico");
  .cure;
  // Actualizar al siguiente punto
  -+patrol_point(P + 1);
  // Ir al siguiente punto
  ?control_points(CP);
  ?patrol_point(NP);
  .nth(NP, CP, NextPosition);
  .goto(NextPosition);
  -target_reached(T).

// Llegar al último punto de patrulla
+target_reached(T): patrolling & team(200) & patrol_point(P) & total_control_points(TP) & P + 1 >= TP
  <-
  // Dejar un pack médico en cada punto de patrulla
  .print("Último punto de patrulla alcanzado, reiniciando");
  .cure;
  // Volver al primer punto
  -+patrol_point(0);
  // Ir al primer punto
  ?control_points(CP);
  ?patrol_point(NP);
  .nth(NP, CP, NextPosition);
  .goto(NextPosition);
  -target_reached(T).

// === COMPORTAMIENTO DEFENSIVO ===

// Ver enemigos muy cerca - retroceder y curar
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position): Distance < 15
  <-
  .print("Enemigo cerca, manteniendo distancia y creando packs");
  .cure;
  // Cambiar dirección de movimiento
  .turn(0.5).

// Ver enemigos a distancia segura - solo curar
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position): Distance >= 15 & Health >= 30
  <-
  .print("Enemigo a distancia segura, creando pack médico");
  .cure.

// Ver enemigos a distancia segura - curar y dispararles 
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position): Distance >= 15  & ammo(A) & A > 10
  <-
  .print("Enemigo débil detectado, disparando");
  .cure;
  .shoot(5, Position).

// === DETECCIÓN Y CURACIÓN PROACTIVA ===

// Ver aliados con poca vida - PRIORIDAD ALTA
+friends_in_fov(ID, Type, Angle, Distance, Health, Position): Health < 50
  <-
  .print("¡Aliado con salud crítica detectado! ID: ", ID, " Salud: ", Health);
  .goto(Position);
  .cure.

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
  .turn(1.0);
  .wait(1000).

// Cuando nos curamos, volvemos a nuestra tarea (Allied)
+pack_taken(medic, Q): team(100)
  <-
  .print("Pack médico recogido: +", Q, " de salud");
  .get_backups.

// Cuando nos curamos, volvemos a nuestra tarea (Axis)
+pack_taken(medic, Q): team(200)
  <-
  .print("Pack médico recogido: +", Q, " de salud");
  ?patrol_point(P);
  ?control_points(C);
  .nth(P, C, Pos);
  .goto(Pos).

// Si tenemos poca munición, seguir igual - la prioridad es curar
+ammo(A): A < 10
  <-
  .print("Munición baja, pero no es prioridad para un médico").

// === MOVIMIENTO ===

// Si estamos detenidos, explorar y buscar aliados
+heading(H): team(100)
  <-
  .print("Explorando y creando packs médicos");
  .cure;
  .wait(2000);
  // Refrescar soldados periódicamente
  .get_backups;
  .turn(0.25).
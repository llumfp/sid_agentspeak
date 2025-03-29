/*
 * ========================================
 * ESTRATEGIA DE AGENTE MÉDICO PARA PYGOMAS
 * ========================================
 * 
 * Agente médico que proporciona soporte curativo al equipo y 
 * participa en combate secundariamente según la situación táctica.
 * 
 * COMPORTAMIENTO GENERAL:
 * - Prioriza la curación de aliados con salud crítica (<50)
 * - Tiene comportamientos específicos según el equipo (Axis o Allied)
 * - Mantiene distancia segura de enemigos cercanos
 * - Dispara a enemigos cuando tiene suficiente munición
 * - Busca packs de munición cuando sus reservas son bajas
 * - Se cura a sí mismo cuando su salud es crítica
 * 
 * EQUIPO AXIS (DEFENSIVO):
 * - Crea puntos de patrulla alrededor de la bandera
 * - Patrulla sistemáticamente estos puntos dejando packs médicos
 * - Protege el área de la bandera
 * 
 * EQUIPO ALLIED (OFENSIVO):
 * - Va directamente a la bandera (punto estratégico donde estarán compañeros)
 * - Se dirige a la base cuando se captura la bandera
 * - Prioriza estar cerca del objetivo sobre seguir a soldados específicos
 * 
 * GESTIÓN DE RECURSOS:
 * - Cura proactivamente cuando su salud es baja (<40)
 * - Busca munición cuando está por debajo del 40%
 * - Responde tácticamente a enemigos según distancia y salud
 * 
 * PATRONES DEFENSIVOS:
 * - Retrocede y cambia dirección ante enemigos cercanos
 * - Dispara a enemigos lejanos si tiene munición suficiente
 * - Prioriza curación sobre combate
 */

// Umbral para considerar mala salud propia
health_threshold(40).

// === INICIALIZACIÓN ===

// EQUIPO AXIS - DEFENSIVO: Patrullar cerca del objetivo
+flag(F): team(200)
  <-
  .print("Inicializando medico defensor");
  // Crear puntos de patrulla mas cercanos al flag (radio pequeño, mas puntos)
  .create_control_points(F, 20, 6, C);
  +control_points(C);
  .length(C, L);
  +total_control_points(L);
  +patrolling;
  +patrol_point(0);
  ?control_points(C);
  .nth(0, C, Position);
  .goto(Position).

// === COMPORTAMIENTO DE EQUIPO ALLIED ===

// EQUIPO ALLIED - OFENSIVO: Ir directamente a por la bandera, 
// ya que es donde seguramente irán los compañeros
+flag(F): team(100)
  <-
  .print("Inicializando medico atacante, yendo hacia bandera");
  +objective(F);
  .goto(F).

// Si se da el caso que la bandera es capturada -- volver base
+flag_taken: team(100)
  <-
  .print("¡BANDERA CAPTURADA! Volviendo a base");
  ?base(B);
  +returning;
  .goto(B).

// Detectar soldados en el campo de visión y seguirlos -- pierde el foco de ir a la bandera
// puede que con un equipo con más soldados mejor descomentar
//+friends_in_fov(ID, Type, Angle, Distance, Health, Position): Type == 1 & team(100)
// <-
//.print("Soldado detectado en FOV, siguiendolo");
//.goto(Position).


// === PATRULLAJE (EQUIPO AXIS) ===

// Llegar a un punto de patrulla
+target_reached(T): patrolling & team(200) & patrol_point(P) & total_control_points(TP) & P + 1 < TP
  <-
  // Dejar un pack médico en cada punto de patrulla
  .print("Punto de patrulla alcanzado, dejando pack medico");
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
  .print("Ultimo punto de patrulla alcanzado, reiniciando");
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
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position): Distance >= 40 & Health >= 30
  <-
  .print("Enemigo a distancia segura, creando pack medico");
  .cure.

// Ver enemigos a distancia segura - curar y dispararles
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position): Distance >= 15  & ammo(A) & A > 5
  <-
  .print("Enemigo detectado, disparando!");
  .cure;
  .shoot(5, Position).

// === DETECCIÓN Y CURACIÓN PROACTIVA ===

// Ver aliados con poca vida - PRIORIDAD ALTA
+friends_in_fov(ID, Type, Angle, Distance, Health, Position): Health < 50
  <-
  .print("Aliado con salud critica detectado! ID: ", ID, " Salud: ", Health);
  .goto(Position);
  .cure.

// Cuando estamos cerca de un aliado, crear pack médico proactivamente -- es despista si just esta a la bandera
//+friends_in_fov(ID, Type, Angle, Distance, Health, Position): Distance < 5
//<-
//.print("Aliado cercano, creando pack medico preventivo");
//.cure.

// === AUTO-PRESERVACIÓN ===

// Si tenemos poca vida, curarnos y buscar refugio
+health(H): health_threshold(T) & H < T
  <-
  .print("Salud critica! Curandome");
  .cure;
  // Retirarse a una posicion segura temporalmente
  .turn(1.0);
  .wait(1000).

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


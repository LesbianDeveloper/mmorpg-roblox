# Muerte, jefes y almas — v1.2

## 1. Principio: Dark Souls puro
**Lo único que protege lo que llevás encima es gastarlo (o guardarlo en un Alma, que tiene límite).** No hay banco en ningún lado (ni santuarios ni ciudades): con monturas para viajar rápido, cualquier banco sería trivial.

## 2. Esencia
- Matar enemigos da **Esencia**. **No se sube de nivel automáticamente.**
- La Esencia se **gasta en un Santuario** para subir de nivel (costo según `XPForLevel(nivel)`).
- Lo ya gastado (niveles, stats, habilidades, mejoras) está a salvo para siempre.
- La única forma de **guardar** Esencia sin gastarla es dentro de un **Alma de jefe** (sección 7).

## 3. Muerte y Remanente
### Qué se pierde al morir
- La **Esencia sin gastar** que no esté guardada en un Alma
- **Todo el oro**
- **Todos los materiales**

### Qué NO se pierde
- El **equipo** (puesto, en la barra rápida o en el inventario)
- Las **pociones** y demás consumibles comprados (comprarlos ya fue gastar)
- Los **frascos** y las **Almas** (con la Esencia guardada en ellas)

### El Remanente
1. Al morir, todo lo perdido queda en un **Remanente** en el lugar exacto donde caíste.
2. Reaparecés en el último **Santuario** activado.
3. Si tocás el Remanente, **recuperás todo**.
4. Si **volvés a morir antes de recuperarlo**, el Remanente viejo se pierde **para siempre** y queda uno nuevo.
5. Queda guardado aunque salgas del juego o cambies de servidor.
6. **Solo lo ve y lo puede recoger su dueño.**

## 4. Curación
- **La vida no se regenera con el tiempo.**
- Solo se recupera:
  - **Descansando en un Santuario** (vida al máximo)
  - Con **pociones** compradas con **oro** en las tiendas
- Excepción racial: la **Ninfa** regenera vida cerca de agua o bosque (a propósito). Se podrán dar pequeñas ventajas de este tipo a otras razas.

## 5. Santuarios, mundo abierto y mazmorras
### Santuarios
- Se activan al tocarlos y pasan a ser tu punto de reaparición.
- Ahí se gasta la Esencia para subir de nivel, se **liberan** Almas (y más adelante se cambia la especialización).

### Mundo abierto (reglas MMO)
- Descansar **solo** restaura vida y estamina. **No** resetea enemigos.
- Los enemigos reaparecen **por tiempo** y **nunca con un jugador cerca**.
- **Regla de diseño de niveles:** los santuarios van **lejos de las zonas de enemigos**.

### Mazmorras y zonas de jefe (reglas Souls)
- **Instancias separadas**: cada grupo entra a su propia copia.
- **Solo o en grupo de hasta 4**.
- Descansar en el santuario de la mazmorra **resetea a todos sus enemigos**.

## 6. Jefes
### Dónde y con quién
- En **zonas separadas** (instancias). **Solo o en grupo de hasta 4.**

### Dificultad dinámica
- Las stats del jefe **escalan con el nivel del jugador**.
- **En grupo se toma el nivel MÁS ALTO**, para que un jugador avanzado no use a novatos para facilitar al jefe.
- Cada jefe tiene un **nivel recomendado** (su "tier"), que define lo buenas que son sus recompensas.

### Botín
- **Varios drops** (equipo, materiales raros, oro, Runas…). El **Alma** es el más raro.

### Probabilidad del Alma
| Factor | Efecto |
|---|---|
| **Dificultad del jefe** (tier) | Más difícil → **mejor Alma** (más capacidad) **pero más baja la probabilidad** |
| **Nivel por encima del recomendado** | Si el de nivel más alto del grupo supera el recomendado, la probabilidad baja todavía más |

Objetivo: el camino a mejores Almas es **progresar hacia jefes más difíciles**, no repetir los fáciles.

Fórmula a ajustar (borrador): `probAlma = probBase(tier) × penalizaciónNivel`, con ×0,85 por cada nivel de exceso y un piso mínimo.

### Tiempo de espera (anti-spam)
- Tras derrotar a un jefe, **cada jugador que participó** espera un tiempo considerable (a definir, ej. 20–30 min) para volver a enfrentarlo.
- **Por jugador y por jefe.**

## 7. Almas y frascos (DEFINIDO)
### Almas
- El jefe suelta el Alma **vacía**, con una **capacidad máxima de Esencia** según el jefe.
- Podés **guardar Esencia en ella en cualquier momento y lugar**, hasta llenarla. Esa Esencia **no se pierde al morir**.
- **Cuando está llena, no entra más.** La Esencia que lleves encima y no hayas podido guardar **se pierde al morir** (va al Remanente).
- En un **Santuario** podés **liberar** el Alma: recuperás toda su Esencia para gastarla y **el Alma se consume**.
- Para tener Almas mejores (más capacidad) hay que hacer lugar consumiendo las que tenés.

### Frascos de alma
- **3 frascos** como máximo; cada uno guarda **un Alma**.
- Se **compran con oro** en tiendas; son **caros**.
- Se compran **una única vez**: no se rompen, no se pierden y son **reutilizables**.
- **Sin un frasco vacío, el Alma no se puede guardar:** aparece *"El alma escapó…"* y se pierde.

### Ni intercambiables ni vendibles
- **Frascos y Almas no se intercambian** con otros jugadores ni **se venden** en tiendas.
- El resto (recursos y equipamiento) **sí se vende** en tiendas a cambio de oro.

## 8. Arquitectura técnica
- `DeathService`: Esencia, Remanente, santuarios. **Hecho.**
- Sin regeneración de vida: script `Health` vacío en `StarterCharacterScripts`. **Hecho.**
- `EnemyService`: reaparición por tiempo, sin jugadores cerca. **Hecho.**
- Zonas de jefe y mazmorras: places separados con servidor reservado por grupo (`TeleportService:ReserveServer`), máx. 4 jugadores.
- `BossService` (futuro): escalado por nivel máximo del grupo, botín, fórmula del Alma, cooldown por jugador y jefe.
- Datos del jugador: `SoulFlasks` (0–3), `Souls` (lista: jefe, capacidad, Esencia guardada), `BossCooldowns` (jefe → hora de desbloqueo).

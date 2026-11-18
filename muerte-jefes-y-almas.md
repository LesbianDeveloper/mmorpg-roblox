# Muerte, jefes y almas — v1.0

## 1. Principio: Dark Souls puro
**Lo único que protege lo que llevás encima es gastarlo.** No hay banco en ningún lado (ni santuarios ni ciudades): con monturas para viajar rápido, cualquier banco sería trivial.

## 2. Esencia
- Matar enemigos da **Esencia**. **No se sube de nivel automáticamente.**
- La Esencia se **gasta en un Santuario** para subir de nivel (costo según `XPForLevel(nivel)`).
- Lo ya gastado (niveles, stats, habilidades, mejoras) está a salvo para siempre.
- La única forma de **guardar** Esencia sin gastarla es dentro de un **Alma de jefe** (sección 6).

## 3. Muerte y Remanente
### Qué se pierde al morir
- La **Esencia sin gastar** (salvo la que está en Almas)
- **Todo el oro**
- **Todos los materiales**

### Qué NO se pierde
- El **equipo** (puesto o en el inventario)
- Las **pociones** y demás consumibles comprados (comprarlos ya fue gastar)
- Los **frascos** y las **Almas** guardadas en ellos

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
  - Con **pociones** compradas con **oro** en las tiendas de las ciudades
- Excepción racial: la **Ninfa** regenera vida cerca de agua o bosque (se mantiene a propósito, como rasgo único). Se podrán dar pequeñas ventajas de este tipo a otras razas para que cada una tenga un estilo propio.

## 5. Santuarios, mundo abierto y mazmorras
### Santuarios
- Se activan al tocarlos y pasan a ser tu punto de reaparición.
- Ahí se gasta la Esencia para subir de nivel (y más adelante se cambia la especialización).

### Mundo abierto (reglas MMO)
- Descansar **solo** restaura vida y estamina. **No** resetea enemigos.
- Los enemigos reaparecen **por tiempo** y **nunca con un jugador cerca**.
- **Regla de diseño de niveles:** los santuarios van **lejos de las zonas de enemigos**.

### Mazmorras y zonas de jefe (reglas Souls)
- Son **instancias separadas**: cada grupo entra a su propia copia.
- Se juegan **solo o en grupo de hasta 4**.
- Descansar en el santuario de la mazmorra **resetea a todos sus enemigos**.

## 6. Jefes
### Dónde y con quién
- Los jefes están en **zonas separadas** (instancias), igual que las mazmorras.
- **Solo o en grupo de hasta 4 jugadores.**

### Dificultad dinámica
- Las stats del jefe (vida, daño, quizás velocidad o patrones extra) **escalan con el nivel del jugador**.
- **En grupo se toma el nivel MÁS ALTO.** Evita que un jugador avanzado use a novatos para que el jefe salga fácil.
- Cada jefe tiene además un **nivel recomendado** (su "tier"), que define lo buenas que son sus recompensas.

### Botín
- Cada jefe tiene **varios drops** (equipo, materiales raros, oro, Runas…).
- El **Alma** es su drop más raro.

### Probabilidad del Alma
Depende de dos factores; ambos la bajan:

| Factor | Efecto |
|---|---|
| **Dificultad del jefe** (tier) | Cuanto más difícil el jefe, **mejor el Alma** (más capacidad de Esencia) **pero más baja la probabilidad** |
| **Nivel del jugador por encima del recomendado** | Si el jugador (el de nivel más alto del grupo) supera el nivel recomendado del jefe, la probabilidad baja todavía más |

Ejemplos:
- Jefe fácil + jugador de nivel alto → probabilidad **muy baja** (no sirve farmear jefes fáciles).
- Jefe difícil + nivel adecuado o bajo → probabilidad **baja**, pero el Alma es grande.
- Resultado buscado: el camino a mejores Almas es **progresar hacia jefes más difíciles**, no repetir los fáciles.

Fórmula a ajustar (borrador):
`probAlma = probBase(tier) × penalizaciónNivel`, con `penalizaciónNivel = 1` si el nivel ≤ recomendado, y decreciendo rápido por cada nivel de más (ej. ×0,85 por nivel de exceso, con un piso mínimo).

### Tiempo de espera (anti-spam)
- Tras derrotar a un jefe, **cada jugador que participó** debe esperar un tiempo considerable (del orden de varios minutos a definir, ej. 20–30) para volver a enfrentarlo.
- El tiempo es **por jugador y por jefe**: no se puede esquivar cambiando de grupo.

## 7. Almas y frascos
### Almas
- Cada Alma tiene una **capacidad máxima de Esencia** según el jefe que la soltó.
- La Esencia guardada en un Alma **no se pierde al morir**.
- Para mejorar, **hay que consumir las Almas que tenés** y hacer lugar para otras mejores.

### Frascos de alma
- Hay **3 slots** de frascos.
- Los frascos se **compran con oro en tiendas** y son **caros**.
- **Sin un frasco vacío, el Alma no se puede guardar:** al soltarla el jefe, aparece *"El alma escapó…"* y se pierde.
- Máximo **3 Almas al mismo tiempo**.

### A definir
- **Cómo se llena un Alma:** ¿se guarda Esencia en ella en un santuario hasta su capacidad? ¿O viene "llena" con una cantidad fija al soltarla el jefe?
- **Qué pasa al consumirla:** ¿la Esencia vuelve a vos para gastarla en ese momento? ¿El frasco queda vacío y reutilizable, o se rompe y hay que comprar otro? (Que se rompa mantiene caros a los frascos a largo plazo.)
- ¿Las Almas se pueden intercambiar o vender entre jugadores?

## 8. Arquitectura técnica (prevista)
- `DeathService`: Esencia, Remanente, santuarios (curar, reaparición, subir de nivel). **Hecho.**
- Sin regeneración de vida: script `Health` vacío en `StarterCharacterScripts`.
- `EnemyService`: reaparición por tiempo, sin jugadores cerca.
- Zonas de jefe y mazmorras: places separados con servidor reservado por grupo (`TeleportService:ReserveServer`), máx. 4 jugadores.
- `BossService` (futuro): escalado por nivel máximo del grupo, tabla de botín, fórmula del Alma, cooldown por jugador y jefe (guardado en DataStore).
- Datos del jugador: `SoulFlasks` (cantidad comprada, máx. 3), `Souls` (lista de almas con jefe y Esencia), `BossCooldowns` (jefe → hora de desbloqueo).

# Estado del desarrollo

Última actualización: 17/11/2026

## Herramientas
- Roblox Studio + VS Code (extensión Luau Language Server + plugin Companion en Studio)
- Script Sync: carpetas `Shared`, `Server` y `Client` sincronizadas a `C:\Users\bauts\Documents\MMORPG-Roblox\src`
- Git + GitHub: repositorio `mmorpg-roblox`
- Animaciones: generadas por código (KeyframeSequence) y publicadas desde ServerStorage > AnimacionesGeneradas. A futuro: Mixamo + "Reasignar rig"

## Estructura de scripts
| Script | Ubicación | Tipo | Función |
|---|---|---|---|
| Races | ReplicatedStorage/Shared | ModuleScript | 13 razas con % y bonus |
| Classes | ReplicatedStorage/Shared | ModuleScript | 17 clases (3 habilitadas: Guerrero, Mago, Sacerdote) |
| Stats | ReplicatedStorage/Shared | ModuleScript | Stats base, `compute(raza, clase, nivel)`, curva de XP |
| CombatConfig | ReplicatedStorage/Shared | ModuleScript | Números de balance del combate |
| Animations | ReplicatedStorage/Shared | ModuleScript | IDs de animaciones |
| Enemies | ReplicatedStorage/Shared | ModuleScript | Datos de enemigos (Esqueleto) |
| Items | ReplicatedStorage/Shared | ModuleScript | Materiales y monedas |
| PlayerData | ServerScriptService/Server | ModuleScript | Carga/guardado en DataStore (`PlayerData_v1`) |
| RaceService | ServerScriptService/Server | ModuleScript | Tiradas de raza (esquirlas y garantía: a quitar) |
| Rewards | ServerScriptService/Server | ModuleScript | XP, subida de nivel, oro, loot; remote `Notify` |
| PlayerSetup | ServerScriptService/Server | Script | Inicializa jugador, leaderstats, remote `RaceRequest` + comandos dev |
| CombatService | ServerScriptService/Server | Script | Ataques, esquiva, bloqueo, parry, estamina; BindableEvent `DealDamage` |
| EnemyService | ServerScriptService/Server | Script | IA de enemigos: aggro, persecución, ataque, retorno, respawn |
| CombatInput | StarterPlayerScripts/Client | LocalScript | Input, animaciones, barras de vida y estamina |
| ProgressHUD | StarterPlayerScripts/Client | LocalScript | Barra de XP, avisos de botín, "¡NIVEL X!" |

Escena: `Dummy` (TrainingDummy), `DummyAtacante` (AttacksPlayers), `AnimRig`, `EnemySpawns/SkeletonSpawn`, `ServerStorage/EnemyTemplates/Skeleton`.

## Sistemas terminados
- [x] Guardado de datos del jugador
- [x] Razas: tirada con Runas
- [x] Stats según raza, clase y nivel
- [x] Combate base: combo ligero x3, pesado, esquiva con i-frames, bloqueo, parry, guardia rota, estamina
- [x] 7 animaciones de combate
- [x] Enemigo con IA (Esqueleto)
- [x] XP, niveles (máx. 60), oro, loot personal para todos los que pegaron

## Controles
Clic izquierdo: ligero · E: pesado · Q: esquiva · F (mantener): bloqueo / parry

## Comandos de prueba (solo en Studio, vista Cliente)
`game.ReplicatedStorage.RaceRequest:InvokeServer(acción, valor)` con:
`devrace "Demon"` · `devrunes 100` · `devshards 1000` · `devlevel 1` · `devxp 500` · `devinv` · `roll` · `shards "Angel"`

Nota: `require()` desde la barra de comandos devuelve una copia vacía de los módulos. Para ver datos reales, usar los comandos dev.

## Pendientes conocidos
- Los enemigos no tienen animación de caminar (se deslizan)
- La IA va en línea recta (sin pathfinding)
- Al resetearse un enemigo, no se borra la marca de quién le pegó
- No hay UI para elegir clase, tirar raza ni ver el inventario

## Decisiones de diseño tomadas (ver razas-clases-combate.md)
- **Muerte estilo Dark Souls, opción A:** la XP pasa a ser **Esencia**, que se gasta en Santuarios para subir de nivel (sin subida automática). Al morir se pierden la Esencia sin gastar, el oro encima y los materiales sin guardar; quedan en un **Remanente** en el lugar de la muerte. Se recupera tocándolo; si morís de nuevo antes, se pierde para siempre. Persiste entre sesiones.
- **Razas por misiones de NPC** como camino principal; las tiradas quedan como apuesta. **Se elimina el pity** (esquirlas y garantía de Épico).
- **La clase se elige al empezar.**

## Próximos pasos
1. Inventario visible (UI)
2. Equipo: armas y armaduras con stats, slots
3. Crafteo en estaciones (forja), con materiales del loot
4. UI de creación de personaje: elección de clase + primera tirada de raza
5. Sistema de muerte: Esencia, Santuarios (gastar Esencia, respawn), Remanente, banco para materiales
6. Sistema de misiones (`QuestService`), base para las misiones de raza
7. Quitar esquirlas y garantía de `RaceService`; agregar razas desbloqueadas
8. Habilidades de clase (teclas 1–4) y habilidad racial (R)
9. Más enemigos, primer jefe con 2 fases
10. Primer bioma y reino

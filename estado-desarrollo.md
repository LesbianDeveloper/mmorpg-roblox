# Estado del desarrollo

Última actualización: 18/11/2026

## Documentos de diseño
- `razas-clases-combate.md`: razas, clases, stats y combate
- `muerte-jefes-y-almas.md`: Esencia, muerte y Remanente, curación, santuarios, mundo abierto vs. mazmorras, jefes, almas y frascos

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
| Stats | ReplicatedStorage/Shared | ModuleScript | `compute(raza, clase, nivel, equipo)`, curva de costo de nivel |
| CombatConfig | ReplicatedStorage/Shared | ModuleScript | Números de balance del combate |
| Animations | ReplicatedStorage/Shared | ModuleScript | IDs de animaciones |
| Enemies | ReplicatedStorage/Shared | ModuleScript | Datos de enemigos (Esqueleto) con loot |
| Items | ReplicatedStorage/Shared | ModuleScript | Materiales, monedas, armas y armaduras (con Slot y Stats) |
| Recipes | ReplicatedStorage/Shared | ModuleScript | Recetas de crafteo por estación |
| PlayerData | ServerScriptService/Server | ModuleScript | DataStore (`PlayerData_v1`): nivel, Esencia, raza, clase, runas, oro, Inventory, Equipment, Shrines, LastShrine, Remnant, CharacterCreated, FreeRollUsed |
| RaceService | ServerScriptService/Server | ModuleScript | Tiradas de raza (esquirlas y garantía: a quitar) |
| Rewards | ServerScriptService/Server | ModuleScript | Esencia, oro, ítems, loot; remote `Notify` |
| PlayerSetup | ServerScriptService/Server | Script | Inicializa jugador, stats, leaderstats, remote `RaceRequest` + comandos dev |
| CombatService | ServerScriptService/Server | Script | Ataques (+daño de arma), esquiva, bloqueo, parry, estamina, defensa; BindableEvent `DealDamage` |
| EnemyService | ServerScriptService/Server | Script | IA de enemigos; respawn por tiempo y sin jugadores a menos de 40 studs; limpia marcas al resetear |
| InventoryService | ServerScriptService/Server | Script | Remote `InventoryRequest`: get / equip / unequip |
| CraftingService | ServerScriptService/Server | Script | Remote `CraftRequest`: valida cercanía, materiales y oro |
| DeathService | ServerScriptService/Server | Script | Muerte, Remanente, santuarios (activar, curar, reaparición), remote `ShrineRequest` (levelup) |
| CreationService | ServerScriptService/Server | Script | Remote `CreationRequest`: elegir clase, tirada gratis única, terminar; congela al personaje hasta terminar |
| Health | StarterPlayer/StarterCharacterScripts | Script (vacío) | Anula la regeneración de vida de Roblox |
| CombatInput | StarterPlayerScripts/Client | LocalScript | Input de combate, animaciones, barras de vida y estamina |
| ProgressHUD | StarterPlayerScripts/Client | LocalScript | Barra de Esencia/nivel, avisos de botín, "¡NIVEL X!" |
| UIKit | StarterPlayerScripts/Client | ModuleScript | Estilo común, sistema de ventanas, datos compartidos |
| InventoryUI | StarterPlayerScripts/Client | LocalScript | Ventana de inventario; clic para equipar |
| EquipmentUI | StarterPlayerScripts/Client | LocalScript | Ventana de equipo (4 slots) y atributos |
| CraftingUI | StarterPlayerScripts/Client | LocalScript | Ventana de crafteo (ProximityPrompt de la estación) |
| ShrineUI | StarterPlayerScripts/Client | LocalScript | Ventana del santuario: subir de nivel con Esencia |
| RemnantVisual | StarterPlayerScripts/Client | LocalScript | Dibuja el Remanente propio (solo lo ve su dueño) |
| CreationUI | StarterPlayerScripts/Client | LocalScript | Pantalla de creación: clase, ruleta de raza, probabilidades |
| MenuBar | StarterPlayerScripts/Client | LocalScript | Íconos abajo a la derecha + atajos de teclado |

Escena: `Dummy`, `DummyAtacante`, `AnimRig`, `EnemySpawns/SkeletonSpawn`, `Stations/Forja` (StationType "Forge"), `Shrines/Santuario del Inicio` (ShrineId "Start"), `ServerStorage/EnemyTemplates/Skeleton`. Los ProximityPrompt usan tecla G y `RequiresLineOfSight = false`.

## Sistemas terminados
- [x] Guardado de datos del jugador
- [x] Creación de personaje: clase + tirada gratis única de raza
- [x] Stats según raza, clase, nivel y equipo
- [x] Combate base: combo ligero x3, pesado, esquiva con i-frames, bloqueo, parry, guardia rota, estamina
- [x] 7 animaciones de combate
- [x] Enemigo con IA (Esqueleto), reaparición segura
- [x] Esencia, oro, loot personal para todos los que pegaron
- [x] Inventario, equipo (4 slots), barra de menú
- [x] Crafteo en la Forja
- [x] Muerte: Remanente (Esencia + oro + materiales), santuarios (activar, curar, reaparecer, subir de nivel)
- [x] Sin regeneración de vida

## Controles
Clic izquierdo: ligero · E: pesado · Q: esquiva · F (mantener): bloqueo / parry · B: inventario · C: equipo · G: usar estación / santuario

Teclas reservadas por Roblox (evitar): I y O (zoom de cámara), / (chat).

## Comandos de prueba (solo en Studio, vista Cliente)
`game.ReplicatedStorage.RaceRequest:InvokeServer(acción, valor)` con:
`devrace "Demon"` · `devrunes 100` · `devshards 1000` · `devlevel 1` · `devxp 500` (da Esencia) · `devinv` · `devgive "BoneSword"` · `devreset` (repite la creación de personaje) · `roll` · `shards "Angel"`

Nota: `require()` desde la barra de comandos devuelve una copia vacía de los módulos. Para ver datos reales, usar los comandos dev.

## Decisiones clave (resumen)
- Dark Souls puro: sin banco; al morir se pierden Esencia, oro y materiales (Remanente). No se pierden equipo, pociones, frascos ni almas.
- Sin regeneración de vida (salvo la Ninfa): solo santuarios y pociones compradas con oro.
- Mundo abierto con reglas MMO; mazmorras y zonas de jefe instanciadas (solo o hasta 4) con reglas Souls.
- Jefes con dificultad dinámica (nivel más alto del grupo), varios drops, Alma muy rara según tier y nivel, cooldown por jugador.
- 3 frascos de alma, caros, comprados con oro; sin frasco vacío, el alma escapa.
- Razas por misiones de NPC; tiradas como apuesta sin pity. Clase elegida al empezar.
- Toda ventana con ícono en la barra de menú y tecla.

## Pendientes conocidos
- Los enemigos no tienen animación de caminar; la IA va en línea recta (sin pathfinding)
- Las 3 clases pelean igual (faltan habilidades de clase)
- No hay botones táctiles para celular
- El equipo no se ve en el personaje
- El bonus de crafteo del Enano no se aplica

## Próximos pasos
1. Ciudad con tienda: pociones de vida (tecla de uso rápido) y frascos de alma
2. Primer jefe en zona instanciada (2 fases, escalado, botín, Alma, cooldown)
3. Habilidades de clase (1–4) y habilidad racial (R)
4. Sistema de misiones (`QuestService`), base para las misiones de raza
5. Quitar esquirlas y garantía de `RaceService`; razas desbloqueadas
6. Mazmorra instanciada con santuario que resetea
7. Primer bioma y reino; monturas
8. Controles táctiles para celular

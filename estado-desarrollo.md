# Estado del desarrollo

Última actualización: 18/11/2026

## Documentos de diseño
- `razas-clases-combate.md`: razas, clases, stats y combate
- `muerte-jefes-y-almas.md`: Esencia, muerte y Remanente, curación, santuarios, mundo abierto vs. mazmorras, jefes, almas y frascos
- `controles-armas-y-habilidades.md`: barra rápida, armas con efectos pasivos, libro de habilidades, mapa de teclas

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
| Items | ReplicatedStorage/Shared | ModuleScript | Materiales, monedas, consumibles, armas (Color) y armaduras; `Value` = precio de venta |
| Recipes | ReplicatedStorage/Shared | ModuleScript | Recetas de crafteo por estación |
| Shops | ReplicatedStorage/Shared | ModuleScript | Artículos de cada tienda (pociones, frasco de alma) |
| PlayerData | ServerScriptService/Server | ModuleScript | DataStore (`PlayerData_v1`): nivel, Esencia, raza, clase, runas, oro, Inventory, Equipment, Hotbar, Shrines, LastShrine, Remnant, CharacterCreated, FreeRollUsed, SoulFlasks |
| RaceService | ServerScriptService/Server | ModuleScript | Tiradas de raza (esquirlas y garantía: a quitar) |
| Rewards | ServerScriptService/Server | ModuleScript | Esencia, oro, ítems, loot; remote `Notify` |
| Hotbar | ServerScriptService/Server | ModuleScript | Barra rápida: asignar, vaciar, elegir slot, objeto en la mano (`HeldItem`), beber pociones |
| PlayerSetup | ServerScriptService/Server | Script | Inicializa jugador, stats (arma = `HeldItem`), leaderstats, remote `RaceRequest` + comandos dev |
| CombatService | ServerScriptService/Server | Script | Ataques (+daño de arma), esquiva, bloqueo, parry, estamina, defensa; bloquea acciones al beber; BindableEvent `DealDamage` |
| EnemyService | ServerScriptService/Server | Script | IA de enemigos; respawn por tiempo y sin jugadores cerca; limpia marcas al resetear |
| InventoryService | ServerScriptService/Server | Script | Remote `InventoryRequest`: get / equip (solo armaduras) / unequip / hotbar_assign / hotbar_clear |
| HotbarService | ServerScriptService/Server | Script | Remote `HotbarAction`: select / use; migra el arma equipada a la barra |
| CraftingService | ServerScriptService/Server | Script | Remote `CraftRequest`: valida cercanía, materiales y oro |
| ShopService | ServerScriptService/Server | Script | Remote `ShopRequest`: buy / sell; valida cercanía al mercader |
| DeathService | ServerScriptService/Server | Script | Muerte, Remanente, santuarios (activar, curar, reaparición), remote `ShrineRequest` (levelup) |
| CreationService | ServerScriptService/Server | Script | Remote `CreationRequest`: clase, tirada gratis única, terminar |
| Health | StarterPlayer/StarterCharacterScripts | Script (vacío) | Anula la regeneración de vida de Roblox |
| CombatInput | StarterPlayerScripts/Client | LocalScript | Input de combate (clic = atacar o usar consumible), animaciones, barras de vida y estamina |
| ProgressHUD | StarterPlayerScripts/Client | LocalScript | Barra de Esencia/nivel, avisos de botín, "¡NIVEL X!" |
| UIKit | StarterPlayerScripts/Client | ModuleScript | Estilo común, sistema de ventanas, datos compartidos |
| InventoryUI | StarterPlayerScripts/Client | LocalScript | Inventario: oro, runas, frascos; clic en arma/poción → barra, en armadura → equipar |
| EquipmentUI | StarterPlayerScripts/Client | LocalScript | Equipo (Cabeza, Pecho, Piernas) y atributos |
| HotbarUI | StarterPlayerScripts/Client | LocalScript | Barra rápida de 6 slots; teclas 1–6; clic derecho vacía |
| CraftingUI | StarterPlayerScripts/Client | LocalScript | Ventana de crafteo |
| ShopUI | StarterPlayerScripts/Client | LocalScript | Tienda: pestañas Comprar / Vender |
| ShrineUI | StarterPlayerScripts/Client | LocalScript | Santuario: subir de nivel con Esencia |
| RemnantVisual | StarterPlayerScripts/Client | LocalScript | Dibuja el Remanente propio |
| CreationUI | StarterPlayerScripts/Client | LocalScript | Pantalla de creación de personaje |
| MenuBar | StarterPlayerScripts/Client | LocalScript | Íconos abajo a la derecha + atajos |

Escena: `Dummy`, `DummyAtacante`, `AnimRig`, `EnemySpawns/SkeletonSpawn`, `Stations/Forja`, `Shrines/Santuario del Inicio` (ShrineId "Start"), `Shops/Mercader` (ShopId "General", sin Humanoid), `ServerStorage/EnemyTemplates/Skeleton`. Los ProximityPrompt usan tecla G y `RequiresLineOfSight = false`.

## Sistemas terminados
- [x] Guardado de datos; creación de personaje (clase + tirada única)
- [x] Stats según raza, clase, nivel, armadura y arma en la mano
- [x] Combate base: combo, pesado, esquiva, bloqueo, parry, guardia rota, estamina; 7 animaciones
- [x] Enemigo con IA (Esqueleto), reaparición segura
- [x] Esencia, oro, loot personal
- [x] Inventario, equipo (armaduras), barra rápida de 6 slots con objeto en la mano
- [x] Pociones de vida (beber vulnerable, 40%)
- [x] Crafteo en la Forja
- [x] Tienda: comprar pociones y frascos de alma, vender recursos y equipo
- [x] Muerte: Remanente, santuarios, subir de nivel; sin regeneración de vida

## Controles
Clic: usar objeto activo (atacar / beber) · 1–6: slot de la barra · E: pesado · Q: esquiva · F: bloqueo/parry · B: inventario · C: equipo · G: interactuar

Teclas reservadas por Roblox (evitar): I y O (zoom de cámara), / (chat).

## Comandos de prueba (solo en Studio, vista Cliente)
`game.ReplicatedStorage.RaceRequest:InvokeServer(acción, valor)` con:
`devrace "Demon"` · `devrunes 100` · `devshards 1000` · `devlevel 1` · `devxp 500` (da Esencia) · `devgold 5000` · `devinv` · `devgive "HealthPotion"` · `devreset` · `roll` · `shards "Angel"`

Notas:
- `require()` desde la barra de comandos devuelve una copia vacía de los módulos.
- Cambiar atributos a mano (ej. `SetAttribute("Gold", …)`) solo cambia lo visible, no los datos reales. Usar los comandos dev.

## Pendientes conocidos
- Los enemigos no tienen animación de caminar; la IA va en línea recta (sin pathfinding)
- Las 3 clases pelean igual (falta el libro de habilidades)
- Faltan efectos pasivos de armas y armas a distancia (proyectiles con costo de maná)
- No hay animación de beber
- No hay botones táctiles para celular
- La armadura no se ve en el personaje
- El bonus de crafteo del Enano no se aplica
- Ventana de Almas (frascos y su contenido): se hace con el primer jefe

## Próximos pasos
1. Libro de habilidades (Z, X, V, T + K) con las primeras habilidades de Guerrero, Mago y Sacerdote
2. Armas a distancia (bastón: bola de fuego con maná) y efectos pasivos de armas
3. Primer jefe en zona instanciada (2 fases, escalado, botín, Alma, cooldown) + ventana de Almas
4. Sistema de misiones (`QuestService`), base para las misiones de raza
5. Quitar esquirlas y garantía de `RaceService`; razas desbloqueadas
6. Mazmorra instanciada con santuario que resetea
7. Primer bioma, ciudad y reino; monturas
8. Controles táctiles para celular

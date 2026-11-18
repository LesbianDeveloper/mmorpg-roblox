# Diseño v0.6 — Razas, clases y combate

> La muerte, la progresión, los jefes y las almas están en **muerte-jefes-y-almas.md**.

## Principio central
- **La clase define CÓMO peleás:** rol, habilidades, armas, recurso. **Se elige al empezar el juego.**
- **La raza define CON QUÉ VENTAJAS:** bonus pasivos que crecen con la rareza y una habilidad racial. **Se gana con misiones** (o con suerte en una tirada).
- **El combate base es común a todos:** vida, estamina, esquiva, bloqueo, ataque ligero y pesado. Sobre esa base, cada clase agrega lo suyo.
- Cualquier raza puede ser cualquier clase, salvo las clases exclusivas de raza.

## Stats
| Stat | Efecto |
|---|---|
| Fuerza | Daño cuerpo a cuerpo pesado, armadura de placas |
| Agilidad | Daño con armas ligeras y a distancia, crítico, velocidad de ataque |
| Intelecto | Daño mágico, curación, maná máximo |
| Vitalidad | Vida máxima |
| Aguante | Estamina máxima y regeneración de estamina |

Fórmula de daño (borrador):
`daño = base_ataque × (1 + stat_principal/100) × multiplicadores (raza, crítico, buffs) × 100/(100 + defensa_objetivo)`

## Recursos
| Recurso | Quién | Para qué |
|---|---|---|
| Vida | Todos | Al llegar a 0, morís. **No se regenera sola** (solo santuarios y pociones) |
| Estamina | Todos | Esquivar, bloquear, atacar, correr. Se regenera sola |
| Recurso de clase | Según la clase | Maná, Furia, Energía, Concentración, Runas, Chi, Furia demoníaca, Esencia de dragón |

---

## Clases

### Elección
La clase se elige **al crear el personaje**. Cambiarla después requiere una misión o un ítem especial (a definir).

### Especializaciones
Cada clase tiene 1 a 3 **especializaciones** (por ejemplo, Paladín: Protección / Sagrado / Represalia). Se cambian en un santuario o ciudad. Cada especialización tiene su set de 4 habilidades.

### Modelo de acceso
| Tipo | Cómo se obtiene |
|---|---|
| **Base** | Gratis desde el inicio |
| **Premium** | Robux (Game Pass) **o** desbloqueo largo jugando (misión de clase + moneda del juego) |
| **Heroica** | Requiere nivel alto + cadena de misiones; también se puede adelantar con Robux |
| **Exclusiva de raza** | Solo si tenés esa raza |

Regla de balance: **las clases pagas son *sidegrades*, no más fuertes.**

### Lista
| Clase | Acceso | Roles (especializaciones) | Stat | Armas | Recurso | Estilo |
|---|---|---|---|---|---|---|
| **Guerrero** | Base | Tanque / Daño | Fuerza | Espada+escudo, armas a dos manos | Furia | Clásico cuerpo a cuerpo; más furia al recibir y hacer daño |
| **Cazador** | Base | Daño a distancia | Agilidad | Arco, ballesta | Concentración | Mascota domesticable que pelea a su lado; trampas |
| **Sacerdote** | Base | Sanación / Daño mágico (sombra) | Intelecto | Bastón, varita | Maná | Curaciones y escudos, o daño de sombras a lo largo del tiempo |
| **Mago** | Base | Daño a distancia (fuego / escarcha / arcano) | Intelecto | Bastón, varita+tomo | Maná | Hechizos de área, control de masas, frágil |
| **Pícaro** | Base | Daño cuerpo a cuerpo | Agilidad | Dagas, espada corta | Energía | Sigilo, golpes por la espalda, venenos, combos |
| **Paladín** | Base | Tanque / Sanación / Daño | Fuerza o Intelecto | Maza, espada+escudo | Maná | Guerrero sagrado con armadura de placas; auras para el grupo |
| **Druida** | Base | Tanque / Sanación / Daño | Agilidad o Intelecto | Bastón, garras | Maná / Energía | Formas: oso (tanque), gato (daño cc), árbol (sanación), lechuza (daño a distancia) |
| **Brujo** | Premium | Daño a distancia | Intelecto | Bastón, daga ritual | Maná + Fragmentos de alma | Invoca esbirros demoníacos; maldiciones |
| **Chamán** | Premium | Sanación / Daño a distancia / Daño cc | Intelecto o Agilidad | Hacha+escudo, bastón | Maná | Tótems elementales (fuego, agua, tierra, aire) |
| **Monje** | Premium | Tanque / Sanación / Daño | Agilidad | Puños, bastón | Chi + Energía | Artes marciales, mucha movilidad, combos |
| **Bardo** | Premium | Sanación / Soporte | Intelecto | Laúd, arpa, flauta | Inspiración | Canciones que dan buffs al grupo o debilitan enemigos |
| **Valquiria** | Premium | Tanque / Daño | Fuerza | Lanza, escudo | Furia | Saltos aéreos, cargas con lanza; mitología nórdica |
| **Ronin** | Premium | Daño cuerpo a cuerpo | Agilidad | Katana, nodachi | Concentración | Posturas, contraataques e *iaido*; estilo Souls puro |
| **Alquimista** | Premium | Daño a distancia / Sanación | Intelecto | Frascos, bombas | Reactivos | Pociones explosivas o curativas; sinergia con crafteo |
| **Caballero de la Muerte** | Heroica | Tanque / Daño | Fuerza | Espada rúnica a dos manos | Runas | Magia de escarcha y sangre; levanta muertos; robo de vida |
| **Cazador de demonios** | Heroica | Tanque / Daño | Agilidad | Gujas de guerra | Furia demoníaca | Movilidad altísima: doble salto, planeo, transformación demoníaca |
| **Evocador** | Exclusiva de **Dracónido** | Sanación / Daño a distancia | Intelecto | Garras, magia | Esencia de dragón | Magia de dragón: ataques cargados, vuelo corto |

Total: 17 clases. Primero 3 base (Guerrero, Mago, Sacerdote); el resto por actualizaciones. **Al final tienen que estar todas.**

---

## Razas

### Cómo se consigue una raza
**Camino principal: misiones de raza.** Cada raza (salvo Humano) tiene un **NPC propio** en el mundo, en su bioma o lugar característico. Hablando con él y completando su **cadena de misiones** obtenés esa raza. Cuanto más rara la raza, más larga y difícil es su cadena.

**Camino secundario: tiradas.** Las Runas del Destino siguen existiendo como apuesta: una tirada puede darte cualquier raza, pero lo bueno es muy improbable. **No hay pity ni esquirlas.**

Reglas:
- La **primera tirada es gratis** al crear el personaje (casi siempre sale Humano).
- Las razas obtenidas por misión quedan **desbloqueadas para siempre**. Se puede cambiar entre razas desbloqueadas en el *Altar de los Linajes*, con algún coste.
- Las misiones tienen requisitos (nivel mínimo, reputación, haber terminado otra cadena…).
- Cambiar de raza conserva nivel, equipo y clase (salvo Evocador, que requiere Dracónido).
- **Si se venden Runas por Robux:** las probabilidades se muestran antes de tirar. Hay que revisar las reglas vigentes de Roblox sobre ítems aleatorios pagos.

### Probabilidades de la tirada (curva empinada)
| Rareza | Raza | % | ~Tiradas promedio |
|---|---|---|---|
| Común | Humano | 70% | 1 |
| Poco común | Enano | 8% | 12 |
| Poco común | Orco | 6% | 17 |
| Raro | Elfo silvano | 4% | 25 |
| Raro | Jotunn (gigante) | 3,5% | 29 |
| Raro | Ninfa | 3% | 33 |
| Épico | Elfo oscuro | 1,5% | 67 |
| Épico | Gorgona | 1,1% | 91 |
| Épico | Æsir / Vanir | 1,1% | 91 |
| Legendario | Kitsune | 0,7% | 143 |
| Legendario | Dracónido | 0,5% | 200 |
| Mítico | Ángel | 0,4% | 250 |
| Mítico | Demonio | 0,2% | 500 |
| | **Total** | **100%** | |

### Misiones de raza (ideas iniciales)
| Raza | NPC / lugar | Idea de la cadena | Dificultad |
|---|---|---|---|
| Enano | Maestro herrero en las minas de montaña | Forjar piezas con materiales de las profundidades; sobrevivir a un derrumbe | Media |
| Orco | Jefe de un campamento de guerra | Pruebas de combate en arena; vencer al campeón del clan | Media |
| Elfo silvano | Guardiana del bosque antiguo | Cazar presas esquivas, proteger el árbol sagrado de una plaga | Media-alta |
| Jotunn | Anciano gigante en las tierras heladas | Resistir tormentas, derrotar a un gigante de escarcha | Alta |
| Ninfa | Espíritu de un manantial oculto | Purificar fuentes corrompidas en varios biomas | Alta |
| Elfo oscuro | Matriarca en una ciudad subterránea | Intrigas, sigilo, traiciones; misiones de infiltración | Muy alta |
| Gorgona | Oráculo de un templo en ruinas | Laberinto con trampas y estatuas vivientes | Muy alta |
| Æsir / Vanir | Vidente junto a un árbol del mundo | Dos caminos (guerra o magia) que deciden el linaje | Muy alta |
| Kitsune | Kitsune en un santuario japonés en el bosque | **Nueve pruebas** (una por cada cola): acertijos, engaños, duelos y ofrendas | Extrema |
| Dracónido | Dragón anciano en un volcán | Ganarse su respeto, recuperar huevos robados, combate contra un dragón | Extrema |
| Ángel | Voz en una catedral en ruinas | Cadena de redención y sacrificio; jefe celestial | Endgame |
| Demonio | Pacto en un portal infernal | Cadena de corrupción; jefe demoníaco | Endgame |

Idea: **Ángel y Demonio son caminos excluyentes.** Elegir uno cierra el otro (o requiere deshacer el pacto).

### Presupuesto de poder por rareza
| Rareza | Bonus pasivos totales | Habilidad racial |
|---|---|---|
| Común | ~5% | Utilidad simple |
| Poco común | ~8% | Defensiva u ofensiva simple |
| Raro | ~12% | Con efecto especial |
| Épico | ~16% | Fuerte, con impacto táctico |
| Legendario | ~20% | Única, con efecto visual propio |
| Mítico | ~25% | Transformación o efecto excepcional; con alguna **desventaja** |

En **Arenas PvP clasificatorias**, los bonus pasivos raciales se normalizan (solo quedan las habilidades raciales).

### Detalle de razas
| Raza | Bonus pasivos | Habilidad racial | Desventaja / nota |
|---|---|---|---|
| **Humano** | +5% Esencia obtenida | *Voluntad*: se libera de un aturdimiento (CD 2 min) | — |
| **Enano** | +6% defensa, +10% eficiencia de crafteo de armaduras | *Piel de piedra*: −30% daño recibido por 5 s | — |
| **Orco** | +6% daño cuerpo a cuerpo, +3% vida | *Grito de guerra*: genera recurso de clase y +10% daño por 6 s | — |
| **Elfo silvano** | +8% daño a distancia, +5% velocidad | *Paso del bosque*: esquiva larga sin coste de estamina | — |
| **Jotunn** | +10% vida, +6% daño cc, resistencia al frío | *Furia del invierno*: crece de tamaño 10 s, sus golpes ralentizan | Hitbox más grande |
| **Ninfa** | +10% curación realizada, **regenera vida cerca de agua o bosque** | *Bendición del manantial*: curación en área | Única regeneración pasiva del juego (a propósito) |
| **Elfo oscuro** | +10% daño mágico, +6% resistencia a sombras | *Velo*: invisibilidad 4 s | — |
| **Gorgona** | +8% agilidad, +8% daño de veneno, inmune a petrificación | *Mirada de piedra*: petrifica 2 s (a jefes solo los ralentiza) | — |
| **Æsir / Vanir** | +5% vida y, según el linaje: Æsir +10% daño físico / Vanir +10% daño mágico y curación | *Llamado del Valhalla*: +10% daño al grupo por 10 s | El linaje se decide en la misión |
| **Kitsune** | +10% agilidad, +10% crítico | *Kitsunebi*: orbes de fuego que persiguen; *Ilusión*: clon señuelo | Gana colas al subir de nivel (1 → 9) |
| **Dracónido** | +12% vida, resistencia al fuego, planeo | *Aliento de fuego*: cono de daño | Única raza que puede ser **Evocador** |
| **Ángel** | +15% curación y daño sagrado, +5% vida | *Gracia divina*: al morir, revive con 50% de vida (CD 20 min); alas | −10% daño de sombras realizado |
| **Demonio** | +15% daño, 5% robo de vida | *Forma infernal*: transformación por 15 s | −15% curación recibida de otros jugadores |

Idea abierta: dar a otras razas **pequeñas ventajas situacionales** del estilo de la Ninfa (ej. Jotunn más fuerte en la nieve, Elfo oscuro en cuevas), para que cada raza tenga un estilo de juego propio y el jugador elija según cómo le gusta jugar.

---

## Combate base (común a todas las clases)
- Ataque ligero (combo de 3) y ataque pesado
- Esquiva con ventana de invulnerabilidad, que cuesta estamina
- Bloqueo que gasta estamina por golpe; parry con ventana corta; guardia rota sin estamina
- 4 habilidades de especialización en las teclas 1–4, más 1 habilidad racial (tecla R)

## Arquitectura técnica
- `ReplicatedStorage/Shared/Races`, `Classes`, `Abilities`, `Enemies`, `Items`, `Recipes`: datos en ModuleScripts.
- `RaceService`: tiradas y asignación de raza. **Pendiente:** quitar esquirlas y garantía de Épico; agregar razas desbloqueadas (`UnlockedRaces`).
- `QuestService` (futuro): cadenas de misiones con pasos, progreso guardado y recompensas.
- Clases premium: Game Pass verificado en el servidor con `MarketplaceService:UserOwnsGamePassAsync`.

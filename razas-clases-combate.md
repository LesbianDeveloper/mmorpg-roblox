# Diseño v0.2 — Razas, clases y combate

## Principio central
- **La clase define CÓMO peleás:** rol, habilidades, armas, recurso.
- **La raza define CON QUÉ VENTAJAS:** bonus pasivos que crecen con la rareza y una habilidad racial.
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
| Vida | Todos | Al llegar a 0, morís |
| Estamina | Todos | Esquivar, bloquear, atacar, correr |
| Recurso de clase | Según la clase | Maná, Furia, Energía, Concentración, Runas, Chi, Furia demoníaca, Esencia |

---

## Clases

### Especializaciones
Cada clase tiene 1 a 3 **especializaciones** (por ejemplo, Paladín: Protección / Sagrado / Represalia). Se cambian fuera de combate, en una ciudad o santuario. Cada especialización tiene su set de 4 habilidades.

### Modelo de acceso
| Tipo | Cómo se obtiene |
|---|---|
| **Base** | Gratis desde el inicio |
| **Premium** | Robux (Game Pass) **o** desbloqueo largo jugando (misión de clase + moneda del juego) |
| **Heroica** | Requiere nivel alto + cadena de misiones; también se puede adelantar con Robux |
| **Exclusiva de raza** | Solo si tenés esa raza |

Regla de balance: **las clases pagas son *sidegrades*, no más fuertes.** Ofrecen otro estilo de juego, no más poder. Así se evita el *pay-to-win*, que en un MMO con PvP espanta jugadores.

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
| **Bardo** *(nueva)* | Premium | Sanación / Soporte | Intelecto | Laúd, arpa, flauta | Inspiración | Canciones que dan buffs al grupo o debilitan enemigos |
| **Valquiria** *(nueva)* | Premium | Tanque / Daño | Fuerza | Lanza, escudo | Furia | Saltos aéreos, cargas con lanza; inspirada en la mitología nórdica |
| **Ronin** *(nueva)* | Premium | Daño cuerpo a cuerpo | Agilidad | Katana, nodachi | Concentración | Posturas, contraataques y *iaido* (golpe desenvainando); estilo Souls puro |
| **Alquimista** *(nueva)* | Premium | Daño a distancia / Sanación | Intelecto | Frascos, bombas | Reactivos | Lanza pociones explosivas o curativas; sinergia con crafteo |
| **Caballero de la Muerte** | Heroica | Tanque / Daño | Fuerza | Espada rúnica a dos manos | Runas | Magia de escarcha y sangre; levanta muertos; robo de vida |
| **Cazador de demonios** | Heroica | Tanque / Daño | Agilidad | Gujas de guerra | Furia demoníaca | Movilidad altísima: doble salto, planeo, transformación demoníaca |
| **Evocador** | Exclusiva de **Dracónido** | Sanación / Daño a distancia | Intelecto | Garras, magia | Esencia | Magia de dragón: ataques cargados (mantener la tecla), vuelo corto |

Total: 17 clases. **No se construyen todas a la vez:** primero 3 base (Guerrero, Mago, Sacerdote) para cubrir tanque, daño y sanación; el resto se agrega por actualizaciones.

---

## Razas

### Probabilidades (curva empinada)
La suma tiene que dar 100%. Humano queda en 70% y el resto cae fuerte por niveles de rareza.

| Rareza | Raza | % | ~Tiradas promedio para obtenerla |
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

### Presupuesto de poder por rareza
Las ventajas crecen con la rareza, pero con tope, para que el jugador habilidoso con un Humano pueda ganarle a uno malo con Demonio.

| Rareza | Bonus pasivos totales | Habilidad racial |
|---|---|---|
| Común | ~5% | Utilidad simple |
| Poco común | ~8% | Defensiva u ofensiva simple |
| Raro | ~12% | Con efecto especial |
| Épico | ~16% | Fuerte, con impacto táctico |
| Legendario | ~20% | Única, con efecto visual propio |
| Mítico | ~25% | Transformación o efecto excepcional; con alguna **desventaja** |

En **Arenas PvP clasificatorias**, los bonus pasivos raciales se normalizan (solo quedan las habilidades raciales), para que el ranking dependa de la habilidad.

### Detalle de razas
| Raza | Bonus pasivos | Habilidad racial | Desventaja / nota |
|---|---|---|---|
| **Humano** | +5% XP | *Voluntad*: se libera de un aturdimiento (CD 2 min) | — |
| **Enano** | +6% defensa, +10% eficiencia de crafteo de armaduras | *Piel de piedra*: −30% daño recibido por 5 s | — |
| **Orco** | +6% daño cuerpo a cuerpo, +3% vida | *Grito de guerra*: genera recurso de clase y +10% daño por 6 s | — |
| **Elfo silvano** | +8% daño a distancia, +5% velocidad | *Paso del bosque*: esquiva larga sin coste de estamina | — |
| **Jotunn** | +10% vida, +6% daño cc, resistencia al frío | *Furia del invierno*: crece de tamaño 10 s, sus golpes ralentizan | Hitbox más grande, más fácil de golpear |
| **Ninfa** | +10% curación realizada, regenera vida cerca de agua o bosque | *Bendición del manantial*: curación en área | — |
| **Elfo oscuro** | +10% daño mágico, +6% resistencia a sombras | *Velo*: invisibilidad 4 s | — |
| **Gorgona** | +8% agilidad, +8% daño de veneno, inmune a petrificación | *Mirada de piedra*: petrifica a los enemigos que la miran 2 s (a jefes solo los ralentiza) | — |
| **Æsir / Vanir** | +5% vida y, según el linaje elegido al obtenerla: Æsir +10% daño físico / Vanir +10% daño mágico y curación | *Llamado del Valhalla*: +10% daño al grupo por 10 s | Se elige el linaje una vez |
| **Kitsune** | +10% agilidad, +10% crítico | *Kitsunebi*: orbes de fuego que persiguen enemigos; *Ilusión*: clon señuelo | Cosmético progresivo: gana colas al subir de nivel (1 → 9) |
| **Dracónido** | +12% vida, resistencia al fuego, planeo | *Aliento de fuego*: cono de daño | Única raza que puede ser **Evocador** |
| **Ángel** | +15% curación y daño sagrado, +5% vida | *Gracia divina*: al morir, revive con 50% de vida (CD 20 min); alas para planear y vuelo corto | −10% daño de sombras realizado |
| **Demonio** | +15% daño, 5% robo de vida | *Forma infernal*: transformación por 15 s (+daño, +velocidad, nuevo moveset) | −15% curación recibida de otros jugadores |

### Cómo se consigue una raza (y por qué cuesta recursos)
- **Primera tirada gratis** al crear el personaje.
- Cada nueva tirada cuesta **Runas del Destino**, que se obtienen derrotando jefes, en misiones diarias y semanales, en eventos, o se craftean con materiales raros.
- **Sistema de esquirlas (pity determinista):** cada tirada da 1 Esquirla del Destino. Con 300 esquirlas elegís cualquier raza legendaria o inferior; con 1000, cualquier raza, incluidas las míticas. Así una raza mítica se puede *ganar* con constancia, no solo con suerte.
- **Garantías:** como mínimo, una raza Épica o mejor cada 60 tiradas.
- Cambiar de raza conserva nivel, equipo y clase (salvo Evocador, que requiere Dracónido).
- **Si se venden Runas por Robux:** las probabilidades se muestran en pantalla antes de tirar. Antes de lanzar, hay que revisar las reglas vigentes de Roblox sobre ítems aleatorios pagos.

---

## Combate base (común a todas las clases)
- Ataque ligero (combo de 3) y ataque pesado (cargable)
- Esquiva con ventana de invulnerabilidad (i-frames), que cuesta estamina
- Bloqueo que gasta estamina por golpe recibido; parry con ventana corta
- Sin estamina: no podés esquivar ni bloquear
- 4 habilidades de especialización en las teclas 1–4, más 1 habilidad racial (tecla R)

## Arquitectura técnica
- `ReplicatedStorage/Shared/Races`, `Classes` y `Abilities`: datos en ModuleScripts.
- `ServerScriptService/Server/RaceService`: tiradas, esquirlas y garantías; **todo en el servidor**.
- `ServerScriptService/Server/CombatService`: valida alcance, cooldowns, estamina y daño.
- Cliente: input, animaciones, efectos; le *pide* al servidor que ejecute las acciones.
- Clases premium: Game Pass por clase, verificado en el servidor con `MarketplaceService:UserOwnsGamePassAsync`.

## Orden de construcción
1. Módulos `Races` y `Classes` (datos), con las stats renombradas a Fuerza, Agilidad, Intelecto, Vitalidad, Aguante
2. Tirada de raza en el servidor, con Runas, Esquirlas y guardado en DataStore
3. Elección de clase entre las 3 iniciales (Guerrero, Mago, Sacerdote), con UI simple
4. Combate base común con Guerrero, más un muñeco de prueba
5. Mago (distancia) y Sacerdote (curación)
6. Primer enemigo con IA, después el primer jefe con 2 fases
7. Más clases y razas por actualizaciones

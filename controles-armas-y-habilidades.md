# Controles, armas y habilidades — v1.0

## 1. Resumen del modelo
| Qué | Define | Cómo se usa |
|---|---|---|
| **Arma** (en la mano) | El **ataque básico** (cuerpo a cuerpo o proyectil) y sus **efectos pasivos** (quemar, aturdir, sangrado…) | Clic izquierdo |
| **Clase** | Qué armas usás bien, un **rasgo pasivo de clase** y su **libro de habilidades** | Habilidades activas con teclas, estilo WoW |
| **Raza** | Bonus pasivos y una **habilidad racial** | Tecla R |

## 2. Barra rápida (estilo Minecraft)
- **6 slots** abajo al centro de la pantalla.
- Se colocan **objetos usables**: armas, pociones, otros consumibles.
- **Teclas 1–6** (o tocar el slot en celular) eligen el slot activo.
- **Clic** usa el objeto activo: con un arma, ataque básico; con una poción, beber.
- El arma del slot activo **se ve en la mano** (sistema de Tools de Roblox).
- Las **armaduras** siguen en la ventana de equipo (C). El slot "Arma" de esa ventana desaparece: el arma es lo que tenés en la mano.
- Lo que está en la barra **no se pierde al morir** (es equipo o consumible comprado).

## 3. Armas
### Ataque básico
- Mismo cálculo de daño base para todas las armas: `(daño del combo + daño del arma) × multiplicador de stats`.
- El tipo de arma define **cómo** llega el daño: tajo cuerpo a cuerpo, proyectil, etc.

### Balance de la distancia (aceptado)
Las armas a distancia pagan su seguridad con:
1. **Costo de recurso:** cada proyectil gasta maná (o concentración). Sin recurso, el atacante a distancia queda casi indefenso.
2. **Proyectiles que viajan:** se pueden esquivar.
3. **Defensa baja:** las clases a distancia usan armaduras livianas (tela, cuero).
4. El cuerpo a cuerpo puede hacer un poco **más de daño por golpe** como premio por el riesgo.

### Efectos pasivos de armas
Las armas no tienen habilidades activas: tienen **efectos pasivos** que se disparan al pegar, por ejemplo:
| Efecto | Qué hace |
|---|---|
| Quemadura | Daño de fuego durante unos segundos |
| Aturdimiento | Probabilidad de aturdir brevemente |
| Sangrado | Daño continuo, acumulable |
| Escarcha | Ralentiza al objetivo |
| Robo de vida | Cura un % del daño hecho |
| Veneno | Daño continuo que reduce la curación recibida |

Las armas crafteadas o soltadas por jefes raros tienen efectos más fuertes o varios a la vez.

## 4. Libro de habilidades (por clase)
- Cada clase tiene su **libro de habilidades** con habilidades activas propias (ej. Guerrero: Carga, Grito desafiante, Torbellino; Mago: Nova de escarcha, Teletransporte, Meteoro; Sacerdote: Curación, Escudo sagrado, Purificar).
- Se usan con **teclas al estilo WoW**, con tiempo de espera (cooldown) y costo de recurso.
- **Barra de habilidades separada** de la barra rápida de objetos.
- Propuesta (a confirmar): **4 habilidades activas** equipables a la vez, con teclas **Z, X, V, T**; más **R** para la habilidad racial. El libro se abre con **K**: ahí ves todas las habilidades de tu clase y elegís cuáles van en la barra.
- Propuesta (a confirmar): las habilidades se **desbloquean con el nivel** (ej. una nueva cada pocos niveles), y algunas avanzadas con misiones de clase.

## 5. Mapa de teclas
| Tecla | Acción |
|---|---|
| Clic izquierdo | Usar objeto activo (ataque básico / beber) |
| 1–6 | Elegir slot de la barra rápida |
| E | Ataque pesado |
| Q | Esquiva |
| F (mantener) | Bloqueo / parry |
| Z, X, V, T | Habilidades de clase *(propuesta)* |
| R | Habilidad racial |
| B | Inventario |
| C | Equipo |
| K | Libro de habilidades *(propuesta)* |
| G | Interactuar (estaciones, santuarios, tiendas, NPC) |

Teclas reservadas por Roblox: I y O (zoom), / (chat).
En celular, todo se maneja con botones en pantalla.

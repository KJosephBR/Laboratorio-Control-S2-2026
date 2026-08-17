# README — Simulación de Motor DC en Octave

## Descripción

Este script simula la respuesta temporal de un motor DC utilizando un modelo de primer orden:

`G(s) = K_M / (tau*s + 1)`

El programa calcula automáticamente `K_M` y `tau` a partir de los parámetros físicos del motor y posteriormente muestra su respuesta ante una **entrada escalón unitario de amplitud 1**.

## ¿Qué hace?

El programa sigue este flujo:

1. Solicita los parámetros físicos del motor.
2. Verifica que los valores ingresados sean válidos.
3. Calcula `K_M` y `tau`.
4. Genera la respuesta del motor ante un escalón unitario.
5. Calcula el valor final, tiempo de establecimiento y error de estado estacionario.
6. Muestra los resultados en la terminal.
7. Genera una gráfica con la respuesta del motor y la referencia unitaria.

En la gráfica:

* **Motor response:** salida del modelo del motor.
* **Unit-step reference:** entrada escalón unitario, con valor 1.
* **Final value:** valor final esperado de la salida.
* Las líneas adicionales muestran los límites del 2 % y los principales puntos característicos.

## ¿Cómo usarlo en Octave?

1. Guardar el código en un archivo con extensión `.m`, por ejemplo:

`motor_simulation.m`

2. Abrir **GNU Octave**.

3. Colocar el archivo en la carpeta de trabajo de Octave o cambiar la carpeta actual hasta donde se encuentra el archivo.

4. Ejecutar en la consola:

```octave
motor_simulation
```

5. Introducir los cinco parámetros solicitados:

```text
Kt - Torque constant
Ra - Armature resistance
b  - Viscous friction coefficient
Kb - Back-EMF constant
J  - Motor and load inertia
```

6. Octave mostrará los parámetros calculados y abrirá la gráfica de la respuesta.

## Requisitos

* GNU Octave.
* No requiere paquetes adicionales para ejecutar este script.

## Archivo principal

`motor_simulation.m`

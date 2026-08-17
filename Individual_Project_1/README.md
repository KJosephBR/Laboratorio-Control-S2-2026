# DC Motor Simulation — GNU Octave

## Overview

This script simulates the **unit-step response of a first-order DC motor model**:

`G(s) = K_M / (tau*s + 1)`

It calculates `K_M` and `tau` from the motor parameters and plots the motor response.

## How to Use

1. Save the script as:

`motor_simulation.m`

2. Open GNU Octave and set the working directory to the script location.

3. Run:

```octave
motor_simulation
```

4. Enter the following motor parameters when requested:

* `Kt` — Torque constant
* `Ra` — Armature resistance
* `b` — Viscous friction coefficient
* `Kb` — Back-EMF constant
* `J` — Motor and load inertia

## Output

The script displays:

* `K_M`
* `tau`
* Final output value
* Response at `tau` and `5*tau`
* 2% settling time

The plot shows the **motor response to a unit-step input (amplitude = 1)**, along with the final value and settling limits.

## Requirements

* GNU Octave
* No additional packages required

# Routh-Hurwitz and Root Locus Simulation

## Description

GNU Octave script for analyzing the stability of a control system defined by its open-loop poles and zeros.

For a selected feedback gain (K), the script:

* Builds the transfer function (G(s)).
* Constructs the closed-loop characteristic equation.
* Generates the Routh-Hurwitz table.
* Determines system stability.
* Calculates the closed-loop poles.
* Generates the Root Locus.

The characteristic equation is:

[
1 + K G(s) = 0
]

---

## Requirements

* GNU Octave
* Control package

If the package is not installed:

```octave
pkg install -forge control
```

---

## Usage

Run the script from the GNU Octave terminal:

```octave
routh_root_locus
```

The script will request:

1. **Open-loop zeros**
2. **Open-loop poles**
3. **Feedback gain (K)**

### Input examples

Real poles or zeros:

```text
-1 -2 -3
```

Complex pair:

```text
-1+2i -1-2i
```

No zeros:

```text
[]
```

The gain must satisfy:

[
K \geq 0
]

---

## Output

The script displays:

* Open-loop transfer function.
* Closed-loop characteristic equation.
* Routh-Hurwitz table.
* Number of sign changes.
* Stability result.
* Closed-loop poles.
* Numerical stability verification.

It also generates a Root Locus plot showing:

* `X` — Open-loop poles.
* `O` — Open-loop zeros.
* `□` — Closed-loop poles for the selected (K).

---

## Input Validation

The script validates:

* Empty inputs.
* Invalid numerical values.
* Complex pole/zero vectors.
* Presence of at least one pole.
* Properness of the transfer function.
* Non-negative feedback gain.

Special Routh-Hurwitz cases involving a zero first element or a complete row of zeros are handled automatically.


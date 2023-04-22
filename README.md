# AESIR Mjollnir rocket simulations

This repository contains the simulation code for AESIR's NOx/Paraffin hybrid Mjollnir rocket.

## Usage

Simply run main.m to simulate and plot the results, where you can also set the most important tunable parameters. To plot the simulations along with data: process data or download processed data from the AESIR Google Drive (Mjollnir/Procedures and tests), store it somewhere convenient, and change the file path in the main.

## Repository structure

- Archive: Old code that did not spark joy anymore.
- Data: Code for data processing.
- Datasets: Tables and test data.
- Plots: Code for generating plots and plots will be saved here.
- Simulation: Code for simulating the engine.
    - Combustion: Helper functions for tank, injection, and combustion chamber computations.
    - Thrust: Helper functions for nozzle and ejection computations.
    - Flight: Helper functions for drag, acceleration, and speed computations.
    - simulate.m: The function that runs the simulations.
    - system_equations.m: The system of equations that is integrated into the simulation.
- main.m: The main interface, where you need to be for basic usage.
- set_options.m: Sets options and contains additional non-tunable model parameters (although they can, of course, be changed).
- setup.m: Initializes the workspace so that we start with a clean slate and all relevant files are added to the path.

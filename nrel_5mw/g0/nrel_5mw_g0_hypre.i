# NREL 5MW G0 Nalu input deck
# Notes:
#   You must adjust "termination_step_count:".

Simulations:
  - name: nrel_5mw
    time_integrator: ti_1
    optimizer: opt1

linear_solvers:

  - name: solve_scalar_trilinos
    type: tpetra
    method: gmres
    preconditioner: sgs
    tolerance: 1e-5
    max_iterations: 300
    kspace: 50
    output_level: 0

  - name: solve_scalar_hypre
    type: hypre
    method: hypre_bicgstab
    preconditioner: boomerAMG
    tolerance: 1e-5
    output_level: 0
    absolute_tolerance: 1.0e-12
    segregated_solver: yes
    max_iterations: 300
    kspace: 100
    bamg_output_level: 0
    #bamg_coarsen_type: 8
    bamg_max_levels: 1
    #bamg_relax_type: 6
    bamg_num_sweeps: 2

  - name: solve_cont
    type: hypre
    method: hypre_gmres
    preconditioner: boomerAMG
    tolerance: 1e-5
    absolute_tolerance: 1.0e-12
    segregated_solver: yes
    max_iterations: 300
    kspace: 20
    output_level: 0
    bamg_output_level: 1
    # coarsen_type: 10 HMIS for MPI, coarsen_type: 8 PMIS for MPI+X
    bamg_coarsen_type: 8
    bamg_interp_type: 6
    #bamg_interp_type: 13
    bamg_cycle_type:  1
    #bamg_relax_type: 3
    bamg_relax_type: 8
    #bamg_relax_type: 18
    #bamg_relax_order: 1
    bamg_relax_order: 0
    bamg_num_sweeps: 1
    bamg_keep_transpose: 1
    # optimal for < 30K DOF per core use max_levels: 5, 6, or 7 for fewer MPI, ranks
    #bamg_max_levels: 5
    #bamg_trunc_factor: 0.1
    bamg_trunc_factor: 0.75
    #bamg_trunc_factor: 0.25
    #bamg_agg_num_levels: 2
    bamg_agg_num_levels: 1
    bamg_agg_interp_type: 4
    bamg_agg_pmax_elmts: 3
    bamg_pmax_elmts: 2
    #bamg_strong_threshold: 0.25
    bamg_strong_threshold: 0.5
    #bamg_non_galerkin_tol: 0.05
    bamg_non_galerkin_tol: 0.1
    bamg_non_galerkin_level_tols:
      levels: [0, 1, 2]
      tolerances: [0.0, 0.01, 0.03 ]
      #tolerances: [0.0, 0.01, 0.01]

realms:

  - name: realm_1
    mesh: mesh/nrel_5mw_g0.exo
    use_edges: no
    activate_aura: no
    automatic_decomposition_type: rcb
    check_for_missing_bcs: yes
    check_jacobians: yes

    time_step_control:
     target_courant: 10.0
     time_step_change_factor: 1.05

    equation_systems:
      name: theEqSys
      max_iterations: 2

      solver_system_specification:
        pressure: solve_cont
        #velocity: solve_scalar_trilinos
        velocity: solve_scalar_hypre
        dpdx: solve_scalar_hypre

      systems:
        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            convergence_tolerance: 1e-5

    initial_conditions:
      - constant: ic_1
        target_name: [block_101, block_201, block_104, block_204, block_105, block_205, block_106, block_206]
        value:
          pressure: 0
          velocity: [8.0,0.0,0.0]

    material_properties:
      target_name: [block_101, block_201, block_104, block_204, block_105, block_205, block_106, block_206]
      specifications:
        - name: density
          type: constant
          value: 1.2
        - name: viscosity
          type: constant
          value: 1.8e-5

    boundary_conditions:

    - inflow_boundary_condition: front
      target_name: surface_1
      inflow_user_data:
        velocity: [8.0,0.0,0.0]

    - open_boundary_condition: back
      target_name: surface_3
      open_user_data:
        pressure: 0.0

    - symmetry_boundary_condition: sides
      target_name: surface_2
      symmetry_user_data:

    - symmetry_boundary_condition: top
      target_name: surface_4
      symmetry_user_data:

    - symmetry_boundary_condition: bottom
      target_name: surface_5
      symmetry_user_data:

    #- wall_boundary_condition: bottom
    #  target_name: surface_5
    #  wall_user_data:
    #    velocity: [0,0,0]
    #    use_wall_function: no

    - wall_boundary_condition: nacelle
      target_name: surface_11
      wall_user_data:
        velocity: [0,0,0]
        use_wall_function: no

    - wall_boundary_condition: tower
      target_name: surface_10
      wall_user_data:
        velocity: [0,0,0]
        use_wall_function: no

    - wall_boundary_condition: blade_1
      target_name: surface_6
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mesh_motion_rotor]
        use_wall_function: no

    - wall_boundary_condition: blade_2
      target_name: surface_7
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mesh_motion_rotor]
        use_wall_function: no

    - wall_boundary_condition: blade_3
      target_name: surface_8
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mesh_motion_rotor]
        use_wall_function: no

    - wall_boundary_condition: hub_rot
      target_name: surface_9
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mesh_motion_rotor]
        use_wall_function: no

    - non_conformal_boundary_condition: back_rot
      current_target_name: [surface_18]
      opposing_target_name: [surface_16]
      non_conformal_user_data:
        expand_box_percentage: 5.0
        search_tolerance: 0.01
        search_method: stk_kdtree

    - non_conformal_boundary_condition: back_stat
      current_target_name: [surface_16]
      opposing_target_name: [surface_18]
      non_conformal_user_data:
        expand_box_percentage: 5.0
        search_tolerance: 0.01
        search_method: stk_kdtree

    - non_conformal_boundary_condition: front_rot
      current_target_name: [surface_14]
      opposing_target_name: [surface_17]
      non_conformal_user_data:
        expand_box_percentage: 5.0
        search_tolerance: 0.01
        search_method: stk_kdtree

    - non_conformal_boundary_condition: front_stat
      current_target_name: [surface_17]
      opposing_target_name: [surface_14]
      non_conformal_user_data:
        expand_box_percentage: 5.0
        search_tolerance: 0.01
        search_method: stk_kdtree

    - non_conformal_boundary_condition: out_rot
      current_target_name: [surface_12]
      opposing_target_name: [surface_13]
      non_conformal_user_data:
        expand_box_percentage: 5.0
        search_tolerance: 0.01
        search_method: stk_kdtree

    - non_conformal_boundary_condition: out_stat
      current_target_name: [surface_13]
      opposing_target_name: [surface_12]
      non_conformal_user_data:
        expand_box_percentage: 5.0
        search_tolerance: 0.01
        search_method: stk_kdtree

    solution_options:

      name: myOptions
      turbulence_model: wale
      use_consolidated_solver_algorithm: yes

      mesh_motion:

        - name: mesh_motion_rotor
          target_name: [block_101, block_104, block_105, block_106]
          omega: 0.8888888888888888 #TSR=7 @ 8.0 m/s inflow velocity
          #centroid: [-14.673948 0.0 1.2838041]
          unit_vector: [0.9961946980917455, 0.0, -0.08715574274765817]
          compute_centroid: yes

        - name: mesh_motion_outer_domain
          target_name: [block_201, block_204, block_205, block_206]
          omega: 0.0

      options:

        - element_source_terms:
            momentum: [lumped_momentum_time_derivative, advection_diffusion, NSO_2ND_ALT]
            continuity: advection

        - non_conformal:
            gauss_labatto_quadrature: no
            algorithm_type: dg
            upwind_advection: yes
            current_normal: yes
            include_png_penalty: no
            activate_coincident_node_error_check: no

        - consistent_mass_matrix_png:
            pressure: no
            velocity: no

        - shifted_gradient_operator:
            velocity: no
            pressure: yes

#    turbulence_averaging:
#      time_filter_interval: 100000.0

      specifications:

        - name: one
          target_name: [block_101, block_201, block_104, block_204, block_105, block_205, block_106, block_206]
          reynolds_averaged_variables:
            - velocity
          compute_q_criterion: yes
          compute_vorticity: yes

    post_processing:

    - type: surface
      physics: surface_force_and_moment
      output_file_name: output/nrel_5mw_g0.timing.dat
      frequency: 1000
      parameters: [0, 0, 0]
      target_name: [surface_6, surface_7, surface_8, surface_9]

    output:
      output_data_base_name: output/nrel_5mw_g0.timing.e
      output_frequency: 1000
      output_start: 1000
      output_node_set: no
      output_variables:
       - velocity
       - pressure
       - turbulent_viscosity
       - vorticity
       - q_criterion
       - mesh_displacement

    restart:
      restart_data_base_name: restart/nrel_5mw_g0.timing
      restart_frequency: 500
      restart_start: 500
      restart_forced_wall_time: 42000

Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      termination_step_count: NUMBER_OF_TIME_STEPS
      time_step: 1.0e-8
      time_stepping_type: adaptive
      time_step_count: 0
      second_order_accuracy: yes

      realms:
        - realm_1

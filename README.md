UnmannedNavigationSystem
========================

<b>This is my final year MEng in EEE project where I investigate Path Planning and Control for Autonomous Vehicles.</b>
<h2>Abstract</h2>
This project involves the research and design of an integrated planning and execution navigation system where at every stage the system is guided by a global path. An integrated approach reduces execution time which is the time is takes to generate and implement a motion control law. The system consists of an optimal predictive control regime and an optimal path planning algorithm for dynamic motion of generic unmanned vehicles in partially unknown environments. In this implementation, portability of solution and rapid re-design for changing specifications are taken into account. The main emphasis of this project is to implement a holistic architecture for an autonomous navigation system. The design started from utilising optimisation theory to develop a custom active-set algorithm to investigate the viability of linear model predictive control (MPC) scheme. MPC calculated optimal control law taking into account future requirements. It then applied the first part of the solution and repeated this procedure at the next time step. The robot’s kinematics was derived taking into account non-holonomic constraint which are the wheels’ sliding and rolling constraint. MPC was used to minimise both the energy used and error between a reference trajectory and the robot’s motion. Also important to navigation is the localisation module. This report highlighted a sensor fusion of odometry information from the precise locomotion of stepper motors and a laser scanner. An Adaptive Monte Carlo Localisation (AMCL) approach was taken to fuse the sensor readings in order to produce accurate pose information. This localisation module is used by the path-planner. The path planner is based on the complete version of the D-star algorithm which generates a path that optimises a heuristic. In this case, it handled both edge avoidance and global path generation while keeping computational requirements to a minimum. The planner decomposed the map into square occupancy grids represented as a graph. These grids became possible robot locations and were the nodes of the graph. D-star expanded upon neighbouring nodes selecting a sequence that would result in minimum distance. A sudden discovery of obstacles can change path cost. In conclusion, D-star was shown to re-compute optimal path in real-time making it suitable for dynamic environments. This report also demonstrated the feasibility of an integrated planning and execution navigation system design for dynamic environment that reduces execution time complexity of optimal motion control to O(1) thus applying MPC to fast processes.

<h2>Layout</h2>
<ol>
<li> Simulations: contains files for Optimal Control Simulation and Results.</li>
<li> Physical System: contains program code for navigation system.</li>
<li> Motor Testing: contains codes used to test and verify motor performance.</li>
<li> Presentation: Powerpoint presentation showing project overview and demo.</li>
</ol>
<h2> Simulation Instruction </h2>
<ul>
<li>	To run simulation results, first enter the directory containing install.m and run it from there.</li>
<li>	To see mpc results for a random feasible trajectory, run mpc.m</li>
<li>	To see MPC results for a sine function path, run SampleMPC.m</li>
<li>  To see MPC performance with noise (i.e demonstrating concept of explicit MPC), run SampleMPC_noise.m</li>
<li>	To generate nicely looking random feasible trajectories, run dispRandomPath.m</li>
</ul>

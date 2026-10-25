# TurtleBot3 + Nav2 Autonomous Navigation (ROS 2 Jazzy, Gazebo)

Autonomous navigation of a TurtleBot3 (waffle) in the Gazebo TurtleBot3 world using the ROS 2 Navigation2 (Nav2) stack. The robot plans a path to a goal and drives around obstacles.

**Demo video:** YOUR_VIDEO_LINK

## Environment
- MacBook Air M4 (Apple Silicon) running Ubuntu 24.04 ARM64 in a UTM virtual machine (8 GB RAM, 4 cores)
- ROS 2 Jazzy, Gazebo Sim (modern `gz`), Nav2

## Install (Ubuntu 24.04)
1. Install ROS 2 Jazzy: https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
2. Install Nav2 and the TurtleBot3 simulation:

        sudo apt install -y ros-jazzy-navigation2 ros-jazzy-nav2-bringup ros-jazzy-nav2-minimal-tb*

Note: on Jazzy the TurtleBot3 simulation comes from `nav2-minimal-tb*` (modern Gazebo), not the older `turtlebot3-gazebo` package used by Iron and earlier tutorials.

## Run
1. Launch the simulation (Gazebo + RViz + Nav2):

        source /opt/ros/jazzy/setup.bash
        ros2 launch nav2_bringup tb3_simulation_launch.py headless:=False use_composition:=False

2. Wait 1-3 minutes until Gazebo and RViz are open and RViz shows "Localization: active".
3. In RViz click **2D Pose Estimate**, then click-drag on the robot's start position (drag to the right). The red laser dots should line up with the black walls; if not, redo it with a slightly different arrow direction.
4. In a second terminal, activate the Nav2 nodes:

        bash activate_nav2.sh

5. Click **Nav2 Goal** in RViz and click-drag on a free spot. The robot plans a path (green line) and drives there, avoiding the cylinders.

## How it works
- **Gazebo** simulates the robot and the world.
- **AMCL** localizes the robot on the saved map using the laser scan.
- **Nav2** planner computes a global path, the controller follows it, costmaps mark obstacles, and the BT navigator coordinates the behaviour.

## Troubleshooting
**Problem:** The Navigation panel stays "inactive" and the terminal shows `Action server is inactive. Rejecting the goal.`

**Diagnosis:** Checking `ros2 lifecycle get /<node>` showed map_server, amcl and controller_server were `active [3]`, but planner_server and bt_navigator were stuck `inactive [2]`. Nav2's lifecycle manager had aborted startup part-way on my slow VM.

**Fix:** Launch with `use_composition:=False` (a composed container crashed once) and run `activate_nav2.sh`, which configures and activates the stalled nodes. Don't press RViz's Startup/Reset buttons on a half-started stack; that made it worse.

## Files
- `activate_nav2.sh`: activates the stalled Nav2 lifecycle nodes
- `README.md`: setup and run instructions

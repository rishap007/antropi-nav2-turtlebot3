# TurtleBot3 Autonomous Navigation with Nav2

This repository contains the setup and run instructions for autonomous navigation of a TurtleBot3 (Waffle) in a Gazebo simulation, using ROS 2 Jazzy and the Navigation2 (Nav2) stack. Given a goal pose in RViz, the robot plans a collision-free path and drives to it while avoiding obstacles.

## Demo

Screen recording (Gazebo and RViz): https://drive.google.com/file/d/16cEhTKvXP4XvcNlC0l9XvRKMjJpmcLvr/view?usp=sharing

## Environment

| Component | Version |
|---|---|
| Host | MacBook Air M4 (Apple Silicon), UTM virtual machine |
| Guest OS | Ubuntu 24.04 LTS (ARM64), 8 GB RAM, 4 CPU cores |
| ROS 2 | Jazzy Jalisco |
| Simulator | Gazebo Sim (gz) |
| Navigation | Nav2 |
| Robot | TurtleBot3 Waffle |
| World | TurtleBot3 world (hexagonal arena with 9 cylindrical obstacles) |

## Installation

1. Install ROS 2 Jazzy by following the official guide:
   https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html

2. Install Nav2 and the TurtleBot3 simulation packages:

```bash
sudo apt install -y ros-jazzy-navigation2 ros-jazzy-nav2-bringup ros-jazzy-nav2-minimal-tb*
```

On ROS 2 Jazzy, the TurtleBot3 simulation is provided by the nav2_minimal_tb packages, which use the current Gazebo Sim. The older turtlebot3_gazebo package used in Iron and earlier tutorials is not required.

## Usage

1. Clone this repository:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/antropi-nav2-turtlebot3.git
cd antropi-nav2-turtlebot3
```

2. Launch Gazebo, RViz and Nav2:

```bash
source /opt/ros/jazzy/setup.bash
ros2 launch nav2_bringup tb3_simulation_launch.py headless:=False use_composition:=False
```

3. Wait until both windows have opened and the Navigation 2 panel in RViz reports "Localization: active". This can take one to three minutes on a virtual machine.

4. In RViz, select 2D Pose Estimate, then click on the robot's starting position and drag in the direction the robot is facing. The laser scan should align with the walls of the map. If it does not, repeat with a slightly different heading.

5. In a second terminal, activate the Nav2 navigation nodes (see Known Issue below):

```bash
bash activate_nav2.sh
```

6. In RViz, select Nav2 Goal, then click on a free area of the map and drag to set the goal heading. The planned path appears as a green line and the robot drives to the goal, avoiding the obstacles.

## How It Works

- Gazebo simulates the robot, its sensors and the world.
- The map server provides a pre-built occupancy map of the arena.
- AMCL localizes the robot on that map using the laser scan and odometry.
- The Nav2 planner computes a global path to the goal.
- The controller follows the path and generates velocity commands, using local and global costmaps to avoid obstacles.
- The behavior tree navigator coordinates planning, control and recovery behaviors.

## Known Issue and Workaround

Symptom: after launch, the Navigation panel in RViz remains "inactive", and the terminal reports "Action server is inactive. Rejecting the goal."

Diagnosis: the lifecycle state of each node was checked with:

```bash
ros2 lifecycle get /planner_server
ros2 lifecycle get /bt_navigator
```

The map_server, amcl and controller_server nodes were active, while planner_server and bt_navigator remained inactive. The Nav2 lifecycle manager had aborted its startup sequence partway through, most likely because the virtual machine was too slow to bring all nodes up within the default timeouts. In one run, the composed node container also crashed.

Workaround: launch with use_composition:=False, so each Nav2 node runs as a separate process, and run activate_nav2.sh. The script configures and activates the remaining lifecycle nodes in order. Messages such as "No transition matching" or "Node not found" are harmless. After the script runs, both planner_server and bt_navigator should report "active [3]".

Avoid using the Startup and Reset buttons in RViz on a partially started Nav2 stack, as this caused further errors.

On a faster machine or a native Ubuntu installation, the standard launch is expected to work without this step.

## Repository Contents

| File | Description |
|---|---|
| README.md | Setup and run instructions |
| activate_nav2.sh | Configures and activates the Nav2 lifecycle nodes that stall on startup |

## References

- Nav2 documentation: https://docs.nav2.org/getting_started/
- ROS 2 Jazzy documentation: https://docs.ros.org/en/jazzy/
- TurtleBot3 manual: https://emanual.robotis.com/

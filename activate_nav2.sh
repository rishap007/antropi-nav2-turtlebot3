#!/bin/bash
# Manually configure + activate the Nav2 lifecycle nodes that stall on slow VMs.
# Run in a second terminal AFTER the launch file is up and the 2D Pose Estimate is set.
source /opt/ros/jazzy/setup.bash
for n in smoother_server planner_server behavior_server bt_navigator waypoint_follower velocity_smoother collision_monitor; do
  echo "== $n"
  ros2 lifecycle set /$n configure
  ros2 lifecycle set /$n activate
done
echo "== Verify (both should say active [3])"
ros2 lifecycle get /planner_server
ros2 lifecycle get /bt_navigator

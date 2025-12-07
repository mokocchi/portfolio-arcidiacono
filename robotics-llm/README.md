# Robotics + AI – Autonomous Fleet Controlled by LLMs

This project implements a real robotic fleet controlled through Large Language Models acting as decision-making agents.  
The system combines computer vision, grid-based navigation, human validation loops, and distributed infrastructure built with Python, Node.js, FFmpeg, and Postgres.

It is designed to explore how LLMs can reason about spatial environments, propose navigation steps, and coordinate physical movement under reliability constraints.

---

## Overview

The system connects multiple physical robots to a cloud-based control plane.  
Each robot streams visual information to the controller, receives navigation commands, and reports status back to the system.

Key capabilities:
- LLM-based reasoning for navigation
- Real-time image grid guidance
- Human-in-the-loop approval for critical actions
- Distributed agents operating across multiple time zones
- FFmpeg pipelines for video frame extraction and compression
- Reliable state tracking backed by Postgres
- Python/Node hybrid infrastructure

---

## High-Level Architecture

```
               +-------------------------+
               |  Web / Control UI       |
               |  - Approve actions      |
               |  - View robot states    |
               +------------+------------+
                            |
                            v
               +------------+------------+
               |     API / Controller    |
               |  (Python / Node.js)     |
               |                          |
               | - Receives frames        |
               | - Builds grid maps       |
               | - Queries LLMs           |
               | - Issues navigation      |
               | - Persists state (DB)    |
               +------------+-------------+
                            |
                            |
    -----------------------------------------------------
    |                      |                           |
    v                      v                           v

+--------------+      +----------------+        +----------------+
|   Robot 1    |      |    Robot 2     |        |    Robot N     |
| - Camera     |      | - Camera       |        | - Camera       |
| - Motor ctr. |      | - Motor ctr.   |        | - Motor ctr.   |
| - Heartbeat  |      | - Heartbeat    |        | - Heartbeat     |
+--------------+      +----------------+        +----------------+

```

- Robots send frames → controller  
- Controller builds a grid representation of the environment  
- LLM evaluates best next step  
- Human operator can approve/deny  
- Controller sends navigation instructions back to robots  

---

## Core Components

### **1. LLM Reasoning Engine**
- Receives grid-encoded snapshots of the robot’s environment  
- Produces stepwise navigation commands (e.g., *move forward*, *turn left*, *avoid obstacle*)  
- Ensures deterministic formatting for downstream automation  
- Supports multiple model providers (OpenAI, Gemini)  

### **2. Vision & Grid System**
- Robots send continuous images via FFmpeg streams  
- Frames are processed into discrete grid cells  
- Obstacles, free space, and targets are marked  
- Grids are used as input context for LLM reasoning  

### **3. Human-in-the-Loop Safety**
- Operators validate risky decisions  
- System can require approval based on:
  - proximity to obstacles  
  - battery status  
  - contradictory LLM reasoning  
- Ensures reliability in multi-robot operations  

### **4. Distributed Control Plane**
- Python agent for LLM interaction and path planning  
- Node.js services for real-time event handling  
- Webhooks for robot telemetry  
- Postgres for mission state and robot metadata  
- Task queues for pending instructions  

### **5. Communication with Robots**
- Lightweight protocol over HTTP/WebSocket  
- Robots provide:
  - heartbeats  
  - sensor data  
  - error states  
- Controller sends:
  - movement commands  
  - stop/override signals  
  - emergency fallback actions  

---

## Example Decision Cycle

1. Robot sends camera frame  
2. Controller slices it into a discrete grid  
3. LLM receives the grid and proposes next movement  
4. Human operator approves (if needed)  
5. Controller issues the command to the robot  
6. Robot moves and reports new state  
7. Cycle repeats  

This loop can run autonomously or with varying degrees of oversight.

---

## Reliability & Operations

The system was designed to:
- operate across different time zones  
- handle intermittent connectivity  
- recover from robot disconnects  
- reconcile inconsistent robot states  
- track mission progress across restarts  
- allow multiple operators to supervise concurrently  

Strong observability was implemented through:
- logs for decision cycles  
- robot heartbeat monitoring  
- metrics on LLM latency  
- state persistence in Postgres  

---

## What This Project Demonstrates

- Systems engineering applied to physical hardware  
- Real-time, distributed control loops  
- Integration of LLM reasoning with deterministic protocols  
- Observability and fault-tolerant design  
- Hybrid AI + robotics + cloud orchestration  
- Ability to design novel infrastructures from scratch  

---

## Links

- TODO: Extended architecture write-up (Notion)  

---
```

# Real-Time Virtual Idol Streaming Infrastructure (24/7)

This project implements a full real-time infrastructure for a virtual streamer operating continuously across multiple platforms.  
It combines text-to-speech pipelines, distributed workers, event scheduling, chat-driven commands, and fault-tolerant automation.

This document focuses solely on the technical design and engineering work.

---

## Overview

The system enables a virtual character to stream 24/7 on major platforms, speak through TTS, react to chat input, and execute automated or scheduled actions.

Key capabilities:
- Real-time TTS generation and playback  
- Multi-platform streaming (Twitch, YouTube, TikTok, etc.)  
- IRC-based chat ingestion  
- Command-driven behavior  
- Distributed workers for parallel tasks  
- Automatic failovers and fallback streams  
- Event scheduling and timed interactions  

The infrastructure was designed to run unattended, self-recover, and remain stable under unpredictable load.

---

## High-Level Architecture

```
             +--------------------------+
             |        Chat Input        |
             | (IRC / APIs / Commands)  |
             +------------+-------------+
                          |
                          v
             +------------+-------------+
             |     Command Processor     |
             |  - Parses chat messages   |
             |  - Normalizes commands    |
             |  - Triggers workflows     |
             +------------+-------------+
                          |
    -------------------------------------------------
    |                                               |
    v                                               v
+---------------------+                       +-----------------------+
|   TTS Engine        |                       |   Event Scheduler     |
| - Generates audio   |                       | - Timed events        |
| - Multiple voices   |                       | - Routine behaviors   |
| - Manages latency   |                       | - Scene switching     |
+----------+----------+                       +-----------+-----------+
|                                              |
v                                              v
+-------+-------+                              +-------+--------+
|  Audio Worker |                              |  Scene Worker  |
| - Encodes     |                              | - Executes UI  |
| - Streams     |                              |   changes       |
+-------+-------+                              +-------+--------+
|                                              |
v                                              v
+----+------------------------+   +------------------+-----+
|   Streaming Output Layer    |   |  Monitoring & Logs     |
| - Twitch / YouTube / TikTok |   | - Health checks        |
| - Failover channels         |   | - Error tracking       |
+-----------------------------+   +-------------------------+

```
---

## Core Components

### **1. Chat Command Processor**
- Listens to IRC and platform APIs  
- Normalizes messages and filters spam  
- Routes commands to appropriate workers  
- Handles user-triggered interactions  

### **2. TTS Engine**
- Generates real-time audio  
- Supports multiple voices, fallback options  
- Optimizes for low-latency streaming  
- Includes retry logic for API failures  

### **3. Event Scheduler**
- Triggers timed events (phrases, scene changes, actions)  
- Manages daily/weekly routines  
- Provides a timeline for scripted sequences  

### **4. Distributed Workers**
- Audio worker: encodes and pushes audio frames  
- Scene worker: interacts with on-screen elements  
- Utility workers: background tasks, queues, and maintenance  

Workers are stateless and can be scaled horizontally.

### **5. Failover & Recovery**
- Automatic fallback streams when upstream APIs fail  
- Reconnect logic for IRC and platform websockets  
- Graceful degradation under load  
- Persistent state for continuity during restarts  

### **6. Monitoring & Logging**
- Unified logs for chat, events, TTS, and worker activity  
- Health checks to restart crashed components  
- Metrics exported for latency and failure rates  

---

## Operational Characteristics

The system was designed to:

- Run continuously with minimal human intervention  
- Recover from upstream failures (TTS API outages, chat disconnects)  
- Handle bursts of chat activity  
- Avoid blocking operations through worker isolation  
- Maintain consistent performance across long-running sessions  

It was actively used in production and validated over extended 24/7 operation.

---

## What This Project Demonstrates

- Real-time systems engineering  
- Distributed, fault-tolerant architecture  
- TTS pipeline design under latency constraints  
- Multi-platform streaming automation  
- Highly asynchronous, event-driven execution  
- Strong focus on recovery, stability, and observability  

---

## Links

- TODO: Architecture write-up (Notion)  


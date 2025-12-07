# Crane – Minimal Container Orchestrator

Crane is a lightweight container orchestration engine built from first principles to expose the core ideas behind scheduling, health checking, autoscaling, reconciliation, observability, and policy enforcement. It is designed as an educational and experimental platform to understand how orchestration systems behave under real constraints.

---

## Overview

Crane provides:
- A pluggable scheduler (BinPack, Spread, custom strategies)  
- Liveness and readiness health checks  
- Metrics-driven horizontal autoscaling  
- Policy enforcement using OPA  
- A reconciliation loop to maintain desired state  
- Prometheus-native metrics and event logs  
- Node agents for workload execution  

Its purpose is to surface the fundamentals that are often hidden inside large, complex orchestration platforms.

---

## Architecture

Crane is designed as a self-contained orchestration environment built on top of Docker, Prometheus, Alertmanager, and OPA.  
The system operates around a control loop that continuously observes metrics, evaluates policies, and reconciles the desired state with the actual state of the application.

Below is the high-level architecture diagram:

<img width="889" height="667" alt="image" src="https://github.com/user-attachments/assets/10d10023-8d74-4eac-a6b0-43273aa17b3a" />

### Components

#### **1. Application Network (NGINX + container instances)**
Crane manages a set of running containers that form the application workload.  
- Containers are created and deleted via the Docker API.  
- NGINX acts as the internal load balancer, dynamically reconfigured by Crane as instances scale up or down.  
- Requests enter through NGINX and are routed to available instances.

#### **2. Prometheus (Metrics Collection)**
Prometheus scrapes metrics from:  
- the running application instances  
- Crane’s own metrics endpoints  

These metrics are used to drive autoscaling decisions (e.g., CPU, memory, saturation signals).

#### **3. Alertmanager (Events & Alerts)**
Alertmanager evaluates alerting rules and triggers webhooks toward Crane.  
Typical alerts used by Crane include:
- instance failures  
- high latency  
- resource exhaustion  

Crane ingests these alerts and may trigger container restarts, rescheduling, or scaling actions.

#### **4. Open Policy Agent (Policy Enforcement)**
OPA provides policy-as-code for controlling:  
- deployment permissions  
- scheduling decisions  
- scaling boundaries  
- security or operational constraints  

Crane queries OPA before performing actions, ensuring deployments comply with defined rules.

#### **5. Crane (Control Plane)**
Crane acts as the orchestrator and reconciliation engine:
- reads metrics and alerts  
- evaluates policies  
- decides whether to scale, restart, or update configuration  
- writes new NGINX configs and triggers reloads  
- interacts with Docker to create/delete containers  

This component implements the core control-loop behavior of the system.

#### **6. CraneUI**
A simple interface that:
- loads policies  
- loads rules  
- provides user-facing controls for orchestration actions  

#### **7. Docker Environment**
The runtime environment where:
- all containers are executed  
- Crane itself runs  
- supporting services (Prometheus, Alertmanager, OPA) reside  

Crane communicates through the Docker API to manage lifecycle operations.

---

## Control Loop Summary

Crane follows a simplified Kubernetes-style reconciliation cycle:

1. **Observe**  
   - Collect metrics from Prometheus  
   - Receive alerts from Alertmanager  
   - Query policies from OPA  

2. **Decide**  
   - Evaluate whether to scale  
   - Recreate unhealthy containers  
   - Modify load balancing configuration  
   - Block or allow deployments based on OPA rules  

3. **Act**  
   - Issue Docker create/delete commands  
   - Update NGINX configuration  
   - Notify components or reload services  

This loop runs continuously, ensuring the system converges toward the desired state.

---

## Workload Specification Example

```yaml
name: api-service
image: node:18
replicas: 3

resources:
  cpu: 0.3
  memory: 256Mi

health:
  liveness:
    type: http
    path: /health
  readiness:
    type: http
    path: /ready

autoscaling:
  min: 2
  max: 10
  metric: cpu
  target: 70
````

---

## Core Features

### Scheduler

* Multiple placement strategies
* Resource-aware decision making
* Constraint and label support
* Extensible through custom policies

### Health Checks

* HTTP, TCP, and command-based probes
* Restart logic based on failure thresholds
* Probe metrics exported for observability

### Autoscaling

* Metrics-driven horizontal scaling
* CPU, memory, and custom metric support
* Control-loop design inspired by HPA fundamentals

### Policy Enforcement

* OPA integration for admission and scheduling decisions
* Workload descriptors evaluated before execution

### Observability

* Prometheus-compatible metrics
* Event stream for debugging scheduling, health, and scaling behavior

### Reconciliation Loop

* Continuously corrects drift between desired and actual state
* Handles node failures, restarts, and placement corrections

---

## Example Behaviors

* Node failure triggers rescheduling of affected workloads
* Increased load automatically scales replicas
* Policies can block invalid deployments
* Unhealthy containers restart based on probe definitions

---

## Use Cases

* Teaching distributed systems concepts
* Workshops on orchestration fundamentals
* SRE onboarding and internal training
* Experimentation with scheduling algorithms
* Debugging-oriented explorations of failure scenarios

---

## What This Project Demonstrates

* Understanding of orchestration and control-plane design
* Distributed system resilience and lifecycle management
* Observability-first engineering
* Metrics and policy-driven automation
* Infrastructure engineering fundamentals

---

## Links

* Crane technical paper (Springer): https://link.springer.com/chapter/10.1007/978-3-031-14599-5_5
* TODO: Architecture write-up (Notion)
  
---

## License

MIT

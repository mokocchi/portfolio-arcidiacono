# Healthcare SaaS – Incident Response & Distributed Debugging

This project documents a series of real production incidents and architectural challenges encountered while working on a healthcare SaaS platform.  
All examples are anonymized and sanitized. No company names, customer data, or internal identifiers are included.

The focus is on the engineering work: large-scale debugging, architectural fixes, migrations, performance improvements, and operational recovery.

---

## Overview

The platform handled user enrollments, authentication, scheduling, and sensitive data workflows.  
It suffered from legacy code, incomplete migrations, timezone inconsistencies, and operational blind spots.

Key areas of responsibility:
- Reverse engineering undocumented services  
- Debugging multi-layered failures across Node, MongoDB, MySQL, and background workers  
- Fixing large-scale enrollment processes  
- Rewriting critical endpoints for performance and reliability  
- Implementing observability and audit trails  
- Recovering corrupted or inconsistent state in production  

This work demonstrates resilience, deep debugging skills, and the ability to restore order in chaotic systems.

---

## Major Incident Categories

### **1. Successful GraphQL → REST Migration**
A major architectural initiative involved replacing legacy GraphQL endpoints with a REST-based API surface.

The migration was executed cleanly and successfully:
- Full mapping of existing queries and their dependencies  
- Reimplementation of business logic with consistent validation  
- Removal of outdated resolver patterns  
- Creation of predictable error surfaces and typed responses  
- Backward compatibility layer maintained during transition  

This was one of the few parts of the system that behaved predictably and migrated without causing incidents later.  
It set the tone for future restructuring work.

---

### **2. Large-Scale Enrollment Pipeline Issues**
Enrollment batches ranged from hundreds to thousands of users (7k+).  
Failures included:
- Duplicate UUID generation  
- Bulk inserts failing mid-transaction  
- Missing rollback logic  
- Dry-run modes not matching production behavior  
- Worker queues retrying broken payloads indefinitely  

Fixes implemented:
- Idempotent enrollment operations  
- Bulk processing with transactional guarantees  
- Removal of unstable UUID layering  
- Clear audit trails for each processed entity  
- Validation and dry-run parity with real processing  

---

### **3. Timezone Disasters (Multi-Region, Including Asia)**
Timezone rules caused:
- Misaligned date boundaries (day +1 in Asia)  
- Authentication windows expiring prematurely  
- Scheduled tasks executing at incorrect times  
- Enrollment periods closing unexpectedly  

Approach taken:
- Reworking date handling with strict UTC boundaries  
- Removing local-time assumptions from business logic  
- Adding monitoring for skewed timestamps  
- Replaying logs to reconstruct the correct temporal state  

---

### **4. Authentication & Auditing Issues**
The system used passport.js in ways that created:
- Silent login failures  
- Incorrect session refresh flows  
- Missing audit entries on critical actions  
- Inconsistent token revocation behavior  

Work performed:
- Unified authentication pipeline  
- Consistent audit logging for sensitive operations  
- Hardening token validation during edge cases  
- Adding real observability for login failures  

---

### **5. Performance Bottlenecks**
Symptoms included:
- Slow endpoints during high-traffic enrollment periods  
- Cascading failures across dependent services  
- Excessive DB round trips  
- Memory spikes in worker processes  

Solutions:
- Rewriting hot-path endpoints  
- Batch queries and pre-fetching strategies  
- Memory profiling and leak mitigation  
- Introducing caching with explicit invalidation rules  

---

## Recovery & State Reconstruction

Several incidents required reconstructing production state from incomplete logs.  
This included:
- Rebuilding user enrollment histories  
- Identifying missing steps in workflows  
- Validating and correcting orphaned records  
- Cross-referencing timestamps across services  
- Replaying partial event streams  

These tasks demonstrated operational calm, precision under pressure, and the ability to restore system integrity without full observability.

---

## Observability Improvements

Added:
- Structured logging with correlation IDs  
- Dashboard for enrollment success/failure rates  
- Alerting for queue anomalies  
- Monitoring for timezone-based drift  
- Fine-grained worker metrics (latency, retries, saturation)  

These improvements prevented repeat incidents and reduced debugging time dramatically.

---

## What This Project Demonstrates

- Large-scale debugging under ambiguous conditions  
- Incident response and postmortem discipline  
- Architecture refactoring during live operations  
- Advanced understanding of distributed failure modes  
- Ability to reconstruct broken state from partial evidence  
- Production hardening of data pipelines  
- Calm problem-solving under pressure  
- Communication skills for explaining complex failures  

This work is representative of real SRE, platform engineering, and senior debugging responsibilities.

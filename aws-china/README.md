# AWS China Migration – Full Infrastructure Deployment in Restricted Regions

This project involved migrating a full production environment into AWS China regions, which operate under different rules, APIs, networking constraints, and compliance boundaries compared to global AWS regions.  
All client details are omitted. The focus is strictly on the engineering and architectural work.

The migration required deep knowledge of AWS primitives, region limitations, network topology, and manual reconstruction of infrastructure without reliable Infrastructure-as-Code.

---

## Overview

The goal was to replicate an existing AWS infrastructure—originally deployed in EU regions—inside AWS China (Beijing and Ningxia), ensuring parity in:

- Compute (ECS)
- Databases (RDS)
- Caching (ElastiCache)
- Networking (VPC, subnets, routing, NAT)
- Certificates and TLS termination
- CDN distribution (CloudFront China)
- VPN connectivity
- IAM roles and trust relationships
- Observability signals

AWS China differs significantly from global regions due to service availability, account separation, and API restrictions.  
Many operations required **manual reverse engineering**, **click-based deployment**, and **iterative validation**.

---

## Key Challenges

### **1. AWS China Account Separation**
China regions operate under a physically and administratively separate AWS partition (`aws-cn`).  
Implications included:
- Different service endpoints  
- Different ARNs and partition-specific IAM rules  
- Incompatible CloudFormation/Terraform modules  
- Separate marketplaces and AMIs  

IAM trust policies required full rewriting with `aws-cn` ARNs.

---

### **2. Reverse Engineering Infrastructure Without IaC**
The original environment was partially (or completely) unmanaged by IaC tools.  
This required:
- Inspecting every resource manually  
- Reconstructing dependencies through the console  
- Mapping ports, subnets, routing tables, and NAT flows  
- Rebuilding ECS services from scratch  
- Reproducing task definitions, autoscaling, and ALB rules  

All dependencies were documented in a structured format to ensure reproducibility.

---

### **3. ECS Migration**
Recreating ECS in China required:
- Rebuilding clusters, services, tasks, and target groups  
- Rebuilding container images using China-compliant registries  
- Adjusting health check configurations  
- Revalidating container-to-container networking  
- Ensuring autoscaling policies behaved identically  

Some global images could not be pulled due to external network restrictions, requiring local mirrors.

---

### **4. RDS & ElastiCache**
Database replication required:
- Schema export/import  
- Careful migration of parameter groups  
- Manual index verification  
- Rebuilding Redis clusters with TTL validation  

Latency differences and regional quirks required extra benchmarking.

---

### **5. CloudFront China**
CloudFront China operates independently of global CloudFront, requiring:
- Separate ICP filing (handled by the client)  
- Manual certificate provisioning  
- Region-specific domain validation  
- Endpoint testing from Chinese networks  

Global CDN behaviors could not be assumed.

---

### **6. TLS / SSL Certificates**
Certificates had to be reissued because:
- ACM global certificates don't work in China  
- Validation required region-specific authorities  
- Some services required manual certificate uploads  

This impacted both ALB and CloudFront layers.

---

### **7. VPN and Networking Constraints**
Stable VPN connectivity had to be rebuilt with:
- New customer gateways  
- Route propagation rules  
- Validation of VPC connectivity across regions  
- Testing from restricted egress paths  

Routing failures often required packet-level debugging.

---

### **8. UI Latency and Operational Pain**
AWS China console is significantly slower, often:
- timing out  
- loading elements in Chinese  
- failing to render entire sections  
- requiring multiple retries per action  

Much of the migration involved patience, deep familiarity with AWS UI behavior, and methodical validation.

---

## Deliverables Produced

- Complete architecture documentation of both source and target environments  
- Fully replicated ECS/RDS/ElastiCache/VPC setup in AWS China  
- Compliance-aligned certificate and DNS configuration  
- Observability pipeline (logs/metrics) reenacted in China partition  
- Operator runbooks for maintenance  
- Manual dependency mapping (later convertible to IaC)  

All components were validated with functional testing and traffic simulations.

---

## What This Project Demonstrates

- Advanced AWS architecture skills across isolated partitions  
- Ability to execute high-stakes migrations with limited automation  
- Reverse engineering of undocumented infrastructure  
- Clear documentation and dependency mapping  
- Deep understanding of networking, IAM, routing, and certificates  
- Resilience and methodical operations under unreliable tooling  
- Experience with complex constraints uncommon in standard AWS deployments  

This project is one of the strongest indicators of production-grade cloud engineering capability.

---

## Links

- TODO: Architecture diagram  

---

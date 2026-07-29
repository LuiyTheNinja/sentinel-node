# 🛡️ Sentinel Node: Enterprise Cloud Threat Intelligence & SIEM Infrastructure Lab

[![Architecture](https://img.shields.io/badge/Architecture-Hybrid_SIEM%2FNSM-blue)](#-system-architecture)
[![OS](https://img.shields.io/badge/OS-Ubuntu_24.04_LTS-orange)](https://ubuntu.com/)
[![SIEM](https://img.shields.io/badge/SIEM-Grafana_Loki-red)](https://grafana.com/)
[![IPS](https://img.shields.io/badge/IPS-CrowdSec-green)](https://crowdsec.net/)
[![Forensics](https://img.shields.io/badge/Forensics-Zeek%20%7C%20CyberChef-purple)](https://zeek.org/)

> **Autonomous Security Operations Center (SOC) & Threat Intelligence Platform**  
> An enterprise-grade, resource-optimized security operations node engineered on a hardened cloud instance. Sentinel Node captures active internet threat traffic via high-interaction honeypots, aggregates structured telemetry into a unified Grafana Loki SIEM, executes background Network Security Monitoring (NSM), and provides an integrated environment for payload deobfuscation and session replay.

---

## 📑 Table of Contents

1. [Platform Overview & Objectives](#-platform-overview--objectives)
2. [System Architecture](#-system-architecture)
3. [Technology Stack](#-technology-stack)
4. [Directory & Repository Structure](#-directory--repository-structure)
5. [Deployment & Setup Guide](#-deployment--setup-guide)
6. [SIEM Log Pipeline & Data Schemas](#-siem-log-pipeline--data-schemas)
7. [Forensic Analysis & Threat Hunting Workflows](#-forensic-analysis--threat-hunting-workflows)
8. [MITRE ATT&CK Mapping](#-mitre-attck-mapping)
9. [Incident Investigation Reports](#-incident-investigation-reports)
10. [Author & Credentials](#-author--credentials)

---

## 🎯 Platform Overview & Objectives

Sentinel Node was engineered to address a core challenge in modern security operations: **building a full-spectrum SOC/NOC observability stack within strict hardware constraints.**

By leveraging containerized microservices bounded by hard cgroup memory caps, the node functions simultaneously as an offensive threat trap and a defensive monitoring system.

### Core Capabilities:

- **High-Interaction Threat Capture:** Emulates interactive Debian Linux shells on public ports (`22` SSH, `23` Telnet) to lure automated scanners, brute-force botnets, and human threat actors.
- **Centralized Observability (SIEM/NOC):** Ingests structured JSON telemetry, system authentication logs, and host performance metrics into Grafana Loki and Prometheus.
- **Network Security Monitoring (NSM):** Runs an automated, non-disruptive packet capture daemon (`tcpdump`) coupled with **Zeek** and **Tshark** for protocol metadata extraction (DNS, TLS, HTTP).
- **Automated Intrusion Prevention:** Integrates **CrowdSec** behavioral engines to enforce automated firewall blocks (`iptables`) based on attack velocity.
- **Static & Dynamic Forensics:** Provides containerized **CyberChef** for payload deobfuscation and raw TTY replay utilities to analyze attacker sessions frame-by-frame.

---

## 🏗️ System Architecture

The node implements strict network segmentation. Production administrative access is shifted to custom high ports (`2222`), leaving standard protocols exposed to log and trap malicious activity.

```text
                                  [ PUBLIC INTERNET ATTACKERS ]
                                                │
                    ┌───────────────────────────┴───────────────────────────┐
                    │                                                       │
                    ▼ (Port 22: SSH / Port 23: Telnet)                      ▼ (Port 2222: Encrypted Admin)
          ┌───────────────────┐                                   ┌───────────────────┐
          │  Cowrie Honeypot  │                                   │ Hardened Host OS  │
          └─────────┬─────────┘                                   └─────────┬─────────┘
                    │                                                       │
                    │ (JSON Session Logs & Dropped Files)                   │ (Syslog / Auth Logs)
                    ▼                                                       ▼
          ┌───────────────────┐                                   ┌───────────────────┐
          │ Promtail Shipper  │                                   │  Zeek / Tcpdump   │
          └─────────┬─────────┘                                   └─────────┬─────────┘
                    │                                                       │
                    └───────────────────────────┬───────────────────────────┘
                                                │
                                                ▼ (HTTP / Port 3100)
                                     ┌────────────────────┐
                                     │ Grafana Loki SIEM  │
                                     └──────────┬─────────┘
                                                │
                                                ▼ (Encrypted Local Tunnel)
                                     ┌────────────────────┐
                                     │ Unified SOC Console│
                                     │  (Port 3000 Web)   │
                                     └────────────────────┘

```

---

🧰 Technology Stack

Domain,Technology,Purpose & Implementation
Operating System,Ubuntu 24.04 LTS,Base cloud instance with systemd socket activation and kernel tuning.
SIEM / Telemetry,Grafana Loki,"Lightweight, high-throughput log aggregation and LogQL query engine."
Log Shipper,Promtail,Ingests /var/log/auth.log and structured honeypot JSON streams.
NOC / Metrics,Prometheus + Node Exporter,"Monitors host memory utilization, IOPS, and network interface metrics."
Deception / Trap,Cowrie Honeypot,"Emulates UNIX shells, records keystrokes, and captures dropped binaries."
Network Forensics,Zeek & Tshark,"Parses .pcap files into structured network logs (dns.log, conn.log, http.log)."
Active IPS,CrowdSec,Analyzes attack patterns to push automatic firewall decisions (iptables-bouncer).
Payload Analysis,CyberChef,Self-hosted deobfuscation engine for decoding XOR/Base64 payloads.

---

📁 Directory & Repository Structure

sentinel-node/
├── README.md <-- Master Portfolio & System Documentation
├── LICENSE <-- MIT Open-Source License
├── .gitignore <-- Excludes Sensitive Data, PCAPs, and Databases
├── configs/
│ ├── docker-compose.yml <-- Container Orchestration (Resource Bounded)
│ ├── prometheus.yml <-- Prometheus Metrics Collector Rules
│ └── promtail.yml <-- Log Scraping & Labeling Pipeline
├── docs/
│ ├── architecture-spec.md <-- Deep-dive Network & Storage Specifications
│ └── dash-queries.logql <-- Pre-built Grafana LogQL Dashboard Queries
├── rules/
│ ├── crowdsec/
│ │ └── honeypot-bf.yaml <-- Custom Scenario: Rapid Brute-Force Detection
│ └── yara/
│ └── malicious_sh.yar <-- Custom YARA Rule for Dropped Shell Scripts
└── writeups/
├── TEMPLATE.md <-- Standardized Incident Investigation Template
└── 2026-07-28-ssh-bruteforce.md <-- Incident Report: Honeypot Recon & Session Replay

---

🚀 Deployment & Setup Guide

Prerequisites
Linux Endpoint (Ubuntu 24.04 LTS recommended)

Docker Engine v24.0+ and Docker Compose v2.0+

Minimum System Resources: 1 vCPU, 2 GB RAM, 20 GB Storage

1. Host Network & SSH Hardening
   To prevent locking yourself out, shift the host SSH daemon off port 22 before deploying the honeypot:

# 1. Update SSH configuration to listen on port 2222

sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# 2. Disable systemd socket activation on Ubuntu 24.04

sudo systemctl stop ssh.socket && sudo systemctl disable ssh.socket

# 3. Create required runtime directories and restart SSH

sudo mkdir -p /run/sshd && sudo chmod 0755 /run/sshd
sudo systemctl daemon-reload
sudo systemctl restart ssh

CRITICAL: Keep your current terminal open and verify administrative access in a new terminal window using ssh -p 2222 user@<endpoint-ip>

2. Environment Initialization
   Clone the repository and prepare local persistent volume directories:

# Create host-level bind paths for logs and captures

sudo mkdir -p /opt/cyber-lab/{prometheus,promtail-config,cowrie-logs,investigations/pcaps}

# Set appropriate permissions for container log shipping

sudo chown -R 1000:1000 /opt/cyber-lab/cowrie-logs/
sudo chmod -R 777 /opt/cyber-lab/cowrie-logs/

3. Launching the SOC/NOC Microservice Stack
   Deploy the 7-container core suite using Docker Compose:

cd configs/
sudo docker compose up -d

Verify that all containers are active within memory boundaries:

sudo docker stats --no-stream

---

📊 SIEM Log Pipeline & Data Schemas

Promtail continuously scrapes honeypot event streams and host authentication logs, attaching structured labels for rapid querying in Grafana Loki.

┌─────────────────────────┐
│ Cowrie JSON Event Stream│
└────────────┬────────────┘
│
▼
┌─────────────────────────┐ LogQL Parsing Pipeline
│ Promtail Data Shipper ├─────────────────────────────────────────────┐
└────────────┬────────────┘ │
│ ▼
▼ {job="cowrie"} |= "eventid"
┌─────────────────────────┐ | json
│ Grafana Loki Storage │ | line_format "{{.src_ip}} -> {{.input}}"
└─────────────────────────┘

Core LogQL SOC Dashboard Queries

1. Live Attacker Command Telemetry
   {job="cowrie"} |= "cowrie.command.input" | json | line_format "IP: {{.src_ip}} | CMD: {{.input}}"

2. Brute-Force Password Dictionary Harvesting
   {job="cowrie"} |= "cowrie.login" | json | line_format "Attacker IP: {{.src_ip}} | User: {{.username}} | Pass: {{.password}}"

3. Attack Velocity (Attempts Per Minute by IP)
   sum by (src_ip) (rate({job="cowrie"} |= "login" [1m]))

---

🔍 Forensic Analysis & Threat Hunting Workflows

1. Terminal Session Replay (TTY Analysis)
   Cowrie records raw terminal interactions in binary TTY logs. Session replays allow analysts to watch an attacker's command executions in real time:

# Locate recorded TTY sessions

sudo ls -la /opt/cyber-lab/cowrie-logs/tty/

# Replay session inside the isolated container

sudo docker exec -it cowrie playlog /cowrie/cowrie-git/var/log/cowrie/tty/<TTY_LOG_HASH>

2. Automated Network Packet Capture & Zeek Analysis
   A host-level background service captures raw .pcap files on honeypot ports (22, 23):

# Run Zeek protocol inspection against a captured PCAP

cd /opt/cyber-lab/investigations/
zeek -r pcaps/honeypot_capture.pcap

# Inspect extracted DNS queries and responses

cat dns.log | zeek-cut query answers

# Inspect extracted HTTP requests and payload transfers

cat http.log | zeek-cut host uri user_agent

3. Static Payload Deobfuscation (CyberChef Integration)
   Any malicious script or binary downloaded by an attacker (wget/curl) is isolated in /opt/cyber-lab/cowrie-logs/downloads/.

Generate the file hash: sha256sum /opt/cyber-lab/cowrie-logs/downloads/<FILE_HASH>

Open CyberChef (http://localhost:8085 via SSH Tunnel).

Apply standard analytical pipelines: From Base64 -> Gunzip -> Extract URLs.

---

🗺️ MITRE ATT&CK Mapping
Activity captured and analyzed within Sentinel Node is routinely categorized against the MITRE ATT&CK Framework:

Tactic,Technique ID,Technique Name,Detection / Data Source
Initial Access,T1110.001,Password Guessing,Loki (cowrie.login event logs)
Execution,T1059.004,Unix Shell Command Execution,Cowrie TTY Logs & Promtail Ingestion
Discovery,T1082,System Information Discovery,"LogQL (uname -a, cat /proc/cpuinfo)"
Discovery,T1033,System Owner/User Discovery,"LogQL (whoami, id, w)"
Command & Control,T1105,Ingress Tool Transfer,"Zeek (http.log), Cowrie Download Vault"

---

📑 Incident Investigation Reports

Detailed incident write-ups produced from real threat activity captured by Sentinel Node:

📄 2026-07-28: SSH Reconnaissance & TTY Session Replay – Analysis of interactive shell discovery commands, session hashing, and LogQL parsing.

📄 Incident Report Template – Standardized SOC analyst incident documentation format.

---

👨‍💻 Author & Credentials
James Cooper

Data Center Engineer | Security-Minded Infrastructure Professional

Certifications: CompTIA Network+, CompTIA Security+, ISC2 Certified in Cybersecurity (CC), Google Cybersecurity Certificate

Specializations: Infrastructure Engineering, Offensive Security/Red Teaming, SIEM/Log Pipeline Architecture, Network Forensics

Repository License: MIT License

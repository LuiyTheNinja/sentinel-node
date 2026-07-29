# SOC Incident Report: [Incident Title]

**Date:** YYYY-MM-DD  
**Analyst:** James Cooper  
**Severity:** Critical | High | Medium | Low  
**Status:** Closed / Mitigated  

---

## 1. Executive Summary
[Brief overview of what occurred, impact, and mitigation steps]

---

## 2. MITRE ATT&CK Mapping
* **Initial Access:** TXXXX.XXX - [Technique Name]
* **Execution:** TXXXX.XXX - [Technique Name]
* **Command & Control:** TXXXX.XXX - [Technique Name]

---

## 3. Investigation & Telemetry

### A. SIEM Log Analysis (Grafana Loki)
* **LogQL Query:** \{job="cowrie"} |= "cowrie.command.input"\
* **Observations:** [Describe log patterns observed]

### B. Session Analysis & TTY Replay (Cowrie)
* **Executed Commands:**
  \\\ash
  # Shell commands executed by attacker
  \\\

### C. Network & Payload Forensics (Zeek / CyberChef)
* **File Hash (SHA-256):** \HASH_HERE\
* **CyberChef Recipe:** \From Base64 -> Gunzip\

---

## 4. Root Cause & Mitigation
* **Action Taken:** [IP bans, rule updates, or firewall changes]

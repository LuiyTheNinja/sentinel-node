# SOC Incident Report: Automated SSH Reconnaissance & TTY Session Replay

**Date:** 2026-07-28  
**Analyst:** James Cooper  
**Severity:** Medium / Informational (Honeypot Trap)  
**Status:** Closed / Logged  

---

## 1. Executive Summary
An external threat actor initiated interactive SSH sessions targeting public port 22. The connections were transparently routed into the Cowrie honeypot container. The actor executed system discovery commands (\uname -a\, \id\, \cat /etc/passwd\) before disconnecting. Telemetry was shipped via Promtail to Grafana Loki, and the raw session was recorded to disk for forensic playback.

---

## 2. MITRE ATT&CK Mapping
* **Initial Access:** T1110.001 - Password Guessing
* **Execution:** T1059.004 - Unix Shell Command Execution
* **Discovery:** T1082 - System Information Discovery
* **Discovery:** T1033 - User Discovery

---

## 3. Investigation & Telemetry

### A. SIEM Log Analysis (Grafana Loki)
Querying \{job="cowrie"} |= "cowrie.command.input"\ extracted structured JSON events:

\\\json
{
  "eventid": "cowrie.command.input",
  "input": "uname -a",
  "message": "CMD: uname -a",
  "src_ip": "162.35.185.136",
  "session": "f6af3dd47949",
  "protocol": "ssh"
}
\\\

### B. Session Analysis (TTY Replay)
* **Session ID:** \6af3dd47949\
* **TTY Log Path:** \ar/lib/cowrie/tty/6dbeb1351949b496f295249fb7aec07cd96569b1202b664138b01148d445b37b\
* **Session Hash (SHA-256):** \6dbeb1351949b496f295249fb7aec07cd96569b1202b664138b01148d445b37b\

---

## 4. Remediation & Mitigation
* Log stream verified in Grafana Loki SIEM console.
* IP telemetry submitted to CrowdSec for collaborative threat intelligence scoring.

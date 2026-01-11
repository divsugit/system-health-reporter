# 🖥️ Automated System Health Reporter

A lightweight Linux based automation tool that generates a daily system health report and emails it to system administrators.  

## Features

### Core Features
- Generates a system health report using:
  - `df` - disk usage
  - `free` - memory & swap usage
  - `uptime` - CPU load & uptime
  - `lsblk` - mounted storage devices
  - `who` - logged in users
- Displays:
  - Disk usage for all mounted partitions
  - Memory and swap usage
  - CPU load averages and uptime
  - Mounted block devices
  - Currently logged-in users
- Clean, readable text-based report
- Includes hostname, IP address, date, and time
- Sends the report via **email (mailx / s-nail)**
- Runs automatically using **cron**
- Fully configurable via a single config file
- Threshold-based alerts:
  - Disk usage
  - Memory usage
- Multiple email recipients supported
- Config-driven cron scheduling
- One command installation
- Reports stored locally for reference

---

## Installation & Setup
Clone repository and change the config file as per requirement then runs install.sh


## Future

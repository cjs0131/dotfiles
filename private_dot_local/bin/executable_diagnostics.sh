#!/bin/bash

# ─────────────────────────────────────────
#  diagnostics.sh
#  System health check + stress test
# ─────────────────────────────────────────

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOGFILE="diagnostics_$TIMESTAMP.log"

echo "==============================" | tee -a $LOGFILE
echo " SYSTEM DIAGNOSTICS" | tee -a $LOGFILE
echo " $TIMESTAMP" | tee -a $LOGFILE
echo "==============================" | tee -a $LOGFILE

# ─────────────────────────────────────────
# 1. CHECK & INSTALL REQUIRED TOOLS
# ─────────────────────────────────────────
echo "" | tee -a $LOGFILE
echo "[ Checking required tools ]" | tee -a $LOGFILE

TOOLS=("stress-ng" "lm-sensors" "memtester" "smartmontools")

for tool in "${TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "  Installing $tool..." | tee -a $LOGFILE
        sudo apt install -y $tool >> $LOGFILE 2>&1
    else
        echo "  $tool already installed" | tee -a $LOGFILE
    fi
done

# ─────────────────────────────────────────
# 2. LAST BOOT ERRORS
# ─────────────────────────────────────────
echo "" | tee -a $LOGFILE
echo "[ Last boot errors ]" | tee -a $LOGFILE
journalctl -b -1 -p err --no-pager 2>/dev/null | tail -30 | tee -a $LOGFILE
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "  (no previous boot log found)" | tee -a $LOGFILE
fi

# ─────────────────────────────────────────
# 3. OOM / PANIC / KILL EVENTS
# ─────────────────────────────────────────
echo "" | tee -a $LOGFILE
echo "[ OOM / Kernel panic / Kill events ]" | tee -a $LOGFILE
journalctl -b -1 --no-pager 2>/dev/null | grep -i "panic\|oom\|kill\|out of memory" | tee -a $LOGFILE
echo "  (empty = none found, which is good)" | tee -a $LOGFILE

# ─────────────────────────────────────────
# 4. REBOOT HISTORY
# ─────────────────────────────────────────
echo "" | tee -a $LOGFILE
echo "[ Reboot history ]" | tee -a $LOGFILE
last reboot | head -10 | tee -a $LOGFILE

# ─────────────────────────────────────────
# 5. CURRENT TEMPERATURES
# ─────────────────────────────────────────
echo "" | tee -a $LOGFILE
echo "[ Current temperatures ]" | tee -a $LOGFILE
sensors 2>/dev/null | tee -a $LOGFILE || echo "  sensors not configured. Run: sudo sensors-detect" | tee -a $LOGFILE

# ─────────────────────────────────────────
# 6. CPU STRESS TEST (60 seconds)
# ─────────────────────────────────────────
echo "" | tee -a $LOGFILE
echo "[ CPU stress test - 60 seconds ]" | tee -a $LOGFILE
echo "  Watch your temps in another terminal with: watch -n 1 sensors" | tee -a $LOGFILE
echo "  Starting in 5 seconds... (Ctrl+C to skip)" | tee -a $LOGFILE
sleep 5
stress-ng --cpu 0 --timeout 60s --metrics-brief 2>&1 | tee -a $LOGFILE
echo "  CPU stress test complete" | tee -a $LOGFILE

# ─────────────────────────────────────────
# 7. MEMORY TEST
# ─────────────────────────────────────────
echo "" | tee -a $LOGFILE
echo "[ Memory test - 2GB ]" | tee -a $LOGFILE
echo "  This may take a few minutes..." | tee -a $LOGFILE
sudo memtester 2048 1 2>&1 | tee -a $LOGFILE

# ─────────────────────────────────────────
# 8. DISK HEALTH
# ─────────────────────────────────────────
echo "" | tee -a $LOGFILE
echo "[ Disk health ]" | tee -a $LOGFILE

# Find all physical disks
DISKS=$(lsblk -d -o NAME,TYPE | grep disk | awk '{print $1}')

for disk in $DISKS; do
    echo "  Checking /dev/$disk..." | tee -a $LOGFILE
    sudo smartctl -H /dev/$disk 2>&1 | tee -a $LOGFILE
    sudo smartctl -A /dev/$disk 2>&1 | grep -E "Reallocated|Pending|Uncorrectable" | tee -a $LOGFILE
done

# ─────────────────────────────────────────
# DONE
# ─────────────────────────────────────────
echo "" | tee -a $LOGFILE
echo "==============================" | tee -a $LOGFILE
echo " DONE. Log saved to: $LOGFILE" | tee -a $LOGFILE
echo "==============================" | tee -a $LOGFILE

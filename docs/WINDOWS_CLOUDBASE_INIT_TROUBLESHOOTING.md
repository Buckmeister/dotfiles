# Windows CloudBase-Init Troubleshooting Guide

**Purpose:** Comprehensive debugging guide for cloudbase-init issues on Windows VMs in XCP-NG

---

## 📋 Overview

This guide documents common cloudbase-init issues encountered during Windows VM provisioning in XCP-NG environments, along with their root causes, diagnostic procedures, and solutions. These issues apply to any XCP-NG setup using Windows templates with CloudBase-Init.

**Key Learning:** CloudBase-Init uses the **OpenStack ConfigDrive** format, not the simple flat-file structure used by Linux cloud-init!

---

## 🔧 Your Environment Configuration

Before following this guide, identify your environment details:

**XCP-NG Hosts:**
- Primary host: `{your-xcp-host.example.com}`
- Pool coordinator IP: `{192.168.x.x}`

**Storage Repositories:**
- **ISO SR Name:** `{your-iso-sr-name}` (e.g., `isostore1`)
  - UUID: `{ISO-SR-UUID}`
  - Type: iso
  - Content-Type: iso
  - Mount: `/run/sr-mount/{ISO-SR-UUID}`

- **NFS/User SR Name:** `{your-nfs-sr-name}` (e.g., `xenstore1`, `nfsstore1`)
  - UUID: `{NFS-SR-UUID}`
  - Type: nfs
  - Content-Type: user

**Helper Scripts Location:**
- Recommended: `/run/sr-mount/{NFS-SR-UUID}/scripts/` (shared across hosts)
- Alternative: `/root/scripts/` (local to each host)

**SSH Access:**
- SSH Key: `~/.ssh/{your_key_name}` (e.g., `~/.ssh/xen_key`)
- Test User: `{your-test-user}` (e.g., `aria`, `testuser`)

---

## 🚨 Common Issues and Solutions

### ✅ Issue #1: ISO Volume Label

**Problem:** ISO created with `CIDATA` label (Linux standard)

**Impact:** Cloudbase-init looks for `config-2` label, couldn't find ConfigDrive

**Root Cause:**
- Linux cloud-init uses `CIDATA` as the default volume label
- Windows cloudbase-init specifically looks for `config-2` label
- Helper script was using Linux defaults

**Fix:** Change `genisoimage -volid config-2` in helper script

**Location:** Helper script (e.g., `create-windows-vm-with-cloudinit-iso.sh`)

**Verification:**
```powershell
# SSH to Windows VM
ssh -i ~/.ssh/{your_key} {your-user}@<VM_IP>

# Check CD-ROM volume label
powershell.exe -Command "Get-Volume | Where-Object {$_.DriveType -eq 'CD-ROM'}"
```

**Expected Output:**
```
DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus
----------- ------------ -------------- --------- ------------ -----------------
D           config-2     UDF            CD-ROM    Healthy      OK
```

---

### ✅ Issue #2: Template State

**Problem:** Template had cloudbase-init already run (not first-boot state)

**Impact:** Cloudbase-init wouldn't run again on new VMs

**Root Cause:**
- Windows template was created from a VM where cloudbase-init already executed
- CloudBase-Init has a "runonce" mechanism that prevents re-execution
- Template needs to be in OOBE (Out-Of-Box Experience) state

**Fix:** Create pristine template with proper sysprep

**Sysprep Command for Template Creation:**
```powershell
# Run on the template VM before converting to template
C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown
```

**Verification:**
```powershell
# Check if cloudbase-init is in first-run state
Test-Path "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\.runonce"

# Should return False for a properly sysprepped template
```

**Template Naming Convention:** Use `w11cb` or similar to indicate "Windows 11 with CloudBase-init"

---

### ✅ Issue #3: Network Profile

**Problem:** Windows identifies networks by MAC; new VMs = new MACs = "new network" = Public profile

**Impact:** SSH blocked by firewall even after OpenSSH installation

**Root Cause:**
- Windows firewall rules differ between Public and Private network profiles
- Each VM clone gets a new MAC address
- Windows treats each MAC as a new network
- Default profile for new networks is "Public"
- Public profile blocks inbound SSH by default

**Fix:** Add PowerShell in cloudbase-init user-data to force Private profile

**Solution in user_data:**
```yaml
#cloud-config
runcmd:
  - 'powershell.exe -Command "Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private"'
```

**Verification:**
```powershell
# Check current network profile
Get-NetConnectionProfile

# Should show NetworkCategory: Private
```

---

### ✅ Issue #4: ISO Storage Repository

**Problem:** Script selected wrong SR type (user/NFS SR instead of ISO SR)

**Impact:** ISOs might not be properly accessible to VMs

**Root Cause:**
- XCP-NG has multiple SR types: user, iso, lvm, etc.
- Helper script was using `xe sr-list shared=true` without filtering by content-type
- First match might be a user/NFS SR (content-type=user), not an ISO SR (content-type=iso)

**Fix:** Changed SR selection to prefer ISO SR (`content-type=iso`)

**Location:** Helper script lines 337-345

**Correct SR Selection:**
```bash
DEFAULT_SR=$(xe sr-list content-type=iso shared=true params=uuid --minimal | cut -d, -f1)
```

**Verification:**
```bash
# On XCP-NG host
xe sr-list uuid=<SR_UUID> params=content-type,name-label
```

**Storage Repository Types (Example):**
- **ISO SR** (e.g., `isostore1`)
  - UUID: `{ISO-SR-UUID}`
  - Type: iso
  - Content-Type: iso
  - Mount: `/run/sr-mount/{ISO-SR-UUID}`
  - Upload Method: Direct file copy + `xe sr-scan`

- **NFS/User SR** (e.g., `xenstore1`, `nfsstore1`)
  - UUID: `{NFS-SR-UUID}`
  - Type: nfs
  - Content-Type: user
  - Upload Method: `xe vdi-create` + `xe vdi-import`

---

### ✅ Issue #5: ISO Upload Method

**Problem:** Used `xe vdi-create` + `xe vdi-import` for ISO SR
- Creates empty 2MB VDI
- vdi-import doesn't work correctly for ISO SRs
- Windows sees: 0 bytes, no label, unreadable

**Impact:** Cloudbase-init never found the ISO (showed as empty drive)

**Root Cause:**
- ISO SRs work fundamentally differently from other SR types
- ISO SRs are file-based (direct file copy to mount point)
- VDI import method is for block-based storage

**Fix:** For ISO SRs, use proper method:
1. Copy ISO file to `/run/sr-mount/{SR-UUID}/`
2. Run `xe sr-scan uuid={SR-UUID}`
3. Find VDI UUID from scan results

**Location:** Helper script lines 356-400

**Correct Method:**
```bash
if [[ "$SR_TYPE" == "iso" ]]; then
    SR_MOUNT="/run/sr-mount/$DEFAULT_SR"
    cp "$ISO_NAME" "$SR_MOUNT/"
    xe sr-scan uuid="$DEFAULT_SR"
    VDI_UUID=$(xe vdi-list sr-uuid="$DEFAULT_SR" name-label="cloud-init-${TIMESTAMP}.iso" params=uuid --minimal)
fi
```

**Verification:**
```bash
# Check ISO in SR
xe vdi-list sr-uuid={ISO-SR-UUID} params=name-label,uuid,virtual-size

# Should show correct file size (not 2MB)
```

---

### ✅ Issue #6: Multiple CD-ROM Drives

**Problem:** Template has empty CD-ROM drive built-in (xvdd)
- Script adds SECOND CD-ROM with cloud-init ISO (xvde)
- Windows only recognizes/mounts FIRST drive (the empty one)
- Cloudbase-init only scans drives visible to Windows

**Resolution:** This was NOT the actual issue! The ISO IS visible to Windows at D: with correct label.

**Status:** ✅ NOT THE ROOT CAUSE

**Lesson Learned:** Always verify actual Windows state before assuming hypervisor-level issues

---

### ✅ Issue #7: ISO Directory Structure (ROOT CAUSE)

**Problem:** ISO has wrong directory structure!

**Current ISO structure (WRONG):**
```
D:\
├── meta-data
└── user-data
```

**Expected by cloudbase-init (OpenStack Nova format):**
```
D:\
└── openstack\
    └── latest\
        ├── meta_data.json
        └── user_data
```

**Evidence from logs:**
```
2025-10-18 14:02:32.359 - D:\openstack\latest\meta_data.json not found
2025-10-18 14:02:32.365 - Looking for a Config Drive with label 'config-2' on 'D:\'.
                          Found mismatching label 'config-2'.
```

**What's happening:**
1. ✅ ISO is created with correct label `config-2`
2. ✅ ISO is mounted and visible in Windows (D:)
3. ✅ Cloudbase-init scans CD-ROM drives
4. ✅ Cloudbase-init finds drive D: with label config-2
5. ❌ Cloudbase-init looks for `D:\openstack\latest\meta_data.json`
6. ❌ File doesn't exist → "No metadata service found"

**Impact:** Cloudbase-init finds the drive but can't read the configuration

**Fix:** Update helper script to create ISO with OpenStack directory structure

**Location:** Helper script (e.g., `/root/scripts/create-windows-vm-with-cloudinit-iso.sh`)

**Fixed Code:**
```bash
# Create directory structure
mkdir -p iso-staging/openstack/latest

# Create cloud-init metadata (JSON format!)
cat > iso-staging/openstack/latest/meta_data.json <<EOF
{
    "instance-id": "${INSTANCE_ID}",
    "local-hostname": "${HOSTNAME}",
    "name": "${HOSTNAME}"
}
EOF

# Create cloud-init user-data (same content as before)
cat > iso-staging/openstack/latest/user_data <<'EOF'
#cloud-config
users:
  - name: {username}
    groups: Administrators
    ssh_authorized_keys:
      - <SSH_PUBLIC_KEY>

runcmd:
  - 'powershell.exe -Command "Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private"'
EOF

# Create ISO with directory structure (use -graft-points!)
genisoimage -output "$ISO_NAME" \
    -volid config-2 \
    -joliet -rock \
    -graft-points /openstack=iso-staging/openstack

# Cleanup
rm -rf iso-staging
```

**Critical Requirements:**
- Volume label MUST be `config-2` (NOT `CIDATA`)
- Directory structure MUST be `openstack/latest/`
- Files MUST be named `meta_data.json` and `user_data` (no hyphen!)
- Use `-graft-points` to control directory structure in ISO
- ISO must be visible/mounted in Windows
- Cloudbase-init must be in OOBE state (first boot after sysprep)

**Verification:**
```powershell
# SSH to Windows VM
ssh -i ~/.ssh/{your_key} {your-user}@<VM_IP>

# Check ISO structure
powershell.exe -Command "Get-ChildItem D:\ -Recurse | Select-Object FullName"

# Should show:
# D:\openstack
# D:\openstack\latest
# D:\openstack\latest\meta_data.json
# D:\openstack\latest\user_data
```

**Status:** ✅ RESOLVED (requires OpenStack directory structure in ISO)

---

### ✅ Issue #8: SSH Keys for Administrator Group Members

**Problem:** SSH key authentication fails even though:
- SSH keys are deployed to `C:\Users\{username}\.ssh\authorized_keys`
- File ownership and permissions are correct
- The user is in the Administrators group

**Impact:** Cannot connect via SSH using keys, only password authentication works

**Root Cause:**
Windows OpenSSH has a **special security feature** for users in the Administrators group:
- Normal users: SSH keys read from `~/.ssh/authorized_keys`
- Administrator users: SSH keys **MUST** be in `C:\ProgramData\ssh\administrators_authorized_keys`
- The user's `~/.ssh/authorized_keys` is completely ignored for Administrator group members
- This is documented Windows OpenSSH behavior to prevent privilege escalation

**Evidence:**
```powershell
# Check if user is in Administrators group
Get-LocalGroupMember -Group "Administrators"
# Shows: {username} is a member

# User's authorized_keys exists but is ignored
Test-Path C:\Users\{username}\.ssh\authorized_keys  # Returns True
# But SSH key auth still fails!

# administrators_authorized_keys doesn't exist
Test-Path C:\ProgramData\ssh\administrators_authorized_keys  # Returns False
```

**Fix:** Copy SSH keys to administrators_authorized_keys with correct permissions

**Manual Fix (for testing):**
```powershell
# Copy authorized_keys to administrators location
Copy-Item C:\Users\{username}\.ssh\authorized_keys C:\ProgramData\ssh\administrators_authorized_keys

# Set correct permissions (only SYSTEM and Administrators)
icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "NT AUTHORITY\SYSTEM:(F)"
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "BUILTIN\Administrators:(F)"

# Restart sshd to pick up changes
Restart-Service sshd
```

**Automated Fix in Helper Script:**
The helper script can include a PowerShell script (e.g., `setup-admin-ssh-keys.ps1`) which automatically:
1. Checks if user is in Administrators group
2. If yes, copies `~/.ssh/authorized_keys` to `C:\ProgramData\ssh\administrators_authorized_keys`
3. Sets correct permissions (only SYSTEM and Administrators have access)
4. Restarts sshd service

**Location:** Add to helper script as a PowerShell write_files entry

**Verification:**
```powershell
# Check that administrators_authorized_keys exists
Get-Content C:\ProgramData\ssh\administrators_authorized_keys

# Check permissions (should show only SYSTEM and Administrators)
Get-Acl C:\ProgramData\ssh\administrators_authorized_keys | Format-List

# Test SSH key authentication
# From remote machine:
ssh -i ~/.ssh/{your_key} {your-user}@<VM_IP> 'echo "SSH key auth works!"'
```

**Alternative Fix (if you don't want user in Administrators group):**
Remove user from Administrators and keep in Users group only. Then the regular `~/.ssh/authorized_keys` will work:
```powershell
Remove-LocalGroupMember -Group "Administrators" -Member "{username}"
# Now ~/.ssh/authorized_keys will be used instead
```

**Status:** ✅ RESOLVED (requires administrators_authorized_keys for Administrator group members)

**References:**
- [Windows OpenSSH Key Management](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement)
- [OpenSSH Server Configuration for Windows](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_server_configuration)

---

## 🔍 How Cloudbase-Init Works

### ConfigDrive Detection Flow
```
1. Try HTTP Metadata Service (169.254.169.254) → Timeout
2. Try ConfigDrive Service:
   - Scan ALL CD-ROM drives for volume label "config-2"
   - If found: Read openstack/latest/meta_data.json and user_data
   - Execute plugins (create user, install SSH, set network, etc.)
3. If no ConfigDrive: Try EC2/CloudStack → Fail
```

### Required ISO Structure

**✅ CORRECT (OpenStack Nova format):**
```
cloud-init-{timestamp}.iso (label: config-2)
└── openstack/
    └── latest/
        ├── meta_data.json       (instance-id, hostname, etc.)
        └── user_data            (PowerShell cloud-config)
```

**❌ WRONG (Linux cloud-init format):**
```
cloud-init-{timestamp}.iso (label: CIDATA)
├── meta-data
└── user-data
```

---

## 🛠️ Diagnostic Commands

### Check VM Status (from XCP-NG host)

```bash
# Find VM by name
xe vm-list name-label='your-test-vm-*' params=name-label,uuid,power-state,networks

# Check attached ISOs
xe vbd-list vm-uuid=<VM-UUID> type=CD

# Check VDI details
xe vdi-list uuid=<VDI-UUID> params=name-label,virtual-size,physical-utilisation,sr-name-label

# List ISOs in ISO SR
xe vdi-list sr-uuid={ISO-SR-UUID} params=name-label,uuid,virtual-size
```

### Check VM Status (from Windows)

```powershell
# Check users
Get-LocalUser

# Check services
Get-Service cloudbase-init,sshd

# Check CD-ROM drives
Get-WmiObject -Class Win32_CDROMDrive | Select-Object Drive,VolumeName,MediaLoaded,Size

# Check cloudbase-init logs
Get-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\cloudbase-init.log" -Tail 50

# Check for errors in logs
Get-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\cloudbase-init.log" |
    Select-String -Pattern "ERROR|WARN|No metadata service" -Context 2

# Verify ConfigDrive detection
Get-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\cloudbase-init.log" |
    Select-String -Pattern "ConfigDrive|config-2|openstack"

# Check ISO structure
Get-ChildItem D:\ -Recurse | Select-Object FullName
```

### Test SSH Access

```bash
# With key (ultimate success test)
ssh -i ~/.ssh/{your_key} {your-user}@<VM_IP>

# With password (if user exists but key setup failed)
ssh {your-user}@<VM_IP>
# Enter password when prompted
```

---

## 🎯 Success Criteria

When automation is complete, running the helper script should result in:

1. ✅ VM created from Windows template (properly sysprepped with cloudbase-init)
2. ✅ ISO created with `config-2` label
3. ✅ ISO uploaded to ISO SR (correct size, readable)
4. ✅ ISO visible and mounted in Windows
5. ✅ ISO has correct OpenStack directory structure
6. ✅ Cloudbase-init detects ConfigDrive
7. ✅ Test user created automatically
8. ✅ OpenSSH installed and running
9. ✅ Network profile set to Private
10. ✅ SSH key deployed to test user
11. ✅ SSH access works without password: `ssh -i ~/.ssh/{your_key} {your-user}@<NEW_VM_IP>`

---

## 📚 References

- **Cloudbase-Init Docs:** https://cloudbase-init.readthedocs.io/
- **ConfigDrive Spec:** https://docs.openstack.org/nova/latest/user/metadata.html#config-drives
- **XCP-NG/XEN Storage:** https://docs.xcp-ng.org/storage/
- **Windows Sysprep:** https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation

---

## 🔧 Helper Scripts

### Helper Script Locations

**Linux VMs:** `create-vm-with-cloudinit-iso.sh`
- Standard cloud-init with flat file structure

**Windows VMs:** `create-windows-vm-with-cloudinit-iso-v2.sh`
- v2 includes OpenStack ISO structure fix (Issue #7)
- v2 includes administrators_authorized_keys fix (Issue #8)
- v2 includes all 7 issue fixes

**Recommended Locations:**
- **Shared NFS Storage:** `/run/sr-mount/{NFS-SR-UUID}/scripts/` (accessible by all XCP-NG hosts)
- **Local Storage:** `/root/scripts/` (host-specific, requires manual sync)

### Deployment to Shared Storage

**Recommended Method (Integrated - if using dotfiles test system):**
```bash
# Use the test script's integrated deployment
cd ~/.config/dotfiles
./tests/test_xen.zsh --deploy-helpers

# Verify deployment
./tests/test_xen.zsh --verify-helpers

# List deployed scripts
./tests/test_xen.zsh --list-helpers
```

**Manual Method (Universal):**
```bash
# Connect to XCP-NG host
ssh -i ~/.ssh/{your_key} root@{your-xcp-host.example.com}

# Copy to shared NFS storage (accessible by all hosts in pool)
cp /root/scripts/create-windows-vm-with-cloudinit-iso-v2.sh \
   /run/sr-mount/{NFS-SR-UUID}/scripts/

# Make executable
chmod +x /run/sr-mount/{NFS-SR-UUID}/scripts/*.sh
```

**Benefits of Shared Storage Deployment:**
- ✅ Single source of truth for all XCP-NG hosts
- ✅ Automatic availability across entire pool
- ✅ No need to sync scripts manually to each host
- ✅ Version control made simple

---

## 💡 Lessons Learned

1. **CloudBase-Init != Linux cloud-init**: Different formats, different expectations
2. **OpenStack format is required**: Directory structure matters!
3. **ISO SR vs User SR**: Different upload methods for different SR types
4. **Network profiles matter**: Public profile blocks SSH by default
5. **Verify in Windows**: Don't assume hypervisor state matches Windows state
6. **Sysprep is critical**: Template must be in OOBE state for cloudbase-init to run
7. **Log analysis is key**: Cloudbase-init logs tell you exactly what it's looking for

---

**This guide represents 7 issues discovered and resolved over multiple debugging sessions. Keep it updated as new issues are discovered!**

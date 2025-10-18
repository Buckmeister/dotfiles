# Windows VM Automated Provisioning - Complete Guide

**Date:** October 18, 2025
**Status:** 5 issues fixed, 1 remaining (Issue #6 - in progress)
**Goal:** Fully automated Windows VM provisioning with cloudbase-init

---

## Quick Reference

### Current Test VM
- **VM:** aria-test-windows-1760785818 (UUID: 9f8a07aa-0825-2740-b1a1-969dd1be90e1)
- **IP:** 192.168.188.119
- **Template:** w11cb (Windows 11 Pro, cloudbase-init pre-installed, sysprep'd)
- **Access:** Admin / YouAreAwesome (password)

### Key Files
- **Helper Script:** `/root/aria-scripts/create-windows-vm-with-cloudinit-iso-v2.sh` (XEN host)
- **ISO SR:** isostore1 (UUID: 8521cd2e-af19-987e-966b-e68e4435f475)

---

## All 6 Issues Discovered

### ✅ Issue #1: ISO Volume Label (FIXED Oct 17)
**Problem:** ISO created with `CIDATA` label (Linux standard)
**Impact:** Cloudbase-init looks for `config-2` label, couldn't find ConfigDrive
**Fix:** Changed `genisoimage -volid config-2` in helper script
**Location:** `/root/aria-scripts/create-windows-vm-with-cloudinit-iso-v2.sh:320`

### ✅ Issue #2: Template State (USER FIXED Oct 18)
**Problem:** Template had cloudbase-init already run (not first-boot state)
**Impact:** Cloudbase-init wouldn't run again on new VMs
**Fix:** User created pristine `w11cb` template with proper sysprep (OOBE state)
**Template:** aec408e3-cdc7-d4dd-186d-0cc2f407fc69

### ✅ Issue #3: Network Profile (FIXED Oct 18)
**Problem:** Windows identifies networks by MAC; new VMs = new MACs = "new network" = Public profile
**Impact:** SSH blocked by firewall even after OpenSSH installation
**Fix:** Added PowerShell in cloudbase-init user-data to force Private profile
**Location:** Helper script lines 200-203

```powershell
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
```

### ✅ Issue #4: ISO Storage Repository (FIXED Oct 18)
**Problem:** Script selected wrong SR type (xenstore1 for user data instead of isostore1 for ISOs)
**Impact:** ISOs might not be properly accessible to VMs
**Fix:** Changed SR selection to prefer ISO SR (`content-type=iso`)
**Location:** Helper script lines 337-345

```bash
DEFAULT_SR=$(xe sr-list content-type=iso shared=true params=uuid --minimal | cut -d, -f1)
```

### ✅ Issue #5: ISO Upload Method (FIXED Oct 18)
**Problem:** Used `xe vdi-create` + `xe vdi-import` for ISO SR
- Creates empty 2MB VDI
- vdi-import doesn't work correctly for ISO SRs
- Windows sees: 0 bytes, no label, unreadable

**Impact:** Cloudbase-init never found the ISO (showed as empty drive)
**Fix:** For ISO SRs, use proper method:
1. Copy ISO file to `/run/sr-mount/{SR-UUID}/`
2. Run `xe sr-scan uuid={SR-UUID}`
3. Find VDI UUID from scan results

**Location:** Helper script lines 356-400

```bash
if [[ "$SR_TYPE" == "iso" ]]; then
    SR_MOUNT="/run/sr-mount/$DEFAULT_SR"
    cp "$ISO_NAME" "$SR_MOUNT/"
    xe sr-scan uuid="$DEFAULT_SR"
    VDI_UUID=$(xe vdi-list sr-uuid="$DEFAULT_SR" name-label="cloud-init-${TIMESTAMP}.iso" params=uuid --minimal)
fi
```

### ❌ Issue #6: Multiple CD-ROM Drives (DISCOVERED Oct 18 - IN PROGRESS)
**Problem:** w11cb template has empty CD-ROM drive built-in (xvdd)
- Script adds SECOND CD-ROM with cloud-init ISO (xvde)
- Windows only recognizes/mounts FIRST drive (the empty one)
- Cloudbase-init only scans drives visible to Windows

**Evidence:**
```
XEN side:
- xvdd: empty=true, vdi-uuid=<not in database>  ← Windows sees this
- xvde: empty=false, vdi-uuid=0683f1bc-..., ISO is 382KB  ← Windows doesn't see this

Windows side:
- D: MediaLoaded=False, VolumeName=(blank), Size=(empty)
```

**Impact:** Cloudbase-init can't find ConfigDrive, logs show "No drive or context file found"
**Fix:** TBD - Either detach template's empty drive OR use template's drive position
**Status:** Currently working on solution

---

## How Cloudbase-Init Works

### ConfigDrive Detection Flow
```
1. Try HTTP Metadata Service (169.254.169.254) → Timeout
2. Try ConfigDrive Service:
   - Scan ALL CD-ROM drives for volume label "config-2"
   - If found: Read meta-data and user-data files
   - Execute plugins (create user, install SSH, set network, etc.)
3. If no ConfigDrive: Try EC2/CloudStack → Fail
```

### Required ISO Structure
```
cloud-init-{timestamp}.iso
├── meta-data          (instance-id, hostname)
└── user-data          (PowerShell cloud-config)
```

**Critical Requirements:**
- Volume label MUST be `config-2` (NOT `CIDATA`)
- ISO must be visible/mounted in Windows
- Cloudbase-init must be in OOBE state (first boot after sysprep)

---

## Storage Repository Details

### ISO SR (isostore1)
- **UUID:** 8521cd2e-af19-987e-966b-e68e4435f475
- **Type:** iso
- **Content-Type:** iso
- **Shared:** true
- **Mount:** `/run/sr-mount/8521cd2e-af19-987e-966b-e68e4435f475`
- **Upload Method:** Direct file copy + `xe sr-scan`

### User SR (xenstore1)
- **UUID:** 75fa3703-d020-e865-dd0e-3682b83c35f6
- **Type:** nfs
- **Content-Type:** user
- **Upload Method:** `xe vdi-create` + `xe vdi-import`

---

## Testing & Verification

### Check VM Status (from XEN host)
```bash
# Find VM by IP
xe vm-list params=name-label,uuid,power-state,networks

# Check attached ISOs
xe vbd-list vm-uuid={VM-UUID} type=CD

# Check VDI details
xe vdi-list uuid={VDI-UUID} params=name-label,virtual-size,physical-utilisation,sr-name-label
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
```

### Test SSH Access
```bash
# With key (ultimate success test)
ssh -i ~/.ssh/aria_xen_key aria@{IP}

# With password (if aria user exists but key setup failed)
sshpass -p 'YouAreAwesome' ssh Admin@{IP}
```

---

## Commands

### Create Test VM
```bash
ssh -i ~/.ssh/aria_xen_key root@opt-bck01.bck.intern \
  "/root/aria-scripts/create-windows-vm-with-cloudinit-iso-v2.sh w11cb"
```

### Cleanup Test VM
```bash
# On XEN host
xe vm-shutdown uuid={VM-UUID} force=true
xe vm-destroy uuid={VM-UUID}
xe vdi-destroy uuid={ISO-VDI-UUID}
```

### List ISOs in isostore1
```bash
xe vdi-list sr-uuid=8521cd2e-af19-987e-966b-e68e4435f475 params=name-label,uuid,virtual-size
```

---

## Next Steps

1. **Fix Issue #6:** Resolve multiple CD-ROM drive conflict
   - Option A: Detach template's empty CD-ROM before attaching our ISO
   - Option B: Use template's existing CD-ROM drive position

2. **Test Complete Automation:**
   - Create fresh VM with Issue #6 fix
   - Verify cloudbase-init finds ConfigDrive
   - Verify aria user is created
   - Verify SSH key is installed
   - Verify SSH access works: `ssh -i ~/.ssh/aria_xen_key aria@{IP}`

3. **Document Working Solution:**
   - Update helper script with final fix
   - Create comprehensive handover documentation
   - Test on clean environment

---

## Success Criteria

When automation is complete, running the helper script should result in:

1. ✅ VM created from w11cb template
2. ✅ ISO created with `config-2` label
3. ✅ ISO uploaded to isostore1 (correct size, readable)
4. ✅ ISO visible and mounted in Windows
5. ✅ Cloudbase-init detects ConfigDrive
6. ✅ Aria user created automatically
7. ✅ OpenSSH installed and running
8. ✅ Network profile set to Private
9. ✅ SSH key deployed to aria user
10. ✅ SSH access works without password: `ssh -i ~/.ssh/aria_xen_key aria@{NEW_VM_IP}`

**Current Progress:** 5/10 (Issues 1-5 fixed, Issue #6 blocking final success)

---

## References

- **Cloudbase-Init Docs:** https://cloudbase-init.readthedocs.io/
- **ConfigDrive Spec:** https://docs.openstack.org/nova/latest/user/metadata.html#config-drives
- **XCP-NG/XEN Storage:** https://docs.xcp-ng.org/storage/
- **Windows Sysprep:** https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation

---

**Last Updated:** October 18, 2025 - Issue #6 discovered and investigation in progress

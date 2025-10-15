# XCP-NG Helper Scripts

This directory contains helper scripts that can be deployed to the NFS shared storage, making them accessible from all cluster hosts automatically.

## Available Helper Scripts

Helper scripts can be deployed from the host systems (opt-bck01, etc.) where they currently reside.

Common helper scripts include:
- `create-vm-with-cloudinit-iso.sh` - Create Linux VMs with cloud-init
- `create-windows-vm-with-cloudinit-iso.sh` - Create Windows VMs with cloudbase-init
- `cleanup-test-vms.sh` - Clean up test VMs
- `list-test-vms.sh` - List all test VMs

## Deployment

Use the deployment tool to manage helper scripts:

```bash
# Migrate existing scripts from /root/aria-scripts to NFS
./tests/deploy_xen_helpers.zsh --migrate

# Deploy all helper scripts to NFS
./tests/deploy_xen_helpers.zsh --deploy-all

# List scripts on NFS
./tests/deploy_xen_helpers.zsh --list

# Verify NFS access across all hosts
./tests/deploy_xen_helpers.zsh --verify

# Check cluster status
./tests/deploy_xen_helpers.zsh --status
```

## NFS Location

Scripts are deployed to the NFS shared storage at:
```
/var/run/sr-mount/75fa3703-d020-e865-dd0e-3682b83c35f6/dotfiles-test-helpers/
```

This location is accessible from all cluster hosts:
- opt-bck01.bck.intern (192.168.188.11)
- opt-bck02.bck.intern (192.168.188.12)
- opt-bck03.bck.intern (192.168.188.13)
- lat-bck04.bck.intern (192.168.188.19)

## Benefits

Deploying helper scripts to NFS provides:
- **Cluster-wide availability**: All hosts can access the same scripts
- **Version consistency**: Single source of truth for helper scripts
- **Automatic failover**: If one host is down, scripts remain available
- **Easy updates**: Update once, available everywhere

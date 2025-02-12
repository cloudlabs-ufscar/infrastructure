# Erro ao deletar volume (error_deleting)

```sh
openstack volume list
+--------------------------------------+------+----------------+------+-------------+
| ID                                   | Name | Status         | Size | Attached to |
+--------------------------------------+------+----------------+------+-------------+
| 84ea0dba-3ecf-4611-b6dc-05b73548e94e |      | error_deleting |   20 |             |
+--------------------------------------+------+----------------+------+-------------+

openstack volume delete 84ea0dba-3ecf-4611-b6dc-05b73548e94e
Failed to delete volume with name or ID '84ea0dba-3ecf-4611-b6dc-05b73548e94e': Invalid volume: Volume status must be available or error or error_restoring or error_extending or error_managing and must not be migrating, attached, belong to a group, have snapshots, awaiting a transfer, or be disassociated from snapshots after volume transfer. (HTTP 400) (Request-ID: req-e66fbd6b-bca6-4435-8f90-7c4b1c6f084a)
1 of 1 volumes failed to delete.
```
###  solução
```sh
cinder reset-state --state available <volume-id>
```
```sh
cinder reset-state --reset-migration-status <volume-id>
```
```sh
cinder reset-state --attach-status detached <volume-id>
```
```sh
cinder delete <volume-id>
```
---
```sh
Request to delete volume 84ea0dba-3ecf-4611-b6dc-05b73548e94e has been accepted.
```

## Erro persiste
```sh
2024-04-14 20:25:22.508 1116169 INFO cinder.volume.targets.tgt [req-96f4f9d0-f4be-463d-a845-aa0ad26f43f2 req-16294fd0-fc12-4080-bd6a-a8e3b2990e54 388453f976ce4084a063974f124faf2a c5017cb7b19041918102de1d97d1b52d - - - -] Removing iscsi_target for Volume ID: 84ea0dba-3ecf-4611-b6dc-05b73548e94e
2024-04-14 20:25:22.612 1116169 ERROR cinder.volume.targets.tgt [req-96f4f9d0-f4be-463d-a845-aa0ad26f43f2 req-16294fd0-fc12-4080-bd6a-a8e3b2990e54 388453f976ce4084a063974f124faf2a c5017cb7b19041918102de1d97d1b52d - - - -] Failed to remove iscsi target for Volume ID: 84ea0dba-3ecf-4611-b6dc-05b73548e94e: Unexpected error while running command.
Command: tgt-admin --delete iqn.2010-10.org.openstack:volume-84ea0dba-3ecf-4611-b6dc-05b73548e94e -f
Exit code: 22
Stdout: 'Command:\n\ttgtadm -C 0 --mode target --op delete --tid=27\nexited with code: 22.\n'
Stderr: 'tgtadm: this target is still active\n': oslo_concurrency.processutils.ProcessExecutionError: Unexpected error while running command.
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server [req-96f4f9d0-f4be-463d-a845-aa0ad26f43f2 req-16294fd0-fc12-4080-bd6a-a8e3b2990e54 388453f976ce4084a063974f124faf2a c5017cb7b19041918102de1d97d1b52d - - - -] Exception during message handling: cinder.exception.ISCSITargetRemoveFailed: Failed to remove iscsi target for volume 84ea0dba-3ecf-4611-b6dc-05b73548e94e.
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server Traceback (most recent call last):
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/targets/tgt.py", line 248, in remove_iscsi_target
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     cinder.privsep.targets.tgt.tgtadmin_delete(iqn, force=True)
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_privsep/priv_context.py", line 271, in _wrap
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     return self.channel.remote_call(name, args, kwargs,
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_privsep/daemon.py", line 215, in remote_call
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     raise exc_type(*result[2])
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server oslo_concurrency.processutils.ProcessExecutionError: Unexpected error while running command.
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server Command: tgt-admin --delete iqn.2010-10.org.openstack:volume-84ea0dba-3ecf-4611-b6dc-05b73548e94e -f
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server Exit code: 22
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server Stdout: 'Command:\n\ttgtadm -C 0 --mode target --op delete --tid=27\nexited with code: 22.\n'
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server Stderr: 'tgtadm: this target is still active\n'
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server During handling of the above exception, another exception occurred:
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server Traceback (most recent call last):
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_messaging/rpc/server.py", line 165, in _process_incoming
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     res = self.dispatcher.dispatch(message)
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_messaging/rpc/dispatcher.py", line 309, in dispatch
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     return self._do_dispatch(endpoint, method, ctxt, args)
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_messaging/rpc/dispatcher.py", line 229, in _do_dispatch
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     result = func(ctxt, **new_args)
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/manager.py", line 203, in wrapper
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     skip_clean = func(self, context, volume, *args, **kwargs)
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "<decorator-gen-722>", line 2, in delete_volume
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/coordination.py", line 238, in _synchronized
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     return f(*a, **k)
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "<decorator-gen-721>", line 2, in delete_volume
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/objects/cleanable.py", line 208, in wrapper
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     result = f(*args, **kwargs)
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/manager.py", line 1035, in delete_volume
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     with excutils.save_and_reraise_exception():
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_utils/excutils.py", line 227, in __exit__
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     self.force_reraise()
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_utils/excutils.py", line 200, in force_reraise
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     raise self.value
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/manager.py", line 1004, in delete_volume
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     self.driver.remove_export(context, volume)
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/drivers/lvm.py", line 854, in remove_export
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     self.target_driver.remove_export(context, volume)
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/targets/iscsi.py", line 234, in remove_export
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     self.remove_iscsi_target(iscsi_target, lun, volume['id'],
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/targets/tgt.py", line 260, in remove_iscsi_target
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server     raise exception.ISCSITargetRemoveFailed(volume_id=vol_id)
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server cinder.exception.ISCSITargetRemoveFailed: Failed to remove iscsi target for volume 84ea0dba-3ecf-4611-b6dc-05b73548e94e.
2024-04-14 20:25:24.274 1116169 ERROR oslo_messaging.rpc.server
```

### Tentar deletar todos
```sh
for i in $(openstack volume list --all-projects -f value --status error_deleting --column=ID); do cinder reset-state --state available $i; done
for i in $(openstack volume list --all-projects -f value --status available --column=ID); do cinder reset-state --reset-migration-status $i; done
for i in $(openstack volume list --all-projects -f value --status available --column=ID); do cinder reset-state --attach-status detached $i; done
for i in $(openstack volume list --all-projects -f value --status available --column=ID); do cinder delete $i; done
```
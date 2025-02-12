# Validando seu script de cloud-init

```sh
sudo apt update -y
sudo apt install cloud-init -y
```

- Caso der tiver algum erro no seu script, ele mostrára o erro:
```sh
sudo cloud-init schema -c default.yaml --annotate
```
```sh
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/cloudinit/config/schema.py", line 682, in validate_cloudconfig_file
    validate_cloudconfig_schema(
  File "/usr/lib/python3/dist-packages/cloudinit/config/schema.py", line 443, in validate_cloudconfig_schema
    raise SchemaValidationError(errors, deprecations)
cloudinit.config.schema.SchemaValidationError: Cloud config schema errors: users.0: {'name': 'ubuntu', 'sudo': 'ALL=(ALL) NOPASSWD:ALL', 'shell': '/bin/bash', 'groups': ['docker'], 'ssh_authorized_keys': 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1quNr6froGfxssJxPQMlQ/1eE7rfdqh5U8ebtL2El51osPoNrk0FR1poGhOlvBJBbgsFd19FT+mlpL4z9ITOlLNvEyeBeAPNVr1JhDcYNItYkV2GR4y59unG4B3JBq0zzzvSy8vVyoLnmdSPUNeAh4hYQFVue4GaaiQAyiJ5/SOZWdABzoyJCnrLxEYoShvWSdb0Dw9j5h4WHed6B8wTZQq8zonJ1DimIxmRHmlHRr+oIGCbCU2fXaDfVCB2Oldej7b4X5e0fI2YvkODa2vBGZgRaOZETmC5EihGZDxoGHGuigXpplELr31mzlqBRZDnTK6ymL2/zWv8LhNp7dwZqa2APOqdJ5IL98fNCp9exOueoiSxuMB0DmLeTadH3T7UE47PMYRaPuP5H/dnDXINlNq8LVERYzm9OcOMyUbzTSQ2B4HZ+zz1rVTuYFJJ9VGtv8nkKNeWXMLJpW5IxOFoczNmvnDLO+rfls6M5F99a0gWMNlUY2aobWwQdL2qEnSM= jujuclient@controllerb'} is not valid under any of the given schemas

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/usr/bin/cloud-init", line 33, in <module>
    sys.exit(load_entry_point('cloud-init==22.4.2', 'console_scripts', 'cloud-init')())
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/cloudinit/cmd/main.py", line 1086, in main
    retval = util.log_time(
             ^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/cloudinit/util.py", line 2680, in log_time
    ret = func(*args, **kwargs)
          ^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/cloudinit/config/schema.py", line 1173, in handle_schema_args
    validate_cloudconfig_file(
  File "/usr/lib/python3/dist-packages/cloudinit/config/schema.py", line 688, in validate_cloudconfig_file
    annotated_cloudconfig_file(
  File "/usr/lib/python3/dist-packages/cloudinit/config/schema.py", line 596, in annotated_cloudconfig_file
    return _Annotator(cloudconfig, original_content, schemamarks).annotate(
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/cloudinit/config/schema.py", line 569, in annotate
    errors_by_line = self._build_errors_by_line(schema_errors)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/cloudinit/config/schema.py", line 485, in _build_errors_by_line
    errors_by_line[self._schemamarks[path]].append(msg)
                   ~~~~~~~~~~~~~~~~~^^^^^^
KeyError: 'users.0'
```
- Caso estiver tudo ok, ele simplesmente será validado:
```sh
Valid cloud-config: default.yaml
```

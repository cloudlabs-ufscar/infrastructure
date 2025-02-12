# Configure remote console access Openstack Juju

- https://docs.openstack.org/nova/latest/admin/remote-console-access.html
- https://docs.openstack.org/project-deploy-guide/charm-deployment-guide/latest/install-openstack.htm
- https://docs.openstack.org/project-deploy-guide/charm-deployment-guide/latest/configure-openstack.html

```yaml
application: nova-cloud-controller
settings:
  console-access-protocol:
    description: |
      Protocol to use when accessing virtual machine console. Supported types
      are None, spice, xvpvnc, novnc and vnc (for both xvpvnc and novnc).
      .
      NOTE: xvpvnc is not supported with bionic/ussuri or focal (or later)
            releases.
    source: user
    type: string
    value: novnc
```
- Configurar o novnc: https://novnc.com/info.html
```sh
juju config nova-cloud-controller console-access-protocol=novnc
```
- Configurar o spice: https://spice-space.org
```sh
juju config nova-cloud-controller console-access-protocol=spice
```
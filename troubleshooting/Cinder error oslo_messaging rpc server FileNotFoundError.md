# Descricão do Problema

Em um ambiente OpenStack, ao tentar criar uma instância de qualquer tipo na aba Compute -> Instances, pode-se encontrar falhas e erros na hora de criação, normalmente erros relacionados a *TIMEOUT* durante a criação ou exaustão de *HOSTS*, é decorrente de falha de comunicação do nó de *compute* com o servidor de banco de dados.

# Identificação do Problema

Após tentativa de criação de instância no nó de compute, recebimento de status de Erro. A seguinte mensagem é provida:
![vm_error](/troubleshooting/images/vm_error.jpeg)

Como pode-se perceber o erro trata de exaustão de hosts para tentar reconstruir falhas na instancia.
Isso decorre normalmente por falha de comunicação com o servidor rabbitmq, isso pode ser análisado em logs na máquina do rabbitmq-server, e também na máquina do nova-compute

# Solução do Problema

Explorando o log da aplicação cinder pode ser encontado em cinder-volume:

```log
2024-03-12 16:32:47.390 79125 INFO cinder.volume.flows.manager.create_volume [req-e4e454d2-8922-4a2a-abd9-9b67af159199 req-757c8e35-c498-438f-be57-dc8a302ad923 388453f976ce4084a063974f124faf2a c5017cb7b19041918102de1d97d1b52d - - - -] Volume volume-0d5ffdca-d6da-4da7-80bb-2900df33eeef (0d5ffdca-d6da-4da7-80bb-2900df33eeef): created successfully
2024-03-12 16:32:48.399 79125 INFO cinder.volume.manager [req-e4e454d2-8922-4a2a-abd9-9b67af159199 req-757c8e35-c498-438f-be57-dc8a302ad923 388453f976ce4084a063974f124faf2a c5017cb7b19041918102de1d97d1b52d - - - -] Created volume successfully.
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server [req-e4e454d2-8922-4a2a-abd9-9b67af159199 req-7488b9f7-8dd4-4df5-bdbc-441ce123ef96 388453f976ce4084a063974f124faf2a c5017cb7b19041918102de1d97d1b52d - - - -] Exception during message handling: FileNotFoundError: [Errno 2] No such file or directory
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server Traceback (most recent call last):
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_messaging/rpc/server.py", line 165, in _process_incoming
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     res = self.dispatcher.dispatch(message)
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_messaging/rpc/dispatcher.py", line 309, in dispatch
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     return self._do_dispatch(endpoint, method, ctxt, args)
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_messaging/rpc/dispatcher.py", line 229, in _do_dispatch
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     result = func(ctxt, **new_args)
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/manager.py", line 4886, in attachment_update
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     connection_info = self._connection_create(context,
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/manager.py", line 4813, in _connection_create
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     model_update = self.driver.create_export(ctxt.elevated(),
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/drivers/lvm.py", line 846, in create_export
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     export_info = self.target_driver.create_export(
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/targets/iscsi.py", line 195, in create_export
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     tid = self.create_iscsi_target(iscsi_name,
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/utils.py", line 669, in _wrapper
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     return r(f, *args, **kwargs)
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/tenacity/__init__.py", line 423, in __call__
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     do = self.iter(retry_state=retry_state)
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/tenacity/__init__.py", line 360, in iter
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     return fut.result()
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3.10/concurrent/futures/_base.py", line 451, in result
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     return self.__get_result()
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3.10/concurrent/futures/_base.py", line 403, in __get_result
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     raise self._exception
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/tenacity/__init__.py", line 426, in __call__
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     result = fn(*args, **kwargs)
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/targets/tgt.py", line 126, in create_iscsi_target
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     (out, err) = cinder.privsep.targets.tgt.tgtadm_show()
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_privsep/priv_context.py", line 271, in _wrap
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     return self.channel.remote_call(name, args, kwargs,
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_privsep/daemon.py", line 215, in remote_call
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server     raise exc_type(*result[2])
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server FileNotFoundError: [Errno 2] No such file or directory
2024-03-12 16:32:52.107 79125 ERROR oslo_messaging.rpc.server 
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server [req-14ed9026-5a5b-4f38-b2d5-78e95d7aedd8 req-f2fba137-3625-441e-bba6-4a0d63d96c53 388453f976ce4084a063974f124faf2a c5017cb7b19041918102de1d97d1b52d - - - -] Exception during message handling: FileNotFoundError: [Errno 2] No such file or directory
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server Traceback (most recent call last):
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_messaging/rpc/server.py", line 165, in _process_incoming
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     res = self.dispatcher.dispatch(message)
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_messaging/rpc/dispatcher.py", line 309, in dispatch
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     return self._do_dispatch(endpoint, method, ctxt, args)
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_messaging/rpc/dispatcher.py", line 229, in _do_dispatch
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     result = func(ctxt, **new_args)
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/manager.py", line 4886, in attachment_update
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     connection_info = self._connection_create(context,
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/manager.py", line 4813, in _connection_create
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     model_update = self.driver.create_export(ctxt.elevated(),
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/drivers/lvm.py", line 846, in create_export
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     export_info = self.target_driver.create_export(
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/targets/iscsi.py", line 195, in create_export
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     tid = self.create_iscsi_target(iscsi_name,
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/utils.py", line 669, in _wrapper
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     return r(f, *args, **kwargs)
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/tenacity/__init__.py", line 423, in __call__
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     do = self.iter(retry_state=retry_state)
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/tenacity/__init__.py", line 360, in iter
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     return fut.result()
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3.10/concurrent/futures/_base.py", line 451, in result
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     return self.__get_result()
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3.10/concurrent/futures/_base.py", line 403, in __get_result
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     raise self._exception
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/tenacity/__init__.py", line 426, in __call__
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     result = fn(*args, **kwargs)
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/cinder/volume/targets/tgt.py", line 126, in create_iscsi_target
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     (out, err) = cinder.privsep.targets.tgt.tgtadm_show()
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_privsep/priv_context.py", line 271, in _wrap
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     return self.channel.remote_call(name, args, kwargs,
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server   File "/usr/lib/python3/dist-packages/oslo_privsep/daemon.py", line 215, in remote_call
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server     raise exc_type(*result[2])
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server FileNotFoundError: [Errno 2] No such file or directory
2024-03-12 17:15:04.806 79125 ERROR oslo_messaging.rpc.server 
```

O erro ocorre pois o cinder usa o protocolo iscsi para fazer a comunicação entre os as VMs e os volumes. Para isso, se faz o uso do tgt como target para gerenciar volumes. Entretanto, o charm de back-end do Cinder, o cinder-lvm, atualmente não instala o tgt (deprecated) a partir da versão Wallaby. O que pode ser encontrado lendo [o código fonte do charm](https://github.com/openstack/charm-cinder-lvm/blob/master/src/lib/charm/openstack/cinder_lvm.py). Em razão disso, o cinder não conseguia criar os volumes para atrelar às instâncias, o que gerava erro. 

Para solucionnar isso basta dirigir-se a máquina onde enncontra-se a aplicação cinder:

`juju ssh cinder/0`

Dentro da máquina da aplicação deve-se abrir o arquivo de configuração de _targeting_ do tgt, rodar comando `sudo nano /etc/tgt/targets.conf`

Adicionar no arquivo a seguinte linha `include /var/lib/cinder/volumes/*`

Salvar sair do editor aberto e reiniciar o serviço de volume rodando o comando 
`service cinder-volume restart`

# Prevenção:
Foi levantado pelo estudo do código que o problema acima pode ser evitado na configuração do openstack, utilizando a seguinte opção de configuração do cinder-lvm:
```yaml
cinder-lvm:
  block-device: sdb
  config-flags: "target_helper=lioadm"
```

# Links Úteis:
1. [Commom Cinder Troubleshootingns](https://opendev.org/openstack/cinder/src/commit/40a33360ade30abb1656aa3762051a0d96c76186/doc/source/admin/ts-cinder-config.rst)
2. [Openstack Service Restart](https://docs.openstack.org/fuel-docs/mitaka/userdocs/fuel-user-guide/troubleshooting/restart-service.html)

# Configuração de uma Nova Rede Física no OpenStack
## Configuração física
Primeiramente, quando se adiciona uma nova rede a um cluster é preciso entender em qual rede essa interface foi \
conectada nas máquinas físicas. Em nosso caso exemplo, criamos uma nova rede que vai "para a rua" (rede externa) \
e que é conectada nas interfaces "eno2" dos computes e do controller.
## Configuração no linux
Identificada a conexão física, precisamos criar bridges para que o OVN possa se vincular e criar uma \
conexão externa. No controller, isso é feito via netplan.
1. Identificar os aquivos de configuração de netplan, que ficam em ```/etc/netplan```
```sh
# ls /etc/netplan
00-installer-config.yaml
```
2. Analisar as configurações atuais de todos os aquivo, com ênfase na interface que você identificou antes.\
Em nosso exemplo, temos os seguinte arquivo:
```yaml
# 00-installer-config.yaml
network:
  ethernets:
    eno1: {}
    eno2:
      addresses:
      - 200.x.x.x/25
      nameservers:
        addresses:
        - 200.x.x.1
        search: []
      routes:
      - to: default
        via: 200.x.x.1
    eno3: {}
  ...
```
Observe que há várias configurações relacionadas à nossa interface eno2, mas no geral o mais importante é observar \
o IP associado a ela e a sua tabela de rotas, se houver
> É importante notar que, ao criar uma bridge nova, os IPs associados à interface serão atribuídos à bridge nova, assim como as suas rotas
3. Criar um novo arquivo de configuração para as bridges.
Em nosso exemplo, vamos criar um novo arquivo em ```/etc/netplan```, o ```01-bridge-mapping.yaml```.
Neste arquivo, vamos criar as seguintes configurações
```yaml
# 01-bridge-mapping.yaml
networks:
  bridges:
    br1:
      interfaces: [ eno2 ]
      addresses: [ 200.18.99.89/25 ]
      routes:
      - to: default
        via: 200.x.x.1
      nameservers:
        addresses:
        - 200.x.x.1
        search: []
```
Perceba que nesta configuração colocamos o tráfego (rota) padrão para esta bridge, além do nameserver (DNS). Isso foi feito por que nosso controller usava a inteface "eno2" para se comunicar à rede externa, por isso precisamos ajustar essa tabela de rotas
> Note que podemos fazer essas configurações todas em um único .yaml, estamos criando outro por questões de organização.
4. Ajustar configurações \
Com o novo .yaml feito, é necessário verificar se não há configurações conflitantes entre os arquivos do netplan.
Por exemplo, perceba que em nosso arquivo ```00-installer-config.yaml``` nossa interface "eno2" ainda estava com \
o IP da máquina, assim como também estava com a rota default. Precisamos remover isso
```diff
# 00-installer-config.yaml
network:
  ethernets:
    eno1: {}
    eno2: {}
-   eno2:
-     addresses:
-     - 200.x.x.x/25
-    nameservers:
-       addresses:
-       - 200.x.x.1
-       search: []
-     routes:
-     - to: default
-       via: 200.x.x.1
  ...
```
5. Aplicar as mudanças \
Verificadas as configurações, hora de aplicar! Vamos usar o comando ```netplan try```,
> O netplan try aplica as configurações e espera uma confirmação do usuário. Se não houver respostas, ele reverte as configurações Isso é importante principalmente se você está mexendo na interface de rede externa do controller para que você não seja trancado de fora (experiência própria)
```sh
# sudo netplan try
Do you wanto to keep these settings?

Press ENTER before timeout to accept the new configuration

Changes will rever in 55 seconds
```

7. Verificando as configurações \
Feita as configurações, vamos verificar se tudo está certinho. Primeiro, vamos ver se as bridges foram criadas \
```sh
# ip a l
...
37: br1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether ba:54:94:cc:62:57 brd ff:ff:ff:ff:ff:ff
    inet 200.18.x.x/25 brd 200.x.x.x scope global br1
       valid_lft forever preferred_lft forever
    inet6 2801:b0:x:x:x:x:x:x/64 scope global dynamic mngtmpaddr noprefixroute 
       valid_lft 86345sec preferred_lft 14345sec
    inet6 fe80::x:x:x:x:x:x/64 scope link 
       valid_lft forever preferred_lft forever
...
```
A bridge existe e ela está "UP". Tudo certo!
## Configurando os serviços do OpenStack
Em nosso caso, estamos usando o ovn-chassis como backend do neutron. O ovn-chassis é um serviço que fica em \
ambos os computes e cria as bridges e switches virtuais usadas pelo Neutron para criar as redes do OpenStack. \
Além disso, é importante notar que estamos usando o Juju para dar deploy, portanto vamos realizar as configurações por ele.
1. Obtendo acesso ao Juju
Primeiro, certifique-se que está no usuário que criou o Juju \
```sudo -iu jujuclient```
2. Exportar as configurações atuais do ovn-chassis
Agora, precisamos copiar as configurações atuais do serviço do ovn-chassis. Vamos usar esse output do Juju \
para facilitar a nossa vida na hora de lançar as configurações. \
``` juju config ovn-chassis > configs_ovn_chassis.yaml``` 
3. Criando as novas configurações do ovn-chassis
O arquivo gerado é enorme, e não vale a pena colocar ele todo aqui, mas vamos passar pelas três configurações que vamos alterar
- bridge-interface-mappings
```yaml
bridge-interface-mappings: 
    description: |
      A space-delimited list of key-value pairs that map a network interface MAC address or name to a local ovs bridge to which it should be connected.
      Note: MAC addresses of physical interfaces that belong to a bond will be resolved to the bond name and the bond will be added to the ovs bridge.
      Bridges referenced here must be mentioned in the `ovn-bridge-mappings` configuration option.
      If a match is found the bridge will be created if it does not already exist, the matched interface will be added to it and the mapping found in `ovn-bridge-mappings` will be added to the local OVSDB under the `external_ids:ovn-bridge-mappings` key in the Open_vSwitch table.
      An example value mapping two network interface mac address to two ovs bridges would be:
          br-internet:00:00:5e:00:00:42 br-provider:enp3s0f0
      Note: OVN gives you distributed East/West and highly available North/South routing by default.  You do not need to add provider networks for use with external Layer3 connectivity to all chassis.
      Doing so will create a scaling problem at the physical network layer that needs to be resolved with globally shared Layer2 (does not scale) or tunneling at the top-of-rack switch layer (adds complexity) and is generally not a recommended configuration.
      Add provider networks for use with external Layer3 connectivity to individual chassis located near the datacenter border gateways by adding the MAC address of the physical interfaces of those units.
    source: user
    type: string
    value: br-ex:eno1
```
o bridge-interface mapping mapeia as interfaces físicas dos computes para uma bridge do OVS. Em nosso setup, \
os computes também usam a "eno2" com bridge para essa nova rede. Vamos adicionar esta nova bridge na eno2
```diff
# configs_ovn_chassis.yaml
...
bridge-interface-mappings: 
  description: ...
  source: user
  type: string
  - value: br-ex:eno1
  + value: br-ex:eno1 br-pub-eno2
```
* ovn-bridge-mapping
```.yaml
ovn-bridge-mappings: 
    description: |
      A space-delimited list of key-value pairs that map a physical network name to a local ovs bridge that provides connectivity to that network.
      The physical network name can be referenced when the administrator programs the OVN logical flows either by talking directly to the Northbound database or by interfacing with a Cloud Management System (CMS).
      Each charm unit will evaluate each key-value pair and determine if the configuration is relevant for the host it is running on based on matches found in the `bridge-interface-mappings` configuration option.
      If a match is found the bridge will be created if it does not already exist, the matched interface will be added to it and the mapping will be added to the local OVSDB under the `external_ids:ovn-bridge-mappings` key in the Open_vSwitch table.
      An example value mapping two physical network names to two ovs bridges would be:
          physnet1:br-internet physnet2:br-provider
      NOTE: Values in this configuration option will only have effect for units that have a interface referenced in the `bridge-interface-mappings` configuration option.
    source: user
    type: string
    value: physnet1:br-ex
```
Esta configuração mapeaia uma rede física a uma bridge do OVN. Basicamente, "nomeia" a rede que está conectada à bridge indicada.\
Em nosso caso, queremos criar uma nova rede, a "physnet2" que vai estar conectada na bridge que criamos no passo anterior
```diff
# configs_ovn_chassis.yaml
...
ovn-bridge-mappings:
  description: ...
  source: user
  type: string
-  value: physnet1:br-ex
+  value: physnet1:br-ex physnet2:br-pub
...
```
* prefer-chassis-as-gw
```.yaml
prefer-chassis-as-gw:
    default: false
    description: |
      Prefer units of this application in CMS (Cloud Management System)
      scheduling of HA chassis groups (aka. gateways) over units of other OVN
      chassis applications present in this deployment.
      .
      By default the CMS will schedule HA chassis groups across all chassis
      with bridge- and bridge interface mappings configured.
      .
      This configuration option would allow you to influence where gateways are
      scheduled when all units have equal bridge- and bridge interface mapping
      configuration.
      .
      NOTE: If none of the OVN chassis named applications in the deployment
      have this option enabled, the CMS will fall back to schedule gateways to
      chassis with bridge- and bridge interface mapping configured.
      .
      NOTE: It is also possible to enable this option on several OVN chassis
      applications at the same time, e.g. on 2 out of 3.
    source: user
    type: boolean
    value: true
```

Esta configuração basicamente define para os computes usarem a rede criada pelo ovn local \
em vez de outras, como diretamente pelo ovn-central, do controller
> [!WARNING]
> Precisamos rever se essa informação está certa
```diff
# configs_ovn_chassis.yaml
...
prefer-chassis-as-gw:
    default: false
    description: ...
    source: user
    type: boolean
-   value: false
+   value: true
...
```
  
4. Aplicando as novas configurações do ovn-chassis \
Feitas as configurações, vamos aplicá-las no serviço usando o juju \
```juju config ovn-chassis --file ./configs_ovn_chassis.yaml``` \
Feito isso, precisamos reiniciar o serviço do ovn-chassis. Primeiro, precisamos do nome dos serviços
```sh
# juju status
...
Unit                         Workload  Agent  Machine  Public address  Ports           Message
cinder/0*                    active    idle   13       10.84.0.12      8776/tcp        Unit is ready
  cinder-lvm/0*              active    idle            10.84.0.12                      Unit is ready
  cinder-mysql-router/0*     active    idle            10.84.0.12                      Unit is ready
glance/0*                    active    idle   3        10.84.0.5       9292/tcp        Unit is ready
  glance-mysql-router/0*     active    idle            10.84.0.5                       Unit is ready
keystone/0*                  active    idle   4        10.84.0.6       5000/tcp        Unit is ready
  keystone-mysql-router/0*   active    idle            10.84.0.6                       Unit is ready
mysql-innodb-cluster/0       active    idle   0        10.84.0.2                       Unit is ready: Mode: R/O, Cluster is ONLINE and can tolerate up to ONE failure.
mysql-innodb-cluster/1       active    idle   1        10.84.0.4                       Unit is ready: Mode: R/O, Cluster is ONLINE and can tolerate up to ONE failure.
mysql-innodb-cluster/2*      active    idle   2        10.84.0.3                       Unit is ready: Mode: R/W, Cluster is ONLINE and can tolerate up to ONE failure.
neutron-api/0*               active    idle   5        10.84.0.7       9696/tcp        Unit is ready
  neutron-api-plugin-ovn/0*  active    idle            10.84.0.7                       Unit is ready
  neutron-mysql-router/0*    active    idle            10.84.0.7                       Unit is ready
nova-cloud-controller/0*     active    idle   7        10.84.0.9       8774-8775/tcp   Unit is ready
  nova-mysql-router/0*       active    idle            10.84.0.9                       Unit is ready
nova-compute/0*              active    idle   14       10.84.0.13                      Unit is ready
  ovn-chassis/0              active    idle            10.84.0.13                      Unit is ready
nova-compute/1               active    idle   15       10.84.0.15                      Unit is ready
  ovn-chassis/1*             active    idle            10.84.0.15                      Unit is ready
openstack-dashboard/0*       active    idle   8        10.84.0.10      80,443/tcp      Unit is ready
  dashboard-mysql-router/0*  active    idle            10.84.0.10                      Unit is ready
ovn-central/0                active    idle   0        10.84.0.2       6641-6642/tcp   Unit is ready (northd: active)
ovn-central/1                active    idle   1        10.84.0.4       6641-6642/tcp   Unit is ready (leader: ovnnb_db)
ovn-central/2*               active    idle   2        10.84.0.3       6641-6642/tcp   Unit is ready (leader: ovnsb_db)
placement/0*                 active    idle   6        10.84.0.8       8778/tcp        Unit is ready
  placement-mysql-router/0*  active    idle            10.84.0.8                       Unit is ready
rabbitmq-server/0*           active    idle   2        10.84.0.3       5672,15672/tcp  Unit is ready
vault/0*                     active    idle   9        10.84.0.11      8200/tcp        Unit is ready (active: true, mlock: enabled)
  vault-mysql-router/0*      active    idle            10.84.0.11                      Unit is ready
...
```
Há muitos serviços, mas o que importa são o ```ovn-chassis/0``` e ```ovn-chassis/1```, que estão rodando nos computes \
Vamos reiniciá-los 
```sh
juju run ovn-chassis/0
juju run ovn-chassis/1
```
5. Criando as configurações do neutron-api \
De forma similar ao ovn-chassis, vamos modificar algumas configurações do neutron-api \
```juju config neutron-api > configs_neutron_api.yaml``` \
Aqui temos somente uma configuração a fazer
* flat-network-provicers:
```yaml
flat-network-providers:
    description: |
      Space-delimited list of Neutron flat network providers.
    source: user
    type: string
    value: physnet1
```
Aqui colocamos a nossa rede flat (rede criada pelo ovn). Como feito antes, criamos a nossa rede physnet2
```diff
# configs_neutron_api.yaml
...
flat-network-providers:
    description: |
      Space-delimited list of Neutron flat network providers.
    source: user
    type: string
-   value: physnet1
+   value: physnet1 physnet2
...
```
6. Aplicando as configurações do neutron-api \
Novamente usando o Juju, vamos lançar as configurações \
```juju config neutron-api --file ./configs_neutron_api.yaml``` \
O neutron faz as atualizações automaticamente, então nosso trabalho aqui está pronto!

## Próximos passos
Com a rede flat disponível para o neutron, agora pode-se criar uma rede flat dentro do OpenStack, que vai \
permitir VMs se comunicarem com o mundo exterior. O passo-a-passo de criar redes flats está no forno!

## Referências
- netplan - https://netplan.io/
- charm neutron-api - https://charmhub.io/neutron-api
- charm ovn-chassis - https://charmhub.io/ovn-chassis
- juju config - https://juju.is/docs/juju/juju-config
- juju actions - https://juju.is/docs/juju/manage-actions



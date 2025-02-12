---
date: 2024-05-20
tags:
  - OVN
  - tunnel
  - geneve
  - networking
---
### Background e contexto
Dentro do OpenStack, o tráfego das VMs podem ter diferentes caminhos. O tráfego entre máquinas virtuais (estejam elas no mesmo compute físico ou não) é chamado de tráfego leste-oeste.
Notou-se que quando VMs eram alocadas na mesma rede lógica do OpenStack (por exemplo, a subnet 192.168.0.0/24), duas VMs nem sempre conseguiam se comunicar.
### Sintomas e descrição do problema
Eventualmente, notou-se que o tráfego entre VMs na mesma rede lógica acontecia apenas quando duas VMs estavam no mesmo nó físico (compute0 ou compute1). Quando as vms se encontram em computes diferentes, um tunnel geneve é criado entre elas.
Dessa maneira, tornou-se necessário identificar se o problema era de transmissão ou de recebimento dos pacotes através desses tunnels.
#### Investigando com tcpdump
Executando tcpdump dentro dos computes nas interfaces das VMs. O tráfego vm1 (compute1) -> vm2 (compute0) foi testado e alguns pontos foram identificados:
- Em compute1, foi possível visualizar o ARP Request produzido por vm1.
- Em compute0, o ARP Request produzido por vm1 foi recebido e vm2 produziu um ARP Reply.
- O ARP Reply nunca chega de volta a compute1.
Dessa maneira, pode-se concluir que o apenas o tráfego compute1 -> compute0 funciona, a outra direção do tráfego não funciona.
Para validar a hipótese o experimento foi invertido. Dessa vez o tráfego é de vm2 (compute0) -> vm1(compute1).
- Em compute0, vm2 produz o ARP Request 
- Já compute1 nunca recebe esse ARP Request.
#### ovs-vswitchd.log
Todos os serviços relacionados a rede estavam sendo executados aparentemente sem falhas.  Exceto ovs no compute1, os logs foram obtidos com: `ubuntu@compute1:~$ sudo cat /var/log/openvswitch/ovs-vswitchd.log`
Duas mensagens cruciais foram obtidas a partir desse log: 
```
(...)
|WARN|receive tunnel port not found 
(...)
|INFO|received packet on  unassociated datapathport 1 (no OpenFlow tunnel port for this packet)
(...)
```

Com a informação obtida através de log, pode-se concluir que compute1 recebe o pacote, mas por algum motivo, não encontra a tunnel port para recebimento.
Falta mais uma informação importante, com `ubuntu@compute0:~$ sudo ovs-vsctl list open_vswitch` é possível identificar algumas informações relevantes sobre o OVS de compute0. O ponto mais importante aqui é o campo `ovn-encap-ip="10.84.0.13"`, que define justamente o IP (local) que compute0 utilizará como tunnel endpoint.
### Resolução do problema
O problema aqui surge por causa de br-ex, essa interface por algum motivo possuía dois IPs distintos em compute0: 10.84.0.13 e 10.84.0.14.
Ou seja, o OVS de compute0 montava os pacotes geneve com source IP de 10.84.0.13 (ovn-encap) mas a rota padrão para 10.84.0.0/16 era por 10.84.0.14. Essa distinção fazia que compute1 rejeitasse o pacote.

O problema finalmente foi resolvido resolvendo esse problema de rotas:
``` shell
ubuntu@compute0:~$ ip r s
default via 10.84.0.1 dev br-ex proto static
10.84.0.0/16 dev br-ex proto kernel scope link src 10.84.0.14
200.18.99.0/25 dev eno2 proto kernel scope link src 200.18.99.115
ubuntu@compute0:~$ sudo ip r del 10.84.0.0/16 dev br-ex
ubuntu@compute0:~$ sudo ip route add 10.84.0.0/16 dev br-ex proto kernel scope link src 10.84.0.13
ubuntu@compute0:~$ ip r s
default via 10.84.0.1 dev br-ex proto static 
10.84.0.0/16 dev br-ex proto kernel scope link src 10.84.0.13
200.18.99.0/25 dev eno2 proto kernel scope link src 200.18.99.115 
```

### Conclusão e comentários finais
O deploy dessa instalação foi realizada há algum tempo e eventualmente modificações foram realizadas nas interfaces. Não foi possível identificar exatamente o motivo de br-ex possuir dois IPs. Algumas hipóteses foram levantadas, dentre elas a possibilidade do MAAS ter adicionado mais um IP a interface em algum momento automaticamente ou algum operador do servidor ter manualmente adicionado esse IP. 
Com essa discussão, é possível concluir que ferramentas como tcpdump são grandes aliadas para ajudar a identificar problemas de conectividade, juntamente com os logs dos serviços relacionados. Também deve-se tomar cuidado com as configurações das interfaces e as configurações de rotas.

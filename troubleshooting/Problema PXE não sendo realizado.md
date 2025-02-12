# Descrição do Problema

Uma vez que se deseja registrar uma máquina física no MAAS via boot PXE (Preboot Execution Environment), e buscando na rede local é possível visualizar um novo ip, aonde deve estar o servidor IPMI, ao acionar a máquina física para ligar, mesmo após um tempo (estima-se cerca de 15 minutos) essa máquina não é adicionada ao MAAS para gerenciamento.

# Identificação do Problema

Esse problema pode ser identificado de duas maneiras:

1. Ao realizar tentativa de conexão ao BMC da máquina física, utilizando ipmitool, receber uma resposta rápida de erro de estabelecimento de sessão![ipmi_image](images/ipmi_error.png "Mensagem IPMI Error") **Importante:** Garantir de ter colocado usuário e senha corretamente. Respostas demoradas normalmente são relacionadas a ips sem IPMI.

2. Após o tempo normal de espera de ligar uma máquina via IPMI, cerca de 15 minutos, **não** encontrar na Subnet relativa ao ip dessa máquina no MAAS o seguinte cenário: ![bmc](images/Subnets.png)

# Solução do Problema

O problema decorrente dos fatos citados anteriormente, decorre de problemas físicos. Isso pode ser decorrente de algum problema físico que não está permitindo a inicialização da máquina por uma espera de prompt. Por exemplo:
![physical](images/physical.jpeg)

No caso acima está sendo descrito que a configuração de memória RAM não está realizada de forma ótima, e o terminal solicita entrada do teclado para continuar, em casos como esse deve-se realizar a manutenção física da máquina condizente com a situação, para esse exemplo, análise da memória RAM para encontrar quais blocos não estão satisfazendo a condição.

Para casos onde a máquina não precisa ser reiniciada, ou não há problema em fisícamente conceder entrada de teclado para a máquina em eventuais Reinicializações, basta conceder a entrada solicitada pela máquina para continuar o boot.

## Possível problema na Identificação 1

Em casos onde é garantido que o ip de tentativa de acesso ipmi, direciona para um BMC, e não encontrou-se problemas físicos na máquina, ou após solução desses, persiste o erro encontrado na identificação 1 apresentada aqui posteriormente. O problema decorre de falta de informação de usuário na conexão ipmi, isso pode ser resolvido acessando a máquina física e encontrar as opções de configurações de utilidade.
![password](images/pass.jpeg)

Tomamos como exemplo a máquina da imagem acima, ao encontrar as configurações de utilidade, pode-se definir em configuração de usuário LAN uma senha e usuário para conexão IPMI, o que é necessário para conexão.

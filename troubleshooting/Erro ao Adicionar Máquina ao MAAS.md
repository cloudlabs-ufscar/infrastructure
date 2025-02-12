# Erro ao Adicionar Máquina ao MAAS
## Contextualização
Em nossa infraestrutura, usamos o MAAS para gerenciar nosso ambiente _bare metal_, ou seja,
para fazer a gestão de nossas máquinas físicas e até mesmo de questões de rede.

Uma das principais atribuições do MAAS em nosso setup é instanciar nós a um _controller_,
o que é feito para adicionar _computing nodes_ a um _cluster_ (seja o _cluster_ cirrus ou stratus)
e também para adicionar o _controller_ do stratus ao _controller_ do cirrus (isso é feito porque 
o stratus é um cluster de testes, e ter ele sob controle do cirrus é muito útil para podermos 
subir e descer um novo ambiente).

## Adicionando uma máquina ao MAAS
Para adicionar uma nova máquina ao MAAS, os seguintes passos são necessários:
1. Reconhecer a máquina (seja automatica ou manualmente)
2. Realizar comissionamento e testes da máquina
3. Realizar deploy de um sistema operacional máquina

Após estes passos, temos um novo nó (físico ou virtual, no caso de VMs do LXD) que pode ser usado
livremente, seja para instanciar no JUJU seja para usar como uma máquina a parte

## Erros
Este processo, entretanto, nem sempre é tão simples assim. Vamos listar aqui alguns erros que 
enfrentamos durante o processo e como resolvemo-os

### A máquina não aparece no MAAS
Este é um erro que pode ter muitas causas. A primeira é (@jesus ou @miguel expliquem aqui!)

Este erro é resolvido substituindo o arquivo ```lpxelinux.0``` que fica em

```/var/snap/maas/common/boot-resources/snapshot-X-Y/bootloader/pxe/i386/```

Para isso:
1. Baixe o arquivo correto que está em ```/etc/lpxelinux.0``` que está em nosso respostório do github da Infra
2. Passe o arquivo para o _controller_ (se não tiver baixado diretamente no _controller_)
* Inicie uma sessão sftp com o servidor ```sftp -P 2002 <seu user>@<cirrus ou stratus>.dc.ufscar.br```
* Passe o arquivo para o _controller_ ```put <path que você baixou/lpxelinux.0>```
3. Pare o serviço do maas \
```sudo snap stop maas``` 
4. Substitua o arquivo atual \
```sudo rm /var/snap/maas/common/boot-resources/snapshot-X-Y/bootloader/pxe/i386/lpxelinux.0``` 
5. Coloque o novo arquivo no local \
```sudo cp <path do arquivo>/lpxelinux.0 /var/snap/maas/common/boot-resources/snapshot-X-Y/bootloader/pxe/i386/``` 
6. Ligue novamente o MAAS \
```sudo snap start maas``` 
Agora as máquinas devem aparecer no MAAS. 

Por vezes, o MAAS pode sobrescrever nosso arquivo lpxelinux.0 arbitrariamente. Para checar isso podemos fazer um checksum
de ambos os arquivos antes de realizarmos todo esse procedimento.

```sha1sum /var/snap/maas/common/var/snap/maas/common/boot-resources/snapshot-X-Y/bootloader/pxe/i386/lpxelinux.0```

```sha1sum <path do lpxelinux.0 baixado>lpxelinux.0```

Se ambos tiverem o mesmo checksum, significa que o arquivo já está correto e não precisamos prosseguir com esta troca

### Adicionando máquinas manualmente no MAAS
Caso após o passo anterior as máquinas não tenham aparecido, ainda há uma esperança, adicionar a máquina manualmente.
Para isso:
1. Identificar o IP da máquina \
```sudo nmap -T5 10.43.0.0/24``` para o cirrus \
```sudo nmap -T5 10.42.0.0/24``` para o stratus
O output será algo parecido com isso 
```sh
Starting Nmap 7.80 ( https://nmap.org ) at 2024-05-17 02:42 UTC
Nmap scan report for 10.43.0.193
Host is up (0.0012s latency).
Not shown: 995 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
443/tcp  open  https
5900/tcp open  vnc
5901/tcp open  vnc-1
MAC Address: 00:26:B9:41:7F:EC (Dell)

Nmap scan report for controllerb (10.43.0.1)
Host is up (0.000023s latency).
Not shown: 994 closed ports
PORT     STATE SERVICE
53/tcp   open  domain
2002/tcp open  globe
3128/tcp open  squid-http
7911/tcp open  unknown
8000/tcp open  http-alt
8443/tcp open  https-alt

Nmap done: 256 IP addresses (2 hosts up) scanned in 8.32 seconds
```
O IP 10.43.0.1 é do nosso próprio _controller_, logo o IP do nó é o do 10.43.0.193

2. Verificar se o IP é mesmo de um BMC
```sh
ipmitool -H 10.84.0.193 -U root -P root -I lanplus
```
Ele deverá adicionar um output parecido com o seguinte:
```sh
No command provided!
Commands:
	raw           Send a RAW IPMI request and print response
	i2c           Send an I2C Master Write-Read command and print response
	spd           Print SPD info from remote I2C device
	lan           Configure LAN Channels
	chassis       Get chassis status and set power state
	power         Shortcut to chassis power commands
  ...
```
Caso apareceça essa saída, significa que temos um BMC válido, pule para o caso.

Continuando, agora podemos adicionar na mão no MAAS
1. Acesse o dashboard do MAAS
![dashboard maas](images/Erro_adicionar_maquina_maas_1.png)
2. Clique em add hardware > machine
![add hardware](images/Erro_adicionar_maquina_maas_2.png)
3. Preencha com um nome (ex. stratus, compute0 ou compute1)
![adding machine](images/Erro_adicionar_maquina_maas_3.png)
4. Coloque o power type para IPMI
![adding machine 2](images/Erro_adicionar_maquina_maas_4.png)
5. Preencha com as informações do IPMI
* IP address - IP obtido no nmap
* Power user - root
* Power password - root
* Privilege Lever - Administrator
![adding machine 3](images/Erro_adicionar_maquina_maas_5.png)
6. Adicione a máquina em Save machine
![adding machine 4](images/Erro_adicionar_maquina_maas_6.png)
A máquina deve entrar em comissionamento. Agora aguarde uns 20 minutos, tome um café e volte depois.
![adding machine 4](images/Erro_adicionar_maquina_maas_7.png)
Caso a máquina entrou no estado de ready, parabéns!

Caso contrário, prossiga para o próximo passo.

### Problemas com o BMC
Um problema possível é estarmos com algum problema no BMC. BMC é um "mini computador" 
que fica ligado ao computador e serve para monitorar, desligar e ligar, além de permitir 
bootar o computador, ou seja, boot pxe.

Para depurá-lo, vamos usar o _ipmitool_, que já foi mostrado anteriormente
1. Rodar um self-test

```ipmitool -H <IP do BMC> -U root -P root mc selftest```

Se estiver tudo certo, o retorno será ```Selftest: passed``` 

Caso contrário, a saída será algo como
```sh
Selftest: device corrupted
FRU device not accessible
```
Neste caso, vamos tentar reiniciar o BMC remotamente

```ipmitool -H <IP do BMC> -U root -P root mc reset```

Caso ainda não tenhamos sucesso, deve-se retirar o computador da tomada, esperar alguns 
segundos e ligar novamente na tomada.

### Problemas de rede no _controller_
Após este último passo, se tudo ocorrer bem, o nó a ser instanciado deve estar funcionando corretamente.
Em nosso caso, fomos apresentados ao seguinte erro:

![add hardware](images/Erro_adicionar_maquina_maas_8.png)

Este erro indica que há um problema de conexão entre o MAAS e seu servidor. Durante o comissionamento, o MAAS
baixa uma imagem efêmera de um SO (provavelmente ubuntu) para instalar na máquina a ser comissionada, entretanto,
como ele não consegue acesso a este servidor, ele não pode baixá-la.
Este problema é um pouco mais abrangente, e pode ter muitas causas. No geral, deve-se investigar a rede e 
procurar o motivo dessa falta de acesso.

Em nosso caso, o problema ocorreu por uma questão de DNS: poucos dias antes deste problema fizemos alterações
nas configurações de rede do _controller_ e nossa configuração nova de rede não apresentava um nameserver.

Resolvendo este problema o comissionamento passou desta fase de "powering on" para "loading ephemeral" e, 
posteriormente, o comissionamento foi concluído tínhamos a máquina funcionando. 

É importante notar que, neste último caso, apesar do MAAS ficar preso em "powering on", o problema não era em ligar a
máquina, e sim para baixar o SO, que era somente a próxima etapa do comissionamento.

Deste modo, é relevante saber os passos do comissionamento, visto que, se há um erro uma etapa, o problema pode ser na 
transição para a próxima etapa:
1. Powering on - Fase de ligar fisicamente a máquina
2. Performing PXE boot - Fase de bootar a máquina via PXE, ou seja, pela rede
3. Loading ephemeral - Fase de carregamento de um SO "efêmero", ou seja, um SO que não vai ser instalado de fato na máquina.
É usado somente para que o maas possa fazer o comissionamento.
4. Gathering information - Fase que o MAAS coleta informações sobre a máquina, como processamento, armazenamento e rede

Após isso, a máquina etrará no estado de ready, pronta para ser alocada pelo usuário ou pelo JUJU.
## Conclusões
Estes foram os erros documentados até agora. Caso um erro diferente apareça, sinta-se a vontade para adicionar mais uma etapa neste troubleshooting

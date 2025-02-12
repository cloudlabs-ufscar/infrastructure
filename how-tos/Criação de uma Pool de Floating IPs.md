# Criação de uma Pool de Floating IPs
## Um pouco de Teoria
Antes de começarmos é importante termos alguns conceitos em mente
### O que é um floating IP?
Floating IP é um IP externo ao OpenStack (público ou local do cluster) que pode ser alocado para instâncias terem\
tráfego externo ao OpenStack.
### O que é uma "pool"?
No contexto de "infra", pool se refere a um conjunto de recursos que estão disponíveis para serem alocados sob \
demanda. Por exemplo, se temos uma pool de processadores, significa que temos um conjunto de processadores que \
podem ser alocados para serem usados. assim que precisarem.\
No geral, alocations pools criam um ambiente mais flexível, permitindo que aplicações, serviços e clientes possam \
"pegar" recursos sob demanda e devolver quando não são mais necessários. 
### O que é uma floating IP pool?
Juntado os dois conceitos, uma pool de floating IPs é um conjunto de IPs, locais ou públicos, que estão disponíveis\
para serem alocados e desalocados livremente por instâncias da cloud para que elas possam mandar e receber pacotes\
para fora da cloud. \
Este modelo é usado em clouds para dar mais flexibilidade ao uso de recursos, pois nem toda instância lançada vai \
precisar de um IP acessível de fora da cloud. Por exemplo, pense que em uma cloud é lançado um serviço web composto \
por um serviço de banco de dados, um backend e um frontend. A comunicação entre os três serviços é feita dentro da \
rede interna da cloud. Somente o frontend precisa de um IP acessível para fora. Desta maneira, alocamos um IP \
flutuante para a VM ou container deste serviço, de modo que ele fica acessível para fora.
### Como as pool são implementadas no OpenStack?
No OpenStack, uma pool de floating IPs é criada mapeando IPs do cluster (públicos ou locais) para uma rede interna.\
Isso é feito através da criação de um switch virtual (do próprio OpenStack) que terá como gateway a rede externa. \
Deste modo, podemos 

## Conferindo as configurações
Este tutorial só faz sentido se tivermos uma [rede física configurada adequadamente](https://github.com/Pesquisa-Cloud-UFSCar/Infra/blob/FloatingIP-pool/how_to/Configura%C3%A7%C3%A3o%20de%20uma%20Nova%20Rede%20F%C3%ADsica%20no%20OpenStack.md) e\
com uma [rede provider funcionando perfeitamente no OpenStack](https://github.com/Pesquisa-Cloud-UFSCar/Infra/blob/FloatingIP-pool/how_to/Cria%C3%A7%C3%A3o%20de%20Provider%20Networks%20no%20OpenStack.md)\
CONTINUE

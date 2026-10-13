---
description: "Perguntas frequentes sobre o Submarine, o gestor de palavras-passe sem conta: chave perdida, servidor em baixo, uso offline, partilha de um cofre e preço."
---

# Perguntas e respostas

## E se eu perder a chave do meu cofre?

Ninguém a consegue recuperar, nem mesmo nós: não há conta nem link para a repor. Se o Submarine ainda estiver aberto num dos seus dispositivos, copie a chave nas definições do cofre e guarde-a num local seguro. Caso contrário, o cofre não poderá voltar a ser aberto.

## E se um servidor encerrar?

Cada cofre é copiado para vários relays, e cada um dos seus dispositivos guarda a sua própria cópia. Se um relay for abaixo, os outros continuam a ter o seu cofre. Pode adicionar ou remover relays nas definições do cofre, em Sincronização.

## Quem gere os servidores?

Os relays Nostr são geridos por operadores independentes, para todas as aplicações que usam o Nostr, e não apenas para o Submarine. Só veem dados encriptados. Também pode alojar o seu próprio relay e adicioná-lo ao seu cofre.

## O Submarine funciona offline?

Sim. Cada alteração é guardada primeiro no seu dispositivo e sincronizada assim que voltar a estar online. O Submarine mostra quantas alterações ainda aguardam envio.

## Posso usá-lo em vários dispositivos?

Sim: no Android, no Windows, no macOS e no Linux, e na web para todos os outros dispositivos. Abra o seu cofre em cada um deles com a mesma chave. [Transferir o Submarine](/pt/download).

## Posso partilhar um cofre?

Sim. Dê a chave do cofre à pessoa com quem o partilha: quem a tiver pode abrir e alterar o cofre. Uma chave não pode ser retirada depois de dada, por isso guarde as palavras-passe partilhadas num cofre só para elas, separadas das suas palavras-passe pessoais.

## E se eu editar o mesmo item em dois dispositivos ao mesmo tempo?

As duas edições são mantidas. O Submarine nunca substitui uma pela outra sem avisar.

## O Submarine é gratuito?

Sim. Não há nada a pagar, nenhuma versão premium nem anúncios. O Submarine é de código aberto, sob a licença MIT.

## Em que é diferente de outros gestores de palavras-passe?

Na maioria dos gestores de palavras-passe, o seu cofre fica nos servidores da empresa que os desenvolve, por trás de uma conta. O Submarine não tem conta nem servidor próprio: o seu cofre é copiado para servidores abertos que é você que escolhe, e só a sua chave o abre. A contrapartida é que ninguém consegue recuperar uma chave perdida. O Submarine é também mais recente e ainda não foi auditado.

## Posso importar as minhas palavras-passe?

Sim, do Bitwarden, e da maioria dos outros gestores de palavras-passe através do Bitwarden. [Importar do Bitwarden](/pt/import-bitwarden). Pode exportar os seus cofres a qualquer momento, num formato que outros gestores de palavras-passe conseguem importar.

## O Submarine é seguro?

O seu cofre é encriptado nos seus dispositivos, e os servidores só veem dados encriptados. No entanto, nenhuma empresa independente auditou ainda o Submarine. [Como o Submarine protege as suas palavras-passe](/pt/security).

## O que é o Nostr?

Um protocolo aberto para trocar dados através de relays: servidores que qualquer pessoa pode alojar. O Submarine usa-o para sincronizar o seu cofre sem uma empresa pelo meio. Não precisa de conhecer o Nostr, nem de ter uma conta Nostr, para usar o Submarine.

## Como comunico um problema?

[Comunique-o no GitHub](https://github.com/nogringo/submarine/issues) ou [contacte-nos no Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).

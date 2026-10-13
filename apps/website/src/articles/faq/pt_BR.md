---
description: "Respostas às dúvidas mais comuns sobre o Submarine, o gerenciador de senhas sem conta: chave perdida, servidor fora do ar, uso offline, cofre compartilhado e preço."
---

# Perguntas e respostas

## E se eu perder a chave do cofre?

Ninguém consegue recuperá-la, nem mesmo nós: não existe conta nem link de redefinição. Se o Submarine ainda estiver aberto em um dos seus dispositivos, copie a chave nas configurações do cofre e guarde-a em um lugar seguro. Caso contrário, o cofre não poderá mais ser aberto.

## E se um servidor sair do ar?

Cada cofre é copiado em vários relays, e cada um dos seus dispositivos guarda sua própria cópia. Se um relay sair do ar, os outros continuam com seu cofre. Você pode adicionar ou remover relays nas configurações do cofre, em Sincronização.

## Quem mantém os servidores?

Os relays Nostr são mantidos por operadores independentes, para todos os apps que usam Nostr, não só para o Submarine. Eles só veem dados criptografados. Você também pode manter seu próprio relay e adicioná-lo ao seu cofre.

## O Submarine funciona offline?

Sim. Cada alteração é salva primeiro no seu dispositivo e sincronizada assim que você volta a ficar online. O Submarine mostra quantas alterações ainda aguardam envio.

## Posso usá-lo em vários dispositivos?

Sim: no Android, Windows, macOS e Linux, e na web para qualquer outro dispositivo. Abra seu cofre em cada um deles com a mesma chave. [Baixe o Submarine](/pt-br/download).

## Posso compartilhar um cofre?

Sim. Dê a chave do cofre à pessoa com quem você quer compartilhá-lo: quem tem a chave pode abrir e alterar o cofre. Uma chave entregue não pode ser tomada de volta, então guarde as senhas compartilhadas em um cofre só para elas, separado das suas senhas pessoais.

## E se eu editar o mesmo item em dois dispositivos ao mesmo tempo?

As duas edições são mantidas. O Submarine nunca substitui uma pela outra sem avisar.

## O Submarine é gratuito?

Sim. Não há nada para pagar, nenhuma versão premium e nenhum anúncio. O Submarine é de código aberto, sob a licença MIT.

## Qual a diferença para outros gerenciadores de senhas?

Na maioria dos gerenciadores de senhas, seu cofre fica nos servidores da empresa que os desenvolve, protegido por uma conta. O Submarine não tem conta nem servidor próprio: seu cofre é copiado em servidores abertos que você escolhe, e só a sua chave o abre. O outro lado disso é que ninguém consegue recuperar uma chave perdida. O Submarine também é mais novo e ainda não foi auditado.

## Posso importar minhas senhas?

Sim, do Bitwarden, e da maioria dos outros gerenciadores de senhas por meio do Bitwarden. [Importar do Bitwarden](/pt-br/import-bitwarden). Você pode exportar seus cofres a qualquer momento, em um formato que outros gerenciadores de senhas conseguem importar.

## O Submarine é seguro?

Seu cofre é criptografado nos seus dispositivos, e os servidores só veem dados criptografados. Mas nenhuma empresa independente auditou o Submarine ainda. [Como o Submarine protege suas senhas](/pt-br/security).

## O que é Nostr?

Um protocolo aberto para trocar dados por meio de relays: servidores que qualquer pessoa pode manter. O Submarine o usa para sincronizar seu cofre sem uma empresa no meio do caminho. Você não precisa conhecer o Nostr, nem ter uma conta Nostr, para usar o Submarine.

## Como relato um problema?

[Relate no GitHub](https://github.com/nogringo/submarine/issues) ou [fale conosco no Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).

---
description: "Como o Submarine protege as suas palavras-passe: encriptadas nos seus dispositivos, em servidores abertos que só veem dados encriptados, e só a sua chave as abre."
---

# Como o Submarine protege as suas palavras-passe

O Submarine encripta o seu cofre nos seus dispositivos, antes de qualquer dado sair deles. Os servidores que o guardam só veem dados encriptados, e não existe nenhuma conta nem nenhum servidor do Submarine pelo meio. Esta página explica o que está protegido, como, e o que ainda falta fazer.

## A chave do seu cofre

Cada cofre tem a sua própria chave, gerada no seu dispositivo quando cria o cofre. Quem tiver esta chave pode abrir o cofre, e mais ninguém pode: nem os servidores, nem nós.

- O Submarine mostra-lhe a chave quando cria o cofre. Guarde-a num local seguro, por exemplo em papel ou num gestor de palavras-passe que já utilize.
- Também a pode guardar encriptada com uma palavra-passe à sua escolha. Nesse caso, precisa da chave encriptada e da respetiva palavra-passe para abrir o cofre.
- Ninguém consegue recuperar uma chave perdida. Não há conta nem link para a repor, por isso guarde uma cópia da chave, ou da chave encriptada e da respetiva palavra-passe.

## Nos seus dispositivos

- Os seus cofres são encriptados em cada dispositivo, com uma chave própria desse dispositivo.
- A sua palavra-passe de bloqueio protege essa chave. O Submarine transforma-a numa chave com o Argon2id, um método concebido para tornar lento e dispendioso adivinhar palavras-passe. Uma palavra-passe de bloqueio esquecida também não pode ser recuperada: nesse caso, volta a abrir os seus cofres com as respetivas chaves.
- A sua impressão digital, o seu rosto ou o bloqueio de ecrã podem desbloquear o Submarine em vez da palavra-passe de bloqueio.
- O Submarine bloqueia-se sozinho ao fim do tempo que escolher, desde imediatamente até algumas horas, e apaga os seus cofres da memória quando se bloqueia.
- As palavras-passe copiadas são apagadas da área de transferência ao fim do tempo que escolher.
- No Android, as capturas e gravações de ecrã do Submarine são bloqueadas, a menos que as permita.

## Nos servidores

Os seus cofres ficam em relays Nostr: servidores abertos geridos por operadores independentes, que qualquer pessoa pode usar ou alojar. Cada cofre é copiado para vários relays, por isso sobrevive se um deles for abaixo, e é você que escolhe os relays que o guardam, incluindo os seus.

Cada alteração que faz é encriptada no seu dispositivo e enviada para os relays num envelope selado. Um relay vê:

- dados encriptados que não consegue ler,
- a chave pública do cofre, que lhe indica que envelopes vão juntos, mas não o que contêm,
- uma data escolhida ao acaso nos dois dias anteriores à alteração, em vez da hora da alteração,
- o seu endereço IP, tal como qualquer site que visita.

Um relay também não pode alterar as suas palavras-passe. Cada alteração é assinada com a chave do cofre, e o Submarine ignora tudo o que o cofre não tenha assinado.

## Sem conta, sem rastreio

- Não existe conta do Submarine, e nenhum servidor do Submarine guarda os seus dados.
- O Submarine não tem estatísticas de utilização, relatórios de falhas nem anúncios.
- O código é aberto, sob a licença MIT, por isso qualquer pessoa pode verificar o que o Submarine faz. [Ver o código-fonte](https://github.com/nogringo/submarine).

## O que ainda falta

Nenhuma empresa independente auditou ainda a segurança do Submarine. Até isso acontecer, guarde as suas palavras-passe mais críticas, como as do email e do banco, num gestor de palavras-passe com provas dadas e comece pelas restantes.

Se encontrar um problema de segurança, [comunique-o](https://github.com/nogringo/submarine/issues) ou [contacte-nos no Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).

## Detalhes técnicos

O formato completo está descrito no [protocolo Nostr Passwords](https://openspecs.uid.ovh/spec/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te/nostr-passwords).

- Um cofre é um par de chaves Nostr. A sua chave é apresentada como uma `nsec`, e a sua forma encriptada é uma `ncryptsec` NIP-49 (scrypt, seguido de XChaCha20-Poly1305).
- Cada alteração é uma nova versão do item: um evento assinado pelo cofre, encriptado para o cofre com NIP-44 (ChaCha20 e HMAC-SHA256, com preenchimento para esconder o tamanho exato) e colocado num gift wrap NIP-59, assinado por uma chave de utilização única e datado ao acaso nos dois dias anteriores.
- Os itens são itens do Bitwarden, e é por isso que o Submarine importa e exporta o formato do Bitwarden.
- Num dispositivo, as chaves dos cofres são encriptadas com AES-256-CBC e HMAC-SHA256 com uma chave do dispositivo. Essa chave é protegida pela palavra-passe de bloqueio através do Argon2id, ou guardada no armazenamento seguro do sistema. A cópia local dos cofres é encriptada com AES-256-GCM.
- Se usa o Nostr, um assinante pode guardar a chave do cofre para que ela nunca entre no Submarine: um bunker (NIP-46), uma aplicação de assinatura como o Amber (NIP-55) ou uma extensão do navegador (NIP-07).

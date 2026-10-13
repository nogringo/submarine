---
description: "Como o Submarine protege suas senhas: criptografia nos seus dispositivos, servidores abertos que só veem dados criptografados e uma chave que só você tem."
---

# Como o Submarine protege suas senhas

O Submarine criptografa seu cofre nos seus dispositivos, antes que qualquer coisa saia deles. Os servidores que o guardam só veem dados criptografados, e não existe conta do Submarine nem servidor do Submarine no meio do caminho. Esta página explica o que é protegido, como, e o que ainda não foi feito.

## A chave do cofre

Cada cofre tem sua própria chave, criada no seu dispositivo quando você cria o cofre. Quem tem essa chave consegue abrir o cofre, e mais ninguém consegue: nem os servidores, nem nós.

- O Submarine mostra a chave quando você cria o cofre. Guarde-a em um lugar seguro, como no papel ou em um gerenciador de senhas que você já usa.
- Você também pode guardá-la criptografada com uma senha à sua escolha. Aí, para abrir o cofre, você precisa ao mesmo tempo da chave criptografada e da senha dela.
- Ninguém consegue recuperar uma chave perdida. Não existe conta nem link de redefinição, então guarde uma cópia da chave, ou da chave criptografada e da senha dela.

## Nos seus dispositivos

- Seus cofres são criptografados em cada dispositivo, com uma chave desse dispositivo.
- Sua senha de bloqueio protege essa chave. O Submarine a transforma em uma chave com o Argon2id, um método feito para deixar a adivinhação de senhas lenta e cara. Uma senha de bloqueio esquecida também não pode ser recuperada: nesse caso, você abre seus cofres de novo com as chaves deles.
- Sua digital, seu rosto ou o bloqueio de tela podem desbloquear o Submarine no lugar da senha de bloqueio.
- O Submarine se bloqueia sozinho depois de um tempo que você escolhe, de imediatamente até algumas horas, e apaga seus cofres da memória ao bloquear.
- As senhas copiadas são apagadas da área de transferência depois de um tempo que você escolhe.
- No Android, capturas de tela e gravações de tela do Submarine são bloqueadas, a menos que você as permita.

## Nos servidores

Seus cofres ficam em relays Nostr: servidores abertos mantidos por operadores independentes, que qualquer pessoa pode usar ou manter. Cada cofre é copiado em vários relays, então ele continua disponível se um deles sair do ar, e é você quem escolhe quais relays o guardam, inclusive os seus.

Cada alteração que você faz é criptografada no seu dispositivo e enviada aos relays em um envelope lacrado. Um relay vê:

- dados criptografados que ele não consegue ler,
- a chave pública do cofre, que indica quais envelopes andam juntos, mas não o que eles contêm,
- uma data sorteada nos dois dias anteriores à alteração, em vez do momento real da alteração,
- seu endereço IP, como qualquer site que você visita.

Um relay também não consegue alterar suas senhas. Cada alteração é assinada com a chave do cofre, e o Submarine ignora tudo o que o cofre não assinou.

## Sem conta, sem rastreamento

- Não existe conta do Submarine, e nenhum servidor do Submarine guarda seus dados.
- O Submarine não tem análises de uso, relatórios de falhas nem anúncios.
- O código é aberto, sob a licença MIT, então qualquer pessoa pode verificar o que o Submarine faz. [Veja o código-fonte](https://github.com/nogringo/submarine).

## O que ainda falta

Nenhuma empresa independente auditou ainda a segurança do Submarine. Até que isso aconteça, mantenha suas senhas mais importantes, como as do e-mail e do banco, em um gerenciador de senhas com um histórico mais longo, e comece pelas outras.

Se você encontrar um problema de segurança, [relate-o](https://github.com/nogringo/submarine/issues) ou [fale conosco no Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).

## Detalhes técnicos

O formato completo está descrito no [protocolo Nostr Passwords](https://openspecs.uid.ovh/spec/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te/nostr-passwords).

- Um cofre é um par de chaves Nostr. A chave dele aparece como um `nsec`, e a forma criptografada dela é um `ncryptsec` da NIP-49 (scrypt, depois XChaCha20-Poly1305).
- Cada alteração é uma nova versão do item: um evento assinado pelo cofre, criptografado para o cofre com a NIP-44 (ChaCha20 e HMAC-SHA256, com preenchimento para esconder o tamanho exato) e colocado em um gift wrap da NIP-59, assinado por uma chave de uso único e com data sorteada nos dois dias anteriores.
- Os itens são itens do Bitwarden, e é por isso que o Submarine importa e exporta o formato do Bitwarden.
- Em um dispositivo, as chaves dos cofres são criptografadas com AES-256-CBC e HMAC-SHA256 por uma chave do dispositivo. Essa chave é protegida pela senha de bloqueio por meio do Argon2id, ou guardada no armazenamento seguro do sistema. A cópia local dos cofres é criptografada com AES-256-GCM.
- Se você usa Nostr, um assinante pode guardar a chave do cofre para que ela nunca entre no Submarine: um assinante remoto (NIP-46), um app de assinatura como o Amber (NIP-55) ou uma extensão do navegador (NIP-07).

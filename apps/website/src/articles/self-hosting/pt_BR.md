---
description: "Guarde uma cópia dos seus cofres, e dos cofres das pessoas próximas, em servidores que você mantém: um relay Nostr para os cofres e um servidor de arquivos para os anexos deles."
---

# Mantenha servidores para você e as pessoas próximas

O Submarine não tem servidor próprio: por padrão, seus cofres são copiados em relays Nostr públicos, mantidos por operadores independentes. Você pode adicionar servidores mantidos por você, ou por alguém de confiança: assim uma cópia do seu cofre fica com pessoas que você conhece.

## Para você e as pessoas próximas

Um só servidor pode guardar os cofres de todo mundo ao seu redor: passe o endereço dele para essas pessoas, e elas o adicionam aos cofres delas como no passo 3.

- Se você desligar seu servidor, elas não perdem nada: os cofres delas continuam nos outros relays e em cada um dos dispositivos delas.
- Seu servidor só vê dados criptografados: ele não consegue ler nem alterar as senhas delas. Como qualquer relay, ele vê o endereço IP delas.
- Se um amigo também mantiver um servidor, adicionem o servidor um do outro: cada um guarda uma cópia para o outro.

## Do que você precisa

- Uma máquina acessível pela internet, como um servidor alugado ou um computador na sua casa.
- Um nome de domínio que aponte para ela, com HTTPS.
- Docker, para instalar os dois servidores abaixo.

## 1. Instale um relay

Instale o [nostr-relay](https://github.com/nogringo/nostr-relay) seguindo as instruções dele. Ao contrário da maioria dos relays, ele só entrega os dados de um cofre para quem tem a chave do cofre, e deixa você excluí-los.

Coloque na frente dele um proxy HTTPS que repasse o cabeçalho Host original: o relay precisa dele para verificar que o Submarine tem a chave do cofre.

O endereço dele começa com `wss://`, por exemplo `wss://relay.example.com`.

## 2. Instale um servidor de arquivos

Os arquivos anexados aos seus itens ficam em servidores de arquivos, não nos relays. Para ter também uma cópia deles, instale o [blossom-server](https://github.com/hzrd149/blossom-server) seguindo as instruções dele.

No arquivo de configuração, adicione esta regra no início das regras de `storage`:

```yaml
- type: application/octet-stream
  expiration: 100 years
```

Assim, os arquivos criptografados do Submarine ficam guardados. Sem essa regra, a configuração de exemplo exclui qualquer arquivo que ninguém tenha aberto em uma semana.

O endereço dele começa com `https://`, por exemplo `https://blossom.example.com`.

## 3. Adicione-os ao seu cofre

1. Abra as configurações do cofre e, em **Sincronização**, abra **Relays**.
2. Aperte **Adicionar relay**, digite o endereço do seu relay, ative **Manter privado** e aperte **Adicionar**.
3. Aperte **Salvar**.
4. De volta às configurações do cofre, abra **Servidores de arquivos** e adicione seu servidor de arquivos do mesmo jeito, com **Adicionar servidor**.

Repita para cada um dos seus cofres. **Manter privado** criptografa o endereço no cofre: senão, qualquer pessoa poderia ver que este cofre fica no seu servidor, e adivinhar de quem ele é.

## Mantenha alguns relays públicos

Mantenha alguns relays públicos junto com o seu: se o seu servidor sair do ar ou perder os dados, seu cofre continua neles. Além disso, cada um dos seus dispositivos guarda sua própria cópia.

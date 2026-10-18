---
description: "Guarde uma cópia dos seus cofres em servidores que você mesmo mantém: um relay Nostr para seus cofres e um servidor de arquivos para os anexos deles."
---

# Mantenha seus próprios servidores

O Submarine não tem servidor próprio: por padrão, seus cofres são copiados em relays Nostr públicos, mantidos por operadores independentes. Adicione servidores que você mesmo mantém, e uma cópia do seu cofre fica neles pelo tempo que você decidir.

## Do que você precisa

- Uma máquina acessível pela internet, como um servidor alugado ou um computador na sua casa.
- Um nome de domínio que aponte para ela, com HTTPS.
- Docker, para instalar os dois servidores abaixo.

## 1. Instale um relay

Instale o [nostr-relay](https://github.com/nogringo/nostr-relay) seguindo as instruções dele. Ao contrário da maioria dos relays, ele só entrega os dados de um cofre para quem tem a chave do cofre, e deixa você excluí-los.

Coloque na frente dele um proxy HTTPS que repasse o cabeçalho Host original: o relay precisa dele para verificar que o Submarine tem a chave do cofre.

O endereço dele começa com `wss://`, por exemplo `wss://relay.example.com`.

## 2. Instale um servidor de arquivos

Os arquivos anexados aos seus itens ficam em servidores de arquivos, não nos relays. Para ter também sua própria cópia deles, instale o [blossom-server](https://github.com/hzrd149/blossom-server) seguindo as instruções dele.

No arquivo de configuração, defina `rules: []` dentro de `storage`. A configuração de exemplo exclui qualquer arquivo que ninguém tenha aberto em uma semana, o que excluiria seus anexos.

O endereço dele começa com `https://`, por exemplo `https://blossom.example.com`.

## 3. Adicione-os ao seu cofre

1. Abra as configurações do cofre e, em **Sincronização**, abra **Relays**.
2. Aperte **Adicionar relay**, digite o endereço do seu relay, ative **Manter privado** e aperte **Adicionar**.
3. Aperte **Salvar**.
4. De volta às configurações do cofre, abra **Servidores de arquivos** e adicione seu servidor de arquivos do mesmo jeito, com **Adicionar servidor**.

Repita para cada um dos seus cofres. **Manter privado** criptografa o endereço no cofre: senão, qualquer pessoa poderia ver que este cofre fica no seu servidor, e adivinhar de quem ele é.

## Mantenha alguns relays públicos

Mantenha alguns relays públicos junto com o seu: se o seu servidor sair do ar ou perder os dados, seu cofre continua neles. Além disso, cada um dos seus dispositivos guarda sua própria cópia.

---
description: "Guarde uma cópia dos seus cofres em servidores que aloja você mesmo: um relay Nostr para os seus cofres e um servidor de ficheiros para os anexos deles."
---

# Aloje os seus próprios servidores

O Submarine não tem servidor próprio: por predefinição, os seus cofres são copiados para relays Nostr públicos, geridos por operadores independentes. Adicione servidores que aloja você mesmo, e uma cópia do seu cofre fica neles durante o tempo que decidir.

## O que precisa

- Uma máquina acessível a partir da internet, como um servidor alugado ou um computador em casa.
- Um nome de domínio que aponte para ela, com HTTPS.
- Docker, para instalar os dois servidores abaixo.

## 1. Instale um relay

Instale o [nostr-relay](https://github.com/nogringo/nostr-relay) seguindo as instruções dele. Ao contrário da maioria dos relays, só entrega os dados de um cofre a quem tem a chave do cofre, e deixa-o apagá-los.

Coloque à frente dele um proxy HTTPS que reencaminhe o cabeçalho Host original: o relay precisa dele para verificar que o Submarine tem a chave do cofre.

O endereço dele começa por `wss://`, por exemplo `wss://relay.example.com`.

## 2. Instale um servidor de ficheiros

Os ficheiros anexados aos seus itens são guardados em servidores de ficheiros, não nos relays. Para ter também a sua própria cópia deles, instale o [blossom-server](https://github.com/hzrd149/blossom-server) seguindo as instruções dele.

No ficheiro de configuração, defina `rules: []` em `storage`. A configuração de exemplo apaga qualquer ficheiro que ninguém tenha aberto durante uma semana, o que apagaria os seus anexos.

O endereço dele começa por `https://`, por exemplo `https://blossom.example.com`.

## 3. Adicione-os ao seu cofre

1. Abra as definições do cofre e, em **Sincronização**, abra **Relays**.
2. Carregue em **Adicionar um relay**, introduza o endereço do seu relay, ative **Manter privado** e carregue em **Adicionar**.
3. Carregue em **Guardar**.
4. De volta às definições do cofre, abra **Servidores de ficheiros** e adicione o seu servidor de ficheiros da mesma forma, com **Adicionar um servidor**.

Repita para cada um dos seus cofres. **Manter privado** encripta o endereço no cofre: caso contrário, qualquer pessoa poderia ver que este cofre está guardado no seu servidor, e adivinhar de quem é.

## Mantenha alguns relays públicos

Mantenha alguns relays públicos ao lado do seu: se o seu servidor for abaixo ou perder os dados, o seu cofre continua neles. Além disso, cada um dos seus dispositivos guarda a sua própria cópia.

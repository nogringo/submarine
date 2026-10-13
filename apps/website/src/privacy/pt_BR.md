# Política de privacidade da extensão do Submarine para navegador

Última atualização: 12 de outubro de 2026.

O Submarine é um gerenciador de senhas. A extensão para navegador mostra as senhas, os cartões e as anotações dos seus cofres, permite criar e editar esses itens, copia os dados para você e preenche suas credenciais nos sites. Esta política explica o que a extensão faz com seus dados. Em resumo: não existe nenhum servidor do Submarine, e a extensão não envia nada para os desenvolvedores dela.

## O que fica no seu navegador

- A chave de cada cofre que você abre, com o nome e a cor que você dá a ele. Esses dados são criptografados com uma chave deste navegador, que por sua vez é protegida pela sua senha de bloqueio, a partir do momento em que você define uma.
- Uma cópia do conteúdo dos seus cofres, para que eles abram sem esperar pela rede. Ela também é criptografada.
- Suas configurações: o tempo até o bloqueio, o tempo até limpar a área de transferência e as opções do gerador de senhas.
- Um formulário que você deixa sem salvar, para que ele apareça de novo quando você reabrir a extensão. Ele fica na memória do navegador, nunca no disco, e some assim que você o salva ou descarta, bloqueia a extensão ou fecha o navegador.

Remover um cofre da extensão apaga do seu navegador a chave e a cópia desse cofre. Desinstalar a extensão apaga tudo o que ela guardou.

## O que sai do seu navegador

Seus cofres ficam em relays Nostr: servidores mantidos por operadores independentes, que guardam dados de qualquer pessoa. Seus itens são criptografados nos seus dispositivos antes de chegar a um relay, então os relays só guardam dados que não conseguem ler.

Para baixar seus cofres, a extensão se conecta aos relays deles: os relays que cada cofre indica, ou então os [relays padrão](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) do Submarine, e três relays de diretório onde a lista de relays de cada cofre é publicada. Cada relay vê seu endereço IP, como qualquer site que você visita, e a chave pública de cada cofre que você abre, com a qual a extensão se autentica e pede os dados desse cofre.

Quando você cria, edita, marca como favorito, move para a lixeira ou restaura um item, a extensão criptografa a nova versão dele no seu dispositivo e a envia para os relays do cofre. Quando você exclui um item permanentemente, ela pede a esses relays que excluam cada uma das versões dele. Uma alteração que nenhum relay aceitou ainda fica aguardando na cópia criptografada no seu navegador e é enviada de novo na próxima vez que você abrir a extensão ou apertar o botão de sincronização.

O gerador de senhas funciona no seu navegador: o que ele gera só sai de lá dentro de um item que você salva.

Quando você pede para preencher uma credencial, pela janela da extensão ou com o atalho de teclado, a extensão escreve o nome de usuário e a senha no formulário de login da página atual, e só se o endereço da página corresponder à credencial. O site recebe esses dados quando você faz login, como quando você os digita.

## O que a extensão não faz

- Ela não tem conta nem servidor próprio: os desenvolvedores dela não recebem nenhum dado.
- Ela não tem análises de uso, rastreamento nem anúncios.
- Ela não lê nada das páginas que você visita, exceto os campos da página atual quando você pede para preencher uma credencial, para saber onde vão o nome de usuário e a senha. Quando você a abre, ela lê o endereço da aba atual para mostrar primeiro as credenciais desse site. Nenhuma dessas informações sai do seu navegador.
- Ela só escreve na área de transferência o que você copia e o código de verificação de uma credencial que ela preenche, e depois esvazia a área de transferência após o tempo escolhido nas configurações. Ela nunca lê a área de transferência.

## Permissões

- Armazenamento: guarda seus cofres e suas configurações no navegador, como descrito acima.
- Escrita na área de transferência: copia uma senha, um código ou qualquer outro campo quando você pede.
- Alarmes: bloqueia os cofres quando o tempo até o bloqueio termina.
- Aba ativa: dá à extensão acesso à aba sobre a qual você a abre ou em que usa o atalho, e só a ela: ao endereço, para mostrar primeiro as credenciais desse site, e à página, para preencher uma credencial quando você pede.
- Scripts: preenche uma credencial na página dessa aba quando você pede.
- Documentos fora da tela, só no Chrome: copia o código de verificação de uma credencial preenchida e esvazia a área de transferência quando o tempo definido termina, mesmo com a janela da extensão fechada.

## Alterações e contato

Esta política muda junto com a extensão. O histórico dela é o deste arquivo no [repositório do Submarine](https://github.com/nogringo/submarine). Para qualquer dúvida, abra uma [issue](https://github.com/nogringo/submarine/issues).

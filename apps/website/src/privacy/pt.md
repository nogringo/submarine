# Política de privacidade da extensão do Submarine para o navegador

Última atualização: 12 de outubro de 2026.

O Submarine é um gestor de palavras-passe. A extensão para o navegador mostra as palavras-passe, os cartões e as notas dos seus cofres, permite criá-los e editá-los, copia-os por si e preenche as suas credenciais nos sites. Esta política explica o que a extensão faz com os seus dados. Em resumo: não existe nenhum servidor do Submarine, e a extensão não envia nada aos seus programadores.

## O que fica no seu navegador

- A chave de cada cofre que abre, com o nome e a cor que lhe dá. Ficam encriptados com uma chave deste navegador, que por sua vez fica protegida pela sua palavra-passe de bloqueio, a partir do momento em que a definir.
- Uma cópia do conteúdo dos seus cofres, para que abram sem esperar pela rede. Também está encriptada.
- As suas definições: o tempo até ao bloqueio, o tempo até limpar a área de transferência e as opções do gerador de palavras-passe.
- Um formulário que deixe por guardar, para que volte a aparecer quando reabrir a extensão. Fica na memória do navegador, nunca no disco, e desaparece assim que o guardar ou descartar, bloquear a extensão ou fechar o navegador.

Remover um cofre da extensão apaga do seu navegador a chave e a cópia desse cofre. Desinstalar a extensão apaga tudo o que ela guardou.

## O que sai do seu navegador

Os seus cofres ficam em relays Nostr: servidores geridos por operadores independentes, que guardam dados de qualquer pessoa. Os seus itens são encriptados nos seus dispositivos antes de chegarem a um relay, por isso os relays só guardam dados que não conseguem ler.

Para transferir os seus cofres, a extensão liga-se aos relays deles: os relays indicados por cada cofre, ou então os [relays predefinidos](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) do Submarine, e três relays de diretório onde é publicada a lista de relays de cada cofre. Cada relay vê o seu endereço IP, tal como qualquer site que visita, e a chave pública de cada cofre que abre, com a qual a extensão inicia sessão e pede os dados desse cofre.

Quando cria, edita, marca como favorito, move para o lixo ou restaura um item, a extensão encripta a nova versão no seu dispositivo e envia-a para os relays do respetivo cofre. Quando elimina um item permanentemente, pede a esses relays que eliminem cada uma das suas versões. Uma alteração que ainda nenhum relay aceitou fica à espera na cópia encriptada do seu navegador e volta a ser enviada da próxima vez que abrir a extensão ou carregar no botão de sincronização.

O gerador de palavras-passe funciona no seu navegador: o que ele gera só sai de lá dentro de um item que guarde.

Quando lhe pede para preencher uma credencial, a partir da janela da extensão ou com o atalho de teclado, a extensão escreve o nome de utilizador e a palavra-passe no formulário de início de sessão da página atual, e só se o endereço da página corresponder à credencial. O site recebe-os quando inicia sessão, tal como quando os escreve.

## O que a extensão não faz

- Não tem conta nem servidor próprio: os seus programadores não recebem dela nenhum dado.
- Não tem estatísticas de utilização, rastreio nem anúncios.
- Não lê nada das páginas que visita, exceto os campos da página atual quando lhe pede para preencher uma credencial, para saber onde vão o nome de utilizador e a palavra-passe. Quando a abre, lê o endereço do separador atual para mostrar primeiro as credenciais desse site. Nenhuma destas informações sai do seu navegador.
- Só escreve na área de transferência o que copia e o código de verificação de uma credencial que preenche, e depois esvazia a área de transferência após o tempo escolhido nas definições. Nunca lê a área de transferência.

## Permissões

- Armazenamento: guarda os seus cofres e as suas definições no navegador, como descrito acima.
- Escrita na área de transferência: copia uma palavra-passe, um código ou qualquer outro campo quando o pedir.
- Alarmes: bloqueia os cofres quando passa o tempo até ao bloqueio.
- Separador ativo: dá à extensão acesso ao separador sobre o qual a abre ou em que usa o atalho, e só a esse: ao endereço, para mostrar primeiro as credenciais desse site, e à página, para preencher uma credencial quando o pedir.
- Scripts: preenche uma credencial na página desse separador quando o pedir.
- Documentos fora do ecrã, só no Chrome: copia o código de verificação de uma credencial preenchida e esvazia a área de transferência quando passa o tempo definido, mesmo com a janela da extensão fechada.

## Alterações e contacto

Esta política muda com a extensão. O seu histórico é o deste ficheiro no [repositório do Submarine](https://github.com/nogringo/submarine). Para qualquer dúvida, abra uma [issue](https://github.com/nogringo/submarine/issues).

# Política de privacidade da extensão do Submarine para o navegador

Última atualização: 18 de outubro de 2026.

O Submarine é um gestor de palavras-passe. A extensão para o navegador mostra as palavras-passe, os cartões e as notas dos seus cofres, permite criá-los e editá-los, copia-os por si, preenche as suas credenciais nos sites e mostra os e-mails enviados para os endereços de e-mail que atribui às suas credenciais. Esta política explica o que a extensão faz com os seus dados. Em resumo: não existe nenhum servidor do Submarine, e a extensão não envia nada aos seus programadores.

## O que fica no seu navegador

- A chave de cada cofre que cria ou abre, com o nome e a cor que lhe dá. Ficam encriptados com uma chave deste navegador, que por sua vez fica protegida pela sua palavra-passe de bloqueio, a partir do momento em que a definir.
- Uma cópia do conteúdo dos seus cofres, para que abram sem esperar pela rede. Também está encriptada.
- As mensagens de um endereço de e-mail, tal como chegaram: encriptadas para a chave desse endereço. A extensão desencripta-as sempre que as mostra, e nunca as guarda desencriptadas.
- As suas definições: o tempo até ao bloqueio, o tempo até limpar a área de transferência, as opções do gerador de palavras-passe, e a ponte de e-mail, os relays e os servidores que os novos endereços de e-mail recebem.
- Um formulário que deixe por guardar, para que volte a aparecer quando reabrir a extensão. Fica na memória do navegador, nunca no disco, e desaparece assim que o guardar ou descartar, bloquear a extensão ou fechar o navegador.

Remover um cofre da extensão apaga do seu navegador a chave e a cópia desse cofre. Desinstalar a extensão apaga tudo o que ela guardou.

## O que sai do seu navegador

Os seus cofres ficam em relays Nostr: servidores geridos por operadores independentes, que guardam dados de qualquer pessoa. Os seus itens são encriptados nos seus dispositivos antes de chegarem a um relay, por isso os relays só guardam dados que não conseguem ler.

Para transferir os seus cofres, a extensão liga-se aos relays deles: os relays indicados por cada cofre, ou então os [relays predefinidos](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) do Submarine, e três relays de diretório onde é publicada a lista de relays de cada cofre. Cada relay vê o seu endereço IP, tal como qualquer site que visita, e a chave pública de cada cofre que abre, com a qual a extensão inicia sessão e pede os dados desse cofre.

Quando cria, edita, marca como favorito, move para o lixo ou restaura um item, a extensão encripta a nova versão no seu dispositivo e envia-a para os relays do respetivo cofre. Quando elimina um item permanentemente, pede a esses relays que eliminem cada uma das suas versões. Uma alteração que ainda nenhum relay aceitou fica à espera na cópia encriptada do seu navegador e volta a ser enviada da próxima vez que abrir a extensão ou carregar no botão de sincronização.

O gerador de palavras-passe funciona no seu navegador: o que ele gera só sai de lá dentro de um item que guarde.

Quando importa uma exportação do Bitwarden, a extensão lê no seu navegador o ficheiro que escolher e depois guarda os itens dele no cofre que indicar, como itens criados por si. Quando exporta um cofre, guarda o ficheiro no seu computador, encriptado com a palavra-passe que escolher, ou não encriptado, se desativar essa opção. O ficheiro não vai para mais lado nenhum.

Quando lhe pede para preencher uma credencial, a partir da janela da extensão ou com o atalho de teclado, a extensão escreve o nome de utilizador e a palavra-passe no formulário de início de sessão da página atual, e só se o endereço da página corresponder à credencial. O site recebe-os quando inicia sessão, tal como quando os escreve.

## Endereços de e-mail

Pode dar a uma credencial um endereço de e-mail próprio, como `npub1...@uid.ovh`, a partir do menu que adiciona um campo. A extensão cria uma chave nova para cada endereço, sem relação com os seus cofres, e guarda-a num campo oculto da credencial, encriptada com o resto do item. O domínio é o de uma ponte de e-mail, `uid.ovh` se não escolher outra nas definições: um servidor gerido por um operador independente, que recebe os e-mails enviados para o endereço, como qualquer servidor de e-mail, encripta-os para a chave do endereço e envia-os para os relays do endereço. A extensão nunca envia e-mails e nunca se liga à ponte.

Quando guarda uma credencial com um endereço de e-mail novo, a extensão publica três listas públicas assinadas com a chave do endereço, para que a ponte saiba onde entregar: a lista dos relays do endereço, enviada para esses relays e para os três relays de diretório; a dos relays onde chegam os e-mails do endereço; e a dos servidores que recebem os e-mails demasiado grandes para um relay. Estas listas indicam a chave, os relays e os servidores do endereço, nunca os seus cofres. Por predefinição, são os [relays e servidores de e-mail predefinidos](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) do Submarine; pode alterar nas definições os que os novos endereços recebem.

Enquanto uma credencial com um endereço de e-mail estiver aberta, a extensão liga-se aos relays desse endereço, encontrados nos relays de diretório, inicia sessão neles com a chave do endereço, transfere as últimas mensagens e recebe as novas até fechar a credencial. Cada relay vê o seu endereço IP e a chave pública do endereço. A extensão também recebe as mensagens privadas (NIP-17) enviadas para essa chave. Um e-mail demasiado grande para um relay é transferido, encriptado, quando o abre, a partir de um dos servidores do endereço ou da ponte, ou então dos servidores predefinidos do Submarine; esse servidor vê o seu endereço IP.

Quando guarda um e-mail, a extensão escreve a mensagem completa, incluindo os anexos, num ficheiro no seu computador. Quando elimina uma mensagem, pede aos relays do endereço que a eliminem. Eliminar uma credencial permanentemente não apaga dos relays as mensagens dela. Uma ligação numa mensagem só se abre num novo separador depois de a confirmar, quando a extensão já lhe mostrou para onde leva.

## O que a extensão não faz

- Não tem conta nem servidor próprio: os seus programadores não recebem dela nenhum dado.
- Nunca envia e-mails, e nunca mostra as imagens nem outros conteúdos que um e-mail carregaria da Internet: mostra os e-mails em texto simples.
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

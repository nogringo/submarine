---
description: Passe as suas palavras-passe do Bitwarden para o Submarine em minutos, com campos personalizados e códigos de dois fatores, e retire-as quando quiser.
---

# Importe as suas palavras-passe do Bitwarden

O Submarine lê o ficheiro de exportação do Bitwarden, por isso passar as suas palavras-passe para cá demora poucos minutos. Nada muda na sua conta Bitwarden: a importação apenas copia os seus itens.

## 1. Exporte o seu cofre do Bitwarden

1. No cofre web do Bitwarden, abra Ferramentas e depois Exportar cofre. As aplicações do Bitwarden têm o mesmo comando nas definições ou nos menus.
2. Escolha o formato .json. Também pode escolher o formato .json encriptado, protegido por uma palavra-passe à sua escolha: o Submarine também o abre.
3. Confirme com a sua palavra-passe mestra do Bitwarden e guarde o ficheiro.

Uma exportação encriptada restrita à sua conta Bitwarden não funciona: só o Bitwarden a consegue abrir. Escolha antes o tipo protegido por palavra-passe.

## 2. Importe o ficheiro para o Submarine

1. Abra o Submarine e crie ou abra o cofre para onde devem ir as suas palavras-passe.
2. Vá a **Definições**, depois a **Importar e exportar**, e carregue em **Importar** ao lado de **Importar do Bitwarden**.
3. Escolha o ficheiro. Se estiver protegido por uma palavra-passe, introduza-a.
4. Verifique quantos itens foram encontrados, escolha o cofre se tiver vários e carregue em **Importar**.

Os seus itens são encriptados no seu dispositivo e depois sincronizados com os seus outros dispositivos, como qualquer outra alteração.

## 3. Elimine o ficheiro de exportação

Uma exportação .json sem palavra-passe não está encriptada: quem a obtiver pode ler todas as suas palavras-passe. Elimine-a assim que a importação terminar e esvazie o lixo do seu computador. Não a envie por e-mail.

## O que é importado

- Credenciais, cartões, notas seguras, identidades, chaves SSH e os outros tipos de itens do Bitwarden, com os respetivos campos personalizados e códigos de autenticação de dois fatores.
- As credenciais, os cartões e as notas seguras podem ser editados no Submarine. Os outros tipos são guardados e apresentados, mas ainda não podem ser editados.
- As chaves de acesso são guardadas e apresentadas, mas o Submarine ainda não consegue iniciar sessão com elas.
- As pastas não são importadas: em vez disso, o Submarine separa os itens por cofre.
- Os ficheiros anexados não fazem parte da exportação do Bitwarden, por isso ficam no Bitwarden.

## Se vem de outro gestor de palavras-passe

O Submarine só lê o formato do Bitwarden. O próprio Bitwarden importa da maioria dos gestores de palavras-passe, como o 1Password, o LastPass, o KeePass ou o seu navegador. Com uma conta gratuita do Bitwarden, importe primeiro as suas palavras-passe para lá e depois siga os passos acima.

## Sair do Submarine

O Submarine exporta no mesmo formato. Em **Definições**, depois **Importar e exportar**, **Exportar um cofre** guarda um ficheiro do Bitwarden, protegido por palavra-passe ou não encriptado, que o Bitwarden e outros gestores de palavras-passe conseguem importar. O lixo não é incluído.

É novo no Submarine? [Transfira-o](/pt/download) ou leia [como protege as suas palavras-passe](/pt/security).

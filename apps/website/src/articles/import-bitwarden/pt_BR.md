---
description: Leve suas senhas do Bitwarden para o Submarine em poucos minutos, com os campos personalizados e os códigos de dois fatores, e exporte-as de volta quando quiser.
---

# Importe suas senhas do Bitwarden

O Submarine lê o arquivo de exportação do Bitwarden, então trazer suas senhas é questão de poucos minutos. Nada muda na sua conta do Bitwarden: a importação só copia seus itens.

## 1. Exporte seu cofre do Bitwarden

1. No cofre web do Bitwarden, abra Ferramentas e depois Exportar cofre. Os apps do Bitwarden têm o mesmo comando nas configurações ou nos menus.
2. Escolha o formato .json. Você também pode escolher o formato .json criptografado, protegido por uma senha à sua escolha: o Submarine também abre esse.
3. Confirme com sua senha mestra do Bitwarden e salve o arquivo.

Uma exportação criptografada restrita à sua conta do Bitwarden não funciona: só o Bitwarden consegue abri-la. Escolha o tipo protegido por senha.

## 2. Importe o arquivo no Submarine

1. Abra o Submarine e crie ou abra o cofre que vai receber suas senhas.
2. Vá em **Configurações**, depois em **Importar e exportar**, e aperte **Importar** ao lado de **Importar do Bitwarden**.
3. Escolha o arquivo. Se ele estiver protegido por senha, digite essa senha.
4. Confira quantos itens foram encontrados, escolha o cofre se você tiver vários e aperte **Importar**.

Seus itens são criptografados no seu dispositivo e depois sincronizados com seus outros dispositivos, como qualquer outra alteração.

## 3. Exclua o arquivo de exportação

Uma exportação .json sem senha não é criptografada: qualquer pessoa que tenha acesso a ela consegue ler todas as suas senhas. Exclua o arquivo assim que a importação terminar e esvazie a lixeira do computador. Não o envie por e-mail.

## O que é importado

- Credenciais, cartões, anotações seguras, identidades, chaves SSH e os outros tipos de item do Bitwarden, com seus campos personalizados e seus códigos de autenticação de dois fatores.
- Credenciais, cartões e anotações seguras podem ser editados no Submarine. Os outros tipos são mantidos e exibidos, mas ainda não podem ser editados.
- As chaves de acesso são mantidas e exibidas, mas o Submarine ainda não consegue fazer login com elas.
- As pastas não são importadas: o Submarine separa os itens por cofre.
- Os arquivos anexados não fazem parte da exportação do Bitwarden, então eles ficam no Bitwarden.

## Vindo de outro gerenciador de senhas

O Submarine só lê o formato do Bitwarden. O próprio Bitwarden importa da maioria dos gerenciadores de senhas, como 1Password, LastPass, KeePass ou o seu navegador. Com uma conta gratuita do Bitwarden, importe suas senhas lá primeiro e depois siga os passos acima.

## Sair do Submarine

O Submarine exporta no mesmo formato. Em **Configurações**, depois em **Importar e exportar**, a opção **Exportar cofre** salva um arquivo do Bitwarden, protegido por senha ou sem criptografia, que o Bitwarden e outros gerenciadores de senhas conseguem importar. A lixeira fica de fora.

Ainda não usa o Submarine? [Baixe o app](/pt-br/download) ou leia [como ele protege suas senhas](/pt-br/security).

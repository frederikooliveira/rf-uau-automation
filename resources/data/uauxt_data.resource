*** Settings ***
Documentation       Dados e configuracoes da aplicacao UauXT.
...                 Responsabilidade: centralizar caminhos, locators, credenciais e constantes.

*** Variables ***
# Caminhos e executaveis
# Pode ser sobrescrito pela variavel de ambiente UAUXT_EXE
${UAUXT_EXE}                %{UAUXT_EXE=C:/UAU/UAU XT/Modulos/UauXT.exe}

# Credenciais: lidas de variaveis de ambiente (definidas no .env local ou CI/CD)
# Nao definir valores reais neste arquivo - use .env (ver .env.example)
${UAUXT_USUARIO_ENV}            %{UAUXT_USUARIO=ENV.UAUXT_USUARIO}
${UAUXT_SENHA_ENV}              %{UAUXT_SENHA=ENV.UAUXT_SENHA}
&{UAUXT_CREDENCIAIS_PADRAO}    usuario=${UAUXT_USUARIO_ENV}    senha=${UAUXT_SENHA_ENV}

# Locators de UI (principais)
${UAUXT_JANELA_LOGIN}       id:MainView
${UAUXT_CAMPO_USUARIO}      id:txtUsuario
${UAUXT_CAMPO_SENHA}        id:txtSenha
${UAUXT_BOTAO_AUTENTICAR}   id:btnAutenticar

# Popup inicial
${UAUXT_POPUP_INICIAL}      subname:Informa

# Timeouts padrao
${UAUXT_TIMEOUT_PADRAO}     20s
${UAUXT_TIMEOUT_POPUP}      50s

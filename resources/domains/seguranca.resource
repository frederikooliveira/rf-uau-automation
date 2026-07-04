*** Settings ***
Documentation       Keywords de dominio para o modulo Segurança no UauXT.
...                 Responsabilidade: encapsular fluxos de negocio da tela de usuarios.
Resource            ../apps/uauxt.resource
Resource            ../apps/uauxt_grid.resource
Resource            ../data/seguranca_data.resource


*** Keywords ***
Acessar Usuarios Via Menu Lateral
    [Documentation]    Acessa a tela Usuarios pelo caminho Segurança > Gestão de Segurança > Usuários.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [DOM-SEG] Acessando Usuarios pelo menu lateral...    console=True
    Acessar Item Via Icone Capacete Obras
    ...    ${UAUXT_SUBMENU_SEGURANCA_TEXTO}
    ...    ${UAUXT_SUBMENU_GESTAO_SEGURANCA_TEXTO}
    ...    ${UAUXT_SUBMENU_USUARIOS_TEXTO}
    ...    ${timeout}
    Log    [DOM-SEG] Tela Usuarios acessada.    console=True

Acessar Grupo Usuarios Via Menu Lateral
    [Documentation]    Acessa a tela Grupo de Usuários pelo caminho Segurança > Gestão de Segurança > Grupo de Usuários.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [DOM-SEG] Acessando Grupo de Usuários pelo menu lateral...    console=True
    Acessar Item Via Icone Capacete Obras
    ...    ${UAUXT_SUBMENU_SEGURANCA_TEXTO}
    ...    ${UAUXT_SUBMENU_GESTAO_SEGURANCA_TEXTO}
    ...    ${UAUXT_SUBMENU_GRUPO_USUARIOS_TEXTO}
    ...    ${timeout}
    Log    [DOM-SEG] Tela Grupo de Usuários acessada.    console=True

Validar Estrutura Usuarios
    [Documentation]    Valida estrutura tecnica basica da tela Usuarios.
    Log    [DOM-SEG] Validando estrutura tecnica da tela Usuarios...    console=True
    ${grid_main}=    Registrar Grid UauXT Por Win32
    ...    ${SEGURANCA_USUARIOS_TELA_LOCATOR}
    ...    0
    Should Not Be Empty    ${grid_main}
    ${toolbars}=    Listar Botoes Toolbar Via Probe    ${SEGURANCA_USUARIOS_TOOLBAR_CLASS}
    Should Not Be Empty    ${toolbars}
    Log    [DOM-SEG] Estrutura tecnica validada.    console=True

Clicar Botao Novo Na Tela Usuarios
    [Documentation]    Clica no botão Novo na toolbar da tela de manutenção de usuários.
    Log    [DOM-SEG] Clicando em Novo na tela de usuários...    console=True
    Clicar Botao Toolbar Por Indice Via Probe
    ...    ${SEGURANCA_USUARIOS_TB_BTN_NOVO_IDX}
    ...    ${SEGURANCA_USUARIOS_TOOLBAR_CLASS}
    Log    [DOM-SEG] Botão Novo acionado.    console=True

Preencher Cadastro Usuario Basico
    [Documentation]    Preenche login, nome e e-mail no cadastro de usuário da tela UauXT.
    [Arguments]    ${login}    ${nome}    ${email}
    Log
    ...    [DOM-SEG] Preenchendo login '${login}', nome '${nome}' e e-mail '${email}'.
    ...    console=True
    Preencher Campo UauXT Por Locator    ${SEG_MNT_USR_DG_TXT1_LOCATOR}    ${login}
    Preencher Campo UauXT Por Locator    ${SEG_MNT_USR_DG_TXT2_LOCATOR}    ${nome}
    Preencher Campo UauXT Por Locator    ${SEG_MNT_USR_DG_TXT5_LOCATOR}    ${email}
    Log    [DOM-SEG] Campos de cadastro preenchidos.    console=True

Clicar Botao Gravar Na Tela Usuarios
    [Documentation]    Aciona o botão Gravar na toolbar da tela de manutenção de usuários.
    Log    [DOM-SEG] Gravando cadastro de usuário...    console=True
    Clicar Botao Toolbar Por Indice Via Probe
    ...    ${SEG_MNT_USR_TB_BTN_GRAVAR_IDX}
    ...    ${SEG_MNT_USR_TOOLBAR_CLASS}
    ...    Manutenção de usuários
    Log    [DOM-SEG] Cadastro gravado.    console=True

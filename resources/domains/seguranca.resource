*** Settings ***
Documentation       Keywords de dominio para o modulo Segurança no UauXT.
...                 Responsabilidade: encapsular fluxos de negocio da tela de usuarios.
Resource            ../apps/uauxt.resource
Resource            ../apps/uauxt_grid.resource
Resource            ../data/seguranca_data.resource


*** Keywords ***
Validar Locator Configurado
    [Documentation]    Falha cedo quando um locator nao foi mapeado.
    [Arguments]    ${locator}    ${nome_locator}
    IF    '${locator}'.startswith('TODO_CONFIGURAR_')
        Fail    Locator nao configurado: ${nome_locator}. Atualize em resources/data/seguranca_data.resource.
    END

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

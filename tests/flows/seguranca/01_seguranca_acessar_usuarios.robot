*** Settings ***
Documentation       Fluxo de acesso a tela de usuários do módulo Segurança.
...                 Pre-requisito: UauXT aberto e usuario autenticado.
Resource            ../../../resources/domains/seguranca.resource
Test Tags           uauxt    seguranca    acessar-usuarios    funcional    comportamento-unico


*** Test Cases ***
Acessar Tela Usuarios
    [Documentation]    Acessa a tela Usuarios pelo menu lateral do UauXT.
    Log    [UAUXT] Iniciando acesso a tela Usuarios...    console=True
    Acessar Usuarios Via Menu Lateral
    Log    [UAUXT] Tela Usuarios acessada com sucesso.    console=True

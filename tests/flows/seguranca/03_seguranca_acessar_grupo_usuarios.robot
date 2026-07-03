*** Settings ***
Documentation       Fluxo de acesso à tela de Grupo de Usuários do módulo Segurança.
...                 Pre-requisito: UauXT aberto e usuário autenticado.
Resource            ../../../resources/domains/seguranca.resource
Test Tags           uauxt    seguranca    acessar-grupo-usuarios    funcional


*** Test Cases ***
Acessar Tela Grupo De Usuarios
    [Documentation]    Acessa a tela Grupo de Usuários pelo menu lateral do UauXT.
    Log    [UAUXT] Iniciando acesso à tela Grupo de Usuários...    console=True
    Acessar Grupo Usuarios Via Menu Lateral
    Log    [UAUXT] Tela Grupo de Usuários acessada com sucesso.    console=True

*** Settings ***
Documentation       Valida a estrutura basica da tela de Usuários no UauXT.
...                 Pre-requisito: UauXT aberto e usuario autenticado.
Resource            ../../../resources/domains/seguranca.resource
Test Tags           uauxt    seguranca    usuarios    funcional    comportamento-unico

*** Test Cases ***
Validar Estrutura Da Tela Usuarios
    [Documentation]    Acessa a tela Usuarios e valida a estrutura tecnica basica.
    Log    [DOM-SEG] Iniciando validacao da tela Usuarios...    console=True
    Acessar Usuarios Via Menu Lateral
    Validar Estrutura Usuarios
    Log    [DOM-SEG] Tela Usuarios validada com sucesso.    console=True

*** Settings ***
Documentation       Keywords de dominio de negocio para cadastro de pessoas no UauXT.
...                 Responsabilidade: fluxos de negocio (nao UI tecnica).
Library             String
Resource            ../apps/uauxt.resource
Resource            ../data/pessoas_data.resource

*** Keywords ***
Validar Locator Configurado
    [Documentation]    Falha cedo quando um locator nao foi mapeado.
    [Arguments]    ${locator}    ${nome_locator}
    IF    '${locator}'.startswith('TODO_CONFIGURAR_')
        Fail    Locator nao configurado: ${nome_locator}. Atualize em resources/data/pessoas_data.resource.
    END

Acessar Menu Pessoas
    [Documentation]    Acessa o menu de pessoas no UauXT apos login.
    Validar Locator Configurado    ${MENU_PESSOAS_LOCATOR}    MENU_PESSOAS_LOCATOR
    Log    [DOM-PESSOAS] Acessando menu de pessoas...    console=True
    Clicar Elemento Quando Disponivel    ${MENU_PESSOAS_LOCATOR}
    Log    [DOM-PESSOAS] Menu de pessoas acessado.    console=True

Clicar Em Novo Cadastro De Pessoa
    [Documentation]    Inicia um novo cadastro de pessoa.
    Validar Locator Configurado    ${BOTAO_NOVO_PESSOA_LOCATOR}    BOTAO_NOVO_PESSOA_LOCATOR
    Log    [DOM-PESSOAS] Clicando em 'Novo Cadastro'...    console=True
    Clicar Elemento Quando Disponivel    ${BOTAO_NOVO_PESSOA_LOCATOR}
    Log    [DOM-PESSOAS] Novo cadastro iniciado.    console=True

Preencher Cadastro De Pessoa
    [Documentation]    Preenche os campos principais do cadastro de pessoa.
    [Arguments]    ${pessoa}
    Validar Locator Configurado    ${CAMPO_NOME_PESSOA_LOCATOR}    CAMPO_NOME_PESSOA_LOCATOR
    Validar Locator Configurado    ${CAMPO_CPF_PESSOA_LOCATOR}    CAMPO_CPF_PESSOA_LOCATOR
    Validar Locator Configurado    ${CAMPO_EMAIL_PESSOA_LOCATOR}    CAMPO_EMAIL_PESSOA_LOCATOR
    Validar Locator Configurado    ${CAMPO_TELEFONE_PESSOA_LOCATOR}    CAMPO_TELEFONE_PESSOA_LOCATOR
    Log    [DOM-PESSOAS] Preenchendo cadastro de ${pessoa}[nome]...    console=True
    Digitar Texto Em Campo    ${CAMPO_NOME_PESSOA_LOCATOR}    ${pessoa}[nome]
    Digitar Texto Em Campo    ${CAMPO_CPF_PESSOA_LOCATOR}    ${pessoa}[cpf]
    Digitar Texto Em Campo    ${CAMPO_EMAIL_PESSOA_LOCATOR}    ${pessoa}[email]
    Digitar Texto Em Campo    ${CAMPO_TELEFONE_PESSOA_LOCATOR}    ${pessoa}[telefone]
    Log    [DOM-PESSOAS] Cadastro preenchido.    console=True

Gravar Cadastro De Pessoa
    [Documentation]    Grava o cadastro de pessoa preenchido.
    Validar Locator Configurado    ${BOTAO_GRAVAR_PESSOA_LOCATOR}    BOTAO_GRAVAR_PESSOA_LOCATOR
    Log    [DOM-PESSOAS] Gravando cadastro...    console=True
    Clicar Elemento Quando Disponivel    ${BOTAO_GRAVAR_PESSOA_LOCATOR}
    Log    [DOM-PESSOAS] Cadastro gravado.    console=True

Cadastrar Pessoa Basica
    [Documentation]    Fluxo completo de cadastro de pessoa apos login.
    [Arguments]    ${perfil}=padrao
    Log    [DOM-PESSOAS] Iniciando cadastro de pessoa (perfil: ${perfil})...    console=True
    ${pessoa}=    Obter Dados Pessoa    ${perfil}
    Acessar Menu Pessoas
    Clicar Em Novo Cadastro De Pessoa
    Preencher Cadastro De Pessoa    ${pessoa}
    Gravar Cadastro De Pessoa
    Log    [DOM-PESSOAS] Cadastro de pessoa concluido.    console=True

Obter Dados Pessoa
    [Documentation]    Retorna um perfil de pessoa centralizado.
    [Arguments]    ${perfil}=padrao
    ${perfil_normalizado}=    Convert To Lower Case    ${perfil}
    IF    '${perfil_normalizado}' == 'padrao'
        RETURN    ${PESSOA_PADRAO}
    ELSE IF    '${perfil_normalizado}' == 'alternativa'
        RETURN    ${PESSOA_ALTERNATIVA}
    ELSE IF    '${perfil_normalizado}' == 'invalida_cpf'
        RETURN    ${PESSOA_INVALIDA_CPF}
    END
    Fail    Perfil de pessoa desconhecido: ${perfil}. Use padrao, alternativa ou invalida_cpf.

Montar Texto Pessoa
    [Documentation]    Converte dicionario de pessoa em texto para log.
    [Arguments]    ${pessoa}
    ${texto}=    Catenate    SEPARATOR=\n
    ...    Nome: ${pessoa}[nome]
    ...    CPF: ${pessoa}[cpf]
    ...    Email: ${pessoa}[email]
    ...    Telefone: ${pessoa}[telefone]
    RETURN    ${texto}

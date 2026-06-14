*** Settings ***
Documentation       Keywords de automacao tecnica para API REST.
...                 Responsabilidade: criar sessao HTTP, montar headers e consumir endpoints.
Library             Collections
Library             OperatingSystem
Library             RequestsLibrary
Resource            ../data/api_data.resource


*** Keywords ***
Validar Configuracao Base Da Api
    [Documentation]    Valida se as variaveis base de API foram configuradas.
    ${base_url}=    Get Environment Variable    API_BASE_URL    ${API_BASE_URL}
    ${auth_path}=    Get Environment Variable    API_AUTH_PATH    ${API_AUTH_PATH}
    ${x_auth}=    Get Environment Variable    API_X_AUTH    ${API_X_AUTH}
    Should Not Be Empty    ${base_url}    [API] Variavel API_BASE_URL nao foi configurada.
    Should Not Be Empty    ${auth_path}    [API] Variavel API_AUTH_PATH nao foi configurada.
    Should Not Be Empty    ${x_auth}    [API] Variavel API_X_AUTH nao foi configurada.
    Log    [API] Configuracao base validada.    console=True

Montar Headers Api Base
    [Documentation]    Monta headers padrao da API Globaltec para autenticacao.
    ${x_auth}=    Get Environment Variable    API_X_AUTH    ${API_X_AUTH}
    Should Not Be Empty    ${x_auth}    [API] Variavel API_X_AUTH nao foi configurada.
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    X-Globaltec-Authorization=${x_auth}
    ...    Accept=application/json
    RETURN    ${headers}

Montar Headers Api
    [Documentation]    Monta headers padrao e inclui Authorization com token-globaltec quando disponivel.
    ${headers}=    Montar Headers Api Base
    ${token_env}=    Get Environment Variable    API_TOKEN_GLOBALTEC    ${API_TOKEN_GLOBALTEC}
    ${token}=    Set Variable    ${token_env}
    IF    '${token}' != ''
        Set To Dictionary    ${headers}    Authorization=${token}
    END
    RETURN    ${headers}

Criar Sessao Api Padrao
    [Documentation]    Cria sessao HTTP padrao para a URL base configurada.
    ${base_url}=    Get Environment Variable    API_BASE_URL    ${API_BASE_URL}
    ${timeout}=    Get Environment Variable    API_TIMEOUT    ${API_TIMEOUT_SEC}
    ${tls_insecure}=    Get Environment Variable    API_TLS_INSECURE    ${API_TLS_INSECURE}
    ${ca_bundle}=    Get Environment Variable    API_CA_BUNDLE    ${API_CA_BUNDLE}
    ${verify}=    Resolver Verificacao Tls Api    ${tls_insecure}    ${ca_bundle}
    ${headers}=    Montar Headers Api
    Create Session    api    ${base_url}    headers=${headers}    timeout=${timeout}    verify=${verify}
    Log    [API] Sessao HTTP criada.    console=True

Resolver Verificacao Tls Api
    [Documentation]    Resolve politica de verificacao TLS para a sessao HTTP.
    [Arguments]    ${tls_insecure}    ${ca_bundle}
    ${mode}=    Evaluate    str($tls_insecure).strip().lower()
    ${verify}=    Set Variable    ${True}
    IF    '${mode}' == '1' or '${mode}' == 'true' or '${mode}' == 'yes'
        ${verify}=    Set Variable    ${False}
        Log    [API] Aviso: TLS inseguro habilitado por API_TLS_INSECURE.    console=True
    ELSE IF    '${ca_bundle}' != ''
        ${verify}=    Set Variable    ${ca_bundle}
    END
    RETURN    ${verify}

Consultar Endpoint Api
    [Documentation]    Executa GET no endpoint relativo informado e retorna resposta.
    [Arguments]    ${endpoint}
    ${resp}=    GET On Session    api    ${endpoint}
    ${status}=    Convert To String    ${resp.status_code}
    Log    [API] GET ${endpoint} -> status=${status}    console=True
    RETURN    ${resp}

Validar Status Http
    [Documentation]    Valida status HTTP esperado.
    [Arguments]    ${response}    ${expected_status}
    ${expected}=    Convert To Integer    ${expected_status}
    ${actual}=    Convert To Integer    ${response.status_code}
    Should Be Equal As Integers    ${actual}    ${expected}
    Log    [API] Status HTTP validado: ${expected}.    console=True

Obter Credenciais Usuario Corporativo
    [Documentation]    Le credenciais da autenticacao corporativa do ambiente/configuracao.
    ${login_ad}=    Get Environment Variable    API_LOGIN_AD    ${API_LOGIN_AD}
    ${senha}=    Get Environment Variable    API_SENHA    ${API_SENHA}
    ${login_uau}=    Get Environment Variable    API_LOGIN_UAU    ${API_LOGIN_UAU}
    RETURN    ${login_ad}    ${senha}    ${login_uau}

Validar Credenciais Usuario Corporativo
    [Documentation]    Garante que as credenciais minimas para autenticacao foram informadas.
    [Arguments]    ${login_ad}    ${senha}    ${login_uau}
    Should Not Be Empty    ${login_ad}    [API] Variavel API_LOGIN_AD nao foi configurada.
    Should Not Be Empty    ${senha}    [API] Variavel API_SENHA nao foi configurada.
    Should Not Be Empty    ${login_uau}    [API] Variavel API_LOGIN_UAU nao foi configurada.

Montar Payload Autenticacao Corporativa
    [Documentation]    Monta payload JSON no contrato da API corporativa.
    [Arguments]    ${login_ad}    ${senha}    ${login_uau}
    ${payload}=    Create Dictionary
    ...    login_ad=${login_ad}
    ...    senha=${senha}
    ...    login_uau=${login_uau}
    RETURN    ${payload}

Autenticar Usuario Corporativo
    [Documentation]    Executa POST de autenticacao corporativa e retorna resposta.
    ${auth_path}    ${auth_status}=    Obter Configuracao Autenticacao Api
    ${payload}=    Obter Payload Autenticacao Corporativa
    ${response}=    Enviar Requisicao Autenticacao Corporativa    ${auth_path}    ${payload}
    Validar E Registrar Resposta De Autenticacao    ${response}    ${auth_status}    ${auth_path}
    RETURN    ${response}

Obter Configuracao Autenticacao Api
    [Documentation]    Retorna endpoint e status esperado para autenticacao.
    ${auth_path}=    Get Environment Variable    API_AUTH_PATH    ${API_AUTH_PATH}
    ${auth_status}=    Get Environment Variable    API_AUTH_OK_STATUS    ${API_AUTH_OK_STATUS}
    RETURN    ${auth_path}    ${auth_status}

Validar E Registrar Resposta De Autenticacao
    [Documentation]    Valida status, persiste token e registra log de autenticacao.
    [Arguments]    ${response}    ${auth_status}    ${auth_path}
    Validar Status Http    ${response}    ${auth_status}
    ${token}=    Extrair Token Globaltec Da Resposta    ${response}
    Salvar Token Globaltec Em Ambiente    ${token}
    ${status}=    Convert To String    ${response.status_code}
    Log    [API] POST ${auth_path} -> status=${status}.    console=True
    Log    [API] Token-globaltec carregado para uso nas demais rotas.    console=True

Obter Payload Autenticacao Corporativa
    [Documentation]    Carrega e valida credenciais de autenticacao, retornando payload final.
    ${login_ad}    ${senha}    ${login_uau}=    Obter Credenciais Usuario Corporativo
    Validar Credenciais Usuario Corporativo    ${login_ad}    ${senha}    ${login_uau}
    ${payload}=    Montar Payload Autenticacao Corporativa    ${login_ad}    ${senha}    ${login_uau}
    RETURN    ${payload}

Enviar Requisicao Autenticacao Corporativa
    [Documentation]    Executa chamada de auth usando header X-Globaltec-Authorization.
    [Arguments]    ${auth_path}    ${payload}
    ${headers}=    Montar Headers Api Base
    ${response}=    Executar Post Auth Com Headers    ${auth_path}    ${payload}    ${headers}
    Log Resposta De Autenticacao Se Erro    ${response}
    RETURN    ${response}

Executar Post Auth Com Headers
    [Documentation]    Executa POST de autenticacao sem falhar por status HTTP.
    [Arguments]    ${auth_path}    ${payload}    ${headers}
    ${payload_json}=    Evaluate    json.dumps($payload, ensure_ascii=False)    modules=json
    ${response}=    Wait Until Keyword Succeeds
    ...    2x
    ...    1s
    ...    Executar Post Auth Com Timeout
    ...    ${auth_path}
    ...    ${payload_json}
    ...    ${headers}
    RETURN    ${response}

Executar Post Auth Com Timeout
    [Documentation]    Executa POST de auth com timeout dedicado.
    [Arguments]    ${auth_path}    ${payload_json}    ${headers}
    ${timeout}=    Get Environment Variable    API_AUTH_TIMEOUT    ${API_AUTH_TIMEOUT_SEC}
    ${response}=    POST On Session
    ...    api
    ...    ${auth_path}
    ...    data=${payload_json}
    ...    headers=${headers}
    ...    timeout=${timeout}
    ...    expected_status=any
    RETURN    ${response}

Log Resposta De Autenticacao Se Erro
    [Documentation]    Registra detalhes da resposta para diagnostico de 401/403.
    [Arguments]    ${response}
    ${status}=    Convert To Integer    ${response.status_code}
    IF    ${status} >= 400
        Log    [API] Falha na autenticacao. status=${status}    console=True
    END

Salvar Token Globaltec Em Ambiente
    [Documentation]    Persiste token-globaltec no ambiente para reutilizacao nas proximas rotas.
    [Arguments]    ${token}
    Set Environment Variable    API_TOKEN_GLOBALTEC    ${token}

Extrair Token Globaltec Da Resposta
    [Documentation]    Extrai token-globaltec do JSON de autenticacao com fallbacks de chave.
    [Arguments]    ${response}
    ${payload}=    Evaluate    $response.json()
    ${token}=    Extrair Token Globaltec De Payload Simples    ${payload}
    ${token}=    Extrair Token Globaltec De Payload Mapeado    ${payload}    ${token}
    Should Not Be Empty    ${token}    [API] Token globaltec nao encontrado na resposta de autenticacao.
    RETURN    ${token}

Extrair Token Globaltec De Payload Simples
    [Documentation]    Retorna o payload quando a resposta de auth vem como string JSON literal.
    [Arguments]    ${payload}
    ${payload_type}=    Evaluate    type($payload).__name__
    ${token}=    Set Variable    ${EMPTY}
    IF    '${payload_type}' == 'str'
        ${token}=    Set Variable    ${payload}
    END
    RETURN    ${token}

Extrair Token Globaltec De Payload Mapeado
    [Documentation]    Procura o token em chaves alternativas quando a resposta e um objeto JSON.
    [Arguments]    ${payload}    ${token_atual}
    ${token}=    Set Variable    ${token_atual}
    IF    '${token}' == ''
        ${token}=    Evaluate    $payload.get('token-globaltec', '') if isinstance($payload, dict) else ''
    END
    IF    '${token}' == ''
        ${token}=    Evaluate    $payload.get('token_globaltec', '') if isinstance($payload, dict) else ''
    END
    IF    '${token}' == ''
        ${token}=    Evaluate    $payload.get('tokenGlobaltec', '') if isinstance($payload, dict) else ''
    END
    IF    '${token}' == ''
        ${token}=    Evaluate    $payload.get('token', '') if isinstance($payload, dict) else ''
    END
    IF    '${token}' == ''
        ${token}=    Evaluate    $payload.get('access_token', '') if isinstance($payload, dict) else ''
    END
    IF    '${token}' == ''
        ${data}=    Evaluate    $payload.get('data', {}) if isinstance($payload, dict) else {}
        ${token}=    Evaluate    $data.get('token-globaltec', '') if isinstance($data, dict) else ''
    END
    RETURN    ${token}

*** Settings ***
Documentation       Dados e configuracoes para testes de API REST.
...                 Responsabilidade: centralizar URL base, endpoints, headers e timeouts.


*** Variables ***
# --- URL base e endpoints ---
${API_BASE_URL}             https://httpbin.org
${API_HEALTH_PATH}          /status/200
${API_AUTH_PATH}            /api/v1/Autenticador/AutenticarUsuarioCorporativo

# --- Configuracoes de request ---
${API_TIMEOUT_SEC}          30
${API_AUTH_TIMEOUT_SEC}     60
${API_EXPECTED_STATUS}      200
${API_AUTH_OK_STATUS}       200
${API_TLS_INSECURE}         false
${API_CA_BUNDLE}            ${EMPTY}

# --- Credenciais e autenticacao ---
${API_X_AUTH}               ${EMPTY}
${API_TOKEN_GLOBALTEC}      ${EMPTY}
${API_LOGIN_AD}             ${EMPTY}
${API_SENHA}                ${EMPTY}
${API_LOGIN_UAU}            ${EMPTY}

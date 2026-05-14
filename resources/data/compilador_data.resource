*** Settings ***
Documentation       Dados e configuracoes da aplicacao UAU Compilador.
...                 Responsabilidade: centralizar caminhos, locators e constantes.

*** Variables ***
# Caminhos e executaveis
# Sobrescreva via variaveis de ambiente ou .env (ver .env.example)
${COMPILADOR_DIR}       %{COMPILADOR_DIR=C:/ProjetosTFS/UAU/10.06/Producao/Componentes}
${COMPILADOR_EXE}       ${COMPILADOR_DIR}/UAUCompilador.exe
${COMPILADOR_JANELA}    executable:UAUCompilador.exe
${PASTA_SAIDA}          %{COMPILADOR_PASTA_SAIDA=C:/UAU/UAU 10.06/Modulos}

# Locators de UI (principais)
${ID_GRID_MODULOS}      id:gvModulos
${ID_CHECKBOX_MARCAR_COMPONENTES}       id:cbxMarcarComponentes
${ID_CHECKBOX_MARCAR_COMPONENTES_FIXO}  id:cbxMarcarComponentesFixo
${ID_PANEL_ROOT}        id:panel2
${ID_VERSAO_CAMPO}      id:txtVersao
${ID_BOTAO_COMPILAR_COMPONENTES}    id:btnCompilarComponentes
${ID_BOTAO_VERSAO_APLICAR}          id:btnVersaoComponentesAplicar
${ID_CHECKBOX_MARCAR_MODULOS}       id:cbxMarcarModulos
${ID_BOTAO_COMPILAR_MODULOS}        id:btnCompilarModulos
${ID_BOTAO_BUSCAR_LOCAL_SAIDA}      id:btnBuscarLocalSaida
${ID_CHECKBOX_COPIAR_MODULOS}       id:cbxCopiarModulos
${ID_BOTAO_COPIAR_COMPONENTES_EXTERNOS}    id:btnCopiarComponentesExternos
${ID_BOTAO_COPIAR_PROJETOS}         id:btnCopiarProjetos

# Timeouts padrao
${COMPILADOR_TIMEOUT_PADRAO}    30s
${COMPILADOR_TIMEOUT_COMPILACAO}    900s

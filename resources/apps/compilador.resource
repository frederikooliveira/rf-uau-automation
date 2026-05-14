*** Settings ***
Documentation       Keywords específicas da aplicação UAU Compilador.
...                 Responsabilidade: controlar a UI do compilador, não testes.
Library             RPA.Windows
Library             Process
Library             String
Library             Collections
Resource            ../core/ui_helpers.resource
Resource            ../core/sync.resource
Resource            ../data/compilador_data.resource

*** Keywords ***
Abrir UAU Compilador
    [Documentation]    Abre o UAUCompilador.exe e aguarda a janela principal ficar responsiva.
    Log    [COMP] Verificando se UAUCompilador ja esta em execucao...    console=True
    ${aberto}=    Verificar Processo Em Execucao    UAUCompilador.exe
    IF    not ${aberto}
        Log    [COMP] Iniciando UAUCompilador.exe...    console=True
        Iniciar Processo Se Nao Existe    ${COMPILADOR_EXE}    UAUCompilador.exe
        Log    [COMP] Aguardando janela do compilador (ate 60s)...    console=True
        Aguardar Janela Por Nome    ${COMPILADOR_JANELA}    60s
        Log    [COMP] UAUCompilador aberto com sucesso.    console=True
    ELSE
        Log    [COMP] UAUCompilador ja esta aberto. Trazendo para foco...    console=True
        Garantir Janela Em Foco    ${COMPILADOR_JANELA}
        Log    [COMP] UAUCompilador em foco.    console=True
    END

Configurar Opcoes Compilador
    [Documentation]    Seleciona Release, Modulo, marca os dois checkboxes Marcar todos, ajusta a versao e inicia compilacao.
    Log    [COMP] Garantindo foco no compilador...    console=True
    Garantir Janela Em Foco    ${COMPILADOR_JANELA}
    Log    [COMP] Selecionando compilacao Release...    console=True
    Click    name:Release and type:RadioButtonControl
    Log    [COMP] Selecionando Abrir Projetos VB6 por Modulo...    console=True
    Click    name:Modulo and type:RadioButtonControl
    Log    [COMP] Marcando todos os componentes de compilacao do UAU...    console=True
    Click    id:cbxMarcarComponentes
    Log    [COMP] Marcando todos os componentes fixos do UAU...    console=True
    ${root}=    Get Element    id:panel2
    ${segundo_cb}=    Get Element    id:cbxMarcarComponentesFixo    root_element=${root}
    Click    ${segundo_cb}
    Log    [COMP] Obtendo versao atual...    console=True
    ${current_version}=    Obter Valor Campo    id:txtVersao
    Log    [COMP] Versao atual: ${current_version}    console=True
    ${parts}=    Split String    ${current_version}    .
    ${last}=    Evaluate    int(${parts}[-1]) - 1
    ${new_version}=    Set Variable    ${parts}[0].${parts}[1].${parts}[2].${last}
    Log    [COMP] Nova versao: ${new_version}    console=True
    Digitar Texto Em Campo    id:txtVersao    ${new_version}
    Log    [COMP] Aplicando nova versao...    console=True
    Click    id:btnVersaoComponentesAplicar
    Pausa Controlada    1s    Aguardando aplicacao da versao
    Log    [COMP] Iniciando compilacao...    console=True
    Click    id:btnCompilarComponentes
    Log    [COMP] Configuracoes aplicadas e compilacao iniciada.    console=True

Compilar Modulos UAU
    [Documentation]    Compila apenas os modulos UAU: clica no folder Modulos UAU, marca todos e compila.
    Log    [COMP] Garantindo foco no compilador...    console=True
    Garantir Janela Em Foco    ${COMPILADOR_JANELA}
    Log    [COMP] Clicando no folder Modulos UAU...    console=True
    Click    name:"Modulos UAU"
    Pausa Controlada    2s    Aguardando a interface atualizar
    Log    [COMP] Marcando todos os modulos UAU...    console=True
    ${checkbox_found}=    Run Keyword And Ignore Error    Click    id:cbxMarcarModulos
    IF    '${checkbox_found}[0]' == 'FAIL'
        Log    [COMP] Checkbox padrao nao encontrado, tentando locator alternativo...    console=True
        Click    name:"Marcar todos" and type:CheckBoxControl
    END
    Pausa Controlada    1s    Aguardando marcacao dos checkboxes
    Log    [COMP] Iniciando compilacao dos modulos...    console=True
    ${btn_found}=    Run Keyword And Ignore Error    Click    id:btnCompilarModulos
    IF    '${btn_found}[0]' == 'FAIL'
        Log    [COMP] Botao padrao nao encontrado, tentando locator alternativo...    console=True
        Click    name:"Compilar" and type:ButtonControl
    END
    Log    [COMP] Compilacao dos modulos UAU iniciada.    console=True

Validar Grid Modulos
    [Documentation]    Valida o grid de modulos apos compilacao.
    Log    [COMP] Iniciando validacao via grid...    console=True
    ${grid}=    Get Element    id:gvModulos
    ${all_rows}=    Get Elements    type:CustomControl    root_element=${grid}
    ${row_count}=    Get Length    ${all_rows}
    Log    [COMP] Grid tem ${row_count} linhas (incluindo cabecalho).    console=True
    FOR    ${i}    IN RANGE    1    ${row_count}
        ${row}=    Get From List    ${all_rows}    ${i}
        ${cells_status}    ${cells}=    Run Keyword And Ignore Error    Get Elements    type:EditControl    root_element=${row}
        IF    '${cells_status}' == 'FAIL'
            Log    [COMP] Linha ${i}: sem celulas, pulando...    console=True
            CONTINUE
        END
        ${cell_count}=    Get Length    ${cells}
        IF    ${cell_count} >= 6
            ${name_cell}=    Get From List    ${cells}    1
            ${name}=    Get Value    ${name_cell}
            ${status_cell}=    Get From List    ${cells}    5
            ${status}=    Get Value    ${status_cell}
            Log    [COMP] Modulo ${name}: status=${status}    console=True
            IF    '${status}' == 'ERRO'
                Fail    Modulo ${name} falhou ao compilar
            ELSE IF    '${status}' != 'Compilado' and '${status}' != ''
                Log    [COMP] Status pendente para modulo ${name}: ${status}    console=True
            END
        ELSE
            Log    [COMP] Linha ${i}: apenas ${cell_count} celulas, pulando...    console=True
        END
    END
    Log    [COMP] Validacao do grid de modulos concluida.    console=True

Aguardar Compilacao
    [Documentation]    Aguarda a compilacao finalizar (genérica para qualquer tipo).
    Log    [COMP] Iniciando aguardo da compilacao geral...    console=True
    Aguardar Resultado Compilacao
    Log    [COMP] Compilacao finalizada com sucesso.    console=True

Aguardar Compilacao Modulos
    [Documentation]    Aguarda compilacao de modulos e valida o grid ao final.
    Log    [COMP] Iniciando aguardo da compilacao de modulos...    console=True
    Aguardar Resultado Compilacao
    Log    [COMP] Compilacao de modulos finalizada. Iniciando validacao do grid...    console=True
    Validar Grid Modulos

Aguardar Resultado Compilacao
    [Documentation]    Aguarda compilacao finalizar. Falha se alerta de inconsistencia aparecer.
    ${status}=    Set Variable    WAITING
    WHILE    $status == 'WAITING'
        ${status}=    Checar Fim De Compilacao
        IF    $status == 'WAITING'
            Pausa Controlada    5s    Verificando status de compilacao
        ELSE IF    $status.startswith('ALERT:')
            ${msg}=    Evaluate    $status.split(':', 1)[1]
            Fail    Compilacao falhou com alerta:\n${msg}
        ELSE IF    $status == 'ALERT'
            Fail    Compilacao falhou - alerta de inconsistencia detectado
        END
    END
    Log    [COMP] Compilacao finalizada com sucesso.    console=True

Checar Fim De Compilacao
    [Documentation]    Verifica se compilacao finalizou ou se ha alerta. Retorna: DONE, ALERT, ALERT:msg ou WAITING.
    Log    [COMP] Verificando popups e status da compilacao...    console=True
    ${windows_status}    ${all_windows}=    Run Keyword And Ignore Error    Get Elements    type:WindowControl
    IF    '${windows_status}' == 'FAIL'
        Log    [COMP] Nenhuma janela encontrada, assumindo sem popup.    console=True
        ${all_windows}=    Create List
    END
    ${success_popup}=    Set Variable    ${NONE}
    FOR    ${win}    IN    @{all_windows}
        ${has_success}=    Evaluate    'Informa' in '${win.name}'
        IF    ${has_success}
            ${success_popup}=    Set Variable    ${win}
            BREAK
        END
    END
    IF    ${success_popup}
        Log    [COMP] Popup de sucesso detectado. Clicando em OK...    console=True
        Fechar Popup Informa
        Log    [COMP] OK clicado. Compilacao concluida com sucesso.    console=True
        Return From Keyword    DONE
    END
    ${popup}=    Set Variable    ${NONE}
    FOR    ${win}    IN    @{all_windows}
        ${has_msg}=    Evaluate    'Mensagens' in '${win.name}' or 'ALERTA' in '${win.name}'
        IF    ${has_msg}
            ${popup}=    Set Variable    ${win}
            BREAK
        END
    END
    IF    ${popup}
        Control Window    subname:Mensagens
        Pausa Controlada    1s    Aguardando popup de alerta ficar ativo
        ${edit_status}    ${edit}=    Run Keyword And Ignore Error
        ...    Get Element    type:EditControl
        IF    '${edit_status}' == 'PASS'
            ${value_status}    ${text}=    Run Keyword And Ignore Error
            ...    Get Value    ${edit}
            IF    '${value_status}' == 'PASS'
                Log    [COMP] ALERTA DE INCONSISTENCIA:\n${text}    level=ERROR    console=True
                Return From Keyword    ALERT:${text}
            ELSE
                Log    [COMP] ALERTA DE INCONSISTENCIA detectado (nao foi possivel ler mensagem)    level=ERROR    console=True
                Return From Keyword    ALERT
            END
        ELSE
            Log    [COMP] ALERTA DE INCONSISTENCIA detectado (sem detalhe)    level=ERROR    console=True
            Return From Keyword    ALERT
        END
    END
    Pausa Controlada    2s    Verificando status de compilacao
    Return From Keyword    WAITING

Configurar Local Saida Arquivos
    [Documentation]    Configura o local de saida dos arquivos compilados para ${PASTA_SAIDA}.
    Log    [COMP] Verificando se pasta de destino existe...    console=True
    ${folder_exists}=    Run Process    cmd    /c    if exist "${PASTA_SAIDA}" echo EXISTS
    IF    '${folder_exists.stdout}'.strip() != 'EXISTS'
        Log    [COMP] Criando pasta ${PASTA_SAIDA}...    console=True
        Run Process    cmd    /c    mkdir "${PASTA_SAIDA}"    2>nul
    END
    Log    [COMP] Garantindo foco no compilador...    console=True
    Garantir Janela Em Foco    ${COMPILADOR_JANELA}
    Log    [COMP] Clicando no botao Buscar Local Saida...    console=True
    Click    id:btnBuscarLocalSaida
    Pausa Controlada    2s    Aguardando dialogo de navegacao
    Log    [COMP] Navegando para ${PASTA_SAIDA}...    console=True
    Control Window    subname:"Escolha o local"
    Pausa Controlada    500ms    Aguardando foco no dialogo
    ${address_field}=    Get Element    id:41477
    Click    ${address_field}
    Pausa Controlada    300ms    Aguardando foco no campo de endereco
    Control Window    subname:"Escolha o local"
    Send Keys    keys={ALT}d
    Pausa Controlada    300ms    Aguardando selecao do endereco
    Send Keys    keys={CTRL}a{DELETE}
    Pausa Controlada    300ms    Limpando endereco anterior
    Send Keys    keys=${PASTA_SAIDA}
    Pausa Controlada    1s    Digitando novo endereco
    Log    [COMP] Clicando no botao Abrir...    console=True
    ${abrir_button}=    Get Element    id:1 and type:ButtonControl
    Log    [COMP] Botao encontrado: ${abrir_button}    console=True
    Double Click    ${abrir_button}
    Pausa Controlada    2s    Aguardando navegacao
    Log    [COMP] Garantindo foco na janela principal...    console=True
    Garantir Janela Em Foco    ${COMPILADOR_JANELA}
    Pausa Controlada    1s    Voltando ao compilador
    Log    [COMP] Marcando checkbox para copiar projetos compilados...    console=True
    Click    id:cbxCopiarModulos
    Pausa Controlada    1s    Checkbox marcado
    Log    [COMP] Clicando no botao 'Copia dos componentes externos'...    console=True
    Click    id:btnCopiarComponentesExternos
    Pausa Controlada    2s    Copiando componentes externos
    Log    [COMP] Clicando no botao 'Copia dos componentes e modulos'...    console=True
    Click    id:btnCopiarProjetos
    Pausa Controlada    2s    Copiando modulos
    Log    [COMP] Local de saida configurado para ${PASTA_SAIDA}.    console=True

"""
Variable file do Robot Framework que carrega o .env na raiz do projeto.
Configurado em robot.toml como variablefile para ser aplicado em todas as execucoes,
independente de como o robot e invocado (robot-runner.ps1, VS Code task, CLI direto).
"""
from pathlib import Path
from dotenv import load_dotenv

_env_file = Path(__file__).resolve().parents[2] / ".env"
load_dotenv(dotenv_path=_env_file, override=True)


def get_variables():
    return {}

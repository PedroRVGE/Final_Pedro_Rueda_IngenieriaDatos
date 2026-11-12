# Uso de IA en el examen

El enunciado pide adjuntar los chats o hilos usados. Se usaron dos sesiones de Claude:

| Sesión | Herramienta | Rol | Hilo adjunto |
|---|---|---|---|
| WSL | Claude Code (terminal en WSL, con Remote Control) | Todo el código, Terraform, AWS CLI, Python, dbt/Airflow y git | [`claude_code_wsl.txt`](claude_code_wsl.txt) (export con `/export`) · sesión: https://claude.ai/code/session_01EycHxF1W36KqrAdeHc6xPS |
| Windows | Claude Cowork + extensión de Chrome | Solo capturas de la consola de AWS y de Airflow (lectura, sin crear ni borrar nada) | https://claude.ai/share/7d220164-2bf0-4403-8943-dbdcab8e1e74 |

La sesión de WSL incluye también la preparación previa al examen (entorno, plantillas, scripts) y la verificación del
entorno Docker del docente. Las dos sesiones se coordinaron con archivos compartidos: `CAPTURAS.md` (qué capturar) y
`ESTADO_COWORK.md` (dónde quedaron las capturas).

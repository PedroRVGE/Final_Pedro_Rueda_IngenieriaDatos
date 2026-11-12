# Prompts de preparación del examen

Instrucciones con las que se arrancaron las dos sesiones de IA antes del examen (2026-11-09). Cada sesión recibió el
mensaje "lee INSTRUCCIONES_*.md y ejecútalo".

| Archivo | Sesión | Qué define |
|---|---|---|
| [`INSTRUCCIONES_WSL.md`](INSTRUCCIONES_WSL.md) | Claude Code en WSL | FASE 1 de preparación (herramientas, entorno conda offline, Terraform con mirror, plantillas de AWS, scripts de verificación y evidencias, repo de entrega) y FASE 2 del examen (plan, OK, evidencias, destroy y verificación) |
| [`INSTRUCCIONES_COWORK.md`](INSTRUCCIONES_COWORK.md) | Claude Cowork + extensión de Chrome | Rol de solo lectura: capturas de la consola de AWS según `CAPTURAS.md`, sin crear ni borrar recursos |

Notas:
- En `INSTRUCCIONES_WSL.md` el perfil de AWS se cambió de `final` a `taller` durante la preparación (el usuario IAM ya
  existía con ese perfil); es la única modificación respecto al original.
- El resultado de esa preparación y del examen está en el hilo completo: [`../chat_ia/`](../chat_ia/).

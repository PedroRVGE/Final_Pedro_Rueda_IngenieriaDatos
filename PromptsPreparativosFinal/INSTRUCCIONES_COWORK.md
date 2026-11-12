# INSTRUCCIONES — Sesión Cowork + extensión de Chrome (carpeta `Final\` de Windows)

> Pedro abre Cowork con esta carpeta y te dice: "lee INSTRUCCIONES_COWORK.md y ejecútalo".
> Ejecuta la **FASE 1** ahora y quédate esperando. Pedro pondrá el enunciado en `enunciado\` (hoy vacía)
> y te avisará: ahí empieza la **FASE 2**.

## Contexto
- Examen final de Ingeniería de Datos (EIA 2026-2), AWS + Terraform. Se permite usar Claude.
- Tu ÚNICO rol: tomar capturas de evidencia en la consola de AWS con Chrome.
  **Nunca crees, modifiques ni borres nada** y no hagas clic en eliminar, detener, modificar ni en asistentes de creación.
  Todo el código y los recursos los maneja otra sesión: Claude Code en WSL.
- Región: **us-east-2 (Ohio)**. Pedro deja iniciada la consola de AWS con su usuario IAM (no root).
- La sesión de WSL te deja en esta carpeta `CAPTURAS.md` (lista de capturas con URL, clics, qué debe verse y nombre de archivo).
  Tú escribes aquí `ESTADO_COWORK.md`, que la sesión de WSL lee para saber dónde quedan tus capturas.
- Todo lo que necesites debería estar instalado ya; en el examen se puede descargar algo si hace falta, pero la idea es no necesitarlo.

---

## FASE 1 — Preparación (ejecutar ya)

1. Verifica que la extensión de Chrome responde: lista las pestañas y abre una nueva.
2. Abre https://us-east-2.console.aws.amazon.com/console/home?region=us-east-2 y confirma que hay sesión iniciada, con qué usuario
   y en qué región. Si no hay sesión, pídele a Pedro que inicie sesión (tú no escribes contraseñas).
3. Prueba capturar 3 páginas de solo lectura de la consola: la lista de buckets de S3, el panel de IAM y Billing/Cost Explorer.
   Para cada una, averigua y anota **dónde queda guardado el archivo en Windows** (carpeta exacta y nombre que le pone).
   Si alguna no se puede capturar, anota cuál y por qué.
4. Escribe `ESTADO_COWORK.md` con: usuario y región de la consola, carpeta exacta donde caen las capturas,
   cómo se llaman los archivos, qué páginas no se pudieron capturar.
5. Cuando la sesión de WSL deje un `CAPTURAS.md` de prueba (FASE 1, paso 11 de la otra sesión), ejecútalo como en la FASE 2
   y avísale a Pedro para que diga "listo" a la otra sesión.
6. Dile a Pedro: "FASE 1 lista, esperando el enunciado" con un resumen de 3 líneas.

---

## FASE 2 — Examen (cuando Pedro avise que el enunciado está en `enunciado\`)

0. Lee el enunciado completo y anota qué evidencias pide (es la única fuente de verdad). Espera a que aparezca `CAPTURAS.md`
   (lo escribe la sesión de WSL con los nombres exactos de los recursos); si el enunciado pide algo que no está en la lista, díselo a Pedro.
1. Lee `CAPTURAS.md`. Para cada captura sin marcar: pestaña nueva → URL (us-east-2) → clics indicados → comprueba que se vea lo que dice
   "Qué TIENE que verse" → toma la captura.
2. Después de cada tanda, dile a Pedro en orden qué capturas tomaste y a qué nombre de la lista corresponde cada una
   (la sesión de WSL las renombra y mueve).
3. Si algo no se ve como se espera (recurso no existe, error, otra región), no lo inventes: díselo a Pedro.
4. Si no puedes capturar una página, dile cuál: Pedro la toma a mano (`Win + Shift + S`) siguiendo CAPTURAS.md.
5. Cuando Pedro diga "hay nuevas", vuelve a leer `CAPTURAS.md` y repite.

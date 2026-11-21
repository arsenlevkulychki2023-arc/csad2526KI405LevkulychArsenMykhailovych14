# Використання агента та проєкту

Усі команди нижче виконуй із кореня репозиторію.

## Запуск агента

1. Відкрий папку репозиторію у VS Code.
2. Відкрий Copilot Chat.
3. У списку агентів вибери `build-engineer`.
4. Для повного послідовного налаштування виконай:

   ```text
   /init
   ```

5. Для окремої перевірки проєкту виконай:

   ```text
   /check
   ```

## Локальна збірка та перевірка

На Linux/macOS запусти:

```bash
./ci.sh
```

На Windows запусти у PowerShell або Command Prompt:

```bat
ci.bat
```

Скрипт створює `.venv/`, якщо її ще немає, встановлює залежності, запускає pytest і копіює `src/hello.py` та `src/add.py` у `dist/`.

## Запуск Hello World

Після успішної збірки можна запустити зібраний файл:

```bash
python3 dist/hello.py
```

На Windows:

```bat
python dist\hello.py
```

Або запусти програму безпосередньо зі `src/` через скрипт запуску.

Linux/macOS:

```bash
./run.sh
```

Windows:

```bat
run.bat
```

## Запуск тестів

Linux/macOS:

```bash
.venv/bin/python -m pytest -v
```

Windows:

```bat
.venv\Scripts\python -m pytest -v
```

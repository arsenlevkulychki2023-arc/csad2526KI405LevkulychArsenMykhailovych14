# Архітектура агента Build Engineer

## 1. Які проблеми вирішує агент

Агент `build-engineer` автоматизує початкове налаштування невеликого кросплатформного Python-проєкту та його build-процесу. Він допомагає узгоджено створити scaffold, запуск у віртуальному середовищі, юніт-тести й CI для Windows, Linux і macOS. Агент перевіряє результати кожного етапу та має зберігати наявний вміст репозиторію, не створюючи дублікатів і не перезаписуючи файли без перевірки.

## 2. Skills та їхня відповідальність

- `project-scaffold` — створює початкову структуру Python-проєкту `hello`: `src/hello.py`, `src/add.py`, порожні каталоги `tests/` і `docs/`, а також `README.md`, якщо його ще немає.
- `build-and-test` — додає залежність `pytest`, конфігурацію pytest, тест додавання та кросплатформні скрипти запуску й CI. Скрипти використовують інтерпретатор із `.venv/` і готують файли в `dist/`.
- `github-actions` — налаштовує `.github/workflows/ci.yml` для матриці Ubuntu, Windows і macOS. Workflow викликає `ci.sh` або `ci.bat` та завантажує артефакти `dist/`.

## 3. Commands, доступні користувачу

- `/git-init` — перевіряє або ініціалізує Git і створює чи доповнює `.gitignore`.
- `/create-project` — створює початкову структуру Python-проєкту за skill `project-scaffold`.
- `/create-build` — налаштовує pytest, скрипти запуску та CI за skill `build-and-test`.
- `/create-actions` — створює або перевіряє GitHub Actions workflow за skill `github-actions`.
- `/check` — перевіряє інструкції, структуру проєкту, тести, запуск, CI та Git-ігнорування й виводить статус `PASS`/`FAIL`.
- `/init` — послідовно виконує початкове налаштування та перевірки, зупиняючись при першій помилці.

## 4. Потік даних між етапами

```text
project_name=hello
        |
        v
project-scaffold
        |
        +--> src/hello.py
        +--> src/add.py
        +--> tests/, docs/, README.md (за потреби)
                 |
                 v
build-and-test
        |
        +--> requirements.txt
        +--> pytest.ini
        +--> tests/test_basic.py
        +--> run.sh, run.bat
        +--> ci.sh, ci.bat
                 |
                 +--> створення/використання .venv/
                 +--> встановлення залежностей і запуск тестів
                 +--> копіювання src/hello.py та src/add.py у dist/
                          |
                          v
github-actions: .github/workflows/ci.yml
        |
        +--> Windows запускає ci.bat
        +--> Linux/macOS запускають ci.sh
        +--> завантаження dist/ як CI-артефакту
```

`project-scaffold` передає build-етапу вихідні модулі `src/hello.py` і `src/add.py`. `build-and-test` бере їх як вхідні файли та визначає залежності, тест, конфігурацію pytest і скрипти. GitHub Actions не дублює build-логіку: він делегує її скриптам `ci.sh` і `ci.bat`, після чого завантажує `dist/`.

## 5. Обробка помилок оркестратором `init`

`/init` читає та виконує prompt-файли строго по черзі: `git-init`, `create-project`, `create-build`, `create-actions`, `check`. Після кожного кроку він перевіряє результат за відповідним prompt. Якщо крок не пройшов перевірки, оркестратор зупиняється, не запускає наступні кроки, повідомляє номер і причину помилки, що потрібно виправити, та вже змінені файли. Невиконані кроки позначаються `SKIPPED`. Загальний успіх дозволений лише тоді, коли фінальний `/check` повернув `PASSED`.

## 6. Відповідність файлів їхнім ролям

| Роль | Розташування | Призначення |
|---|---|---|
| Agent | `.github/agents/` | Опис ролі, меж відповідальності, інструментів і правил роботи агента. |
| Skills | `.github/skills/` | Спеціалізовані інструкції для scaffold, build/test і GitHub Actions. |
| Commands | `.github/prompts/` | Виконувані користувачем prompt-команди та оркестратор `init`. |

## 7. Формат VS Code Copilot

Налаштування використовують формат VS Code Copilot: custom agents (`.agent.md`), prompt files (`.prompt.md`) і agent skills (`SKILL.md`). Вони зберігаються в `.github/` репозиторію та працюють разом: agent визначає роль, skills описують спеціалізовані процедури, а commands запускають окремі або послідовні сценарії.

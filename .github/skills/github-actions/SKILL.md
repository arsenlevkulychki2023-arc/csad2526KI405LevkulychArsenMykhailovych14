---
name: github-actions
description: "Застосовуй, коли потрібно створити або перевірити GitHub Actions workflow для Python-проєкту з наявними ci.sh і ci.bat на Ubuntu, Windows та macOS."
---

# GitHub Actions CI

## Коли застосовувати
Використовуй цей skill, коли потрібно налаштувати `.github/workflows/ci.yml` для кросплатформної перевірки Python-проєкту. Перед роботою переконайся, що в корені репозиторію вже є `ci.sh` і `ci.bat`. Workflow лише запускає ці скрипти; встановлення залежностей, тестування та створення `dist/` залишаються їхньою відповідальністю.

## Вхід
- `ci.sh` і `ci.bat` уже існують у корені репозиторію.

## Вихід
Створи `.github/workflows/ci.yml` з такими властивостями:
- Тригери `push` і `pull_request` для гілок `develop` та `master`.
- Одна job зі стратегією matrix для `ubuntu-latest`, `windows-latest` і `macos-latest`; `fail-fast: false`.
- Кроки: checkout, `actions/setup-python@v5` з `python-version: "3.12"`, запуск відповідного CI-скрипту та завантаження артефакту.
- На не-Windows runner запускається лише `./ci.sh` з `shell: bash`.
- На Windows runner запускається лише `ci.bat` з `shell: cmd`.
- Артефакт завантажується через `actions/upload-artifact@v4` з `path: dist/`, унікальним ім'ям `hello-${{ matrix.os }}` і `if-no-files-found: error`.
- У workflow немає секретних значень або згадок `token`, `password` чи `secret`.

## Правила роботи
1. Перевір наявність `.github/workflows/ci.yml`, `ci.sh` і `ci.bat`. Прочитай наявний workflow перед будь-якими змінами.
2. Якщо `ci.sh` або `ci.bat` відсутній, зупинись і повідом, що спершу потрібно створити їх за допомогою `build-and-test`.
3. Не перезаписуй наявний workflow без перевірки. Якщо він уже відповідає вимогам, залиш без змін. Якщо відрізняється, покажи конфлікт і внеси лише безпечні необхідні зміни, зберігши сторонній вміст.
4. Workflow має мати рівно одну job з matrix по трьох ОС. Не додавай паралельні job або інші кроки, що дублюють build чи test.
5. У `run`-кроках дозволені тільки виклики `./ci.sh` або `ci.bat` у відповідних умовних кроках. Не додавай прямих команд `python`, `python3`, `pip`, `pytest`, shell-команд встановлення залежностей чи інших build-команд.
6. Не додавай credentials, секретні змінні, `secrets`-контекст або значення доступу. Workflow повинен працювати без секретів.
7. Перевір executable bit `ci.sh`. Unix крок викликає його як `./ci.sh`, тому Git має зберігати режим `100755`. Якщо файл tracked і режим неправильний, виправ його командою `git update-index --chmod=+x -- ci.sh`. Якщо файл ще untracked, не змінюй Git index поза запитом; повідом, що executable bit потрібно закріпити після додавання файла до індексу.
8. Перевір YAML і всі критерії нижче. Перед завершенням покажи diff або список змін та результати перевірок.

## Структура workflow
Використовуй окремі умовні кроки для Unix-подібних runner і Windows. Unix-крок має `if: runner.os != 'Windows'`, `shell: bash` і єдиний рядок `run: ./ci.sh`. Windows-крок має `if: runner.os == 'Windows'`, `shell: cmd` і єдиний рядок `run: ci.bat`.

Для `setup-python` задай `python-version: "3.12"`. Артефакт завантажуй лише після запуску CI-скрипту, шляхом `dist/`; `if-no-files-found: error` має зробити відсутність результату помилкою job.

## Перевірки
1. Перевір валідність YAML. Якщо встановлено `actionlint`, запусти його для `.github/workflows/ci.yml`. Інакше, якщо доступний PyYAML, виконай:

   ```console
   python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml', encoding='utf-8'))"
   ```

   Якщо жоден валідатор недоступний, не стверджуй, що YAML перевірено; повідом про це.
2. Перевір, що workflow містить обидва тригери з гілками `develop` і `master`.
3. Перевір, що matrix містить усі три значення: `ubuntu-latest`, `windows-latest`, `macos-latest`, і встановлено `fail-fast: false`.
4. Перевір наявність checkout, `actions/setup-python@v5` з версією Python `3.12`, двох умовних запусків (`./ci.sh` для не-Windows та `ci.bat` для Windows) і upload-artifact з усіма заданими параметрами.
5. Переглянь кожен `run` у workflow: там мають бути лише `./ci.sh` або `ci.bat`, не прямі команди Python, pip чи pytest.
6. Переконайся, що вміст `ci.yml` не містить слів `token`, `password` або `secret` без урахування регістру. Наприклад, пошук не повинен знаходити збіг у `.github/workflows/ci.yml`.
7. Перевір, що `ci.sh` має Git mode `100755`. Якщо немає прав на виконання, Unix runner не зможе виконати `./ci.sh`; не вважай цю умову виконаною.
8. Якщо будь-яка перевірка не пройшла, повідом причину й не позначай workflow як успішно перевірений.

## Типова помилка
**`ci.sh` не має прав на виконання.** Виклик `./ci.sh` завершується помилкою на Linux/macOS, якщо executable bit не збережений у Git. Перевір режим файла; для tracked файла встанови його командою `git update-index --chmod=+x -- ci.sh`, потім повтори відповідну перевірку.

## Приклад
Вхід:

```text
ci.sh і ci.bat вже створені
Потрібен GitHub Actions CI для develop і master на Ubuntu, Windows та macOS
```

Очікуваний результат:

```text
.github/workflows/ci.yml
  push: develop, master
  pull_request: develop, master
  matrix: ubuntu-latest, windows-latest, macos-latest
  Unix run: ./ci.sh
  Windows run: ci.bat
  artifact: hello-${{ matrix.os }} з dist/
```

Після успішного запуску workflow кожна з трьох ОС має окремий успішний job і завантажений артефакт `dist/` з унікальним ім'ям.

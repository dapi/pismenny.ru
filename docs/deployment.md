---
title: Публикация pismenny.ru через GitHub Pages
doc_role: engineering
purpose: Определяет безопасную доставку изменений из master в GitHub Pages, публичную проверку и диагностику 404.
derived_from:
  - ../.github/workflows/pages.yml
must_not_define:
  - article_editorial_taxonomy
  - pismenny_blog_article_presentation
  - pismenny_blog_release_lifecycle
status: active
canonical_for:
  - pismenny_ru_deployment
  - pismenny_ru_public_verification
audience: humans_and_agents
---

# Публикация pismenny.ru через GitHub Pages

Этот документ — единственный источник операционных правил deployment для `pismenny.ru`: доставка изменений из репозитория в GitHub Pages, безопасная синхронизация с `master`, проверка публичной версии и диагностика 404.

Он **не определяет** содержание, редакционный профиль, HTML-контракт или условия перехода между публикационными состояниями. Для полного лонгрида используется [`docs/article-creation-checklist.md`](article-creation-checklist.md), для остальных публичных поверхностей сайта — [`docs/site-content-contract.md`](site-content-contract.md).

## Как устроена публикация

- Публичный домен задан файлом `CNAME`: `pismenny.ru`.
- GitHub Actions workflow [`.github/workflows/pages.yml`](../.github/workflows/pages.yml) запускается при push в `master` или вручную через `workflow_dispatch`.
- Workflow забирает содержимое корня репозитория как статический artifact и публикует его через GitHub Pages.
- Отдельной сборки, генератора сайта и production-сервера нет.
- Файл workflow — реализация этого процесса. Изменять его только при осознанном изменении deployment-архитектуры.

Коммит в локальном репозитории или даже успешный `git push` ещё не означает, что публичная страница уже обновилась: сначала должен успешно завершиться Pages workflow, затем новая версия должна стать доступна через публичный домен.

## Безопасная последовательность публикации

### 1. Проверить локальную область изменений

```sh
git branch --show-current
git status --short
git diff --check
git diff --stat
```

Публикующий коммит должен содержать только намеренные изменения. Не откатывать, не перезаписывать и не включать в него чужие или параллельные изменения.

### 2. Зафиксировать намеренные файлы

Добавить явно перечисленные файлы, ещё раз проверить staged diff и создать коммит:

```sh
git add path/to/file another/path
git diff --cached --check
git diff --cached
git commit -m "Describe the publication"
```

Не использовать `git add .`, если рабочее дерево содержит несвязанные изменения.

### 3. Синхронизироваться с удалённым `master`

После создания локального коммита:

```sh
git fetch origin
git rev-list --left-right --count HEAD...origin/master
git log --oneline --left-right HEAD...origin/master
```

В выводе `git rev-list --left-right --count HEAD...origin/master` вторая цифра показывает число удалённых коммитов, которых ещё нет локально. Если она равна нулю, `origin/master` уже является предком `HEAD`, будущий push будет fast-forward и rebase не нужен. Если вторая цифра больше нуля, сначала добиться чистого рабочего дерева, затем выполнить:

```sh
git rebase origin/master
```

Не запускать rebase поверх оставшихся чужих или несвязанных незакоммиченных изменений. Не прятать их автоматически: либо согласовать отдельный commit/stash с владельцем, либо провести синхронизацию в отдельном чистом рабочем дереве.

Если rebase обнаружил конфликт, остановиться, определить владельца пересекающихся изменений и разрешить конфликт осознанно. Не использовать force push и не удалять чужие правки ради публикации.

После rebase повторить проверки:

```sh
git status --short
git diff --check origin/master...HEAD
git diff --stat origin/master...HEAD
```

### 4. Отправить `master`

Workflow публикует только изменения, попавшие в `master`:

```sh
git push origin master
```

Публикация другой ветки сама по себе не запускает production deployment.

### 5. Дождаться GitHub Pages

При установленном GitHub CLI:

```sh
gh run list --workflow pages.yml --branch master --limit 5
gh run watch RUN_ID --exit-status
```

Передать в `gh run watch` идентификатор нужного запуска из `gh run list`. Альтернатива — открыть Actions в GitHub и проверить оба job: `build` и `deploy`.

Нормальна небольшая задержка между push, завершением Actions и обновлением ответа с `pismenny.ru`. Первичный 404 во время незавершённого workflow ещё не доказывает ошибку страницы.

## Проверка публичной версии

Проверять нужно точный URL изменённой страницы, а не только главную:

```sh
curl -fsSIL https://pismenny.ru/articles/{slug}.html
curl -fsSL https://pismenny.ru/articles/{slug}.html | rg '<title>|canonical|robots|article:type'
```

Для hero:

```sh
curl -fsSIL https://pismenny.ru/articles/assets/{slug}-hero.png
```

Для опубликованной статьи дополнительно проверить discovery-поверхности:

```sh
curl -fsSL https://pismenny.ru/articles/ | rg '{slug}'
curl -fsSL https://pismenny.ru/sitemap.xml | rg '{slug}'
curl -fsSL https://pismenny.ru/articles/feed.xml | rg '{slug}'
```

Для черновика ожидается обратное: сама страница и hero отдаются по прямой ссылке, страница содержит `noindex,nofollow,noarchive`, а slug отсутствует в index, sitemap и feed.

После машинной проверки открыть страницу в браузере и проверить как минимум:

- заголовок, видимый статус и отсутствие повторяющегося лида;
- загрузку hero и его кадрирование;
- внешние и внутренние ссылки;
- мобильную и десктопную ширину.

## Диагностика 404 и старой версии

Проверять уровни по порядку.

### 1. Коммит действительно дошёл до `origin/master`

```sh
git fetch origin
git log -1 --oneline origin/master
git show origin/master:articles/{slug}.html >/dev/null
```

Если последняя команда не находит файл, проблема находится до deployment: неверный коммит, ветка, путь или имя файла.

### 2. Workflow завершился успешно

Проверить последний запуск `pages.yml`. При ошибке открыть логи конкретного job. Пока `deploy` не завершился успешно, CDN проверять рано.

### 3. URL точно соответствует пути и регистру

GitHub Pages различает регистр. Для файла `articles/example.html` проверять `/articles/example.html`, а не другое написание, путь с `draft` или старый slug. Workflow загружает корень репозитория (`path: .`), поэтому публичный путь повторяет путь файла.

### 4. Проверить ответ без догадок браузера

```sh
curl -sS -D - -o /dev/null https://pismenny.ru/articles/{slug}.html
curl -fsSL 'https://pismenny.ru/articles/{slug}.html?verify=COMMIT_SHA' | head
```

Параметр проверки помогает отличить устаревший браузерный или промежуточный кэш от отсутствующего файла. Он не меняет канонический URL и не должен попадать в ссылки.

### 5. Локализовать проблему домена

Если все страницы на `pismenny.ru` недоступны, проверить `CNAME`, настройки custom domain в GitHub Pages, DNS и TLS. Если главная и старые статьи открываются, а новая возвращает 404, вероятнее ошибка commit/workflow/path, а не DNS.

### 6. Повторить после завершения доставки

После успешного `deploy` дать GitHub Pages и CDN несколько минут и повторить точный `curl`. Если 404 сохраняется, приложить к диагностике:

- SHA опубликованного коммита;
- URL и ожидаемый путь файла;
- ссылку или идентификатор Pages run;
- заголовки ответа `curl`;
- результат `git show origin/master:{path}`.

Это позволяет отличить ошибку содержимого репозитория, workflow, маршрута и публичной доставки.

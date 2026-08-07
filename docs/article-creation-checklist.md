---
title: Контракт представления и выпуска статей на pismenny.ru
doc_role: spec
purpose: Определяет, как исходная статья из my-os представляется и проверяется, а состояния publication record проецируются на HTML-лонгрид pismenny_blog.
derived_from:
  - repo://dapi/my-os/content/article-editorial-policy.md
  - repo://dapi/my-os/content/publication-strategy.md
  - repo://dapi/my-os/content/publications/README.md
must_not_define:
  - article_editorial_taxonomy
  - article_review_profiles
  - publication_target_model
  - cross_channel_adaptation_policy
  - public_canonical_url_policy
  - public_canonical_url_storage
  - publication_status_values
  - pismenny_site_content_presentation
  - hero_visual_style
  - github_pages_deployment
status: active
canonical_for:
  - pismenny_blog_article_presentation
  - pismenny_blog_release_lifecycle
audience: humans_and_agents
---

# Контракт представления и выпуска статей на pismenny.ru

Этот документ — единственный источник требований к тому, как каноническая статья из `my-os` представляется и выпускается как `publication_target: pismenny_blog`: полный HTML-лонгрид в `/articles/`. Он также регулирует техническое включение лонгрида в article index, sitemap и feed. Самостоятельные страницы, карточки и подборки цели `pismenny_site` определены в [`docs/site-content-contract.md`](site-content-contract.md). Старое имя файла сохранено, чтобы не ломать существующие ссылки и агентские инструкции.

## Границы ответственности

Контракт определяет:

- стабильный URL и HTML-структуру страницы статьи;
- отображение редакционного профиля, но не смысл его значений;
- HTML meta, Open Graph, Twitter Card и JSON-LD;
- подключение hero-изображения;
- техническое оформление внешних и внутренних ссылок;
- HTML-проекцию состояния publication item на `pismenny.ru`;
- переход страницы между защищённым черновым, опубликованным и снятым представлением;
- локальные проверки перед выпуском.

Контракт **не определяет**:

- типы статей, основание знания и профиль редакторского ревью;
- правила исследования, аргументации, глоссария и состава источников;
- роли площадок, выбор публичной канонической версии и допустимую адаптацию текста;
- визуальный язык или процесс генерации иллюстрации;
- механику GitHub Pages и порядок `git push`.

Владельцы этих требований:

- редакционная семантика — [`my-os/content/article-editorial-policy.md`](/Users/danil/code/my-os/content/article-editorial-policy.md);
- стратегия публикаций и отношения между исходной статьёй и площадками — [`my-os/content/publication-strategy.md`](/Users/danil/code/my-os/content/publication-strategy.md);
- значения статусов и фактический canonical URL — [`my-os/content/publications/README.md`](/Users/danil/code/my-os/content/publications/README.md) и record конкретной статьи;
- карточки, подборки и самостоятельные страницы сайта — [`docs/site-content-contract.md`](site-content-contract.md);
- визуальный стиль — skill `pismenny-editorial-systems`;
- публикация репозитория — [`docs/deployment.md`](deployment.md).

Если требования расходятся, содержание и редакционный профиль берутся из `my-os`, а способ их HTML-представления на сайте — из этого документа.

## Исходная статья и URL

- Канонический авторский исходник находится в `my-os/articles/`; HTML в этом репозитории является представлением для конкретной площадки.
- Страница хранится как `articles/{slug}.html` и публикуется по адресу `https://pismenny.ru/articles/{slug}.html`.
- `slug` выбирается до первой публикации и после этого не меняется без отдельного плана редиректа.
- Ни путь файла, ни URL не должны содержать статус или слова `draft`, `final`, `published`, а также суффиксы редакций `v1`, `v2`.
- Переход из черновика в опубликованное состояние не переименовывает файл и не меняет URL.
- `public_canonical_url` выбирается по стратегии `my-os` и фиксируется в publication record. Для обычной публикации `pismenny_blog` он совпадает со стабильным URL страницы.
- `<link rel="canonical">`, `og:url` и JSON-LD получают `public_canonical_url`; контракт определяет способ отображения, но не переопределяет выбор основной публичной версии.

## Редакционный профиль: только проекция

Значения и публичные подписи `article_type` и `content_basis` определяет редакционная политика `my-os`. Этот документ не дублирует их enum, смысл или правила выбора. `article_type` является редакционным жанром, а `article_section` — отдельной тематической рубрикой.

Для новой статьи сайт получает редакционный профиль из исходника и проецирует его так:

| Поле исходника | Представление на `pismenny.ru` |
|---|---|
| `article_type` | Видимая метка из таблицы редакционной политики; `<meta name="article:type">` |
| `content_basis` | Дополнительная видимая метка только тогда, когда её разрешает редакционная политика; `<meta name="article:content_basis">` со значениями через запятую |
| `article_section` | Тематическая рубрика; Open Graph `article:section`; JSON-LD `articleSection` |

Основная метка `article_type` показывается в видимых метаданных статьи. Если `content_basis` содержит `author_experience`, рядом можно показать дополнительную редакционную метку «Из практики»; остальные основания не выводятся как обязательные бейджи.

Такое разделение следует семантике [Schema.org `articleSection`](https://schema.org/articleSection), где поле обозначает раздел издания, и [Open Graph `article:section`](https://ogp.me/#type_article), где ожидается название верхнеуровневого раздела, например Technology.

Не придумывать собственные названия типов в HTML и не переносить `content_basis` в нестандартные свойства Schema.org. Изменение enum или публичной подписи сначала вносится в редакционную политику, затем отражается на сайте.

## Обязательные отображения метаданных

Одна единица данных должна иметь один видимый источник и синхронно заполнять машинные представления:

| Данные | HTML страницы | Meta / Open Graph / Twitter | JSON-LD `Article` |
|---|---|---|---|
| Название | один `<h1>` | `<title>`, `og:title`, `twitter:title` | `headline` |
| Описание | один лид или подзаголовок | `description`, `og:description`, `twitter:description` | `description` |
| Автор | видимое имя | `author`, `article:author` | `author` типа `Person` |
| Дата выпуска | `<time datetime="YYYY-MM-DD">` | `article:published_time` | `datePublished` |
| Дата изменения, если есть | `<time datetime="YYYY-MM-DD">` | `article:modified_time` | `dateModified` |
| Тип статьи | видимая метка из редакционной политики | `article:type` | нестандартное поле не добавляется |
| Тематическая рубрика | при необходимости ссылка или подпись рубрики | `article:section` | `articleSection` |
| URL | ссылка не обязательна | `canonical`, `og:url` | `url`, `mainEntityOfPage` |
| Hero | один видимый `<img>` | `og:image`, `twitter:image` и оба `*:image:alt` | `image` |
| Язык | `<html lang="ru">` | `og:locale=ru_RU` | `inLanguage=ru` |
| Статус publication item | Защитная пометка для `draft` и `review` | `robots` и `googlebot` по правилам lifecycle ниже | нестандартное поле не добавляется |

Дополнительно:

- `og:type` для статьи — `article`;
- `twitter:card` — `summary_large_image`;
- абсолютные URL обязательны в `canonical`, Open Graph и JSON-LD;
- значения дат должны совпадать во всех представлениях;
- JSON-LD должен быть валидным JSON внутри `<script type="application/ld+json">`;
- заголовок, описание или лид не выводятся дважды только ради заполнения метаданных.

## Hero-изображение

Интеграционный контракт сайта фиксирован:

- размер — ровно `1200×630` пикселей;
- формат — PNG;
- путь в репозитории — `articles/assets/{slug}-hero.png`;
- публичный URL — `https://pismenny.ru/articles/assets/{slug}-hero.png`;
- один содержательный `alt` используется у видимого `<img>`, в `og:image:alt` и `twitter:image:alt`;
- тот же абсолютный URL используется в `og:image`, `twitter:image` и JSON-LD `image`;
- видимый hero располагается один раз после заголовка и метаданных статьи, до основного текста;
- изображение не растягивается и сохраняет соотношение сторон `1200:630` на мобильной и десктопной ширине.

Визуальную метафору, палитру, фактуру и процесс генерации определяет skill `pismenny-editorial-systems`. Skill получает путь назначения от этого контракта и не должен задавать другой путь для `pismenny.ru`.

## Ссылки

### Внешние

Внешняя ссылка открывается в новой вкладке и всегда содержит безопасные атрибуты:

```html
<a href="https://example.com/source" target="_blank" rel="noopener noreferrer">Название источника</a>
```

Если для ссылки действительно требуется `nofollow`, он добавляется без удаления защитных значений:

```html
<a href="https://example.com/source" target="_blank" rel="nofollow noopener noreferrer">Название источника</a>
```

Анкор должен называть материал или место назначения, а не быть голым URL или текстом «здесь». Требование о том, какие источники нужны статье, принадлежит редакционной политике, а не этому HTML-контракту.

### Внутренние

- Использовать стабильный публичный URL без статуса и номера редакции.
- Для страниц внутри `pismenny.ru` не добавлять `target="_blank"` без специальной причины.
- Не ссылаться из опубликованной статьи на черновик как на доступный всем материал без явной пометки.
- Решение о смысловой перелинковке принимает редакционный процесс; этот контракт определяет только корректность URL.

## Проекция `publication_status` в HTML

Полный enum и его смысл определяет контракт publication record в `my-os`; этот документ не вводит собственные значения. Не смешивать `publication_status` конкретного item с `status` исходного Markdown-документа. Черновик исходника не становится автоматически доступным на сайте, а редактирование опубликованного source не меняет статус HTML автоматически.

| `publication_status` из record | Представление `pismenny_blog` |
|---|---|
| `not_started` | HTML-artifact отсутствует |
| `planned` | Публичный HTML-artifact ещё не требуется |
| `draft` | Защищённое черновое представление по прямой ссылке |
| `review` | Локальное preview либо то же защищённое представление по прямой ссылке; публично страница остаётся помеченной как черновик |
| `published` | Индексируемая статья на стабильном URL и во всех discovery-поверхностях |
| `retired` | Статья удалена из discovery; URL перенаправлен на преемника, если инфраструктура это поддерживает, или оставлен как явно архивный `noindex`-материал |

### Защищённое представление: `draft` и публичный `review`

Черновое представление можно развернуть для проверки по прямой стабильной ссылке. Оно должно:

- отдавать обычную страницу по тому же URL, который сохранится после выпуска;
- содержать `<meta name="robots" content="noindex,nofollow,noarchive">`;
- содержать `<meta name="googlebot" content="noindex,nofollow,noarchive">`;
- явно показывать `Черновик` в видимых метаданных статьи;
- отсутствовать в `articles/index.html`;
- отсутствовать в `sitemap.xml`;
- отсутствовать в `articles/feed.xml`.

### Опубликованное представление: `published`

При выпуске страницы:

1. Удалить видимую метку `Черновик`.
2. Удалить `noindex,nofollow,noarchive` для `robots` и `googlebot`; не оставлять противоречивые директивы.
3. Добавить статью в `articles/index.html`.
4. Добавить канонический URL в `sitemap.xml`.
5. Добавить публикацию в `articles/feed.xml`.
6. Сохранить прежние файл, slug, URL и hero-путь.
7. Проверить публичную страницу по процедуре из [`docs/deployment.md`](deployment.md).

Если опубликованную страницу временно возвращают в `draft` или `review`, переход выполняется целиком в обратную сторону: директивы возвращаются, а ссылки из трёх discovery-поверхностей удаляются.

### Снятое представление: `retired`

1. Удалить статью из article index, sitemap и feed.
2. Если есть явный преемник и выбранная статическая реализация умеет корректный redirect, настроить его. Не считать HTML meta refresh эквивалентом HTTP-редиректа без отдельного решения.
3. В остальных случаях сохранить стабильный URL как архив, добавить `noindex,nofollow,noarchive` и видимую метку «Архив».
4. Не превращать снятие в случайный 404: выбранное поведение фиксируется в publication record.

## Локальный чеклист перед выпуском

### Для любого состояния

- [ ] HTML-файл называется `articles/{slug}.html`, а canonical указывает на этот же публичный путь.
- [ ] Название, описание, автор, даты, URL, тип, тематическая рубрика и hero согласованы между своими видимыми и машинными представлениями.
- [ ] Редакционный `article_type` не записан в `article:section` или JSON-LD `articleSection` вместо тематической рубрики.
- [ ] Описание или лид визуально не продублированы.
- [ ] JSON-LD разбирается как JSON.
- [ ] Hero существует по пути `articles/assets/{slug}-hero.png` и имеет размер `1200×630`.
- [ ] Внешние ссылки имеют `target="_blank"` и `rel="noopener noreferrer"`.
- [ ] Страница проверена на десктопной и мобильной ширине.
- [ ] В `git diff` нет случайных изменений других статей или ассетов.

Для локальной проверки удобно запустить из корня репозитория:

```sh
python3 -m http.server 8000
```

И открыть `http://localhost:8000/articles/{slug}.html`. Размер PNG на macOS проверяется командой:

```sh
sips -g pixelWidth -g pixelHeight articles/assets/{slug}-hero.png
```

JSON-LD можно извлечь из страницы и проверить любым JSON-парсером; перед коммитом как минимум убедиться, что блок не содержит синтаксической ошибки и все URL абсолютные.

### Для `draft` и публичного `review`

- [ ] Обе директивы `noindex,nofollow,noarchive` присутствуют.
- [ ] Видимая метка `Черновик` присутствует один раз.
- [ ] Slug отсутствует в `articles/index.html`, `sitemap.xml` и `articles/feed.xml`.

### Для `published`

- [ ] Директивы `noindex` и видимая метка `Черновик` удалены.
- [ ] Статья присутствует ровно один раз в `articles/index.html`, `sitemap.xml` и `articles/feed.xml`.
- [ ] Дата и URL в feed/sitemap совпадают со страницей.
- [ ] После GitHub Pages deployment выполнена публичная проверка.

### Для `retired`

- [ ] Статья отсутствует в index, sitemap и feed.
- [ ] Работает поддерживаемый инфраструктурой редирект либо страница явно помечена как архивная и закрыта от индексации.
- [ ] Publication record содержит фактическое поведение URL и дату проверки.

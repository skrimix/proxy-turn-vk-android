# qWDTT

qWDTT — Android-приложение для подключения к собственному VPS через TURN-инфраструктуру звонков VK.

Приложение создаёт системный VPN-туннель на телефоне, передаёт зашифрованный трафик через VK TURN и выпускает его в интернет через ваш сервер. Для сети такое соединение похоже на медиатрафик звонка WebRTC, а не на обычное прямое подключение к VPN-серверу.

## Быстрый старт

1. Скачайте APK в разделе [Releases](https://github.com/SpaceNeuroX/proxy-turn-vk-android/releases).
2. Добавьте VPS на вкладке «Серверы» и выполните установку серверной части.
3. Создайте профиль подключения или импортируйте готовую ссылку.
4. Добавьте хеш звонка VK.
5. Нажмите «Подключить» и разрешите Android создать VPN-соединение.

## Сборки

- стабильные подписанные версии публикуются в [GitHub Releases](https://github.com/SpaceNeuroX/proxy-turn-vk-android/releases);
- тестовые debug-сборки ветки `develop` доступны в [GitHub Actions](https://github.com/SpaceNeuroX/proxy-turn-vk-android/actions/workflows/android-debug.yml).

## Docker Compose

Docker-вариант запускает сервер в отдельном bridge network namespace. Интерфейс
`wdtt0`, IP forwarding и правила NAT создаются внутри контейнера, а не напрямую
в сетевом namespace VPS. Docker по-прежнему создаёт свои обычные bridge/NAT
правила для опубликованных портов.

Raw-режим включён по умолчанию на UDP-порту `56003`. Порт задаётся через
`WDTT_RAW_PORT` в `.env` и должен совпадать с Raw-портом в настройках Android.
Разрешите входящий UDP-трафик на этот порт в firewall VPS.
`WDTT_PUBLIC_PORT` по-прежнему задаёт внешний TCP/UDP-порт WireGuard-транспорта
и API (по умолчанию `56000`).

Требования: Linux VPS, Docker Compose и доступный `/dev/net/tun`.

```bash
cp .env.example .env
chmod 600 .env
# Задайте надёжный WDTT_PASSWORD в .env
docker compose up -d --build
docker compose logs -f server
```

Остановить сервер:

```bash
docker compose down
```

Конфигурация, база паролей и WireGuard-ключи хранятся в именованном Docker
volume `wdtt-data` и сохраняются после `docker compose down`. Для полного
удаления данных volume нужно удалить отдельно.

## Обсуждение и поддержка

- [Группа qWDTT в Telegram](https://t.me/darkbit_chat)
- [Поддержать разработку](https://pay.cloudtips.ru/p/64a6c43c)

## Лицензия

Проект распространяется по лицензии [GNU GPL v3](LICENSE).

## Происхождение проекта

При создании qWDTT в качестве технической основы использовались исходники Android-приложения и серверной части оригинального проекта [WDTT](https://github.com/amurcanov/proxy-turn-vk-android). Оригинальный репозиторий сейчас архивирован.

qWDTT — самостоятельное развитие этой кодовой базы: приложение, интерфейс, режимы подключения, управление серверами и значительная часть клиентской и серверной логики развиваются отдельно. Проект не является официальным продолжением или новым релизом оригинального WDTT.

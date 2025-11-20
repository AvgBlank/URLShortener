# 🔗 trim.lol — URL Shortener (Flask + MongoDB)

![Status](https://img.shields.io/badge/status-active-brightgreen)
![Runtime](https://img.shields.io/badge/python-3.12%2B-3776AB?logo=python)
![Backend](https://img.shields.io/badge/backend-Flask-000000?logo=flask)
![Database](https://img.shields.io/badge/database-MongoDB-47A248?logo=mongodb)
![Auth](https://img.shields.io/badge/auth-Google%20OAuth-4285F4?logo=google)
![Server](https://img.shields.io/badge/server-Gunicorn-499848?logo=gunicorn)
![Deploy](https://img.shields.io/badge/Deploy-Vercel-000000?logo=vercel)
![Container](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&logoColor)
![Package](https://img.shields.io/badge/package-uv-6E56CF?logo=python&logoColor)

trim.lol is a simple, privacy‑friendly URL shortener built with Flask and MongoDB. It lets you generate short links with either random IDs (via Hashids) or custom aliases, track basic click counts, and manage your links from a minimal dashboard. Authentication is intentionally lightweight: you can log in using a generated User ID or with Google OAuth.

## Table of Contents

- [Live Services](#live-services)
- [Repository Structure](#repository-structure)
- [Tech Stack](#tech-stack)
- [High-Level Architecture](#high-level-architecture)
- [Features](#features)
- [API Endpoints](#api-endpoints)
- [Installation (Local Development)](#installation-local-development)
  - [Prerequisites](#prerequisites)
  - [1) Clone](#1-clone)
  - [2) Environment variables](#2-environment-variables)
  - [3) Install dependencies](#3-install-dependencies)
  - [4) Start development](#4-start-development)
  - [Docker Compose](#docker-compose)
- [Usage Guide](#usage-guide)
- [Roadmap](#roadmap)
- [Authors](#authors)

<a id="live-services"></a>

## 📌 Live Services

| Layer | Platform | Link                          |
| ----- | -------- | ----------------------------- |
| Web   | Vercel   | https://trim-lol.vercel.app   |

<a id="repository-structure"></a>

## 📁 Repository Structure

```
URLShortener/
├─ app.py                 # Flask app: routes, MongoDB integration, OAuth
├─ server.py              # Gunicorn launcher (binds 127.0.0.1:5261)
├─ pyproject.toml         # Project metadata + dependencies
├─ docker-compose.yml     # MongoDB + web service (Flask) definitions
├─ Dockerfile             # Production image (uv + gunicorn)
├─ vercel.json            # Vercel config (framework: flask)
├─ to-do.md
├─ static/
│  └─ images/             # Favicon, logo, background image
└─ templates/             # Jinja templates
   ├─ base.html           # Tailwind (CDN) + shared layout
   ├─ index.html          # Landing (Sign up / Login / Google Login)
   ├─ signup.html         # Generate a new User ID (or Google Sign-In)
   ├─ login.html          # Login with User ID (or Google)
   ├─ generateurl.html    # Create short link (random or custom alias)
   ├─ stats.html          # Your links, clicks, copy/delete actions
   └─ 404.html            # Not found page
```

<a id="tech-stack"></a>

## 🛠 Tech Stack

- Language: Python 3.12+
- Backend: Flask, Jinja2, Gunicorn
- Database: MongoDB (`pymongo`)
- Auth: Google OAuth (`authlib`) and cookie-based sessions
- URL IDs: `hashids` (randomized, salt-based)
- Config: `python-dotenv`
- Timezone: `pytz`
- HTTP: `requests`
- UI: Tailwind CSS via CDN templates
- Infra: Docker, Docker Compose, Vercel
- Package/Env: `uv` (PEP 621 `pyproject.toml` + `uv sync`)

<a id="high-level-architecture"></a>

## 🧩 High-Level Architecture

```
Browser (Jinja templates)
   |
   v
Flask app (app.py)
 - Routes: signup/login/google OAuth, generate, stats, delete, redirect
 - A session cookie identifies the current user
   |
   v
MongoDB (collections)
 - users: { ID, UserID }
 - urls:  { ID, Timestamp, OriginalURL, ShortenedURL, Clicks, UserID }

External: Google OAuth via authlib (login/signup using email as UserID)
```

- Redirects: any `GET /<id>` looks up `ShortenedURL` and redirects to `OriginalURL` while incrementing `Clicks`.
- Domain: links render as `DOMAIN + ShortenedURL` where `DOMAIN` defaults to `https://trim.lol/` (override via env).

<a id="features"></a>

## 🚀 Features

- Accounts
  - Generate a unique User ID and store as cookie
  - Login with existing User ID
  - Login/Sign up with Google OAuth (email becomes `UserID`)
- Short Links
  - Random IDs via Hashids (salted with `userID`)
  - Custom alias (validated to avoid spaces/punctuation/URLs)
  - Prevents shortening of `trim.lol`, `bit.ly`, `tinyurl.com` links
- Dashboard
  - List your links with original URL, short URL, clicks, timestamp
  - Copy to clipboard, delete link
  - Basic refresh to re-enable form after creation
- Redirects
  - `/<id>` redirects to original URL and increments click count
- Styling
  - Tailwind CSS via CDN, responsive layouts, dark UI

<a id="api-endpoints"></a>

## 📡 API Endpoints

Base URL (local): `http://127.0.0.1:5261` (via `server.py`/Gunicorn)  
Optional dev server: `http://127.0.0.1:5000` (via `app.py`/Flask dev)

| Endpoint            | Method | Description                                           | Access                 |
| ------------------- | ------ | ----------------------------------------------------- | ---------------------- |
| `/`                 | GET    | Landing page, clears cookie if present                | Public                 |
| `/signup`           | GET    | Show signup (generate new User ID)                    | Public                 |
| `/signup`           | POST   | Create new `UserID`, set cookie                       | Public                 |
| `/login`            | GET    | Show login form                                       | Public                 |
| `/login`            | POST   | Login using existing `UserID`                         | Public                 |
| `/login/google`     | GET    | Start Google OAuth flow                               | Public                 |
| `/authorize/google` | GET    | OAuth callback; sets `userID` cookie                  | Public                 |
| `/generateurl`      | GET    | Render form to create short link                      | Auth (cookie required) |
| `/generateurl`      | POST   | Create new short link (random/custom)                 | Auth (cookie required) |
| `/stats`            | GET    | List current user’s links + copy/delete actions       | Auth (cookie required) |
| `/delete`           | POST   | Delete a link for current user (JSON `shortened_url`) | Auth (cookie required) |
| `/<id>`             | GET    | Redirect by short ID and increment click counter      | Public                 |
| `/logout`           | GET    | Clear cookie and return to home                       | Public                 |
| `/404`              | GET    | Not found page                                        | Public                 |

<a id="installation-local-development"></a>

## ⚙️ Installation (Local Development)

<a id="prerequisites"></a>

### Prerequisites

- Python 3.12+
- MongoDB (local or remote URI)
- Google OAuth 2.0 credentials (Client ID/Secret) — required on startup
- `uv` package manager (recommended): https://docs.astral.sh/uv

<a id="1-clone"></a>

### 1) Clone

```zsh
git clone https://github.com/AvgBlank/URLShortener.git
cd URLShortener
```

<a id="2-environment-variables"></a>

### 2) Environment variables

Create `.env` in the repository root and fill the values:

```env
# Required
SECRET_KEY=your-secret-key
link=mongodb://localhost:27017/
google_client_id=your-google-client-id
google_client_secret=your-google-client-secret

# Optional
DOMAIN=http://127.0.0.1:5261/
```

Notes:
- `link` is the MongoDB connection string. In Docker Compose, it is set to `mongodb://database:27017/`.
- `DOMAIN` is used when rendering shortened links in the UI.

<a id="3-install-dependencies"></a>

### 3) Install dependencies (uv recommended)

Using `uv` (creates `.venv` and installs from `pyproject.toml`):

```zsh
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# From repo root
uv sync
```

Alternative (pip + venv):

```zsh
python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install authlib flask gunicorn hashids jinja2 pymongo python-dotenv pytz requests
```

<a id="4-start-development"></a>

### 4) Start development

Recommended (runs Gunicorn on `127.0.0.1:5261` via `server.py`):

```zsh
# with uv
uv run server.py

# or with an activated venv
python server.py
```

Optional (Flask dev server on `127.0.0.1:5000`):

```zsh
# with uv
uv run app.py

# or with an activated venv
python app.py
```

<a id="docker-compose"></a>

### Docker Compose

Runs MongoDB and the web app together on `http://localhost:5261`.

```zsh
docker compose up --build
```

Environment is read from `.env` plus the Compose `environment` block.

## 🧪 Usage Guide

- Web app
  - Visit local (recommended): `http://127.0.0.1:5261`
  - Or dev server: `http://127.0.0.1:5000` (if using Flask dev)
  - Sign Up → copy your generated `User ID`
  - Or Login with existing `UserID`, or use Google Login
  - Create a short URL in “Generate URL”
    - Optional: provide a custom alias
  - View and manage your links in “Statistics”

- Example: delete a link via API (when logged in via browser cookie)

## 👥 Authors

- AvgBlank — https://github.com/AvgBlank
- AalokeCode — https://github.com/AalokeCode

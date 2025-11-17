FROM ghcr.io/astral-sh/uv:python3.13-alpine

EXPOSE 5261

WORKDIR /URLShortner/

COPY ./pyproject.toml ./pyproject.toml

RUN uv sync

CMD ["gunicorn", "app:app", "--workers", "4", "--bind", "0.0.0.0:5261"]

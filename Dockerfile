# ---------- Stage 1: builder ----------
FROM python:3.10-slim AS builder

# Устанавливаем зависимости для сборки Python-библиотек
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git curl && \
    rm -rf /var/lib/apt/lists/*

# Устанавливаем Python-зависимости
RUN pip install --no-cache-dir \
    "numpy<2" \
    torch==2.2.0+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html \
    git+https://github.com/openai/whisper.git \
    uvicorn fastapi python-multipart

# ---------- Stage 2: final ----------
FROM python:3.10-slim

# Только ffmpeg для работы Whisper
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Копируем Python и библиотеки
COPY --from=builder /usr/local /usr/local

# Копируем приложение
WORKDIR /app
COPY server.py .

EXPOSE 8020

CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8020"]


############# VERSION 2 #############
# ---------- Stage 1: builder ----------
FROM python:3.10-slim AS builder

# Устанавливаем только то, что нужно для сборки Python-библиотек
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git curl ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Устанавливаем зависимости Python с фиксированным numpy
RUN pip install --no-cache-dir \
    "numpy<2" \
    torch==2.2.0+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html \
    git+https://github.com/openai/whisper.git \
    uvicorn fastapi python-multipart

# ---------- Stage 2: final ----------
FROM python:3.10-slim

# Только runtime-зависимости
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Копируем только установленный Python и библиотеки
COPY --from=builder /usr/local /usr/local

# Копируем приложение
WORKDIR /app
COPY server.py .

# Проброс порта
EXPOSE 8020

# Команда запуска
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8020"]

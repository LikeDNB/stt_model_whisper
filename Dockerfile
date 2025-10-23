# Запуск
FROM python:3.10-slim

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    git \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем Python-зависимости
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir \
        "numpy<2" \
        torch==1.13.1+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html \
        git+https://github.com/openai/whisper.git \
        "SpeechRecognition[whisper-local]" \
        pydub \
        imageio-ffmpeg \
        uvicorn \
        fastapi \
        python-multipart

# Настраиваем ffmpeg для pydub
RUN python -c "import imageio_ffmpeg as ffmpeg; from pydub import AudioSegment; AudioSegment.converter = ffmpeg.get_ffmpeg_exe()"

# Create non-root user
RUN useradd -m -u 1000 appuser

# Копируем сервер
WORKDIR /app
COPY server.py /app/server.py

# Set permissions
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Открываем порт
EXPOSE 8020

# Запуск
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8020"]

FROM pytorch/pytorch:2.2.0-cpu-py3.10

# Устанавливаем только runtime зависимости
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY server.py .

RUN pip install --no-cache-dir git+https://github.com/openai/whisper.git uvicorn fastapi python-multipart

EXPOSE 8020

CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8020"]

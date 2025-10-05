FROM python:3.10-slim

RUN apt-get update && apt-get install -y --no-install-recommends git ffmpeg && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY server.py .
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt --index-url https://download.pytorch.org/whl/cpu

EXPOSE 8020
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8020"]

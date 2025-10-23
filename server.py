from fastapi import FastAPI, UploadFile, File
import uvicorn
import speech_recognition as sr
from pydub import AudioSegment
import tempfile
import os
import io

app = FastAPI()
recognizer = sr.Recognizer()

@app.post("/transcribe")
async def transcribe_audio(file: UploadFile = File(...)):
    # Временный файл
    suffix = file.filename.split('.')[-1] if '.' in file.filename else 'wav'
    with tempfile.NamedTemporaryFile(suffix=f".{suffix}", delete=False) as tmp:
        contents = await file.read()
        tmp.write(contents)
        tmp_path = tmp.name

    try:
        # Конвертация MP3 в WAV, если нужно
        audio_path = tmp_path
        if suffix.lower() == "mp3":
            wav_tmp = tempfile.NamedTemporaryFile(suffix=".wav", delete=False)
            wav_tmp.close()
            audio_path = wav_tmp.name
            AudioSegment.from_mp3(tmp_path).export(audio_path, format="wav")

        # Распознавание через Whisper
        with sr.AudioFile(audio_path) as source:
            audio_data = recognizer.record(source)
            text = recognizer.recognize_whisper(audio_data, model="tiny")  # можно tiny/base/small

        return {"text": text}

    except sr.UnknownValueError:
        return {"error": "Не удалось распознать речь"}
    except sr.RequestError as e:
        return {"error": f"Ошибка распознавания: {e}"}
    finally:
        # Убираем временные файлы
        os.remove(tmp_path)
        if audio_path != tmp_path:
            os.remove(audio_path)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8020)

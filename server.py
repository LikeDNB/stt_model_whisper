from fastapi import FastAPI, UploadFile, File
import whisper
import uvicorn
import tempfile

app = FastAPI()

model = whisper.load_model("tiny")  # Можно tiny/base/small/medium/large

@app.post("/transcribe")
async def transcribe_audio(file: UploadFile = File(...)):
    # Сохраняем временный файл
    with tempfile.NamedTemporaryFile(suffix=".wav") as tmp:
        contents = await file.read()
        tmp.write(contents)
        tmp.flush()
        
        # Распознаём аудио
        result = model.transcribe(tmp.name)
        
    return {"text": result["text"]}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8020)

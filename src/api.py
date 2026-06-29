import base64
import io
import sys
from pathlib import Path

# 루트에서 `uvicorn src.api:app`으로 실행할 때 pipeline·count_utils 를 찾을 수 있도록
# src/ 디렉터리를 sys.path 맨 앞에 추가한다.
sys.path.insert(0, str(Path(__file__).parent))

import cv2
import numpy as np
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from PIL import Image

from ocr_utils import recognize_serials_for_result
from pipeline import DEFAULT_WEIGHTS, detect_firearms, load_model

app = FastAPI(title="ROKA 총기류 탐지 API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

_model = None


def _get_model():
    global _model
    if _model is None:
        _model = load_model(DEFAULT_WEIGHTS)
    return _model


@app.on_event("startup")
def _preload():
    _get_model()


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/detect")
async def detect(file: UploadFile = File(...), conf: float = 0.7, read_serial: bool = True):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="이미지 파일만 업로드 가능합니다.")

    contents = await file.read()
    image_pil = Image.open(io.BytesIO(contents)).convert("RGB")
    img_array = np.array(image_pil)

    model = _get_model()
    counts, results = detect_firearms(model, img_array, conf=conf)

    result = results[0]
    if read_serial and len(result.boxes) > 0:
        serials = recognize_serials_for_result(result)
    else:
        serials = [{"text": None, "confidence": 0.0}] * len(result.boxes)

    detections = [
        {
            "class": model.names[int(cls_id)],
            "confidence": round(float(conf_val), 4),
            "serialNumber": serial["text"],
            "serialConfidence": serial["confidence"],
        }
        for cls_id, conf_val, serial in zip(
            result.boxes.cls.tolist(), result.boxes.conf.tolist(), serials
        )
    ]

    # 바운딩박스가 그려진 annotated 이미지를 base64로 인코딩해서 함께 반환
    annotated_bgr = result.plot()
    annotated_rgb = cv2.cvtColor(annotated_bgr, cv2.COLOR_BGR2RGB)
    buf = io.BytesIO()
    Image.fromarray(annotated_rgb).save(buf, format="JPEG", quality=85)
    annotated_b64 = base64.b64encode(buf.getvalue()).decode()

    return JSONResponse({
        "counts": counts,
        "detections": detections,
        "total": sum(counts.values()),
        "annotatedImage": annotated_b64,
    })

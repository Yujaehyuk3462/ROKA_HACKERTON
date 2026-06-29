"""
총기 일련번호 인식 모듈
- serial_yolo.pt 가 있으면 YOLOv8 digit detection 사용 (학습된 모델)
- 없으면 EasyOCR 폴백
"""
import re
from functools import lru_cache
from pathlib import Path

import cv2
import numpy as np

_DIGIT_PATTERN = re.compile(r"\d{4,8}")
_SERIAL_MODEL_PATH = Path(__file__).parent / "serial_yolo.pt"
_DIGIT_NAMES = list("0123456789")


# ── YOLOv8 digit 모델 ─────────────────────────────────────────────
@lru_cache(maxsize=1)
def _get_digit_model():
    from ultralytics import YOLO
    return YOLO(str(_SERIAL_MODEL_PATH))


def _recognize_yolo(crop_bgr: np.ndarray) -> dict:
    model = _get_digit_model()
    results = model(crop_bgr, verbose=False, conf=0.3)

    if not results or results[0].boxes is None or len(results[0].boxes) == 0:
        return {"text": None, "confidence": 0.0}

    boxes = results[0].boxes
    confs = boxes.conf.tolist()
    classes = boxes.cls.tolist()
    xyxy = boxes.xyxy.tolist()

    # 왼쪽→오른쪽 정렬 후 자릿수 조립
    detections = sorted(zip(xyxy, classes, confs), key=lambda d: d[0][0])
    digits = "".join(_DIGIT_NAMES[int(cls)] for _, cls, _ in detections)

    m = _DIGIT_PATTERN.search(digits)
    if not m:
        return {"text": None, "confidence": 0.0}

    avg_conf = sum(c for _, _, c in detections) / len(detections)
    return {"text": m.group(), "confidence": round(float(avg_conf), 4)}


# ── EasyOCR 폴백 ──────────────────────────────────────────────────
@lru_cache(maxsize=1)
def _get_easyocr_reader():
    import easyocr
    return easyocr.Reader(["en"], gpu=False)


def _recognize_ocr(crop_bgr: np.ndarray) -> dict:
    gray = cv2.cvtColor(crop_bgr, cv2.COLOR_BGR2GRAY)
    reader = _get_easyocr_reader()
    results = reader.readtext(gray, allowlist="0123456789")
    candidates = [
        (match.group(), conf)
        for _, text, conf in results
        for match in [_DIGIT_PATTERN.search(text)]
        if match
    ]
    if not candidates:
        return {"text": None, "confidence": 0.0}
    text, conf = max(candidates, key=lambda c: c[1])
    return {"text": text, "confidence": round(float(conf), 4)}


# ── 공통 전처리 + 라우팅 ──────────────────────────────────────────
def _crop_with_margin(image: np.ndarray, box, margin_ratio: float = 0.08) -> np.ndarray:
    h, w = image.shape[:2]
    x1, y1, x2, y2 = box
    mx = (x2 - x1) * margin_ratio
    my = (y2 - y1) * margin_ratio
    x1 = max(0, int(x1 - mx))
    y1 = max(0, int(y1 - my))
    x2 = min(w, int(x2 + mx))
    y2 = min(h, int(y2 + my))
    return image[y1:y2, x1:x2]


def recognize_serial(image: np.ndarray, box, upscale: int = 3) -> dict:
    """
    총기 bbox 영역에서 일련번호(숫자열)를 인식한다.

    image: BGR numpy 배열 (원본 이미지)
    box:   (x1, y1, x2, y2) 픽셀 좌표
    반환:  {"text": "2231140" | None, "confidence": 0.0~1.0}
    """
    crop = _crop_with_margin(image, box)
    if crop.size == 0:
        return {"text": None, "confidence": 0.0}

    crop = cv2.resize(crop, None, fx=upscale, fy=upscale, interpolation=cv2.INTER_CUBIC)

    if _SERIAL_MODEL_PATH.exists():
        return _recognize_yolo(crop)
    return _recognize_ocr(crop)


def recognize_serials_for_result(result) -> list[dict]:
    """YOLO Results 객체 하나에 대해 박스별 일련번호 인식 결과 리스트를 반환한다."""
    image = result.orig_img
    return [recognize_serial(image, box) for box in result.boxes.xyxy.tolist()]

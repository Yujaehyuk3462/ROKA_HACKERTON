from pathlib import Path

from ultralytics import YOLO

from count_utils import count_by_class

# __file__ 기준 절대 경로로 지정 — 어느 디렉터리에서 실행해도 모델을 찾을 수 있음
DEFAULT_WEIGHTS = str(Path(__file__).parent.parent / "models" / "firearms_yolo_no_m16" / "best.pt")


def load_model(weights_path: str = DEFAULT_WEIGHTS) -> YOLO:
    return YOLO(weights_path)


def detect_firearms(model: YOLO, source, conf: float = 0.7, save: bool = False):
    """입력 이미지를 YOLO 모델로 분석해 (클래스별 개수, raw 결과)를 반환한다."""
    results = model.predict(source=source, conf=conf, save=save)
    counts = count_by_class(results, model.names)
    return counts, results

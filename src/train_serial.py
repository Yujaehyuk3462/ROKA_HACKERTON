#!/usr/bin/env python3
"""
총기 일련번호 숫자 인식 YOLOv8 모델 학습 스크립트
- 데이터셋: riflenumber.v1i.yolov8 (18장, 0~9 digits, polygon 포맷)
- 폴리곤 → bbox 변환 후 YOLOv8n detection 학습
- 출력: src/serial_yolo.pt
"""
import shutil
from pathlib import Path

import yaml

DATASET_DIR = Path(r"C:\Users\hse09\Documents\카카오톡 받은 파일\riflenumber.v1i.yolov8")
SRC_DIR = Path(__file__).parent
CONVERTED_DIR = SRC_DIR / "serial_dataset"
RUNS_DIR = SRC_DIR / "runs"
OUTPUT_MODEL = SRC_DIR / "serial_yolo.pt"


# ── 폴리곤 라벨 → YOLO bbox 변환 ────────────────────────────────
def polygon_to_bbox(values: list[float]) -> tuple[float, float, float, float]:
    """polygon 좌표 시퀀스(x1 y1 x2 y2 ...) → YOLO cx cy w h (정규화)."""
    xs = values[0::2]
    ys = values[1::2]
    xmin, xmax = min(xs), max(xs)
    ymin, ymax = min(ys), max(ys)
    cx = (xmin + xmax) / 2
    cy = (ymin + ymax) / 2
    w = xmax - xmin
    h = ymax - ymin
    return cx, cy, w, h


def convert_labels(src_label_dir: Path, dst_label_dir: Path) -> None:
    dst_label_dir.mkdir(parents=True, exist_ok=True)
    for lbl_path in src_label_dir.glob("*.txt"):
        lines_out = []
        for line in lbl_path.read_text().splitlines():
            parts = line.strip().split()
            if len(parts) < 5:
                continue
            cls_id = int(parts[0])
            coords = list(map(float, parts[1:]))
            if len(coords) < 4 or len(coords) % 2 != 0:
                continue
            cx, cy, w, h = polygon_to_bbox(coords)
            lines_out.append(f"{cls_id} {cx:.6f} {cy:.6f} {w:.6f} {h:.6f}")
        (dst_label_dir / lbl_path.name).write_text("\n".join(lines_out))


def prepare_dataset() -> Path:
    print("[1/3] 폴리곤 라벨 → bbox 변환 중...")
    src_img = DATASET_DIR / "train" / "images"
    src_lbl = DATASET_DIR / "train" / "labels"

    dst_img = CONVERTED_DIR / "train" / "images"
    dst_lbl = CONVERTED_DIR / "train" / "labels"
    dst_img.mkdir(parents=True, exist_ok=True)

    # 이미지 복사
    for img in src_img.glob("*"):
        shutil.copy(img, dst_img / img.name)

    # 라벨 변환 복사
    convert_labels(src_lbl, dst_lbl)

    # val 세트 없으므로 train을 공유
    for split in ("val",):
        (CONVERTED_DIR / split / "images").mkdir(parents=True, exist_ok=True)
        (CONVERTED_DIR / split / "labels").mkdir(parents=True, exist_ok=True)
        for img in src_img.glob("*"):
            shutil.copy(img, CONVERTED_DIR / split / "images" / img.name)
        convert_labels(src_lbl, CONVERTED_DIR / split / "labels")

    # data.yaml 생성
    cfg = {
        "path": str(CONVERTED_DIR.resolve()),
        "train": "train/images",
        "val": "val/images",
        "nc": 10,
        "names": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    }
    cfg_path = CONVERTED_DIR / "data.yaml"
    cfg_path.write_text(yaml.dump(cfg, allow_unicode=True))
    print(f"    데이터셋 준비 완료: {CONVERTED_DIR}")
    return cfg_path


def train(cfg_path: Path) -> None:
    from ultralytics import YOLO

    print("[2/3] YOLOv8n 학습 시작 (CPU, ~150 epoch)...")
    model = YOLO("yolov8n.pt")
    model.train(
        data=str(cfg_path),
        epochs=150,
        imgsz=640,
        batch=4,
        patience=40,
        project=str(RUNS_DIR),
        name="serial_yolo",
        device="cpu",
        optimizer="AdamW",
        lr0=0.001,
        lrf=0.01,
        # 소규모 데이터셋 보완을 위한 augmentation
        degrees=15.0,
        scale=0.4,
        shear=5.0,
        hsv_h=0.02,
        hsv_s=0.4,
        hsv_v=0.4,
        fliplr=0.3,
        mosaic=0.8,
        mixup=0.1,
        exist_ok=True,
        verbose=True,
    )


def export_model() -> None:
    print("[3/3] best.pt 복사...")
    best = RUNS_DIR / "serial_yolo" / "weights" / "best.pt"
    if best.exists():
        shutil.copy(best, OUTPUT_MODEL)
        print(f"    저장 완료: {OUTPUT_MODEL}")
    else:
        print(f"    [경고] best.pt 없음: {best}")


def main():
    cfg_path = prepare_dataset()
    train(cfg_path)
    export_model()
    print("\n=== 학습 완료 ===")
    print(f"모델 경로: {OUTPUT_MODEL}")
    print("서버 재배포 후 serial_yolo.pt 가 자동으로 사용됩니다.")


if __name__ == "__main__":
    main()

import argparse

from ultralytics import YOLO


def parse_args():
    parser = argparse.ArgumentParser(description="군수품(총기류) 탐지 YOLO 모델 학습")
    parser.add_argument("--data", default="data/data.yaml", help="data.yaml 경로")
    parser.add_argument("--model", default="yolov8n.pt", help="베이스 모델(사전학습 가중치)")
    parser.add_argument("--epochs", type=int, default=100)
    parser.add_argument("--imgsz", type=int, default=640)
    parser.add_argument("--batch", type=int, default=16)
    parser.add_argument("--project", default="models", help="결과 저장 폴더")
    parser.add_argument("--name", default="firearms_yolo", help="실험 이름")
    parser.add_argument("--device", default="0", help="학습 장치 (예: 0=GPU 0번, cpu=CPU)")
    return parser.parse_args()


def main():
    args = parse_args()
    model = YOLO(args.model)
    model.train(
        data=args.data,
        epochs=args.epochs,
        imgsz=args.imgsz,
        batch=args.batch,
        project=args.project,
        name=args.name,
        device=args.device,
    )


if __name__ == "__main__":
    main()

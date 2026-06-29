import argparse

from pipeline import DEFAULT_WEIGHTS, detect_firearms, load_model


def parse_args():
    parser = argparse.ArgumentParser(description="이미지에서 총기류 종류/개수 탐지")
    parser.add_argument("source", help="이미지 파일 또는 폴더 경로")
    parser.add_argument("--weights", default=DEFAULT_WEIGHTS)
    parser.add_argument("--conf", type=float, default=0.7)
    parser.add_argument("--save", action="store_true", help="박스가 그려진 결과 이미지 저장")
    parser.add_argument("--read-serial", action="store_true", help="OCR로 총번(숫자) 인식 시도")
    return parser.parse_args()


def main():
    args = parse_args()
    model = load_model(args.weights)
    counts, results = detect_firearms(model, args.source, conf=args.conf, save=args.save)

    print("탐지 결과 (클래스별 개수):")
    for name, count in counts.items():
        print(f"  {name}: {count}")
    print(f"총 개수: {sum(counts.values())}")

    if args.read_serial:
        from ocr_utils import recognize_serials_for_result

        print("\n총번(OCR) 인식 결과:")
        for result in results:
            for cls_id, conf_val, serial in zip(
                result.boxes.cls.tolist(),
                result.boxes.conf.tolist(),
                recognize_serials_for_result(result),
            ):
                name = model.names[int(cls_id)]
                text = serial["text"] or "인식 실패"
                print(f"  {name} (탐지 conf {conf_val:.2f}) -> 총번: {text} (OCR conf {serial['confidence']:.2f})")

    if args.save and results:
        print(f"결과 이미지 저장 위치: {results[0].save_dir}")


if __name__ == "__main__":
    main()

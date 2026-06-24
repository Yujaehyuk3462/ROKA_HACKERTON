from collections import Counter


def count_by_class(results, class_names):
    """YOLO 추론 결과(list of ultralytics Results)에서 클래스별 탐지 개수를 집계한다."""
    counter = Counter()
    for result in results:
        for cls_id in result.boxes.cls.tolist():
            counter[class_names[int(cls_id)]] += 1
    return dict(counter)

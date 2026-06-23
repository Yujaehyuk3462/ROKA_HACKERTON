# db/ — Firebase 기반 DB 모듈

이 폴더는 **스마트 군수물자 관리 앱**의 DB 구현을 담당하는 부분이다.
YOLO 모델 학습(`data/`, `models/`, `src/`)과는 독립적으로 동작하며, 아직 앱(`src/app.py`)과는 통합되지 않은 상태다.

자세한 설계 배경/필드 명세는 `DB_설계문서.txt`를 참고할 것.

---

## 1. 컬렉션 구조

```
Firestore
 ├─ weapons            화기 마스터 (k1 / k2 / k2c1 / m16, 4개 문서 고정)
 ├─ images             라벨링된 참고 사진 카탈로그 (Storage 경로 + 메타데이터)
 └─ detectionRecords   탐지 결과 기록 (앱 연동 전, 모듈 단위로만 구현됨)

Cloud Storage
 └─ weapons/{weaponClass}/{filename}.jpg
```

- **문서ID(`weapons.code`)와 `images.weaponClass`, `detectionRecords.confirmedDetections[].class`는 모두 YOLO 모델의 클래스명(`data_combined.yaml`의 `names`)과 소문자로 정확히 일치시킨다.** 현재 학습된 클래스는 `m16`, `k2`이며, `k1`, `k2c1`은 아직 학습 데이터셋에 없지만 동일한 표기 규칙(소문자, 약칭)으로 미리 등록해 두었다. 이렇게 맞춰두면 YOLO 출력값을 변환 없이 그대로 `weapons` 조회에 쓸 수 있다.
  - 주의: `m16`은 정식 명칭 "M16A1"과 다른 약칭이다. `code` 필드는 식별자(YOLO와 일치)이고, `officialName` 필드가 실제 정식 명칭("M16A1 소총")이다. 둘을 혼동하지 말 것.
- `images`는 YOLO 학습 파이프라인을 대체하지 않는다. 실제 학습 데이터는 팀원이 관리하는 로컬 Roboflow 데이터셋(`data/*.yaml`)을 그대로 쓰고, 여기서는 사진 원본/정보를 보존·카탈로그화·향후 내보내기 용도로만 사용한다.
- `assetItems`, `storageLocations`, `discrepancies` 등 재고 비교 기능은 설계 단계에서 다뤘으나 아직 구현하지 않음 (향후 확장).

---

## 2. 파일 목록

| 파일 | 역할 |
|---|---|
| `firebase_config.py` | Firebase Admin SDK 초기화 (다른 스크립트들은 이 모듈을 통해서만 Firebase에 접근) |
| `seed_weapons.py` | `weapons` 마스터 컬렉션 초기 등록 |
| `upload_dataset.py` | 라벨링된 사진 + 메타데이터를 Storage/Firestore에 업로드 |
| `detection_store.py` | 탐지 결과를 `detectionRecords`에 저장하는 모듈 (앱 미연동, 단독 테스트만 가능) |
| `firestore.rules` | Firestore 보안 규칙 |
| `storage.rules` | Cloud Storage 보안 규칙 |

---

## 3. 처음 설정하는 방법

### 3-1. Firebase 프로젝트 준비

1. [console.firebase.google.com](https://console.firebase.google.com)에서 프로젝트 생성 (현재 `roka-hackathon` 사용 중)
2. **Firestore Database** 활성화 — Standard 버전, 프로덕션 모드, 리전 `asia-northeast3 (서울)`
3. **Storage** 활성화 — ⚠️ Firebase 정책상 **Blaze(종량제) 요금제로 업그레이드해야** 새 버킷을 만들 수 있다. 업그레이드 시 예산 알림(Budget Alert)을 낮게 설정해 둘 것. 무료 한도(월 1GB 저장/10GB 다운로드) 내에서는 과금되지 않는다.

### 3-2. 서비스 계정 키 발급

1. 프로젝트 설정 → 서비스 계정 탭 → "새 비공개 키 생성"
2. 다운로드한 JSON 파일을 **`serviceAccountKey.json`으로 이름을 바꿔서** 이 폴더(`db/`)에 둔다
3. **절대 깃허브에 커밋하지 않는다.** (`.gitignore`에 이미 등록되어 있는지 확인할 것)

> 키가 노출(채팅, 이메일, 공개 레포 등)됐다면 즉시 콘솔에서 해당 키를 폐기하고 재발급한다. 발급된 키는 프로젝트 전체에 대한 관리자 권한을 가진다.

### 3-3. Python 환경

```bash
pip install firebase-admin pillow
```

### 3-4. `firebase_config.py`의 버킷 이름 확인

```python
STORAGE_BUCKET = os.environ.get("FIREBASE_STORAGE_BUCKET", "실제_버킷_이름")
```

콘솔의 Storage 메뉴 상단에 표시되는 정확한 버킷 이름을 그대로 넣을 것 (`프로젝트ID.appspot.com` 또는 `프로젝트ID.firebasestorage.app` 형태일 수 있음, 추측하지 말고 콘솔에서 확인).

---

## 4. 실행 순서

```bash
cd db

# 1) 화기 마스터 데이터 등록 (최초 1회)
python seed_weapons.py

# 2) 라벨링된 사진 업로드 (Storage 활성화 후, ./raw_data/{class}/*.jpg 구조로 정리되어 있어야 함)
python upload_dataset.py
```

실행 후 Firebase 콘솔 → Firestore Database → 데이터 탭에서 `weapons`, `images` 컬렉션에 문서가 생성됐는지 확인한다.

`detection_store.py`는 단독 호출용 모듈이라 직접 실행하는 파일이 아니다. 테스트하려면 별도 스크립트에서 `save_detection_record(...)`를 import해서 호출한다.

---

## 5. 보안 규칙 적용

Firebase 콘솔에서 적용한다 (CLI 로그인 문제로 `firebase deploy`가 막힌 경우의 대안).

1. Firestore → **규칙** 탭 → `firestore.rules` 내용 붙여넣기 → 게시
2. Storage → **규칙** 탭 → `storage.rules` 내용 붙여넣기 → 게시

규칙은 읽기는 공개 허용, 쓰기는 인증된 사용자만 허용한다. `firebase-admin` SDK(서비스 계정 키)로 실행하는 스크립트는 이 규칙을 우회하므로, 위 스크립트 실행에는 영향이 없다. 이 규칙은 추후 앱(클라이언트)이 Firestore에 직접 접근할 때부터 의미를 가진다.

---

## 6. 알려진 제약 / 주의사항

- `weapons` 마스터 데이터 중 `overallLengthMm`, `weightKg` 등 세부 제원은 아직 공식 출처로 검증되지 않아 `null`로 비워두고 `specsVerified: false`로 표시해 두었다. 임의로 수치를 채우지 말고 검증 후 업데이트할 것.
- 현재 YOLO 모델은 `m16`, `k2` 2종만 학습되어 있다(팀원 쪽 `data/data_combined.yaml` 기준). `weapons` 컬렉션은 4종(`k1`, `k2`, `k2c1`, `m16`) 모두 미리 등록해 두었으니, K1/K2C1 학습 데이터가 추가되는 대로 모델만 갱신하면 된다. 단, 추가될 클래스명이 `k1`, `k2c1`이 아닌 다른 표기로 정해지면 `weapons` 문서ID도 그에 맞춰 다시 등록해야 한다.
- `detectionRecords`는 아직 `src/app.py`와 통합되지 않았다. 통합 시 사용자가 오탐을 제거/확정하는 단계를 거친 뒤 `save_detection_record()`를 호출하도록 연결해야 한다. YOLO 출력 클래스명을 그대로 넘기면 되므로 별도 변환 매핑은 불필요하다.

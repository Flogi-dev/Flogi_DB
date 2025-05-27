-- 00_DB/main/schema/01_user/01_info_new.sql
-- Module: 01_user (사용자 모듈)
-- Description: 모든 사용자의 기본 정보를 저장합니다. (새 규칙 적용 버전)
-- Target DB: PostgreSQL Primary RDB
-- Requires: 00_common_helper_functions.sql, 00_common_global_enums.sql (또는 통합된 ENUM 파일)
--           CITEXT extension (CREATE EXTENSION IF NOT EXISTS citext;)

-- 사용자 정보 기본 테이블 (새 규칙 적용)
CREATE TABLE user_info_new (
  -- 🆔 기본 식별자 (새 규칙 적용)
  internal_user_info_uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(), -- 내부 전용 UUID PK
  user_info_public_id TEXT UNIQUE NOT NULL DEFAULT gen_random_id('usr_', 16), -- 외부 공개용 고유 ID (16자리 랜덤 문자열)

  -- 🔗 계정 연결 정보
  account_links JSONB DEFAULT '{}'::JSONB, -- 사용자의 다른 내부 서비스/모듈 계정 연결 정보. 예: {"team_uuid": "팀UUID", "organization_uuid": "조직UUID"}
  -- oauth_links JSONB: user_oauth 테이블로 기능 이전 또는 최소 정보만 캐싱. 여기서는 제거하고 user_oauth 테이블 직접 참조 권장.

  -- 👤 사용자 기본 정보
  username CITEXT UNIQUE, -- 사용자 별명 또는 로그인 ID (앱 레벨에서 고유성 및 정책 관리, CITEXT로 대소문자 무관 고유성)
                         -- NULL 허용 여부: MVP에서는 NULL 허용, 정식 서비스 시 NOT NULL 고려
  full_name TEXT,        -- 사용자 전체 이름 (실명)
  email CITEXT UNIQUE NOT NULL, -- 사용자 이메일 주소 (CITEXT로 대소문자 무관 고유성)
  phone CITEXT UNIQUE,   -- 사용자 전화번호 (CITEXT로 대소문자 무관 고유성, 국가번호 포함 저장 권장)
  profile_img_url TEXT,  -- 사용자 프로필 사진 URL (외부 저장소 URL)
  bio TEXT,              -- 사용자 자기소개

  -- ⚙️ 계정 상태 및 유형
  account_type user_account_type_enum NOT NULL DEFAULT 'individual'::user_account_type_enum, -- 계정 유형 (ENUM)
  account_status user_account_status_enum NOT NULL DEFAULT 'pending_verification'::user_account_status_enum, -- 계정 상태 (ENUM)
  is_active BOOLEAN NOT NULL DEFAULT FALSE, -- 계정 활성화 여부 (account_status와 연동되거나 별도 관리 가능, 여기서는 명시적 플래그)
  is_beta_tester BOOLEAN NOT NULL DEFAULT FALSE, -- 베타 테스터 여부
  email_verified_at TIMESTAMPTZ,          -- 이메일 인증 완료 시각 (UTC)
  phone_verified_at TIMESTAMPTZ,          -- 전화번호 인증 완료 시각 (UTC)

  -- 🌍 환경 설정
  nation TEXT,                           -- 사용자 국가 코드 (ISO 3166-1 Alpha-2, 예: KR, US)
  timezone TEXT DEFAULT 'UTC',           -- 사용자 선호 시간대 (IANA Time Zone Database, 예: Asia/Seoul). 기본값 UTC 권장.
  language TEXT DEFAULT 'en',            -- 사용자 선호 서비스 UI 언어 (예: ko, en)

  -- 📜 약관 동의
  agreed_terms_at TIMESTAMPTZ,           -- 서비스 이용약관 동의 시각 (UTC)
  agreed_privacy_at TIMESTAMPTZ,         -- 개인정보 수집 및 이용 동의 시각 (UTC)
  agreed_marketing_at TIMESTAMPTZ,       -- 마케팅 정보 수신 동의 시각 (UTC)

  -- 🔑 마지막 활동
  last_login_at TIMESTAMPTZ,             -- 마지막 로그인 시각 (UTC)

  -- 🕒 기록 타임스탬프 (새 규칙 적용)
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 레코드 생성 시각 (UTC)
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP  -- 레코드 마지막 수정 시각 (UTC)
);

-- 기존 테이블의 트리거와 유사하게 updated_at 자동 갱신 트리거 추가 필요
CREATE TRIGGER trg_user_info_new_set_updated_at
BEFORE UPDATE ON user_info_new
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at(); -- fn_set_updated_at 함수는 00_common_functions_and_types.sql 에 정의되어 있어야 함

-- Comments
COMMENT ON TABLE user_info_new IS '모든 사용자의 기본 정보를 저장하는 테이블 (UUID PK 및 새 규칙 적용 버전).';
COMMENT ON COLUMN user_info_new.internal_user_info_uuid IS '내부 시스템 전용 고유 식별자 (UUID, PK).';
COMMENT ON COLUMN user_info_new.user_info_public_id IS '외부에 공개될 수 있는 사용자의 고유 식별자 (TEXT, gen_random_id 사용).';
COMMENT ON COLUMN user_info_new.account_links IS '사용자의 다른 내부 서비스/모듈 계정 연결 정보 (JSONB). 예: {"team_uuid": "팀UUID", "organization_uuid": "조직UUID"}';
COMMENT ON COLUMN user_info_new.username IS '사용자 별명 또는 로그인 ID (CITEXT, UNIQUE, NULL 가능). 앱 레벨에서 고유성 및 정책 관리.';
COMMENT ON COLUMN user_info_new.full_name IS '사용자의 전체 이름 (실명).';
COMMENT ON COLUMN user_info_new.email IS '사용자 이메일 주소 (CITEXT, UNIQUE NOT NULL).';
COMMENT ON COLUMN user_info_new.phone IS '사용자 전화번호 (CITEXT, UNIQUE, NULL 가능). 국가번호 포함 권장.';
COMMENT ON COLUMN user_info_new.profile_img_url IS '사용자 프로필 사진 URL (외부 저장소 URL).';
COMMENT ON COLUMN user_info_new.bio IS '사용자 자기소개.';
COMMENT ON COLUMN user_info_new.account_type IS '사용자 계정 유형 (user_account_type_enum 참조). 기본값: individual.';
COMMENT ON COLUMN user_info_new.account_status IS '사용자 계정 상태 (user_account_status_enum 참조). 기본값: pending_verification.';
COMMENT ON COLUMN user_info_new.is_active IS '계정 활성화 여부 플래그. account_status와 연동될 수 있음. 기본값: FALSE.';
COMMENT ON COLUMN user_info_new.is_beta_tester IS '베타 테스터 여부. 기본값: FALSE.';
COMMENT ON COLUMN user_info_new.email_verified_at IS '이메일 인증 완료 시각 (TIMESTAMPTZ, UTC).';
COMMENT ON COLUMN user_info_new.phone_verified_at IS '전화번호 인증 완료 시각 (TIMESTAMPTZ, UTC).';
COMMENT ON COLUMN user_info_new.nation IS '사용자 국가 코드 (ISO 3166-1 Alpha-2).';
COMMENT ON COLUMN user_info_new.timezone IS '사용자 선호 시간대 (IANA Time Zone Database). 기본값: UTC.';
COMMENT ON COLUMN user_info_new.language IS '사용자 선호 서비스 UI 언어. 기본값: en.';
COMMENT ON COLUMN user_info_new.agreed_terms_at IS '서비스 이용약관 동의 시각 (TIMESTAMPTZ, UTC).';
COMMENT ON COLUMN user_info_new.agreed_privacy_at IS '개인정보 수집 및 이용 동의 시각 (TIMESTAMPTZ, UTC).';
COMMENT ON COLUMN user_info_new.agreed_marketing_at IS '마케팅 정보 수신 동의 시각 (TIMESTAMPTZ, UTC).';
COMMENT ON COLUMN user_info_new.last_login_at IS '마지막 로그인 시각 (TIMESTAMPTZ, UTC).';
COMMENT ON COLUMN user_info_new.created_at IS '레코드 생성 시각 (TIMESTAMPTZ, UTC). 기본값: 현재 시각.';
COMMENT ON COLUMN user_info_new.updated_at IS '레코드 마지막 수정 시각 (TIMESTAMPTZ, UTC). 기본값: 현재 시각 (트리거로 자동 업데이트).';

-- Indexes (새 규칙 및 컬럼명 변경에 따라 인덱스명도 조정)
-- user_info_public_id, email, phone, username은 UNIQUE 제약조건으로 자동 인덱스 생성됨.
CREATE INDEX idx_user_info_new_account_type ON user_info_new(account_type);
CREATE INDEX idx_user_info_new_account_status ON user_info_new(account_status);
CREATE INDEX idx_user_info_new_is_active ON user_info_new(is_active); -- 특정 값 필터링에 부분 인덱스 고려 가능
-- 예: CREATE INDEX idx_user_info_new_active_users ON user_info_new(internal_user_info_uuid) WHERE is_active = TRUE;

/*
설계 근거:
1. PK 규칙: `internal_user_info_uuid UUID PK DEFAULT uuid_generate_v4()` 적용.
2. 외부 ID 규칙: `user_info_public_id TEXT UNIQUE NOT NULL DEFAULT gen_random_id('usr_', 16)` 적용.
3. Timestamp 규칙: 모든 날짜/시간 컬럼 `TIMESTAMPTZ` (UTC 저장 가정) 적용. `timezone` 컬럼 기본값 'UTC'로 설정.
4. Email/Phone 규칙: `CITEXT` + `UNIQUE` 적용. (CITEXT 확장 필요 명시)
5. BOOLEAN 규칙: `NOT NULL DEFAULT FALSE` (또는 TRUE) 명시.
6. JSONB 규칙: `account_links` 컬럼에 내부 구조 예시 및 한글 주석 명시. (기존 `oauth_links`는 `user_oauth` 테이블과의 역할 중복으로 제거 고려)
7. 주석 블록: 파일 끝에 설계 근거 요약 (본 주석 블록이 해당).
*/
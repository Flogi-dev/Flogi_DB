-- 00_DB/main/schema/01_user/02_oauth_new.sql
-- Module: 01_user (사용자 모듈)
-- Description: 사용자의 OAuth 소셜 연동 정보를 저장합니다. (새 규칙 적용 버전)
-- Target DB: PostgreSQL Primary RDB
-- Requires: 00_common_helper_functions.sql, 00_common_global_enums.sql, 01_info_new.sql
--           CITEXT extension (CREATE EXTENSION IF NOT EXISTS citext;)

-- 사용자 소셜 연동 정보 테이블 (새 규칙 적용)
CREATE TABLE user_oauth_new (
  -- 🔗 user_info_new와 1:1 연결 (user_info_public_id 기반)
  user_info_public_id TEXT PRIMARY KEY REFERENCES user_info_new(user_info_public_id) ON DELETE CASCADE,
  -- user_info_new 테이블의 user_info_public_id를 참조하며, 사용자 탈퇴(user_info_new 레코드 삭제) 시 관련 OAuth 정보도 함께 삭제됩니다.

  -- 🟦 Google 연동 정보
  google_provider_id TEXT UNIQUE,        -- Google 플랫폼에서 발급된 사용자의 고유 ID (CITEXT 불필요, 제공자 ID는 대소문자 구분 가능성 있음)
  google_email CITEXT,                 -- Google 계정에 등록된 이메일 (user_info_new.email과 다를 수 있음, 정보 제공용, CITEXT로 중복 방지)
  google_profile_img_url TEXT,         -- Google 프로필 사진 URL

  -- 🟨 Kakao 연동 정보
  kakao_provider_id TEXT UNIQUE,         -- Kakao 플랫폼에서 발급된 사용자의 고유 ID
  kakao_email CITEXT,                  -- Kakao 계정에 등록된 이메일
  kakao_profile_img_url TEXT,          -- Kakao 프로필 사진 URL

  -- 🐙 GitHub 연동 정보
  github_provider_id TEXT UNIQUE,        -- GitHub 플랫폼에서 발급된 사용자의 고유 ID
  github_email CITEXT,                 -- GitHub 계정에 등록된 이메일
  github_profile_img_url TEXT,         -- GitHub 프로필 사진 URL

  -- ⚫️ Apple 연동 정보
  apple_provider_id TEXT UNIQUE,         -- Apple 플랫폼에서 발급된 사용자의 고유 ID
  apple_email CITEXT,                  -- Apple 계정의 이메일 주소 (비공개 릴레이 가능)
  apple_profile_img_url TEXT,          -- Apple 계정의 프로필 사진 URL

  -- (신규) 🏢 Naver 연동 정보 (예시로 추가, 필요시 확장)
  naver_provider_id TEXT UNIQUE,         -- Naver 플랫폼에서 발급된 사용자의 고유 ID
  naver_email CITEXT,                  -- Naver 계정에 등록된 이메일
  naver_profile_img_url TEXT,          -- Naver 프로필 사진 URL

  -- (신규) 🌐 기타 OAuth 제공자 정보 (확장성 고려)
  -- 만약 지원해야 할 OAuth 제공자가 매우 많아지거나 동적으로 추가/삭제되어야 한다면,
  -- EAV(Entity-Attribute-Value) 모델 또는 별도의 user_oauth_provider_details 테이블(user_info_public_id, provider_enum, provider_user_id, email, profile_img_url 등)로
  -- 정규화하는 방안을 장기적으로 고려할 수 있습니다. MVP에서는 현재와 같이 주요 제공자별 컬럼 유지.
  -- other_oauth_providers JSONB DEFAULT '{}'::JSONB, -- 예: {"custom_oidc": {"provider_id": "...", "email": "...", ...}}

  -- 🕒 기록 타임스탬프 (새 규칙 적용)
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 레코드 생성 시각 (UTC)
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP  -- 레코드 마지막 수정 시각 (UTC)
);

-- updated_at 자동 갱신 트리거
CREATE TRIGGER trg_user_oauth_new_set_updated_at
BEFORE UPDATE ON user_oauth_new
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at(); -- fn_set_updated_at 함수는 00_common_functions_and_types.sql 또는 헬퍼 함수 파일에 정의

-- Comments
COMMENT ON TABLE user_oauth_new IS '사용자의 OAuth 소셜 연동 정보를 저장하는 테이블 (새 규칙 적용 버전). user_info_new와 1:1 관계입니다.';
COMMENT ON COLUMN user_oauth_new.user_info_public_id IS 'user_info_new 테이블의 공개용 사용자 ID (TEXT, PK, FK).';

COMMENT ON COLUMN user_oauth_new.google_provider_id IS 'Google OAuth를 통해 얻은 사용자의 고유 식별자 (TEXT, UNIQUE).';
COMMENT ON COLUMN user_oauth_new.google_email IS 'Google 계정의 이메일 주소 (CITEXT). user_info_new.email과 다를 수 있습니다.';
COMMENT ON COLUMN user_oauth_new.google_profile_img_url IS 'Google 계정의 프로필 사진 URL (TEXT).';

COMMENT ON COLUMN user_oauth_new.kakao_provider_id IS 'Kakao OAuth를 통해 얻은 사용자의 고유 식별자 (TEXT, UNIQUE).';
COMMENT ON COLUMN user_oauth_new.kakao_email IS 'Kakao 계정의 이메일 주소 (CITEXT).';
COMMENT ON COLUMN user_oauth_new.kakao_profile_img_url IS 'Kakao 계정의 프로필 사진 URL (TEXT).';

COMMENT ON COLUMN user_oauth_new.github_provider_id IS 'GitHub OAuth를 통해 얻은 사용자의 고유 식별자 (TEXT, UNIQUE).';
COMMENT ON COLUMN user_oauth_new.github_email IS 'GitHub 계정의 이메일 주소 (CITEXT).';
COMMENT ON COLUMN user_oauth_new.github_profile_img_url IS 'GitHub 계정의 프로필 사진 URL (TEXT).';

COMMENT ON COLUMN user_oauth_new.apple_provider_id IS 'Apple OAuth를 통해 얻은 사용자의 고유 식별자 (TEXT, UNIQUE). Apple 비공개 이메일 릴레이 서비스 사용 여부도 고려해야 합니다.';
COMMENT ON COLUMN user_oauth_new.apple_email IS 'Apple 계정의 이메일 주소 (CITEXT, 비공개 릴레이 가능).';
COMMENT ON COLUMN user_oauth_new.apple_profile_img_url IS 'Apple 계정의 프로필 사진 URL (TEXT).';

COMMENT ON COLUMN user_oauth_new.naver_provider_id IS 'Naver OAuth를 통해 얻은 사용자의 고유 식별자 (TEXT, UNIQUE). (예시 추가)';
COMMENT ON COLUMN user_oauth_new.naver_email IS 'Naver 계정의 이메일 주소 (CITEXT). (예시 추가)';
COMMENT ON COLUMN user_oauth_new.naver_profile_img_url IS 'Naver 계정의 프로필 사진 URL (TEXT). (예시 추가)';

-- COMMENT ON COLUMN user_oauth_new.other_oauth_providers IS '기타 OAuth 제공자 정보를 유연하게 저장하기 위한 JSONB 필드. (장기적 확장성 고려)';

COMMENT ON COLUMN user_oauth_new.created_at IS '이 소셜 연동 레코드가 데이터베이스에 처음 생성된 시각 (TIMESTAMPTZ, UTC).';
COMMENT ON COLUMN user_oauth_new.updated_at IS '이 소셜 연동 정보가 마지막으로 갱신된 시각 (TIMESTAMPTZ, UTC). (예: 토큰 갱신 시 또는 프로필 정보 동기화 시)';

-- Indexes (새 규칙 및 컬럼명 변경에 따라 인덱스명도 조정)
-- user_info_public_id는 PK이므로 자동 인덱스.
-- 각 *_provider_id 컬럼은 UNIQUE 제약조건으로 자동 B-tree 인덱스 생성됨.
-- 필요시 이메일 컬럼에도 인덱스 추가 고려 (OAuth 제공자별 이메일로 사용자 검색 기능이 있다면)
-- 예: CREATE INDEX idx_user_oauth_new_google_email ON user_oauth_new(google_email) WHERE google_email IS NOT NULL;

/*
설계 근거:
1. PK 규칙: `user_info_new.user_info_public_id`를 PK이자 FK로 사용하여 `user_info_new`와 1:1 관계 명확화.
2. 외부 ID 규칙: 각 OAuth 제공자별 고유 ID(`*_provider_id`)는 `TEXT UNIQUE`로 설정.
3. Timestamp 규칙: `created_at`, `updated_at` 컬럼 `TIMESTAMPTZ` (UTC 저장 가정) 적용.
4. Email 규칙: 각 OAuth 제공자별 이메일(`*_email`)은 `CITEXT` 적용 (제공자별로 동일 이메일 중복 가입 방지 효과).
5. 주석 블록: 파일 끝에 설계 근거 요약.
6. 확장성: `other_oauth_providers JSONB` 컬럼 또는 EAV 모델 전환 가능성을 주석으로 언급. (MVP에서는 주요 제공자 컬럼 방식 유지)
*/
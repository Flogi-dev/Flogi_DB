-- 00_DB/main/schema/00_common_global_enums.sql
-- Common ENUM types for Flogi DB, aligned with README.md

-- 사용자 계정 유형 ENUM
DO $$ BEGIN
    CREATE TYPE user_account_type_enum AS ENUM (
        'individual',
        'organization_member',
        'admin',
        'guest'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON TYPE user_account_type_enum IS '사용자의 계정 유형을 정의합니다. (개인, 조직 멤버, 관리자, 게스트 등) <-READ-ME 매핑> (user_config.yml 또는 시스템 정책과 연관)';

-- 요금제 키 ENUM (Comfort Commit 시스템 설계서 README.md 6장 기반)
DO $$ BEGIN
    CREATE TYPE plan_key_enum AS ENUM (
        'free',
        'basic',
        'premium',
        'organization'
        -- 'enterprise', -- (README.md 6장에 명시되어 있지 않음, 필요시 추가)
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON TYPE plan_key_enum IS '시스템에서 제공하는 요금제의 고유 키 값입니다. (무료, 기본, 프리미엄, 조직 등) <-READ-ME 매핑> (Comfort Commit 시스템 설계서 6장 사용자 요금제 & 기능 분기)';

-- 사용자 계정 상태 ENUM
DO $$ BEGIN
    CREATE TYPE user_account_status_enum AS ENUM (
        'pending_verification',
        'active',
        'suspended',
        'deactivated',
        'deletion_pending',
        'deleted'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON TYPE user_account_status_enum IS '사용자 계정의 현재 상태를 나타냅니다. (인증 대기, 활성, 일시정지, 비활성화, 삭제 대기, 삭제됨 등) <-READ-ME 매핑> (시스템 정책과 연관)';

-- 사용자 탈퇴 요청 상태 ENUM
DO $$ BEGIN
    CREATE TYPE deletion_request_status_enum AS ENUM (
        'requested',
        'pending_confirmation',
        'confirmed',
        'processing',
        'completed',
        'cancelled',
        'failed'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON TYPE deletion_request_status_enum IS '사용자 계정 탈퇴 요청의 처리 단계를 나타냅니다. <-READ-ME 매핑> (GDPR/CCPA 삭제권 처리 플로우와 연관)';

-- Secret 타입 ENUM (user_secret 테이블용)
DO $$ BEGIN
    CREATE TYPE user_secret_type_enum AS ENUM (
        'llm_api_key',
        'oauth_refresh_token',
        'oauth_access_token',
        'slack_bot_token',
        'slack_user_token',
        'github_app_installation_token',
        'internal_service_secret'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON TYPE user_secret_type_enum IS 'user_secret 테이블에서 관리하는 비밀 정보의 유형을 정의합니다. (LLM API 키, OAuth 토큰 등) <-READ-ME 매핑> (보안 정책과 연관)';

-- Secret 상태 ENUM (user_secret 테이블용)
DO $$ BEGIN
    CREATE TYPE user_secret_status_enum AS ENUM (
        'active',
        'revoked_by_user',
        'revoked_by_provider',
        'expired',
        'pending_rotation',
        'compromised'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON TYPE user_secret_status_enum IS 'user_secret 테이블에 저장된 비밀 정보의 현재 상태를 나타냅니다. <-READ-ME 매핑> (보안 정책과 연관)';

-- 피드백 타입 ENUM (user_feedback_log 테이블용)
DO $$ BEGIN
    CREATE TYPE feedback_type_enum AS ENUM (
        'bug_report',
        'feature_request',
        'general_comment',
        'ux_issue',
        'praise',
        'other'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON TYPE feedback_type_enum IS '사용자 피드백의 유형을 정의합니다. <-READ-ME 매핑> (서비스 개선 프로세스와 연관)';

-- 알림 이벤트 타입 ENUM (user_notification_pref 테이블 JSONB 내부용)
DO $$ BEGIN
    CREATE TYPE notification_event_type_enum AS ENUM (
        'commit_generation_success',
        'commit_generation_failure',
        'commit_approval_requested',
        'commit_approved',
        'commit_rejected',
        'system_maintenance_scheduled',
        'system_maintenance_completed',
        'new_feature_released',
        'plan_limit_approaching',
        'plan_limit_reached',
        'reward_granted',
        'security_alert'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON TYPE notification_event_type_enum IS '사용자에게 발송될 수 있는 알림의 이벤트 유형을 정의합니다. user_notification_pref의 JSONB 필드 내에서 사용됩니다. <-READ-ME 매핑> (알림 정책과 연관)';

-- 알림 채널 ENUM (user_notification_pref 테이블 JSONB 내부용 및 notification_delivery_logs용)
DO $$ BEGIN
    CREATE TYPE notification_channel_enum AS ENUM (
        'email',
        'slack',
        'kakao',
        'discord',
        'in_app_web',
        'mobile_push'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON TYPE notification_channel_enum IS '알림이 발송될 수 있는 채널의 종류를 정의합니다. <-READ-ME 매핑> (07_upload/noti_platform/ 참고)';

/*
설계 근거:
1. 지시서의 ENUM 관련 규칙 및 README.md 6장과의 일치성 요구 반영.
2. 기존 ENUM 타입을 검토하고, `plan_key_enum`은 README.md 내용을 우선하여 정의.
3. 리팩토링 대상 테이블(`user_secret`, `user_feedback_log`, `user_notification_pref`)에 필요한 신규 ENUM 타입 추가.
4. `DO $$ BEGIN ... EXCEPTION WHEN duplicate_object THEN null; END $$;` 구문을 사용하여 멱등성 확보.
*/
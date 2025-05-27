-- 00_DB/main/schema/00_common_helper_functions.sql
-- Helper functions for Flogi DB

-- Required Extension: uuid-ossp
-- (Ensure this is enabled: CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; in init-db-extensions.sh)
-- Required Extension: pgcrypto (if advanced random string generation is needed beyond simple uuid substring)

CREATE OR REPLACE FUNCTION gen_random_id(p_prefix TEXT, p_length INTEGER)
RETURNS TEXT AS $$
DECLARE
    v_uuid_str TEXT;
    v_random_part TEXT;
    v_final_length INTEGER;
BEGIN
    -- Generate a V4 UUID and remove hyphens (32 characters)
    v_uuid_str := replace(uuid_generate_v4()::TEXT, '-', '');

    -- Determine the length of the random part, considering the prefix
    v_final_length := p_length - length(p_prefix);

    -- Ensure the random part length is at least 1 and not more than 32
    IF v_final_length < 1 THEN
        -- If prefix itself is too long or p_length is too small,
        -- return prefix with a very short random string or handle error
        v_random_part := substr(v_uuid_str, 1, 1); -- fallback to 1 char random
    ELSIF v_final_length > 32 THEN
        v_random_part := v_uuid_str; -- use full 32 chars
    ELSE
        v_random_part := substr(v_uuid_str, 1, v_final_length);
    END IF;

    RETURN p_prefix || v_random_part;
END;
$$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION gen_random_id(TEXT, INTEGER) IS '지정된 prefix와 UUID 기반 랜덤 문자열(요청 길이 - prefix 길이만큼)을 결합하여 고유 식별자를 생성합니다. UUID v4를 사용하며, 반환되는 전체 문자열 길이가 p_length와 정확히 일치하지 않을 수 있습니다 (prefix 길이에 따라 랜덤 파트가 조정됨). 충돌 방지를 위해 적절한 길이와 고유한 prefix 조합이 중요합니다. 예: gen_random_id(''usr_'', 16)';

/*
설계 근거:
1. 작업 지시서의 `gen_random_id(prefix, length)` 요구사항 충족.
2. `uuid_generate_v4()`를 사용하여 예측 불가능성 및 분산도 확보.
3. 반환되는 ID의 전체 길이가 아닌, 랜덤 파트의 길이를 p_length와 prefix를 고려하여 조정.
*/
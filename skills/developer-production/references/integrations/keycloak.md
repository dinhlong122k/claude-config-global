# Keycloak

**Khi áp dụng:** Keycloak là issuer/resource server, login provider hoặc Admin API dependency. [Bảo mật](../controls/security.md) sở hữu auth/authz chung.

## CRITICAL

| ID | Bắt buộc |
| --- | --- |
| KC-001 | Chốt realm, issuer, client, flow (browser/resource server/service account), environment và owner cấu hình. |
| KC-002 | Bearer token: xác minh signature, issuer, audience/token type, expiration và clock skew theo policy; ánh xạ role/scope/tenant có test. Phân biệt 401 với 403. |
| KC-003 | Chốt discovery/JWKS cache, key rotation và hành vi khi Keycloak unavailable. Không chấp nhận token chưa xác minh hoặc fail-open. Nếu gọi token/userinfo/Admin API, cấu hình timeout/deadline và retry-safe. |
| KC-004 | Client secret/private key/service account có quyền tối thiểu, lưu/rotate an toàn; redact token/user info khỏi log, error và message. |
| KC-005 | Phân loại invalid/expired token, issuer/audience mismatch, thiếu scope, 429, 5xx, timeout, key rotation; map về 401/403/503 hoặc contract tương ứng. Không retry credential sai. |
| KC-006 | Test anonymous, invalid/expired token, sai audience/realm, thiếu quyền, tenant mismatch, JWKS rotate/unavailable và Admin API failure nếu dùng. |

## OPTIONAL — cân nhắc theo nhu cầu

| ID | Quyết định |
| --- | --- |
| KC-O01 | Introspection: cần revocation freshness hơn JWT verification offline? |
| KC-O02 | Token exchange/delegation: trust, scope và audience mới? |
| KC-O03 | Admin API provisioning: feature thật sự cần quyền quản trị identity? |
| KC-O04 | Fine-grained authorization/UMA: policy nên ở Keycloak hay app? |
| KC-O05 | Backchannel logout/session revocation: freshness và UX yêu cầu? |

**Cấu hình cần ghi:** issuer/realm/client/flow, audience, JWK/discovery/cache/skew, role mapping, API timeout, secret ref, unavailable policy, error map.

**Đối chiếu phiên bản:** [Keycloak Securing Applications](https://www.keycloak.org/securing-apps).

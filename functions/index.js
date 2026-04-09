const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

const VALID_CELEB_TYPES = ["idol", "actor", "youtuber", "sports", "politician"];
const MAX_SCORE = 999999;
const MAX_COMBO = 500;
const MAX_SURVIVAL_SECONDS = 120;
const RATE_LIMIT_SECONDS = 60;

exports.submitScore = onCall({ region: "us-central1" }, async (request) => {
  // 1. 인증 확인
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
  }

  const { celebType, score, maxCombo, survivalSeconds, displayName } = request.data;
  const userId = request.auth.uid;

  // 2. 필수 필드 검증
  if (!celebType || score === undefined || maxCombo === undefined || survivalSeconds === undefined) {
    throw new HttpsError("invalid-argument", "필수 필드가 누락되었습니다.");
  }

  // 3. 셀럽 타입 검증
  if (!VALID_CELEB_TYPES.includes(celebType)) {
    throw new HttpsError("invalid-argument", `유효하지 않은 셀럽 타입: ${celebType}`);
  }

  // 4. 점수 범위 검증
  if (!Number.isInteger(score) || score < 0 || score > MAX_SCORE) {
    throw new HttpsError("invalid-argument", `점수 범위 초과: ${score} (0~${MAX_SCORE})`);
  }

  // 5. 콤보 검증
  if (!Number.isInteger(maxCombo) || maxCombo < 0 || maxCombo > MAX_COMBO) {
    throw new HttpsError("invalid-argument", `콤보 범위 초과: ${maxCombo}`);
  }

  // 6. 생존 시간 검증
  if (typeof survivalSeconds !== "number" || survivalSeconds < 0 || survivalSeconds > MAX_SURVIVAL_SECONDS) {
    throw new HttpsError("invalid-argument", `생존 시간 범위 초과: ${survivalSeconds}`);
  }

  // 7. 점수-시간 논리 검증 (1초당 최대 약 3000점 = 피버+부스트+고콤보)
  const maxScorePerSecond = 3000;
  if (survivalSeconds > 0 && score / survivalSeconds > maxScorePerSecond) {
    throw new HttpsError("invalid-argument", "점수와 생존 시간이 논리적으로 맞지 않습니다.");
  }

  // 8. Rate limiting (유저당 60초에 1회)
  const rateLimitRef = db.collection("rate_limits").doc(userId);
  const rateLimitDoc = await rateLimitRef.get();

  if (rateLimitDoc.exists) {
    const lastSubmit = rateLimitDoc.data().lastSubmit?.toMillis() || 0;
    const now = Date.now();
    if (now - lastSubmit < RATE_LIMIT_SECONDS * 1000) {
      throw new HttpsError("resource-exhausted", "너무 빠른 점수 제출입니다. 잠시 후 다시 시도해주세요.");
    }
  }

  // 9. Firestore에 기록
  const scoreData = {
    user_id: userId,
    display_name: displayName || "Anonymous",
    score,
    max_combo: maxCombo,
    survival_seconds: survivalSeconds,
    created_at: FieldValue.serverTimestamp(),
  };

  await db.collection("leaderboards").doc(celebType).collection("scores").add(scoreData);

  // Rate limit 갱신
  await rateLimitRef.set({ lastSubmit: FieldValue.serverTimestamp() });

  return { success: true, message: "점수가 등록되었습니다." };
});

exports.getLeaderboard = onCall({ region: "us-central1" }, async (request) => {
  const { celebType, limit: queryLimit } = request.data;

  if (!VALID_CELEB_TYPES.includes(celebType)) {
    throw new HttpsError("invalid-argument", `유효하지 않은 셀럽 타입: ${celebType}`);
  }

  const resultLimit = Math.min(queryLimit || 100, 100);

  const snapshot = await db
    .collection("leaderboards")
    .doc(celebType)
    .collection("scores")
    .orderBy("score", "desc")
    .orderBy("created_at", "desc")
    .limit(resultLimit)
    .get();

  const scores = snapshot.docs.map((doc, index) => ({
    rank: index + 1,
    ...doc.data(),
    created_at: doc.data().created_at?.toMillis() || null,
  }));

  return { scores };
});

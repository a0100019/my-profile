"use client";

import { signInWithPopup } from "firebase/auth";
import { getFirebaseAuth, googleProvider } from "@/lib/firebase";
import { useState } from "react";
import { useRouter } from "next/navigation";

export default function Home() {
  const [loading, setLoading] = useState(false);
  const [agreed, setAgreed] = useState(true);
  const [showTerms, setShowTerms] = useState(false);
  const router = useRouter();

  const handleGoogleLogin = async () => {
    if (!agreed) {
      alert("약관에 동의해주세요.");
      return;
    }
    setLoading(true);
    try {
      await signInWithPopup(getFirebaseAuth(), googleProvider);
      router.replace("/dashboard");
    } catch (error) {
      console.error("로그인 실패:", error);
      setLoading(false);
    }
  };

  return (
    <main className="flex-1 flex flex-col items-center justify-center px-6">
      {/* 배경 장식 */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-20 -left-20 w-72 h-72 rounded-full bg-pastel-pink opacity-40 blur-3xl" />
        <div className="absolute top-1/4 -right-16 w-64 h-64 rounded-full bg-pastel-blue opacity-40 blur-3xl" />
        <div className="absolute bottom-20 left-1/4 w-56 h-56 rounded-full bg-pastel-mint opacity-40 blur-3xl" />
        <div className="absolute -bottom-10 right-1/3 w-48 h-48 rounded-full bg-pastel-purple opacity-30 blur-3xl" />
      </div>

      <div className="relative z-10 flex flex-col items-center gap-8 max-w-sm w-full">
        {/* 로고 */}
        <div className="flex flex-col items-center gap-3">
          <h1 className="text-4xl sm:text-5xl font-bold tracking-tight">
            <span className="text-pastel-purple">p</span>
            <span className="text-pastel-pink">r</span>
            <span className="text-pastel-blue">o</span>
            <span className="text-pastel-mint">f</span>
            <span className="text-pastel-peach">i</span>
            <span className="text-pastel-purple">l</span>
            <span className="text-pastel-pink">e</span>
            <span className="text-foreground">.</span>
            <span className="text-pastel-blue">m</span>
            <span className="text-pastel-mint">e</span>
          </h1>
          <p className="text-muted text-sm text-center leading-relaxed">
            나만의 취향을 담은 프로필을 만들고
            <br />
            친구에게 공유해보세요
          </p>
        </div>

        {/* 카드 미리보기 */}
        <div className="w-full bg-card rounded-3xl shadow-lg p-6 border border-pastel-pink/30 no-bubble">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-12 h-12 rounded-full bg-gradient-to-br from-pastel-pink to-pastel-purple" />
            <div>
              <div className="h-3 w-24 bg-pastel-blue/40 rounded-full" />
              <div className="h-2 w-16 bg-pastel-mint/40 rounded-full mt-2" />
            </div>
          </div>
          <div className="flex flex-wrap gap-2">
            {["🍕 피자", "🎬 영화", "🎵 음악", "📚 독서", "✈️ 여행", "💕 이상형", "🐶 동물", "💼 MBTI", "🎌 애니"].map(
              (tag) => (
                <span
                  key={tag}
                  className="text-xs px-3 py-1.5 rounded-full bg-pastel-yellow/50 text-foreground/70"
                >
                  {tag}
                </span>
              )
            )}
          </div>
        </div>

        {/* 구글 로그인 버튼 */}
        <button
          onClick={handleGoogleLogin}
          disabled={loading}
          className="w-full flex items-center justify-center gap-3 bg-card hover:bg-card/80 text-foreground font-medium py-3.5 px-6 rounded-2xl shadow-md border border-pastel-purple/20 transition-all duration-200 hover:shadow-lg hover:scale-[1.02] active:scale-[0.98] disabled:opacity-60 disabled:cursor-not-allowed"
        >
          <svg className="w-5 h-5" viewBox="0 0 24 24">
            <path
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z"
              fill="#4285F4"
            />
            <path
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
              fill="#34A853"
            />
            <path
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
              fill="#FBBC05"
            />
            <path
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
              fill="#EA4335"
            />
          </svg>
          {loading ? "로그인 중..." : "Google로 시작하기"}
        </button>

        {/* 약관 동의 */}
        <div className="flex items-center gap-2">
          <label className="flex items-center gap-2 cursor-pointer select-none">
            <input
              type="checkbox"
              checked={agreed}
              onChange={(e) => setAgreed(e.target.checked)}
              className="w-4 h-4 accent-pastel-purple rounded"
            />
            <span className="text-muted text-xs">이용약관에 동의합니다</span>
          </label>
          <button
            onClick={() => setShowTerms(true)}
            className="text-xs text-pastel-purple hover:text-pastel-purple/70 transition-colors underline"
          >
            자세히보기
          </button>
        </div>

        {/* 이용약관 모달 */}
        {showTerms && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-6 w-full max-w-sm shadow-xl max-h-[80vh] overflow-y-auto">
              <h3 className="text-base font-semibold text-center mb-4">이용약관</h3>
              <div className="text-xs text-foreground/70 leading-relaxed flex flex-col gap-3">
                <div>
                  <p className="font-semibold text-foreground mb-1">제1조 (목적)</p>
                  <p>본 약관은 mybio.kr(이하 &quot;서비스&quot;)의 이용 조건 및 절차, 이용자와 서비스 제공자의 권리·의무를 규정함을 목적으로 합니다.</p>
                </div>
                <div>
                  <p className="font-semibold text-foreground mb-1">제2조 (정의)</p>
                  <p>① &quot;서비스&quot;란 사용자가 자신의 취향과 관심사를 프로필로 만들어 공유할 수 있는 웹 애플리케이션을 말합니다.</p>
                  <p>② &quot;이용자&quot;란 Google 계정으로 로그인하여 서비스를 이용하는 자를 말합니다.</p>
                </div>
                <div>
                  <p className="font-semibold text-foreground mb-1">제3조 (개인정보 수집 및 이용)</p>
                  <p>서비스는 Google 로그인을 통해 아래 정보를 수집합니다.</p>
                  <p className="mt-1">• 이름 (표시명)</p>
                  <p>• 이메일 주소</p>
                  <p>• 프로필 사진 URL</p>
                  <p className="mt-1">수집된 정보는 프로필 표시 및 서비스 운영 목적으로만 사용되며, 제3자에게 제공하지 않습니다.</p>
                </div>
                <div>
                  <p className="font-semibold text-foreground mb-1">제4조 (이용자의 의무)</p>
                  <p>① 이용자는 타인의 권리를 침해하는 콘텐츠를 게시해서는 안 됩니다.</p>
                  <p>② 이용자는 서비스를 부정한 목적으로 사용해서는 안 됩니다.</p>
                  <p>③ 이용자가 업로드한 콘텐츠(사진, 텍스트 등)에 대한 책임은 이용자 본인에게 있습니다.</p>
                </div>
                <div>
                  <p className="font-semibold text-foreground mb-1">제5조 (서비스 제공 및 변경)</p>
                  <p>① 서비스는 무료로 제공되며, 사전 공지 후 내용이 변경될 수 있습니다.</p>
                  <p>② 서비스 제공자는 천재지변, 기술적 장애 등 불가피한 사유로 서비스를 일시 중단할 수 있습니다.</p>
                </div>
                <div>
                  <p className="font-semibold text-foreground mb-1">제6조 (계정 탈퇴 및 데이터 삭제)</p>
                  <p>이용자는 언제든지 설정에서 계정 탈퇴가 가능하며, 탈퇴 시 모든 개인정보와 프로필 데이터가 즉시 삭제됩니다.</p>
                </div>
                <div>
                  <p className="font-semibold text-foreground mb-1">제7조 (면책)</p>
                  <p>서비스 제공자는 이용자가 서비스 내에 게시한 정보의 신뢰도, 정확성에 대해 책임을 지지 않습니다.</p>
                </div>
              </div>
              <button
                onClick={() => setShowTerms(false)}
                className="w-full mt-4 py-3 rounded-2xl bg-gradient-to-r from-pastel-purple to-pastel-pink text-white font-medium hover:shadow-lg transition-all"
              >
                확인
              </button>
            </div>
          </div>
        )}
      </div>
    </main>
  );
}

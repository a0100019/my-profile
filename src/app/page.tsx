"use client";

import { signInWithPopup } from "firebase/auth";
import { getFirebaseAuth, googleProvider } from "@/lib/firebase";
import { useState } from "react";
import { useRouter } from "next/navigation";

export default function Home() {
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleGoogleLogin = async () => {
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

        <p className="text-muted text-xs text-center">
          로그인하면 나만의 프로필 링크를 받을 수 있어요
        </p>
      </div>
    </main>
  );
}

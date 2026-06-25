"use client";

import { useEffect, useState } from "react";
import { collection, query, where, getDocs, doc, getDoc, setDoc, updateDoc, increment, arrayUnion, arrayRemove } from "firebase/firestore";
import { db, auth } from "@/lib/firebase";
import { useParams } from "next/navigation";
import { onAuthStateChanged } from "firebase/auth";
import type { User } from "firebase/auth";

interface CategoryData {
  items: string[];
}

interface ProfileData {
  displayName: string;
  photoURL: string;
  email: string;
  username: string;
  [key: string]: unknown;
}

const CATEGORIES = [
  { key: "food", emoji: "🍕", label: "음식" },
  { key: "movie", emoji: "🎬", label: "영화" },
  { key: "music", emoji: "🎵", label: "음악" },
  { key: "book", emoji: "📚", label: "책" },
  { key: "hobby", emoji: "⚽", label: "취미" },
  { key: "travel", emoji: "✈️", label: "여행" },
  { key: "game", emoji: "🎮", label: "게임" },
  { key: "drama", emoji: "📺", label: "드라마" },
  { key: "pokemon", emoji: "🐾", label: "포켓몬" },
  { key: "ideal", emoji: "💕", label: "이상형" },
];

const ROW_COLORS = [
  { color: "bg-pastel-pink/25", border: "border-pastel-pink/40" },
  { color: "bg-pastel-peach/25", border: "border-pastel-peach/40" },
  { color: "bg-pastel-yellow/25", border: "border-pastel-yellow/40" },
  { color: "bg-pastel-mint/25", border: "border-pastel-mint/40" },
  { color: "bg-pastel-blue/25", border: "border-pastel-blue/40" },
  { color: "bg-pastel-purple/25", border: "border-pastel-purple/40" },
];

export default function PublicProfile() {
  const params = useParams();
  const username = params.username as string;
  const [profile, setProfile] = useState<ProfileData | null>(null);
  const [loading, setLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);
  const [expandedCategories, setExpandedCategories] = useState<Set<string>>(new Set());
  const [views, setViews] = useState<number>(0);
  const [likes, setLikes] = useState<number>(0);
  const [liked, setLiked] = useState(false);
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [profileUserId, setProfileUserId] = useState<string>("");

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (u) => setCurrentUser(u));
    return () => unsubscribe();
  }, []);

  useEffect(() => {
    const fetchProfile = async () => {
      const isTag = /^\d+$/.test(username);
      const q = isTag
        ? query(collection(db, "users"), where("tag", "==", Number(username)))
        : query(collection(db, "users"), where("username", "==", username));
      const snapshot = await getDocs(q);
      if (snapshot.empty) {
        setNotFound(true);
      } else {
        const userData = snapshot.docs[0].data() as ProfileData;
        const userId = snapshot.docs[0].id;
        setProfile(userData);
        setProfileUserId(userId);
        setViews((userData.views as number) || 0);
        setLikes((userData.likes as number) || 0);

        // 내가 이미 좋아요 눌렀는지 확인
        if (currentUser) {
          const likedList = (userData.likedBy as string[]) || [];
          setLiked(likedList.includes(currentUser.uid));
        }

        // 조회수 증가 (10초 쿨다운)
        const visitorKey = `view_${userId}`;
        const lastView = localStorage.getItem(visitorKey);
        const now = Date.now();
        if (!lastView || now - Number(lastView) > 10000) {
          localStorage.setItem(visitorKey, String(now));
          const userRef = doc(db, "users", userId);
          await updateDoc(userRef, { views: increment(1) });
          setViews((prev) => prev + 1);
        }
      }
      setLoading(false);
    };
    fetchProfile();
  }, [username, currentUser]);

  const handleLike = async () => {
    if (!currentUser || !profileUserId) return;
    const targetRef = doc(db, "users", profileUserId);
    const myRef = doc(db, "users", currentUser.uid);

    if (liked) {
      await updateDoc(targetRef, { likes: increment(-1), likedBy: arrayRemove(currentUser.uid) });
      await updateDoc(myRef, { likedProfiles: arrayRemove(profileUserId) });
      setLikes((prev) => prev - 1);
      setLiked(false);
    } else {
      await updateDoc(targetRef, { likes: increment(1), likedBy: arrayUnion(currentUser.uid) });
      await updateDoc(myRef, { likedProfiles: arrayUnion(profileUserId) });
      setLikes((prev) => prev + 1);
      setLiked(true);
    }
  };

  if (loading) {
    return (
      <main className="flex-1 flex items-center justify-center">
        <div className="w-8 h-8 rounded-full border-3 border-pastel-purple border-t-transparent animate-spin" />
      </main>
    );
  }

  if (notFound) {
    return (
      <main className="flex-1 flex flex-col items-center justify-center px-6 gap-4">
        <p className="text-6xl">😢</p>
        <p className="text-lg font-semibold text-foreground">
          프로필을 찾을 수 없어요
        </p>
      </main>
    );
  }

  const activeDefault = CATEGORIES.filter(
    (cat) =>
      profile?.[cat.key] &&
      (profile[cat.key] as CategoryData).items?.length > 0
  );
  const customKeys = profile ? Object.keys(profile).filter((k) => k.startsWith("custom_") && (profile[k] as CategoryData)?.items?.length > 0) : [];
  const customCategories = customKeys.map((k) => ({
    key: k,
    emoji: "✨",
    label: k.replace("custom_", ""),
  }));
  const activeCategories = [...activeDefault, ...customCategories];

  return (
    <main className="flex-1 flex flex-col items-center px-6 py-10">
      <div className="max-w-sm w-full flex flex-col items-center gap-6">
        {/* 헤더 */}
        <div className="w-full relative flex items-center justify-center">
          <h1 className="text-2xl font-bold">
            <span className="text-pastel-purple">my</span>
            <span className="text-foreground">.</span>
            <span className="text-pastel-blue">profile</span>
          </h1>
          {!currentUser && (
            <a href="/" className="absolute right-0 px-3 py-1.5 rounded-full bg-gradient-to-r from-pastel-purple to-pastel-pink text-white text-xs font-medium shadow-sm hover:shadow-md hover:scale-105 active:scale-95 transition-all">
              나도 만들기 ✨
            </a>
          )}
        </div>

        {/* 프로필 카드 */}
        <div className="w-full bg-card rounded-3xl shadow-lg p-6 border border-pastel-pink/30 no-bubble">
          <div className="flex items-center gap-4 mb-4">
            {profile?.photoURL ? (
              <img
                src={profile.photoURL}
                alt="프로필"
                className="w-16 h-16 rounded-full border-2 border-pastel-purple/30"
                referrerPolicy="no-referrer"
              />
            ) : (
              <div className="w-16 h-16 rounded-full bg-gradient-to-br from-pastel-pink to-pastel-purple" />
            )}
            <div>
              <h2 className="text-lg font-semibold">
                {profile?.username}{profile?.tag && <span className="text-pastel-purple text-sm font-normal ml-1.5">#{profile.tag as number}</span>}
              </h2>
              <p className="text-sm text-muted">{profile?.displayName}</p>
            </div>
          </div>

          <div className="flex items-center gap-3 text-xs text-muted mb-2">
            <span>🔮 {views}</span>
            <button
              onClick={handleLike}
              disabled={!currentUser}
              className={`flex items-center gap-1 px-2 py-1 rounded-full transition-all ${liked ? "bg-pastel-pink/30 text-pastel-pink" : "hover:bg-pastel-pink/10"}`}
            >
              <span>{liked ? "🩷" : "🤍"}</span>
              <span>{likes}</span>
            </button>
          </div>

          {(profile?.bio || (profile?.infoFields as {label: string; value: string}[])?.length > 0) && (
            <div className="w-full rounded-2xl bg-pastel-purple/10 border border-pastel-purple/20 p-4 mb-2">
              <p className="text-xs text-muted font-medium mb-3">자기소개</p>
              {profile?.bio && (
                <div className="w-full px-3 py-2 rounded-xl bg-card/60 border border-pastel-purple/15 mb-2 text-center">
                  <p className="text-[10px] text-muted">한줄 소개</p>
                  <p className="text-sm text-foreground/70">{profile.bio as string}</p>
                </div>
              )}
              {(profile?.infoFields as {label: string; value: string}[])?.length > 0 && (
                <div className="grid grid-cols-2 gap-2">
                  {(profile.infoFields as {label: string; value: string}[]).map((f, i) => (
                    <div key={i} className="px-3 py-2 rounded-xl bg-card/60 border border-pastel-purple/15 text-center">
                      <p className="text-[10px] text-muted">{f.label}</p>
                      <p className="text-sm text-foreground/70">{f.value}</p>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {activeCategories.length === 0 ? (
            <p className="text-sm text-muted text-center py-8">
              아직 작성된 프로필이 없어요
            </p>
          ) : (
            <div className="flex flex-col gap-2 mt-2">
              {activeCategories.map((cat, catIndex) => {
                const rowColor = ROW_COLORS[catIndex % ROW_COLORS.length];
                return (
                <div key={cat.key}>
                  <button
                    onClick={() => {
                      const next = new Set(expandedCategories);
                      if (next.has(cat.key)) next.delete(cat.key);
                      else next.add(cat.key);
                      setExpandedCategories(next);
                    }}
                    className={`w-full flex items-center justify-between px-4 py-3 rounded-2xl ${rowColor.color} border ${rowColor.border} hover:brightness-95 transition-all`}
                  >
                    <span className="font-medium">
                      {cat.emoji} {cat.label}
                    </span>
                    <span className="text-muted text-sm">
                      {expandedCategories.has(cat.key) ? "▲" : "▼"}
                    </span>
                  </button>
                  {expandedCategories.has(cat.key) && (
                    <div className="px-4 py-3 flex flex-col gap-2">
                      {(profile?.[cat.key] as CategoryData)?.items.map(
                        (item, i) => (
                          <div
                            key={i}
                            className={`flex items-center gap-2 text-sm px-3 py-2 rounded-2xl ${rowColor.color}`}
                          >
                            <span className="w-5 h-5 flex items-center justify-center rounded-full bg-pastel-purple/20 text-pastel-purple text-xs font-bold shrink-0">{i + 1}</span>
                            <span className="text-foreground/80">{item}</span>
                          </div>
                        )
                      )}
                    </div>
                  )}
                </div>
                );
              })}
            </div>
          )}
        </div>


      </div>
    </main>
  );
}

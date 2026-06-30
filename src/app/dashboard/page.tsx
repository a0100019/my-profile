"use client";

import { useEffect, useState, useRef } from "react";
import { onAuthStateChanged, signOut } from "firebase/auth";
import { doc, getDoc, getDocFromServer, setDoc, updateDoc, runTransaction, serverTimestamp, collection, getDocs, arrayUnion, arrayRemove, addDoc, query, orderBy, onSnapshot, increment, type Timestamp } from "firebase/firestore";
import { auth, db } from "@/lib/firebase";
import { useRouter } from "next/navigation";
import type { User } from "firebase/auth";
import ProfilePhotoUpload from "@/components/ProfilePhotoUpload";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import { getFirebaseStorage } from "@/lib/firebase";
import { compressImage } from "@/lib/image";

interface CardItem {
  text: string;
  link?: string;
  image?: string;
}

interface CategoryData {
  items: (string | CardItem)[];
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ProfileData = Record<string, any>;

const ALL_CATEGORIES = [
  { key: "food", emoji: "🍕", label: "음식" },
  { key: "movie", emoji: "🎬", label: "영화" },
  { key: "music", emoji: "🎵", label: "음악" },
  { key: "book", emoji: "📚", label: "책" },
  { key: "hobby", emoji: "⚽", label: "취미" },
  { key: "travel", emoji: "✈️", label: "여행" },
  { key: "game", emoji: "🎮", label: "게임" },
  { key: "drama", emoji: "📺", label: "드라마" },
  { key: "drink", emoji: "🥤", label: "음료" },
  { key: "comic", emoji: "📖", label: "만화" },
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

export default function Dashboard() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [profile, setProfile] = useState<ProfileData>({});
  const [expandedCategories, setExpandedCategories] = useState<Set<string>>(new Set());
  const [editingCategory, setEditingCategory] = useState<string | null>(null);
  const [editInput, setEditInput] = useState("");
  const [editItems, setEditItems] = useState<CardItem[]>([]);
  const [editLink, setEditLink] = useState("");
  const [editImage, setEditImage] = useState("");
  const [uploadingCardImage, setUploadingCardImage] = useState(false);
  const [cardImageZoom, setCardImageZoom] = useState<string | null>(null);
  const [showSettings, setShowSettings] = useState(false);
  const [showTerms, setShowTerms] = useState(false);
  const [showRanking, setShowRanking] = useState(false);
  const [rankingTab, setRankingTab] = useState<"views" | "likes" | "friends">("views");
  const [rankingList, setRankingList] = useState<{username: string; displayName: string; tag: number; photoURL: string; views: number; likes: number; friends: number}[]>([]);
  const [loadingRanking, setLoadingRanking] = useState(false);
  const [dragIndex, setDragIndex] = useState<number | null>(null);
  const [copied, setCopied] = useState(false);
  const [userTag, setUserTag] = useState<number | null>(null);
  const [customCategory, setCustomCategory] = useState("");
  const [bio, setBio] = useState("");
  const [editingBio, setEditingBio] = useState(false);
  const [infoFields, setInfoFields] = useState<{label: string; value: string}[]>([]);
  const [editingInfo, setEditingInfo] = useState(false);
  const [newInfoLabel, setNewInfoLabel] = useState("");
  const [newInfoValue, setNewInfoValue] = useState("");
  const [photoZoom, setPhotoZoom] = useState(false);
  const [showLikedBy, setShowLikedBy] = useState(false);
  const [showLikedProfiles, setShowLikedProfiles] = useState(false);
  const [likedByList, setLikedByList] = useState<{username: string; displayName: string; tag: number}[]>([]);
  const [likedProfilesList, setLikedProfilesList] = useState<{username: string; displayName: string; tag: number}[]>([]);
  const [loadingList, setLoadingList] = useState(false);
  const [showFriends, setShowFriends] = useState(false);
  const [friendsList, setFriendsList] = useState<{username: string; displayName: string; tag: number; photoURL?: string; uid: string}[]>([]);
  const [friendRequests, setFriendRequests] = useState<{username: string; displayName: string; tag: number; photoURL?: string; uid: string}[]>([]);
  const [reorderingCategories, setReorderingCategories] = useState(false);
  const [categoryOrder, setCategoryOrder] = useState<string[]>([]);
  const [dragCatIndex, setDragCatIndex] = useState<number | null>(null);
  const [editingName, setEditingName] = useState(false);
  const [editingUsername, setEditingUsername] = useState(false);
  const [editName, setEditName] = useState("");
  const [editUsername, setEditUsername] = useState("");
  const [showComments, setShowComments] = useState(false);
  const [commentCount, setCommentCount] = useState(0);
  const [comments, setComments] = useState<{id: string; text: string; senderUid: string; senderName: string; senderTag: string; senderPhoto: string; createdAt: Timestamp | null}[]>([]);
  const [commentInput, setCommentInput] = useState("");
  const [sendingComment, setSendingComment] = useState(false);
  const [chatTarget, setChatTarget] = useState<{uid: string; username: string; photoURL?: string} | null>(null);
  const [chatMessages, setChatMessages] = useState<{id: string; text: string; senderUid: string; createdAt: Timestamp | null}[]>([]);
  const [chatInput, setChatInput] = useState("");
  const [sendingChat, setSendingChat] = useState(false);
  const chatBottomRef = useRef<HTMLDivElement>(null);
  const router = useRouter();

  const defaultUsername = (user?.email?.split("@")[0] || "").slice(0, 15);
  const username = (profile as Record<string, unknown>).username as string || defaultUsername;
  const displayName = (profile as Record<string, unknown>).displayName as string || user?.displayName || "";

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      if (!currentUser) {
        router.replace("/");
        return;
      }
      setUser(currentUser);

      try {
        const username = (currentUser.email?.split("@")[0] || "").slice(0, 15);
        const docRef = doc(db, "users", currentUser.uid);
        const docSnap = await getDocFromServer(docRef);
        if (docSnap.exists()) {
          const data = docSnap.data();
          setProfile(data as ProfileData);
          if (data.bio) setBio(data.bio);
          if (data.tag) setUserTag(data.tag);
          if (data.categoryOrder) setCategoryOrder(data.categoryOrder);
          if (data.infoFields) setInfoFields(data.infoFields);
        } else {
          const tag = await runTransaction(db, async (transaction) => {
            const counterRef = doc(db, "meta", "counter");
            const counterSnap = await transaction.get(counterRef);
            const current = counterSnap.exists() ? counterSnap.data().userCount || 0 : 0;
            const newCount = current + 1;
            transaction.set(counterRef, { userCount: newCount }, { merge: true });
            return newCount;
          });
          setUserTag(tag);
          await setDoc(docRef, {
            username,
            displayName: currentUser.displayName,
            photoURL: currentUser.photoURL,
            email: currentUser.email,
            createdAt: new Date().toISOString(),
            tag,
          });
        }
        await updateDoc(docRef, { lastActiveAt: serverTimestamp() });
        const commentsSnap = await getDocs(collection(db, "users", currentUser.uid, "comments"));
        setCommentCount(commentsSnap.size);
      } catch (error) {
        console.error("프로필 로드 실패:", error);
      }
      setLoading(false);
    });
    return () => unsubscribe();
  }, [router]);

  const toCardItem = (item: string | CardItem): CardItem =>
    typeof item === "string" ? { text: item } : item;

  const saveCategory = async (categoryKey: string, items: CardItem[]) => {
    if (!user) return;
    const newProfile = { ...profile, [categoryKey]: { items } };
    setProfile(newProfile);
    setEditingCategory(null);
    setEditInput("");

    await setDoc(
      doc(db, "users", user.uid),
      {
        [categoryKey]: { items },
        username,
        displayName: user.displayName,
        photoURL: user.photoURL,
        email: user.email,
      },
      { merge: true }
    );
  };

  const removeCategory = async (categoryKey: string) => {
    if (!user) return;
    const newProfile = { ...profile };
    delete newProfile[categoryKey];
    setProfile(newProfile);
    setExpandedCategories((prev) => { const next = new Set(prev); next.delete(categoryKey); return next; });

    const { deleteField } = await import("firebase/firestore");
    await updateDoc(doc(db, "users", user.uid), { [categoryKey]: deleteField() });
  };

  const fetchUserList = async (uids: string[]) => {
    const results: {username: string; displayName: string; tag: number}[] = [];
    for (const uid of uids) {
      const snap = await getDoc(doc(db, "users", uid));
      if (snap.exists()) {
        const d = snap.data();
        results.push({ username: d.username || "", displayName: d.displayName || "", tag: d.tag || 0 });
      }
    }
    return results;
  };

  const openRanking = async () => {
    setShowRanking(true);
    setLoadingRanking(true);
    try {
      const snapshot = await getDocs(collection(db, "users"));
      const users = snapshot.docs.map((d) => {
        const data = d.data();
        return {
          username: data.username || "",
          displayName: data.displayName || "",
          tag: data.tag || 0,
          photoURL: data.photoURL || "",
          views: data.views || 0,
          likes: data.likes || 0,
          friends: (data.friends as string[] || []).length,
        };
      });
      setRankingList(users);
    } catch (error) {
      console.error("순위 로드 실패:", error);
    }
    setLoadingRanking(false);
  };

  const openLikedBy = async () => {
    setLoadingList(true);
    setShowLikedBy(true);
    const list = (profile as Record<string, unknown>).likedBy as string[] || [];
    setLikedByList(await fetchUserList(list));
    setLoadingList(false);
  };

  const openLikedProfiles = async () => {
    setLoadingList(true);
    setShowLikedProfiles(true);
    const list = (profile as Record<string, unknown>).likedProfiles as string[] || [];
    setLikedProfilesList(await fetchUserList(list));
    setLoadingList(false);
  };

  const openFriends = async () => {
    setLoadingList(true);
    setShowFriends(true);
    const list = (profile as Record<string, unknown>).friends as string[] || [];
    const results: {username: string; displayName: string; tag: number; photoURL?: string; uid: string}[] = [];
    for (const uid of list) {
      const snap = await getDoc(doc(db, "users", uid));
      if (snap.exists()) {
        const d = snap.data();
        results.push({ username: d.username || "", displayName: d.displayName || "", tag: d.tag || 0, photoURL: d.photoURL || "", uid });
      }
    }
    setFriendsList(results);

    const requests = (profile as Record<string, unknown>).friendRequests as string[] || [];
    const reqResults: {username: string; displayName: string; tag: number; photoURL?: string; uid: string}[] = [];
    for (const uid of requests) {
      const snap = await getDoc(doc(db, "users", uid));
      if (snap.exists()) {
        const d = snap.data();
        reqResults.push({ username: d.username || "", displayName: d.displayName || "", tag: d.tag || 0, photoURL: d.photoURL || "", uid });
      }
    }
    setFriendRequests(reqResults);
    setLoadingList(false);
  };

  const acceptFriend = async (targetUid: string) => {
    if (!user) return;
    const myRef = doc(db, "users", user.uid);
    const targetRef = doc(db, "users", targetUid);
    await updateDoc(myRef, { friends: arrayUnion(targetUid), friendRequests: arrayRemove(targetUid) });
    await updateDoc(targetRef, { friends: arrayUnion(user.uid), sentRequests: arrayRemove(user.uid) });
    setFriendRequests((prev) => prev.filter((r) => r.uid !== targetUid));
    const accepted = friendRequests.find((r) => r.uid === targetUid);
    if (accepted) setFriendsList((prev) => [...prev, accepted]);
    setProfile((prev: ProfileData) => ({
      ...prev,
      friends: [...((prev.friends as string[]) || []), targetUid],
      friendRequests: ((prev.friendRequests as string[]) || []).filter((id: string) => id !== targetUid),
    }));
  };

  const rejectFriend = async (targetUid: string) => {
    if (!user) return;
    const myRef = doc(db, "users", user.uid);
    const targetRef = doc(db, "users", targetUid);
    await updateDoc(myRef, { friendRequests: arrayRemove(targetUid) });
    await updateDoc(targetRef, { sentRequests: arrayRemove(user.uid) });
    setFriendRequests((prev) => prev.filter((r) => r.uid !== targetUid));
    setProfile((prev: ProfileData) => ({
      ...prev,
      friendRequests: ((prev.friendRequests as string[]) || []).filter((id: string) => id !== targetUid),
    }));
  };

  const removeFriend = async (targetUid: string) => {
    if (!user) return;
    const myRef = doc(db, "users", user.uid);
    const targetRef = doc(db, "users", targetUid);
    await updateDoc(myRef, { friends: arrayRemove(targetUid) });
    await updateDoc(targetRef, { friends: arrayRemove(user.uid) });
    setFriendsList((prev) => prev.filter((f) => f.uid !== targetUid));
    setProfile((prev: ProfileData) => ({
      ...prev,
      friends: ((prev.friends as string[]) || []).filter((id: string) => id !== targetUid),
    }));
  };

  const openComments = () => {
    if (!user) return;
    setShowComments(true);
    const commentsRef = collection(db, "users", user.uid, "comments");
    const q = query(commentsRef, orderBy("createdAt", "desc"));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      setComments(snapshot.docs.map((d) => ({
        id: d.id,
        text: d.data().text as string,
        senderUid: d.data().senderUid as string,
        senderName: d.data().senderName as string,
        senderTag: d.data().senderTag as string,
        senderPhoto: d.data().senderPhoto as string || "",
        createdAt: d.data().createdAt as Timestamp | null,
      })));
      setCommentCount(snapshot.size);
    });
    return unsubscribe;
  };

  const sendComment = async () => {
    if (!user || !commentInput.trim() || sendingComment) return;
    setSendingComment(true);
    await addDoc(collection(db, "users", user.uid, "comments"), {
      text: commentInput.trim(),
      senderUid: user.uid,
      senderName: username,
      senderTag: String(userTag || ""),
      senderPhoto: user.photoURL || "",
      createdAt: serverTimestamp(),
    });
    setCommentInput("");
    setSendingComment(false);
  };

  const deleteComment = async (commentId: string) => {
    if (!user) return;
    const { deleteDoc: delDoc } = await import("firebase/firestore");
    await delDoc(doc(db, "users", user.uid, "comments", commentId));
  };

  const getChatId = (uid1: string, uid2: string) => [uid1, uid2].sort().join("_");

  const openChat = async (target: {uid: string; username: string; photoURL?: string}) => {
    setChatTarget(target);
    setChatInput("");
    if (user) {
      await updateDoc(doc(db, "users", user.uid), { [`chatUnread.${target.uid}`]: 0 });
      setProfile((prev: ProfileData) => ({
        ...prev,
        chatUnread: { ...((prev.chatUnread as Record<string, number>) || {}), [target.uid]: 0 },
      }));
    }
  };

  useEffect(() => {
    if (!chatTarget || !user) return;
    const chatId = getChatId(user.uid, chatTarget.uid);
    const messagesRef = collection(db, "chats", chatId, "messages");
    const q = query(messagesRef, orderBy("createdAt", "asc"));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const msgs = snapshot.docs.map((d) => ({
        id: d.id,
        text: d.data().text as string,
        senderUid: d.data().senderUid as string,
        createdAt: d.data().createdAt as Timestamp | null,
      }));
      setChatMessages(msgs);
      setTimeout(() => chatBottomRef.current?.scrollIntoView({ behavior: "smooth" }), 100);
    });
    return () => unsubscribe();
  }, [chatTarget, user]);

  const sendChat = async () => {
    if (!user || !chatTarget || !chatInput.trim() || sendingChat) return;
    setSendingChat(true);
    const chatId = getChatId(user.uid, chatTarget.uid);
    await addDoc(collection(db, "chats", chatId, "messages"), {
      text: chatInput.trim(),
      senderUid: user.uid,
      createdAt: serverTimestamp(),
    });
    await updateDoc(doc(db, "users", chatTarget.uid), {
      [`chatUnread.${user.uid}`]: increment(1),
    });
    setChatInput("");
    setSendingChat(false);
  };

  const handleLogout = async () => {
    await signOut(auth);
    router.push("/");
  };

  const handleShare = async () => {
    if (!userTag) return;
    const url = `${window.location.origin}/u/${userTag}`;
    await navigator.clipboard.writeText(url);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const addedDefault = ALL_CATEGORIES.filter((cat) => profile[cat.key]);
  const customKeys = Object.keys(profile).filter((k) => k.startsWith("custom_") && (profile[k] as CategoryData)?.items?.length > 0);
  const customCategories = customKeys.map((k) => ({
    key: k,
    emoji: "✨",
    label: k.replace("custom_", ""),
  }));
  const unsortedCategories = [...addedDefault, ...customCategories];
  const addedCategories = categoryOrder.length > 0
    ? [...unsortedCategories].sort((a, b) => {
        const ai = categoryOrder.indexOf(a.key);
        const bi = categoryOrder.indexOf(b.key);
        if (ai === -1 && bi === -1) return 0;
        if (ai === -1) return 1;
        if (bi === -1) return -1;
        return ai - bi;
      })
    : unsortedCategories;
  const availableCategories = ALL_CATEGORIES.filter((cat) => !profile[cat.key]);

  if (loading) {
    return (
      <main className="flex-1 flex items-center justify-center">
        <div className="w-8 h-8 rounded-full border-3 border-pastel-purple border-t-transparent animate-spin" />
      </main>
    );
  }

  return (
    <main className="flex-1 flex flex-col items-center px-6 py-10">
      <div className="max-w-sm w-full flex flex-col items-center gap-6">
        {/* 헤더 */}
        <div className="w-full relative flex items-center justify-center">
          <button
            onClick={() => setShowSettings(true)}
            className="absolute left-0 text-sm text-muted hover:text-foreground transition-colors"
          >
            ⚙️
          </button>
          <h1 className="text-2xl font-bold">
            <span className="text-pastel-purple">my</span>
            <span className="text-foreground">.</span>
            <span className="text-pastel-blue">profile</span>
          </h1>
          {(() => {
            const reqCount = ((profile as Record<string, unknown>).friendRequests as string[] || []).length;
            const unreadMap = (profile as Record<string, unknown>).chatUnread as Record<string, number> || {};
            const chatCount = Object.values(unreadMap).reduce((a: number, b: number) => a + b, 0);
            const total = reqCount + chatCount;
            return (
              <button
                onClick={openFriends}
                className={`absolute right-0 text-sm transition-colors ${total > 0 ? "text-foreground font-semibold" : "text-muted hover:text-foreground"}`}
              >
                👫 친구{total > 0 && <span className="ml-1 bg-red-500 text-white px-1.5 py-0.5 rounded-full text-[10px] font-bold min-w-[20px] inline-flex items-center justify-center shadow-lg shadow-red-500/40 animate-bounce">{total}</span>}
              </button>
            );
          })()}
        </div>

        {/* ===== 프로필 카드 (공유 시 이 부분만 보임) ===== */}
        <div className="w-full bg-card rounded-3xl shadow-lg p-6 border border-pastel-pink/30 no-bubble">
          {/* 프로필 헤더 */}
          <div className="flex items-center gap-4 mb-4">
            {(() => {
              const photoURL = (profile as Record<string, unknown>).photoURL as string || user?.photoURL || "";
              return photoURL ? (
                <img
                  src={photoURL}
                  alt="프로필"
                  className="w-16 h-16 rounded-full border-2 border-pastel-purple/30 object-cover cursor-pointer shrink-0"
                  referrerPolicy="no-referrer"
                  onClick={() => setPhotoZoom(true)}
                />
              ) : (
                <div
                  className="w-16 h-16 rounded-full bg-gradient-to-br from-pastel-pink to-pastel-purple shrink-0 cursor-pointer"
                  onClick={() => setPhotoZoom(true)}
                />
              );
            })()}
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between">
                <h2 className="text-lg font-semibold">
                  {username}{userTag !== null && <span className="text-pastel-purple text-sm font-normal ml-1.5">#{userTag}</span>}
                </h2>
                <button
                  onClick={() => {
                    setEditName(displayName);
                    setEditUsername(username);
                    setEditingName(true);
                  }}
                  className="text-xs text-pastel-purple hover:text-pastel-purple/70 transition-colors shrink-0"
                >
                  프로필 변경
                </button>
              </div>
              <p className="text-sm text-muted">{displayName}</p>
              <div className="flex items-center gap-2 text-xs text-muted mt-1">
                <span className="px-2 py-0.5 rounded-full border border-foreground/15">조회수 {(profile as Record<string, unknown>).views as number || 0}</span>
                <button onClick={openLikedBy} className="px-2 py-0.5 rounded-full border border-foreground/15 hover:border-pastel-pink/50 transition-colors">
                  받은 좋아요 {(profile as Record<string, unknown>).likes as number || 0}
                </button>
                <button onClick={openLikedProfiles} className="px-2 py-0.5 rounded-full border border-foreground/15 hover:border-pastel-purple/50 transition-colors">
                  누른 좋아요
                </button>
              </div>
            </div>
          </div>

          {/* 자기소개 */}
          <div className="w-full rounded-2xl bg-pastel-purple/10 border border-pastel-purple/20 p-4 mb-2">
            <div className="flex items-center justify-between mb-3">
              <p className="text-xs text-muted font-medium">자기소개</p>
              <button
                onClick={() => setEditingInfo(true)}
                className="text-xs text-pastel-purple hover:text-pastel-purple/70 transition-colors"
              >
                편집
              </button>
            </div>

            {/* 한줄소개 — 풀 너비 */}
            <div className="w-full px-3 py-2 rounded-xl bg-card/60 border border-pastel-purple/15 mb-2 text-center">
              <p className="text-[10px] text-muted">한줄 소개</p>
              <p className="text-sm text-foreground/70">{bio || "-"}</p>
            </div>

            {/* 정보 필드 — 반칸씩 */}
            {infoFields.length > 0 && (
              <div className="grid grid-cols-2 gap-2">
                {infoFields.map((f, i) => (
                  <div key={i} className="px-3 py-2 rounded-xl bg-card/60 border border-pastel-purple/15 text-center">
                    <p className="text-[10px] text-muted">{f.label}</p>
                    <p className="text-sm text-foreground/70">{f.value}</p>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* 자기소개 편집 모달 */}
          {editingInfo && (
            <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
              <div className="bg-card rounded-3xl p-6 w-full max-w-sm shadow-xl max-h-[80vh] overflow-y-auto">
                <h3 className="text-base font-semibold text-center mb-4">자기소개 편집</h3>

                {/* 한줄소개 */}
                <div className="mb-4">
                  <label className="text-xs text-muted mb-1 block">한줄 소개</label>
                  <textarea
                    value={bio}
                    onChange={(e) => setBio(e.target.value.slice(0, 200))}
                    maxLength={200}
                    placeholder="한줄 소개를 입력해보세요"
                    className="w-full px-4 py-3 rounded-2xl border border-pastel-purple/30 bg-background text-foreground text-sm resize-none h-16 focus:outline-none focus:border-pastel-purple"
                  />
                  <p className="text-xs text-muted text-right">{bio.length}/200</p>
                </div>

                {/* 기존 필드들 */}
                {infoFields.map((f, i) => (
                  <div key={i} className="flex items-center gap-2 mb-2">
                    <div className="flex-1 grid grid-cols-2 gap-2">
                      <input
                        value={f.label}
                        onChange={(e) => {
                          const next = [...infoFields];
                          next[i] = { ...next[i], label: e.target.value };
                          setInfoFields(next);
                        }}
                        maxLength={15}
                        className="px-3 py-2 rounded-xl border border-pastel-purple/30 bg-background text-sm focus:outline-none focus:border-pastel-purple"
                        placeholder="항목"
                      />
                      <input
                        value={f.value}
                        onChange={(e) => {
                          const next = [...infoFields];
                          next[i] = { ...next[i], value: e.target.value };
                          setInfoFields(next);
                        }}
                        maxLength={25}
                        className="px-3 py-2 rounded-xl border border-pastel-purple/30 bg-background text-sm focus:outline-none focus:border-pastel-purple"
                        placeholder="내용"
                      />
                    </div>
                    <button
                      onClick={() => setInfoFields(infoFields.filter((_, idx) => idx !== i))}
                      className="text-xs text-foreground/30 hover:text-red-400 transition-colors px-1"
                    >
                      ✕
                    </button>
                  </div>
                ))}

                {/* 새 필드 추가 */}
                <div className="flex items-center gap-2 mb-4">
                  <div className="flex-1 grid grid-cols-2 gap-2">
                    <input
                      value={newInfoLabel}
                      onChange={(e) => setNewInfoLabel(e.target.value)}
                      maxLength={15}
                      className="px-3 py-2 rounded-xl border border-pastel-purple/30 bg-background text-sm focus:outline-none focus:border-pastel-purple"
                      placeholder="항목 (예: MBTI)"
                    />
                    <input
                      value={newInfoValue}
                      onChange={(e) => setNewInfoValue(e.target.value)}
                      maxLength={25}
                      className="px-3 py-2 rounded-xl border border-pastel-purple/30 bg-background text-sm focus:outline-none focus:border-pastel-purple"
                      placeholder="내용 (예: INFP)"
                    />
                  </div>
                  <span className="text-xs px-1 invisible">✕</span>
                </div>

                <div className="flex gap-2">
                  <button
                    onClick={async () => {
                      setEditingInfo(false);
                      if (user) {
                        await setDoc(doc(db, "users", user.uid), { bio, infoFields }, { merge: true });
                      }
                    }}
                    className="flex-1 py-3 rounded-2xl bg-gradient-to-r from-pastel-purple to-pastel-pink text-white font-medium hover:shadow-lg transition-all"
                  >
                    완료
                  </button>
                  <button
                    onClick={() => {
                      if (newInfoLabel.trim() && newInfoValue.trim()) {
                        setInfoFields([...infoFields, { label: newInfoLabel.trim(), value: newInfoValue.trim() }]);
                        setNewInfoLabel("");
                        setNewInfoValue("");
                      }
                    }}
                    className="flex-1 py-3 rounded-2xl bg-pastel-purple/15 border border-pastel-purple/30 text-pastel-purple font-medium hover:bg-pastel-purple/25 transition-all"
                  >
                    추가하기
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* 추가된 카테고리들 (접기/펼치기) */}
          {addedCategories.length === 0 ? (
            <p className="text-sm text-muted text-center py-8 border-2 border-dashed border-pastel-purple/20 rounded-2xl">
              아직 프로필을 작성하지 않았어요
              <br />
              아래에서 카테고리를 추가해보세요!
            </p>
          ) : (
            <div className="flex flex-col gap-2 mt-2">
              {addedCategories.map((cat, catIndex) => {
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
                      {profile[cat.key]?.items.map((rawItem: string | CardItem, i: number) => {
                        const item = toCardItem(rawItem);
                        return (
                        <div
                          key={i}
                          className={`flex items-center gap-2 text-sm px-3 py-2 rounded-2xl ${rowColor.color}`}
                        >
                          <span className="w-5 h-5 flex items-center justify-center rounded-full bg-pastel-purple/20 text-pastel-purple text-xs font-bold shrink-0">{i + 1}</span>
                          <span className="text-foreground/80 flex-1">{item.text}</span>
                          {item.image && (
                            <img src={item.image} alt={item.text} className="w-8 h-8 rounded-lg object-cover shrink-0 cursor-pointer hover:opacity-80 transition-opacity" onClick={() => setCardImageZoom(item.image!)} />
                          )}
                          {item.link && (
                            <a href={item.link.match(/^https?:\/\//) ? item.link : `https://${item.link}`} target="_blank" rel="noopener noreferrer" className="text-[10px] text-pastel-purple hover:text-pastel-purple/70 shrink-0">링크 이동</a>
                          )}
                        </div>
                        );
                      })}
                      <div className="flex justify-end mt-1">
                        <button
                          onClick={() => {
                            setEditingCategory(cat.key);
                            setEditItems((profile[cat.key]?.items || []).map(toCardItem));
                          }}
                          className="px-4 py-1.5 rounded-xl bg-pastel-purple/15 border border-pastel-purple/30 text-pastel-purple text-xs font-medium hover:bg-pastel-purple/25 transition-colors"
                        >
                          편집
                        </button>
                      </div>
                    </div>
                  )}
                </div>
                );
              })}
            </div>
          )}

          {/* 순서 바꾸기 (흰 박스 안) */}
          {addedCategories.length >= 2 && (
            <button
              onClick={() => {
                setReorderingCategories(true);
                setCategoryOrder(addedCategories.map((c) => c.key));
              }}
              className="w-full text-center text-xs text-muted hover:text-pastel-purple transition-colors mt-2"
            >
              순서 바꾸기
            </button>
          )}
        </div>

        {/* 카테고리 추가하기 */}
        {availableCategories.length > 0 && (
          <div className="w-full rounded-2xl border border-pastel-purple/15 bg-card/60 p-4">
            <p className="text-sm text-muted mb-3 text-center">카테고리 추가하기</p>
            <div className="flex flex-wrap gap-2 justify-center">
              {availableCategories.map((cat) => (
                <button
                  key={cat.key}
                  onClick={() => {
                    setEditingCategory(cat.key);
                    setEditItems([]);
                  }}
                  className="flex items-center gap-1.5 px-4 py-2.5 rounded-full bg-background border border-pastel-purple/20 text-sm font-medium hover:border-pastel-purple/50 hover:shadow-md hover:scale-[1.03] active:scale-[0.97] transition-all duration-200"
                >
                  {cat.emoji} {cat.label}
                  <span className="text-pastel-purple ml-0.5">+</span>
                </button>
              ))}
              <div className="flex items-center gap-1.5 w-full mt-1">
                <input
                  value={customCategory}
                  onChange={(e) => setCustomCategory(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" && customCategory.trim()) {
                      const key = `custom_${customCategory.trim()}`;
                      if (!profile[key]) {
                        setEditingCategory(key);
                        setEditItems([]);
                      }
                      setCustomCategory("");
                    }
                  }}
                  placeholder="원하는 카테고리를 만들어봐요"
                  maxLength={20}
                  className="flex-1 px-4 py-2.5 rounded-full bg-background border border-pastel-mint/30 text-sm focus:outline-none focus:border-pastel-mint"
                />
                <button
                  onClick={() => {
                    if (customCategory.trim()) {
                      const key = `custom_${customCategory.trim()}`;
                      if (!profile[key]) {
                        setEditingCategory(key);
                        setEditItems([]);
                      }
                      setCustomCategory("");
                    }
                  }}
                  className="px-3 py-2.5 rounded-full bg-pastel-mint/20 border border-pastel-mint/30 text-pastel-mint text-sm font-medium"
                >
                  +
                </button>
              </div>
            </div>
          </div>
        )}

        {/* 순위 보기 + 댓글 보기 */}
        <div className="flex gap-2">
          <button
            onClick={openRanking}
            className="flex-1 py-3 rounded-2xl bg-pastel-yellow/30 border border-pastel-yellow/50 text-foreground font-medium hover:bg-pastel-yellow/40 transition-colors text-sm"
          >
            순위 보기
          </button>
          <button
            onClick={openComments}
            className="flex-1 py-3 rounded-2xl bg-pastel-blue/30 border border-pastel-blue/50 text-foreground font-medium hover:bg-pastel-blue/40 transition-colors text-sm"
          >
            댓글 보기({commentCount})
          </button>
        </div>

        {/* 링크 공유 버튼 */}
        <button
          onClick={handleShare}
          className="w-full py-3.5 rounded-2xl bg-gradient-to-r from-pastel-blue to-pastel-mint text-white font-medium shadow-md hover:shadow-lg hover:scale-[1.02] active:scale-[0.98] transition-all duration-200"
        >
          {copied ? "✅ 링크가 복사되었어요!" : "🔗 내 프로필 링크 공유하기"}
        </button>

        {/* ===== 카테고리 설정 모달 ===== */}
        {editingCategory && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-6 w-full max-w-sm shadow-xl">
              <h3 className="text-lg font-semibold mb-4">
                {ALL_CATEGORIES.find((c) => c.key === editingCategory)?.emoji ?? "✨"}{" "}
                {ALL_CATEGORIES.find((c) => c.key === editingCategory)?.label ?? editingCategory.replace("custom_", "")}{" "}
                추가
              </h3>

              {/* 추가된 카드들 (드래그로 순서 변경) */}
              {editItems.length > 0 && (
                <div className="flex flex-col gap-2 mb-3">
                  {editItems.map((item, i) => (
                    <div
                      key={item.text + i}
                      draggable
                      onDragStart={() => setDragIndex(i)}
                      onDragOver={(e) => {
                        e.preventDefault();
                        if (dragIndex === null || dragIndex === i) return;
                        const newItems = [...editItems];
                        const dragged = newItems.splice(dragIndex, 1)[0];
                        newItems.splice(i, 0, dragged);
                        setEditItems(newItems);
                        setDragIndex(i);
                      }}
                      onDragEnd={() => setDragIndex(null)}
                      onTouchStart={() => setDragIndex(i)}
                      className={`flex items-center gap-2 px-3 py-2.5 rounded-2xl border transition-all cursor-grab active:cursor-grabbing ${
                        dragIndex === i
                          ? "bg-pastel-purple/10 border-pastel-purple/40 scale-[1.02] shadow-md"
                          : "bg-pastel-yellow/20 border-pastel-yellow/30"
                      }`}
                    >
                      <span className="w-6 h-6 flex items-center justify-center rounded-full bg-pastel-purple/20 text-pastel-purple text-xs font-bold shrink-0">
                        {i + 1}
                      </span>
                      {item.image && <img src={item.image} alt="" className="w-7 h-7 rounded-lg object-cover shrink-0" />}
                      <div className="flex-1 min-w-0">
                        <span className="text-sm text-foreground/80">{item.text}</span>
                        {item.link && <p className="text-[10px] text-pastel-purple truncate">🔗 {item.link}</p>}
                        {item.image && !item.link && <p className="text-[10px] text-pastel-mint">🖼️ 이미지</p>}
                      </div>
                      <div className="flex items-center gap-1 shrink-0">
                        {i > 0 && (
                          <button
                            onClick={() => {
                              const newItems = [...editItems];
                              [newItems[i - 1], newItems[i]] = [newItems[i], newItems[i - 1]];
                              setEditItems(newItems);
                            }}
                            className="text-xs text-muted hover:text-foreground px-1"
                          >
                            ▲
                          </button>
                        )}
                        {i < editItems.length - 1 && (
                          <button
                            onClick={() => {
                              const newItems = [...editItems];
                              [newItems[i], newItems[i + 1]] = [newItems[i + 1], newItems[i]];
                              setEditItems(newItems);
                            }}
                            className="text-xs text-muted hover:text-foreground px-1"
                          >
                            ▼
                          </button>
                        )}
                        <button
                          onClick={() =>
                            setEditItems(editItems.filter((_, idx) => idx !== i))
                          }
                          className="text-xs text-foreground/30 hover:text-red-400 px-1 transition-colors"
                        >
                          ✕
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {/* 입력 필드 */}
              <div className="flex flex-col gap-2">
                <div className="flex gap-2">
                  <input
                    value={editInput}
                    onChange={(e) => setEditInput(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === "Enter" && editInput.trim()) {
                        e.preventDefault();
                        const newItem: CardItem = { text: editInput.trim() };
                        if (editLink.trim()) newItem.link = editLink.trim();
                        if (editImage.trim()) newItem.image = editImage.trim();
                        setEditItems([...editItems, newItem]);
                        setEditInput("");
                        setEditLink("");
                        setEditImage("");
                      }
                    }}
                    maxLength={50}
                    placeholder="입력 후 엔터 (최대 50자)"
                    className="flex-1 px-4 py-3 rounded-2xl border border-pastel-purple/30 bg-background text-foreground text-sm focus:outline-none focus:border-pastel-purple"
                    autoFocus
                  />
                </div>
                <div className="flex gap-2">
                  <input
                    value={editLink}
                    onChange={(e) => { setEditLink(e.target.value); if (e.target.value) setEditImage(""); }}
                    placeholder="🔗 링크 (선택)"
                    className={`flex-1 px-3 py-2 rounded-xl border text-xs focus:outline-none ${editLink ? "border-pastel-purple/40 bg-pastel-purple/5" : "border-pastel-purple/20 bg-background"} ${editImage ? "opacity-40 pointer-events-none" : ""}`}
                    disabled={!!editImage}
                  />
                  {editImage ? (
                    <div className="flex items-center gap-1">
                      <img src={editImage} alt="" className="w-8 h-8 rounded-lg object-cover" />
                      <button onClick={() => setEditImage("")} className="text-xs text-foreground/30 hover:text-red-400">✕</button>
                    </div>
                  ) : (
                    <label className={`px-3 py-2 rounded-xl border text-xs cursor-pointer transition-colors ${editLink ? "opacity-40 pointer-events-none border-pastel-purple/20" : "border-pastel-mint/30 bg-pastel-mint/10 hover:bg-pastel-mint/20 text-pastel-mint"}`}>
                      {uploadingCardImage ? "..." : "🖼️ 사진"}
                      <input
                        type="file"
                        accept="image/jpeg,image/png,image/webp"
                        className="hidden"
                        disabled={!!editLink}
                        onChange={async (e) => {
                          const file = e.target.files?.[0];
                          if (!file || !user) return;
                          setUploadingCardImage(true);
                          try {
                            const compressed = await compressImage(file);
                            const storage = getFirebaseStorage();
                            const path = `card-images/${user.uid}/${Date.now()}`;
                            const storageRef = ref(storage, path);
                            await uploadBytes(storageRef, compressed, { contentType: "image/webp" });
                            const url = await getDownloadURL(storageRef);
                            setEditImage(url);
                            setEditLink("");
                          } catch {
                            alert("이미지 업로드에 실패했습니다.");
                          } finally {
                            setUploadingCardImage(false);
                            e.target.value = "";
                          }
                        }}
                      />
                    </label>
                  )}
                </div>
              </div>

              <div className="flex gap-2 mt-4">
                <button
                  onClick={() => {
                    if (editItems.length > 0) {
                      saveCategory(editingCategory, editItems);
                    } else {
                      removeCategory(editingCategory);
                    }
                    setEditingCategory(null);
                    setEditInput("");
                    setEditItems([]);
                    setEditLink("");
                    setEditImage("");
                  }}
                  className="flex-1 py-3 rounded-2xl bg-gradient-to-r from-pastel-purple to-pastel-pink text-white font-medium hover:shadow-lg transition-all"
                >
                  나가기
                </button>
                <button
                  onClick={() => {
                    if (editInput.trim()) {
                      const newItem: CardItem = { text: editInput.trim() };
                      if (editLink.trim()) newItem.link = editLink.trim();
                      if (editImage.trim()) newItem.image = editImage.trim();
                      setEditItems([...editItems, newItem]);
                      setEditInput("");
                      setEditLink("");
                      setEditImage("");
                    }
                  }}
                  className="flex-1 py-3 rounded-2xl bg-pastel-purple/20 text-pastel-purple font-medium hover:bg-pastel-purple/30 transition-colors"
                >
                  추가하기
                </button>
              </div>
            </div>
          </div>
        )}


        {/* ===== 좋아요 받은 리스트 모달 ===== */}
        {showLikedBy && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-6 w-full max-w-sm shadow-xl">
              <h3 className="text-base font-semibold text-center mb-4">🩷 좋아요 받은 사람</h3>
              {loadingList ? (
                <div className="flex justify-center py-6">
                  <div className="w-6 h-6 rounded-full border-2 border-pastel-purple border-t-transparent animate-spin" />
                </div>
              ) : likedByList.length === 0 ? (
                <p className="text-sm text-muted text-center py-4">아직 좋아요가 없어요</p>
              ) : (
                <div className="flex flex-col gap-2 max-h-64 overflow-y-auto mb-4">
                  {likedByList.map((u, i) => (
                    <a key={i} href={`/u/${u.tag}`} target="_blank" rel="noopener noreferrer" className={`block px-4 py-3 rounded-2xl ${ROW_COLORS[i % ROW_COLORS.length].color} border ${ROW_COLORS[i % ROW_COLORS.length].border} hover:brightness-95 transition-all`}>
                      <p className="text-sm font-medium">{u.username} <span className="text-pastel-purple text-xs">#{u.tag}</span></p>
                      <p className="text-xs text-muted">{u.displayName}</p>
                    </a>
                  ))}
                </div>
              )}
              <button
                onClick={() => setShowLikedBy(false)}
                className="w-full py-3 rounded-2xl bg-gradient-to-r from-pastel-purple to-pastel-pink text-white font-medium"
              >
                닫기
              </button>
            </div>
          </div>
        )}

        {/* ===== 내가 좋아요 누른 리스트 모달 ===== */}
        {showLikedProfiles && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-6 w-full max-w-sm shadow-xl">
              <h3 className="text-base font-semibold text-center mb-4">💌 내가 좋아요 누른 프로필</h3>
              {loadingList ? (
                <div className="flex justify-center py-6">
                  <div className="w-6 h-6 rounded-full border-2 border-pastel-purple border-t-transparent animate-spin" />
                </div>
              ) : likedProfilesList.length === 0 ? (
                <p className="text-sm text-muted text-center py-4">아직 좋아요를 누른 프로필이 없어요</p>
              ) : (
                <div className="flex flex-col gap-2 max-h-64 overflow-y-auto mb-4">
                  {likedProfilesList.map((u, i) => (
                    <a key={i} href={`/u/${u.tag}`} target="_blank" rel="noopener noreferrer" className={`block px-4 py-3 rounded-2xl ${ROW_COLORS[i % ROW_COLORS.length].color} border ${ROW_COLORS[i % ROW_COLORS.length].border} hover:brightness-95 transition-all`}>
                      <p className="text-sm font-medium">{u.username} <span className="text-pastel-purple text-xs">#{u.tag}</span></p>
                      <p className="text-xs text-muted">{u.displayName}</p>
                    </a>
                  ))}
                </div>
              )}
              <button
                onClick={() => setShowLikedProfiles(false)}
                className="w-full py-3 rounded-2xl bg-gradient-to-r from-pastel-purple to-pastel-pink text-white font-medium"
              >
                닫기
              </button>
            </div>
          </div>
        )}

        {/* ===== 친구 목록 모달 ===== */}
        {showFriends && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-6 w-full max-w-sm shadow-xl max-h-[80vh] flex flex-col">
              <h3 className="text-base font-semibold text-center mb-4">👫 친구</h3>

              {loadingList ? (
                <div className="flex justify-center py-6">
                  <div className="w-6 h-6 rounded-full border-2 border-pastel-purple border-t-transparent animate-spin" />
                </div>
              ) : (
                <div className="flex-1 overflow-y-auto flex flex-col gap-4">
                  {friendRequests.length > 0 && (
                    <div>
                      <p className="text-xs text-pastel-pink font-medium mb-2">받은 친구 요청</p>
                      <div className="flex flex-col gap-2">
                        {friendRequests.map((u, i) => (
                          <div key={u.uid} className={`flex items-center gap-3 px-4 py-3 rounded-2xl ${ROW_COLORS[i % ROW_COLORS.length].color} border ${ROW_COLORS[i % ROW_COLORS.length].border}`}>
                            {u.photoURL ? (
                              <img src={u.photoURL} alt="" className="w-8 h-8 rounded-full border border-pastel-purple/20 shrink-0" referrerPolicy="no-referrer" />
                            ) : (
                              <div className="w-8 h-8 rounded-full bg-gradient-to-br from-pastel-pink to-pastel-purple shrink-0" />
                            )}
                            <div className="flex-1 min-w-0">
                              <p className="text-sm font-medium truncate">{u.username} <span className="text-pastel-purple text-xs">#{u.tag}</span></p>
                              <p className="text-xs text-muted truncate">{u.displayName}</p>
                            </div>
                            <div className="flex gap-1.5 shrink-0">
                              <button onClick={() => acceptFriend(u.uid)} className="px-2.5 py-1 rounded-xl bg-pastel-mint/30 text-pastel-mint text-xs font-medium hover:bg-pastel-mint/50 transition-colors">수락</button>
                              <button onClick={() => rejectFriend(u.uid)} className="px-2.5 py-1 rounded-xl bg-pastel-pink/30 text-pastel-pink text-xs font-medium hover:bg-pastel-pink/50 transition-colors">거절</button>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  <div>
                    <p className="text-xs text-muted font-medium mb-2">내 친구 {friendsList.length > 0 && `(${friendsList.length})`}</p>
                    {friendsList.length === 0 ? (
                      <p className="text-sm text-muted text-center py-4">아직 친구가 없어요</p>
                    ) : (
                      <div className="flex flex-col gap-2">
                        {friendsList.map((u, i) => (
                          <div key={u.uid} className={`flex items-center gap-3 px-4 py-3 rounded-2xl ${ROW_COLORS[i % ROW_COLORS.length].color} border ${ROW_COLORS[i % ROW_COLORS.length].border}`}>
                            <a href={`/u/${u.tag}`} target="_blank" rel="noopener noreferrer" className="flex items-center gap-3 flex-1 min-w-0">
                              {u.photoURL ? (
                                <img src={u.photoURL} alt="" className="w-8 h-8 rounded-full border border-pastel-purple/20 shrink-0" referrerPolicy="no-referrer" />
                              ) : (
                                <div className="w-8 h-8 rounded-full bg-gradient-to-br from-pastel-pink to-pastel-purple shrink-0" />
                              )}
                              <div className="min-w-0">
                                <p className="text-sm font-medium truncate">{u.username} <span className="text-pastel-purple text-xs">#{u.tag}</span></p>
                                <p className="text-xs text-muted truncate">{u.displayName}</p>
                              </div>
                            </a>
                            <div className="flex gap-1.5 shrink-0">
                              {(() => {
                                const unread = ((profile as Record<string, unknown>).chatUnread as Record<string, number> || {})[u.uid] || 0;
                                return (
                                  <button onClick={() => { setShowFriends(false); openChat({ uid: u.uid, username: u.username, photoURL: u.photoURL }); }} className={`relative px-2 py-1 rounded-xl text-xs font-medium transition-colors ${unread > 0 ? "bg-red-500/20 text-red-500 animate-pulse" : "bg-pastel-blue/30 text-pastel-blue hover:bg-pastel-blue/50"}`}>
                                    채팅{unread > 0 && <span className="absolute -top-1.5 -right-1.5 bg-red-500 text-white text-[10px] font-bold min-w-[18px] px-1 flex items-center justify-center rounded-full">{unread}</span>}
                                  </button>
                                );
                              })()}
                              <button onClick={() => removeFriend(u.uid)} className="text-xs text-muted hover:text-pastel-pink transition-colors">삭제</button>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              )}

              <button
                onClick={() => setShowFriends(false)}
                className="w-full mt-4 py-3 rounded-2xl bg-gradient-to-r from-pastel-purple to-pastel-pink text-white font-medium"
              >
                닫기
              </button>
            </div>
          </div>
        )}

        {/* ===== 사진 확대 모달 ===== */}
        {photoZoom && (
          <div
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-6"
            onClick={() => setPhotoZoom(false)}
          >
            {(() => {
              const photoURL = (profile as Record<string, unknown>).photoURL as string || user?.photoURL || "";
              return photoURL ? (
                <img
                  src={photoURL}
                  alt="프로필"
                  className="w-64 h-64 rounded-full object-cover border-4 border-white shadow-2xl"
                  referrerPolicy="no-referrer"
                />
              ) : (
                <div className="w-64 h-64 rounded-full bg-gradient-to-br from-pastel-pink to-pastel-purple border-4 border-white shadow-2xl" />
              );
            })()}
          </div>
        )}

        {/* ===== 설정 모달 ===== */}
        {showSettings && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-6 w-full max-w-sm shadow-xl">
              <h3 className="text-base font-semibold text-center mb-4">설정</h3>

              <div className="flex flex-col gap-3">
                <button
                  onClick={() => {
                    setShowSettings(false);
                    handleLogout();
                  }}
                  className="w-full px-4 py-3 rounded-2xl bg-pastel-purple/10 border border-pastel-purple/20 text-sm text-foreground hover:bg-pastel-purple/20 transition-colors text-left"
                >
                  로그아웃
                </button>
                <button
                  onClick={async () => {
                    if (!user) return;
                    const ok = confirm("정말 탈퇴하시겠어요? 모든 데이터가 삭제됩니다.");
                    if (!ok) return;
                    try {
                      const { deleteDoc } = await import("firebase/firestore");
                      await deleteDoc(doc(db, "users", user.uid));
                      await user.delete();
                      router.replace("/");
                    } catch {
                      alert("탈퇴에 실패했습니다. 다시 로그인 후 시도해주세요.");
                    }
                  }}
                  className="w-full px-4 py-3 rounded-2xl bg-red-50 border border-red-200 text-sm text-red-400 hover:bg-red-100 transition-colors text-left"
                >
                  계정 탈퇴
                </button>
                <button
                  onClick={() => {
                    setShowSettings(false);
                    setShowTerms(true);
                  }}
                  className="w-full px-4 py-3 rounded-2xl bg-pastel-purple/10 border border-pastel-purple/20 text-sm text-foreground hover:bg-pastel-purple/20 transition-colors text-left"
                >
                  이용약관 보기
                </button>
              </div>

              <button
                onClick={() => setShowSettings(false)}
                className="w-full mt-4 py-3 rounded-2xl bg-gradient-to-r from-pastel-purple to-pastel-pink text-white font-medium hover:shadow-lg transition-all"
              >
                닫기
              </button>
            </div>
          </div>
        )}

        {/* ===== 댓글 모달 ===== */}
        {showComments && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-5 w-full max-w-sm shadow-xl flex flex-col" style={{ maxHeight: "75vh" }}>
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-base font-semibold">댓글 ({commentCount})</h3>
                <button onClick={() => setShowComments(false)} className="text-muted hover:text-foreground text-lg">✕</button>
              </div>

              <div className="flex-1 overflow-y-auto flex flex-col gap-3 mb-3">
                {comments.length === 0 ? (
                  <p className="text-sm text-muted text-center py-8">아직 댓글이 없어요</p>
                ) : (
                  comments.map((c) => (
                    <div key={c.id} className="flex gap-2.5">
                      {c.senderPhoto ? (
                        <img src={c.senderPhoto} alt="" className="w-7 h-7 rounded-full shrink-0 mt-0.5" referrerPolicy="no-referrer" />
                      ) : (
                        <div className="w-7 h-7 rounded-full bg-gradient-to-br from-pastel-pink to-pastel-purple shrink-0 mt-0.5" />
                      )}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-baseline gap-1.5">
                          <a href={`/u/${c.senderTag}`} target="_blank" rel="noopener noreferrer" className="text-sm font-medium hover:text-pastel-purple transition-colors">{c.senderName}</a>
                          <span className="text-[10px] text-muted">#{c.senderTag}</span>
                          {c.createdAt && <span className="text-[10px] text-muted ml-auto shrink-0">{c.createdAt.toDate().toLocaleDateString("ko-KR", { month: "short", day: "numeric" })}</span>}
                        </div>
                        <p className="text-sm text-foreground/80 break-words">{c.text}</p>
                      </div>
                      {c.senderUid === user?.uid && (
                        <button onClick={() => deleteComment(c.id)} className="text-[10px] text-muted hover:text-pastel-pink shrink-0 self-start mt-1">삭제</button>
                      )}
                    </div>
                  ))
                )}
              </div>

              <div className="flex gap-2 pt-3 border-t border-pastel-purple/15">
                <input
                  value={commentInput}
                  onChange={(e) => setCommentInput(e.target.value)}
                  onKeyDown={(e) => { if (e.key === "Enter" && !e.nativeEvent.isComposing) sendComment(); }}
                  placeholder="댓글을 남겨보세요"
                  maxLength={200}
                  className="flex-1 px-4 py-2.5 rounded-2xl bg-background border border-pastel-blue/20 text-sm focus:outline-none focus:border-pastel-blue/50"
                />
                <button
                  onClick={sendComment}
                  disabled={!commentInput.trim() || sendingComment}
                  className="px-4 py-2.5 rounded-2xl bg-pastel-blue text-white text-sm font-medium hover:bg-pastel-blue/80 disabled:opacity-40 transition-colors shrink-0"
                >
                  등록
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ===== 채팅 모달 ===== */}
        {chatTarget && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-5 w-full max-w-sm shadow-xl flex flex-col" style={{ height: "70vh" }}>
              <div className="flex items-center gap-3 mb-3 pb-3 border-b border-pastel-purple/15">
                <button onClick={() => setChatTarget(null)} className="text-muted hover:text-foreground transition-colors text-sm">←</button>
                {chatTarget.photoURL ? (
                  <img src={chatTarget.photoURL} alt="" className="w-8 h-8 rounded-full object-cover shrink-0" referrerPolicy="no-referrer" />
                ) : (
                  <div className="w-8 h-8 rounded-full bg-gradient-to-br from-pastel-pink to-pastel-purple shrink-0" />
                )}
                <p className="text-sm font-semibold">{chatTarget.username}</p>
              </div>

              <div className="flex-1 overflow-y-auto flex flex-col gap-2 py-2">
                {chatMessages.length === 0 ? (
                  <p className="text-xs text-muted text-center py-8">첫 메시지를 보내보세요!</p>
                ) : (
                  chatMessages.map((msg) => {
                    const isMine = msg.senderUid === user?.uid;
                    return (
                      <div key={msg.id} className={`flex ${isMine ? "justify-end" : "justify-start"}`}>
                        <div className={`max-w-[75%] px-3.5 py-2 rounded-2xl text-sm ${isMine ? "bg-pastel-purple/20 text-foreground rounded-br-md" : "bg-pastel-mint/20 text-foreground rounded-bl-md"}`}>
                          <p className="break-words">{msg.text}</p>
                          {msg.createdAt && (
                            <p className={`text-[9px] mt-1 ${isMine ? "text-pastel-purple/50 text-right" : "text-pastel-mint/50"}`}>
                              {msg.createdAt.toDate().toLocaleTimeString("ko-KR", { hour: "2-digit", minute: "2-digit" })}
                            </p>
                          )}
                        </div>
                      </div>
                    );
                  })
                )}
                <div ref={chatBottomRef} />
              </div>

              <div className="flex gap-2 mt-3 pt-3 border-t border-pastel-purple/15">
                <input
                  value={chatInput}
                  onChange={(e) => setChatInput(e.target.value)}
                  onKeyDown={(e) => { if (e.key === "Enter" && !e.nativeEvent.isComposing) sendChat(); }}
                  placeholder="메시지를 입력하세요"
                  maxLength={500}
                  className="flex-1 px-4 py-2.5 rounded-2xl bg-background border border-pastel-purple/20 text-sm focus:outline-none focus:border-pastel-purple/50"
                />
                <button
                  onClick={sendChat}
                  disabled={!chatInput.trim() || sendingChat}
                  className="px-4 py-2.5 rounded-2xl bg-pastel-purple text-white text-sm font-medium hover:bg-pastel-purple/80 disabled:opacity-40 transition-colors shrink-0"
                >
                  전송
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ===== 순위 모달 ===== */}
        {showRanking && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-6 w-full max-w-sm shadow-xl max-h-[80vh] flex flex-col">
              <h3 className="text-base font-semibold text-center mb-3">🏆 순위</h3>

              <div className="flex gap-2 mb-4">
                <button
                  onClick={() => setRankingTab("views")}
                  className={`flex-1 py-2 rounded-xl text-sm font-medium transition-colors ${rankingTab === "views" ? "bg-pastel-purple/20 text-pastel-purple" : "bg-background text-muted hover:bg-pastel-purple/10"}`}
                >
                  🔮 조회수
                </button>
                <button
                  onClick={() => setRankingTab("likes")}
                  className={`flex-1 py-2 rounded-xl text-sm font-medium transition-colors ${rankingTab === "likes" ? "bg-pastel-pink/20 text-pastel-pink" : "bg-background text-muted hover:bg-pastel-pink/10"}`}
                >
                  🩷 좋아요
                </button>
                <button
                  onClick={() => setRankingTab("friends")}
                  className={`flex-1 py-2 rounded-xl text-sm font-medium transition-colors ${rankingTab === "friends" ? "bg-pastel-mint/20 text-pastel-mint" : "bg-background text-muted hover:bg-pastel-mint/10"}`}
                >
                  👫 친구
                </button>
              </div>

              <div className="flex-1 overflow-y-auto flex flex-col gap-2">
                {loadingRanking ? (
                  <div className="flex justify-center py-8">
                    <div className="w-6 h-6 rounded-full border-2 border-pastel-purple border-t-transparent animate-spin" />
                  </div>
                ) : (
                  [...rankingList]
                    .sort((a, b) => rankingTab === "views" ? b.views - a.views : rankingTab === "likes" ? b.likes - a.likes : b.friends - a.friends)
                    .map((u, i) => {
                      const rowColor = ROW_COLORS[i % ROW_COLORS.length];
                      const medal = i === 0 ? "🥇" : i === 1 ? "🥈" : i === 2 ? "🥉" : `${i + 1}`;
                      return (
                        <a
                          key={u.tag}
                          href={`/u/${u.tag}`}
                          target="_blank"
                          rel="noopener noreferrer"
                          className={`flex items-center gap-3 px-3 py-2.5 rounded-2xl ${rowColor.color} border ${rowColor.border} hover:brightness-95 transition-all`}
                        >
                          <span className="w-6 text-center text-sm font-bold shrink-0">{medal}</span>
                          {u.photoURL ? (
                            <img src={u.photoURL} alt="" className="w-8 h-8 rounded-full object-cover shrink-0" referrerPolicy="no-referrer" />
                          ) : (
                            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-pastel-pink to-pastel-purple shrink-0" />
                          )}
                          <div className="flex-1 min-w-0">
                            <p className="text-sm font-medium truncate">{u.username} <span className="text-pastel-purple text-xs font-normal">#{u.tag}</span></p>
                            <p className="text-[10px] text-muted truncate">{u.displayName}</p>
                          </div>
                          <span className="text-sm font-semibold text-pastel-purple shrink-0">
                            {rankingTab === "views" ? u.views : rankingTab === "likes" ? u.likes : u.friends}
                          </span>
                        </a>
                      );
                    })
                )}
              </div>

              <button
                onClick={() => setShowRanking(false)}
                className="w-full mt-4 py-3 rounded-2xl bg-gradient-to-r from-pastel-purple to-pastel-pink text-white font-medium hover:shadow-lg transition-all"
              >
                닫기
              </button>
            </div>
          </div>
        )}

        {/* ===== 이용약관 모달 ===== */}
        {showTerms && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-6 w-full max-w-sm shadow-xl max-h-[80vh] overflow-y-auto">
              <h3 className="text-base font-semibold text-center mb-4">이용약관</h3>
              <div className="text-xs text-foreground/70 leading-relaxed flex flex-col gap-3">
                <div>
                  <p className="font-semibold text-foreground mb-1">제1조 (목적)</p>
                  <p>본 약관은 profile.me(이하 &quot;서비스&quot;)의 이용 조건 및 절차, 이용자와 서비스 제공자의 권리·의무를 규정함을 목적으로 합니다.</p>
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

        {/* ===== 카드 이미지 확대 모달 ===== */}
        {cardImageZoom && (
          <div
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-6"
            onClick={() => setCardImageZoom(null)}
          >
            <img
              src={cardImageZoom}
              alt=""
              className="max-w-[80vw] max-h-[80vh] rounded-2xl object-contain shadow-2xl"
            />
          </div>
        )}

        {/* ===== 프로필 변경 모달 ===== */}
        {editingName && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-6 w-full max-w-sm shadow-xl">
              <h3 className="text-base font-semibold text-center mb-4">프로필 변경</h3>

              <div className="flex justify-center mb-4">
                <ProfilePhotoUpload
                  user={user!}
                  currentPhotoURL={(profile as Record<string, unknown>).photoURL as string || user?.photoURL || null}
                  onPhotoUpdated={(url) => setProfile((prev) => ({ ...prev, photoURL: url }))}
                  size="lg"
                />
              </div>

              <div className="flex flex-col gap-4 mb-4">
                <div>
                  <label className="text-xs text-muted mb-1 block">아이디</label>
                  <input
                    value={editUsername}
                    onChange={(e) => setEditUsername(e.target.value.replace(/\s/g, ""))}
                    maxLength={15}
                    className="w-full px-4 py-3 rounded-2xl border border-pastel-purple/30 bg-background text-foreground text-sm focus:outline-none focus:border-pastel-purple"
                  />
                  <p className="text-xs text-muted text-right mt-1">{editUsername.length}/15</p>
                </div>
                <div>
                  <label className="text-xs text-muted mb-1 block">이름</label>
                  <input
                    value={editName}
                    onChange={(e) => setEditName(e.target.value)}
                    maxLength={10}
                    className="w-full px-4 py-3 rounded-2xl border border-pastel-purple/30 bg-background text-foreground text-sm focus:outline-none focus:border-pastel-purple"
                  />
                  <p className="text-xs text-muted text-right mt-1">{editName.length}/10</p>
                </div>
                <div className="px-3 py-2 rounded-xl bg-pastel-purple/10 border border-pastel-purple/20">
                  <p className="text-xs text-pastel-purple text-center">
                    이름과 아이디는 다른 사람과 중복될 수 있어요
                    <br />
                    #{userTag} 태그는 고유 번호로 변경할 수 없어요
                  </p>
                </div>
              </div>

              <div className="flex gap-3">
                <button
                  onClick={() => setEditingName(false)}
                  className="flex-1 py-3 rounded-2xl border border-pastel-pink/30 text-muted font-medium hover:bg-background transition-colors"
                >
                  취소
                </button>
                <button
                  onClick={async () => {
                    if (editName.trim() && editUsername.trim() && user) {
                      const newName = editName.trim();
                      const newUsername = editUsername.trim();
                      setProfile((prev) => ({ ...prev, displayName: newName, username: newUsername }));
                      await setDoc(doc(db, "users", user.uid), { displayName: newName, username: newUsername }, { merge: true });
                    }
                    setEditingName(false);
                  }}
                  className="flex-1 py-3 rounded-2xl bg-gradient-to-r from-pastel-purple to-pastel-pink text-white font-medium hover:shadow-lg transition-all"
                >
                  확인
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ===== 카테고리 순서 바꾸기 모달 ===== */}
        {reorderingCategories && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 px-6">
            <div className="bg-card rounded-3xl p-6 w-full max-w-sm shadow-xl">
              <h3 className="text-base font-semibold text-center mb-4">카테고리 순서 바꾸기</h3>
              <div className="flex flex-col gap-2 mb-4">
                {categoryOrder.map((key, i) => {
                  const cat = addedCategories.find((c) => c.key === key) || { emoji: "✨", label: key.replace("custom_", "") };
                  const rowColor = ROW_COLORS[i % ROW_COLORS.length];
                  return (
                    <div
                      key={key}
                      draggable
                      onDragStart={() => setDragCatIndex(i)}
                      onDragOver={(e) => {
                        e.preventDefault();
                        if (dragCatIndex === null || dragCatIndex === i) return;
                        const newOrder = [...categoryOrder];
                        const [moved] = newOrder.splice(dragCatIndex, 1);
                        newOrder.splice(i, 0, moved);
                        setCategoryOrder(newOrder);
                        setDragCatIndex(i);
                      }}
                      onDragEnd={() => setDragCatIndex(null)}
                      className={`flex items-center justify-between px-4 py-3 rounded-2xl ${rowColor.color} border ${rowColor.border} cursor-grab active:cursor-grabbing`}
                    >
                      <span className="font-medium text-sm">
                        {cat.emoji} {cat.label}
                      </span>
                      <div className="flex items-center gap-1">
                        {i > 0 && (
                          <button
                            onClick={() => {
                              const newOrder = [...categoryOrder];
                              [newOrder[i - 1], newOrder[i]] = [newOrder[i], newOrder[i - 1]];
                              setCategoryOrder(newOrder);
                            }}
                            className="text-xs text-muted hover:text-foreground px-1"
                          >
                            ▲
                          </button>
                        )}
                        {i < categoryOrder.length - 1 && (
                          <button
                            onClick={() => {
                              const newOrder = [...categoryOrder];
                              [newOrder[i], newOrder[i + 1]] = [newOrder[i + 1], newOrder[i]];
                              setCategoryOrder(newOrder);
                            }}
                            className="text-xs text-muted hover:text-foreground px-1"
                          >
                            ▼
                          </button>
                        )}
                        <span className="text-muted text-xs ml-1">☰</span>
                      </div>
                    </div>
                  );
                })}
              </div>
              <button
                onClick={async () => {
                  if (user) {
                    await setDoc(doc(db, "users", user.uid), { categoryOrder }, { merge: true });
                  }
                  setReorderingCategories(false);
                }}
                className="w-full py-3 rounded-2xl bg-gradient-to-r from-pastel-purple to-pastel-pink text-white font-medium hover:shadow-lg transition-all"
              >
                완료
              </button>
            </div>
          </div>
        )}

      </div>
    </main>
  );
}

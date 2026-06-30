import { initializeApp } from "firebase/app";
import { getFirestore, doc, setDoc, collection, getDocs } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyBEmVwtGiCPjyfYqbJuG7husJ5BWK2U0Tw",
  authDomain: "my-profile-5209e.firebaseapp.com",
  projectId: "my-profile-5209e",
  storageBucket: "my-profile-5209e.firebasestorage.app",
  messagingSenderId: "384775334484",
  appId: "1:384775334484:web:b5b26a281339dd4fa91bc1",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const dummyUsers = [
  {
    uid: "dummy_minjae",
    username: "minjae_k",
    displayName: "김민재",
    tag: "3",
    photoURL: "",
    bio: "맛집 돌아다니는 거 좋아하는 대학생",
    views: 8,
    likes: 5,
    friends: ["dummy_yuna", "dummy_jiwon"],
    friendRequests: [],
    sentRequests: [],
    chatUnread: {},
    infoFields: [
      { label: "나이", value: "22" },
      { label: "MBTI", value: "ENFP" },
      { label: "사는 곳", value: "서울 마포구" },
    ],
    categoryOrder: ["food", "music", "game", "movie"],
    food: {
      items: [
        { text: "엽떡 2단계", image: "", link: "" },
        { text: "연어 초밥", image: "", link: "" },
        { text: "부대찌개", image: "", link: "" },
        { text: "마라탕 (곱창 넣어야 함)", image: "", link: "" },
      ],
    },
    music: {
      items: [
        { text: "뉴진스 - Ditto", image: "", link: "" },
        { text: "아이유 - 밤편지", image: "", link: "" },
        { text: "The Weeknd - Blinding Lights", image: "", link: "" },
      ],
    },
    game: {
      items: [
        { text: "발로란트 (실버)", image: "", link: "" },
        { text: "마인크래프트", image: "", link: "" },
      ],
    },
    movie: {
      items: [
        { text: "인터스텔라", image: "", link: "" },
        { text: "범죄도시 시리즈", image: "", link: "" },
        { text: "어바웃 타임", image: "", link: "" },
      ],
    },
  },
  {
    uid: "dummy_yuna",
    username: "yuna.log",
    displayName: "이유나",
    tag: "4",
    photoURL: "",
    bio: "카페 탐방 / 소소한 일상 기록",
    views: 12,
    likes: 9,
    friends: ["dummy_minjae", "dummy_sojin"],
    friendRequests: [],
    sentRequests: [],
    chatUnread: {},
    infoFields: [
      { label: "나이", value: "21" },
      { label: "MBTI", value: "INFJ" },
      { label: "직업", value: "디자인과 재학" },
    ],
    categoryOrder: ["drink", "movie", "book", "ideal"],
    drink: {
      items: [
        { text: "아이스 바닐라 라떼", image: "", link: "" },
        { text: "딸기 스무디", image: "", link: "" },
        { text: "자몽 에이드", image: "", link: "" },
      ],
    },
    movie: {
      items: [
        { text: "라라랜드", image: "", link: "" },
        { text: "이터널 선샤인", image: "", link: "" },
        { text: "너의 이름은", image: "", link: "" },
      ],
    },
    book: {
      items: [
        { text: "아몬드 - 손원평", image: "", link: "" },
        { text: "나미야 잡화점의 기적", image: "", link: "" },
      ],
    },
    ideal: {
      items: [
        { text: "유머 감각 있는 사람", image: "", link: "" },
        { text: "같이 카페 가줄 사람", image: "", link: "" },
        { text: "연락 잘 되는 사람", image: "", link: "" },
      ],
    },
  },
  {
    uid: "dummy_jiwon",
    username: "jwpark_",
    displayName: "박지원",
    tag: "5",
    photoURL: "",
    bio: "코딩하다 지치면 러닝함",
    views: 6,
    likes: 3,
    friends: ["dummy_minjae"],
    friendRequests: [],
    sentRequests: [],
    chatUnread: {},
    infoFields: [
      { label: "나이", value: "24" },
      { label: "MBTI", value: "INTP" },
      { label: "직업", value: "백엔드 개발자" },
    ],
    categoryOrder: ["game", "music", "food", "hobby"],
    game: {
      items: [
        { text: "리그 오브 레전드 (골드)", image: "", link: "" },
        { text: "오버워치2", image: "", link: "" },
        { text: "스팀 인디게임 아무거나", image: "", link: "" },
      ],
    },
    music: {
      items: [
        { text: "실리카겔 - NO PAIN", image: "", link: "" },
        { text: "잔나비 - 주저하는 연인들을 위해", image: "", link: "" },
        { text: "Radiohead - Creep", image: "", link: "" },
      ],
    },
    food: {
      items: [
        { text: "제육볶음", image: "", link: "" },
        { text: "돈까스 (경양식)", image: "", link: "" },
        { text: "김치볶음밥", image: "", link: "" },
      ],
    },
    hobby: {
      items: [
        { text: "새벽 러닝 (한강)", image: "", link: "" },
        { text: "넷플릭스 몰아보기", image: "", link: "" },
      ],
    },
  },
  {
    uid: "dummy_sojin",
    username: "sojin._.03",
    displayName: "최소진",
    tag: "6",
    photoURL: "",
    bio: "애니 좋아하는 평범한 고3",
    views: 4,
    likes: 7,
    friends: ["dummy_yuna", "dummy_hyunwoo"],
    friendRequests: [],
    sentRequests: [],
    chatUnread: {},
    infoFields: [
      { label: "나이", value: "19" },
      { label: "MBTI", value: "ISFP" },
    ],
    categoryOrder: ["comic", "drama", "pokemon", "food"],
    comic: {
      items: [
        { text: "원피스", image: "", link: "" },
        { text: "주술회전", image: "", link: "" },
        { text: "나의 히어로 아카데미아", image: "", link: "" },
        { text: "체인소맨", image: "", link: "" },
      ],
    },
    drama: {
      items: [
        { text: "이상한 변호사 우영우", image: "", link: "" },
        { text: "더 글로리", image: "", link: "" },
      ],
    },
    pokemon: {
      items: [
        { text: "이브이", image: "", link: "" },
        { text: "피카츄", image: "", link: "" },
        { text: "팬텀", image: "", link: "" },
      ],
    },
    food: {
      items: [
        { text: "떡볶이 (밀떡파)", image: "", link: "" },
        { text: "붕어빵 (팥)", image: "", link: "" },
        { text: "치즈볼", image: "", link: "" },
      ],
    },
  },
  {
    uid: "dummy_hyunwoo",
    username: "hw_travel",
    displayName: "정현우",
    tag: "7",
    photoURL: "",
    bio: "여행 계획 짜는 게 제일 재밌음",
    views: 11,
    likes: 6,
    friends: ["dummy_sojin"],
    friendRequests: [],
    sentRequests: [],
    chatUnread: {},
    infoFields: [
      { label: "나이", value: "26" },
      { label: "MBTI", value: "ESTP" },
      { label: "직업", value: "여행사 근무" },
    ],
    categoryOrder: ["travel", "food", "music", "drink"],
    travel: {
      items: [
        { text: "오사카 (도톤보리 최고)", image: "", link: "" },
        { text: "제주도 동쪽 해안", image: "", link: "" },
        { text: "방콕 카오산로드", image: "", link: "" },
        { text: "다낭 (바나힐 꼭 가세요)", image: "", link: "" },
      ],
    },
    food: {
      items: [
        { text: "스시 오마카세", image: "", link: "" },
        { text: "쌀국수", image: "", link: "" },
        { text: "타코", image: "", link: "" },
      ],
    },
    music: {
      items: [
        { text: "10cm - 봄이 좋냐", image: "", link: "" },
        { text: "악뮤 - 어떻게 이별까지 사랑하겠어", image: "", link: "" },
      ],
    },
    drink: {
      items: [
        { text: "하이볼", image: "", link: "" },
        { text: "아이스 아메리카노", image: "", link: "" },
        { text: "코코넛 워터", image: "", link: "" },
      ],
    },
  },
];

async function seed() {
  for (const u of dummyUsers) {
    const { uid, ...data } = u;
    await setDoc(doc(db, "users", uid), data, { merge: true });
    console.log(`✓ ${data.username} (#${data.tag}) seeded`);
  }
  console.log("\nDone! 5 dummy users created.");
  process.exit(0);
}

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});

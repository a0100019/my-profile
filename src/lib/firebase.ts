import { initializeApp, getApps, type FirebaseApp } from "firebase/app";
import { getAuth, GoogleAuthProvider, type Auth } from "firebase/auth";
import { getFirestore, type Firestore } from "firebase/firestore";
import { getStorage, type FirebaseStorage } from "firebase/storage";

const firebaseConfig = {
  apiKey: "AIzaSyBEmVwtGiCPjyfYqbJuG7husJ5BWK2U0Tw",
  authDomain: "my-profile-5209e.firebaseapp.com",
  projectId: "my-profile-5209e",
  storageBucket: "my-profile-5209e.firebasestorage.app",
  messagingSenderId: "384775334484",
  appId: "1:384775334484:web:b5b26a281339dd4fa91bc1",
};

function getApp(): FirebaseApp {
  return getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];
}

let _auth: Auth;
let _db: Firestore;
let _storage: FirebaseStorage;

export function getFirebaseAuth(): Auth {
  if (!_auth) _auth = getAuth(getApp());
  return _auth;
}

export const googleProvider = new GoogleAuthProvider();

export function getFirebaseDb(): Firestore {
  if (!_db) _db = getFirestore(getApp());
  return _db;
}

export function getFirebaseStorage(): FirebaseStorage {
  if (!_storage) _storage = getStorage(getApp());
  return _storage;
}

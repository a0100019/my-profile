const CACHE_PREFIX = "profile-photo:";

export async function compressImage(
  file: File,
  maxSize = 512,
  quality = 0.8
): Promise<Blob> {
  const bitmap = await createImageBitmap(file);
  const { width, height } = bitmap;

  let targetW = width;
  let targetH = height;
  if (width > maxSize || height > maxSize) {
    const ratio = Math.min(maxSize / width, maxSize / height);
    targetW = Math.round(width * ratio);
    targetH = Math.round(height * ratio);
  }

  const canvas = new OffscreenCanvas(targetW, targetH);
  const ctx = canvas.getContext("2d")!;
  ctx.drawImage(bitmap, 0, 0, targetW, targetH);
  bitmap.close();

  return canvas.convertToBlob({ type: "image/webp", quality });
}

export function cachePhoto(uid: string, url: string) {
  try {
    sessionStorage.setItem(CACHE_PREFIX + uid, url);
  } catch {}
}

export function getCachedPhoto(uid: string): string | null {
  try {
    return sessionStorage.getItem(CACHE_PREFIX + uid);
  } catch {
    return null;
  }
}

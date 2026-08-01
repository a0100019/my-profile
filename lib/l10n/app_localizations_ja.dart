// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'murimuri.io';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '削除';

  @override
  String get commonEdit => '編集';

  @override
  String get commonAdd => '追加';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonLoading => '読み込み中...';

  @override
  String get commonNone => 'ありません';

  @override
  String get categoryFood => 'グルメ';

  @override
  String get categoryMovie => '映画';

  @override
  String get categoryMusic => '音楽';

  @override
  String get categoryBook => '本';

  @override
  String get categoryHobby => '趣味';

  @override
  String get categoryTravel => '旅行';

  @override
  String get categoryGame => 'ゲーム';

  @override
  String get categoryDrama => 'ドラマ';

  @override
  String get categoryDrink => 'ドリンク';

  @override
  String get categoryComic => '漫画';

  @override
  String get categoryPokemon => 'ポケモン';

  @override
  String get categoryYoutube => 'YouTube';

  @override
  String get categoryExercise => '運動';

  @override
  String get categoryWebtoon => 'ウェブトゥーン';

  @override
  String get categoryBrand => 'ブランド';

  @override
  String get categoryMbti => 'MBTI';

  @override
  String get categoryIdeal => '理想のタイプ';

  @override
  String get nationalityTitle => '国籍を選択してください';

  @override
  String get nationalitySubtitle => '選択した国籍に合わせて画面の言語が設定されます';

  @override
  String get nationalityKorea => '韓国';

  @override
  String get nationalityJapan => '日本';

  @override
  String get nationalityNext => '次へ';

  @override
  String get loginAgreeTerms => '利用規約に同意してください。';

  @override
  String get loginFailed => 'ログインに失敗しました。もう一度お試しください。';

  @override
  String get loginTitle => 'murimuri.io';

  @override
  String get loginSubtitle => '自分だけの好みを詰め込んだプロフィールを作って\n友達に共有してみましょう';

  @override
  String get loginGoogleButton => 'Googleで始める';

  @override
  String get loginLoggingIn => 'ログイン中...';

  @override
  String get loginAgreeCheckbox => '利用規約に同意します';

  @override
  String get loginViewTerms => '詳しく見る';

  @override
  String get loginTermsTitle => '利用規約';

  @override
  String get dashboardShare => 'プロフィール共有';

  @override
  String get dashboardStore => '🛍️ ストア';

  @override
  String get storeComingSoonTitle => 'ストア準備中です';

  @override
  String get storeComingSoonSubtitle => 'もうすぐグッズをお届けできます。少々お待ちください!';

  @override
  String get dashboardShareCopied => 'コピーしました!';

  @override
  String get dashboardAddCategory => 'カテゴリーを追加';

  @override
  String get dashboardCustomCategoryHint => '好きなカテゴリーを作ってみよう';

  @override
  String get dashboardCategoryExists => 'すでに追加されているカテゴリーです。';

  @override
  String get dashboardFriends => '友達';

  @override
  String get dashboardWarningTitle => '⚠️ 警告';

  @override
  String get dashboardWarningContent =>
      '複数のユーザーから通報を受けました。通報が5回累積すると、アカウントがロックされることがあります。';

  @override
  String get dashboardPhotoUploadFailed => '写真のアップロードに失敗しました。もう一度お試しください。';

  @override
  String get dashboardAccountDeleteFailed => '退会処理に失敗しました。もう一度お試しください。';

  @override
  String get dashboardReportedListTitle => '通報したユーザー';

  @override
  String get dashboardLikedByTitle => 'いいねをくれた人';

  @override
  String get dashboardLikedProfilesTitle => '自分がいいねしたプロフィール';

  @override
  String get profileCardEdit => 'プロフィール変更';

  @override
  String get profileCardBio => '自己紹介';

  @override
  String get profileCardBioOneLine => 'ひとこと紹介';

  @override
  String profileCardViews(Object count) {
    return '閲覧数 $count';
  }

  @override
  String profileCardLikesReceived(Object count) {
    return 'もらったいいね $count';
  }

  @override
  String get profileCardLikesGiven => '押したいいね';

  @override
  String get profileCardRanking => '🏆 ランキングを見る';

  @override
  String profileCardComments(Object count) {
    return '💬 コメントを見る($count)';
  }

  @override
  String get categoryEmptyItems => 'まだ項目がありません';

  @override
  String get categoryAddItemHint => '新しい項目を追加';

  @override
  String get categoryAddLinkHint => 'リンク(URL)を入力';

  @override
  String get categoryDeleteCategory => 'カテゴリーを削除';

  @override
  String categoryDeleteConfirm(Object label) {
    return '「$label」カテゴリーを削除しますか?';
  }

  @override
  String get editProfileTitle => 'プロフィール編集';

  @override
  String get editProfileName => '名前';

  @override
  String get editProfileUsername => 'ユーザー名';

  @override
  String get editProfileBio => 'ひとこと紹介';

  @override
  String get editProfileInfoFields => '情報項目';

  @override
  String get editProfileFieldLabelHint => '項目名';

  @override
  String get editProfileFieldValueHint => '内容';

  @override
  String get editProfileUsernameEmpty => 'ユーザー名を入力してください。';

  @override
  String get editProfileUsernameTaken => 'すでに使われているユーザー名です。';

  @override
  String get settingsTitle => '⚙️ 設定';

  @override
  String get settingsPrivacy => '🔒 プロフィール非公開';

  @override
  String get settingsPrivacyDesc => '非公開にすると検索やランダムプロフィールから除外されます';

  @override
  String get settingsReportedList => '🚨 通報したユーザー';

  @override
  String get settingsNationality => '🌐 国籍/言語';

  @override
  String get settingsBamboo => '🎋 竹林(意見箱)';

  @override
  String get settingsTerms => '📋 利用規約';

  @override
  String get settingsLogout => '🚪 ログアウト';

  @override
  String get settingsLogoutConfirm => 'ログアウトしますか?';

  @override
  String get settingsDeleteAccount => '❌ 退会する';

  @override
  String get settingsDeleteAccountConfirm =>
      '退会するとプロフィール・カテゴリー・コメントなど全てのデータが即座に削除され、元に戻せません。本当に退会しますか?';

  @override
  String get settingsTermsTitle => '利用規約';

  @override
  String get bambooTitle => '🎋 竹林(意見箱)';

  @override
  String get bambooDescription =>
      '竹林はサイトについての意見を自由に書き込める場所です。匿名なので安心してご意見をお寄せください!';

  @override
  String get bambooEmpty => 'まだ投稿がありません';

  @override
  String get bambooInputHint => '匿名で書き込む...';

  @override
  String commentsTitle(Object count) {
    return 'コメント ($count)';
  }

  @override
  String get commentsEmpty => 'まだコメントがありません';

  @override
  String get commentsInputHint => 'コメントを書く...';

  @override
  String get commentsDeleteTitle => 'コメント削除';

  @override
  String get commentsDeleteConfirm => 'このコメントを削除しますか?';

  @override
  String get friendsTitle => '友達';

  @override
  String get friendsTabFriends => '👫 友達';

  @override
  String get friendsTabGlobalChat => '💬 全体チャット';

  @override
  String get friendsTabRandom => '🎲 ランダムプロフィール';

  @override
  String get friendsEmptyList => 'まだありません';

  @override
  String get friendsRequestsHeader => '友達リクエスト';

  @override
  String get friendsNoFriends => 'まだ友達がいません';

  @override
  String get friendsNoMessages => 'まだメッセージがありません';

  @override
  String get friendsAccept => '承認';

  @override
  String get friendsReject => '拒否';

  @override
  String get friendsRemove => '友達を削除';

  @override
  String friendsRemoveConfirm(Object username) {
    return '「$username」さんを友達から削除しますか?';
  }

  @override
  String get friendsMessageDeleteTitle => 'メッセージ削除';

  @override
  String get friendsMessageDeleteConfirm => 'このメッセージを削除しますか?';

  @override
  String get friendsChatInputHint => 'メッセージを入力...';

  @override
  String get friendsSearchHint => 'ユーザー名で検索';

  @override
  String get friendsSearchEmpty => '検索結果がありません';

  @override
  String get friendsLoadMore => 'もっと見る';

  @override
  String get rankingTitle => '🏆 ランキング';

  @override
  String get rankingViews => '閲覧数';

  @override
  String get rankingLikes => 'いいね';

  @override
  String get rankingFriends => '友達';

  @override
  String get reportTitle => '通報する';

  @override
  String get reportPrompt => '通報理由を入力してください。';

  @override
  String get reportHint => '例: 暴言、荒らし、なりすまし等';

  @override
  String get reportButton => '🚨 通報';

  @override
  String get reportedButton => '通報済み';

  @override
  String get reportAlreadyReported => 'すでに通報したユーザーです。';

  @override
  String get reportSubmitted => '通報を受け付けました。';

  @override
  String get reportFailed => '通報の処理に失敗しました。もう一度お試しください。';

  @override
  String get publicProfileNotFound => 'プロフィールが見つかりません';

  @override
  String get publicProfileBlocked => 'アクセスできないプロフィールです';

  @override
  String publicProfileLikes(Object count) {
    return 'いいね $count';
  }

  @override
  String get publicProfileFriendAdd => '友達追加';

  @override
  String get publicProfileFriendPending => 'リクエスト中';

  @override
  String get publicProfileCommentFailed => 'コメントの投稿に失敗しました。もう一度お試しください。';

  @override
  String get publicProfileAnonymous => '匿名';

  @override
  String get publicProfileCommentsHeader => '💬 コメント';

  @override
  String get lockedTitle => 'アカウントがロックされました';

  @override
  String get lockedSubtitle => '複数のユーザーから通報を受けたため、アカウントの利用が制限されました。';

  @override
  String get lockedReasonTitle => '通報理由';

  @override
  String get lockedReasonEmpty => '登録された理由はありません';

  @override
  String get lockedReasonUnwritten => '(理由未記入)';

  @override
  String get lockedContactTitle => 'お問い合わせ';

  @override
  String get lockedContactSubtitle => '誤りがあればお知らせください';

  @override
  String get lockedContactHint => '内容を入力してください';

  @override
  String get lockedContactSubmit => '送信';

  @override
  String get lockedContactSent => 'お問い合わせを受け付けました。確認後ご連絡いたします。';

  @override
  String get lockedContactFailed => '送信に失敗しました。もう一度お試しください。';

  @override
  String get lockedLogout => 'ログアウト';
}

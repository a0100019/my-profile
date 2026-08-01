import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @appName.
  ///
  /// In ko, this message translates to:
  /// **'murimuri.io'**
  String get appName;

  /// No description provided for @commonCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get commonAdd;

  /// No description provided for @commonClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get commonClose;

  /// No description provided for @commonLoading.
  ///
  /// In ko, this message translates to:
  /// **'불러오는 중...'**
  String get commonLoading;

  /// No description provided for @commonNone.
  ///
  /// In ko, this message translates to:
  /// **'없어요'**
  String get commonNone;

  /// No description provided for @categoryFood.
  ///
  /// In ko, this message translates to:
  /// **'음식'**
  String get categoryFood;

  /// No description provided for @categoryMovie.
  ///
  /// In ko, this message translates to:
  /// **'영화'**
  String get categoryMovie;

  /// No description provided for @categoryMusic.
  ///
  /// In ko, this message translates to:
  /// **'음악'**
  String get categoryMusic;

  /// No description provided for @categoryBook.
  ///
  /// In ko, this message translates to:
  /// **'책'**
  String get categoryBook;

  /// No description provided for @categoryHobby.
  ///
  /// In ko, this message translates to:
  /// **'취미'**
  String get categoryHobby;

  /// No description provided for @categoryTravel.
  ///
  /// In ko, this message translates to:
  /// **'여행'**
  String get categoryTravel;

  /// No description provided for @categoryGame.
  ///
  /// In ko, this message translates to:
  /// **'게임'**
  String get categoryGame;

  /// No description provided for @categoryDrama.
  ///
  /// In ko, this message translates to:
  /// **'드라마'**
  String get categoryDrama;

  /// No description provided for @categoryDrink.
  ///
  /// In ko, this message translates to:
  /// **'음료'**
  String get categoryDrink;

  /// No description provided for @categoryComic.
  ///
  /// In ko, this message translates to:
  /// **'만화'**
  String get categoryComic;

  /// No description provided for @categoryPokemon.
  ///
  /// In ko, this message translates to:
  /// **'포켓몬'**
  String get categoryPokemon;

  /// No description provided for @categoryYoutube.
  ///
  /// In ko, this message translates to:
  /// **'유튜브'**
  String get categoryYoutube;

  /// No description provided for @categoryExercise.
  ///
  /// In ko, this message translates to:
  /// **'운동'**
  String get categoryExercise;

  /// No description provided for @categoryWebtoon.
  ///
  /// In ko, this message translates to:
  /// **'웹툰'**
  String get categoryWebtoon;

  /// No description provided for @categoryBrand.
  ///
  /// In ko, this message translates to:
  /// **'브랜드'**
  String get categoryBrand;

  /// No description provided for @categoryMbti.
  ///
  /// In ko, this message translates to:
  /// **'MBTI'**
  String get categoryMbti;

  /// No description provided for @categoryIdeal.
  ///
  /// In ko, this message translates to:
  /// **'이상형'**
  String get categoryIdeal;

  /// No description provided for @nationalityTitle.
  ///
  /// In ko, this message translates to:
  /// **'국적을 선택해주세요'**
  String get nationalityTitle;

  /// No description provided for @nationalitySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'선택하신 국적에 맞춰 화면 언어가 설정돼요'**
  String get nationalitySubtitle;

  /// No description provided for @nationalityKorea.
  ///
  /// In ko, this message translates to:
  /// **'한국'**
  String get nationalityKorea;

  /// No description provided for @nationalityJapan.
  ///
  /// In ko, this message translates to:
  /// **'일본'**
  String get nationalityJapan;

  /// No description provided for @nationalityNext.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get nationalityNext;

  /// No description provided for @loginAgreeTerms.
  ///
  /// In ko, this message translates to:
  /// **'약관에 동의해주세요.'**
  String get loginAgreeTerms;

  /// No description provided for @loginFailed.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했어요. 다시 시도해주세요.'**
  String get loginFailed;

  /// No description provided for @loginTitle.
  ///
  /// In ko, this message translates to:
  /// **'murimuri.io'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'나만의 취향을 담은 프로필을 만들고\n친구에게 공유해보세요'**
  String get loginSubtitle;

  /// No description provided for @loginGoogleButton.
  ///
  /// In ko, this message translates to:
  /// **'Google로 시작하기'**
  String get loginGoogleButton;

  /// No description provided for @loginLoggingIn.
  ///
  /// In ko, this message translates to:
  /// **'로그인 중...'**
  String get loginLoggingIn;

  /// No description provided for @loginAgreeCheckbox.
  ///
  /// In ko, this message translates to:
  /// **'이용약관에 동의합니다'**
  String get loginAgreeCheckbox;

  /// No description provided for @loginViewTerms.
  ///
  /// In ko, this message translates to:
  /// **'자세히보기'**
  String get loginViewTerms;

  /// No description provided for @loginTermsTitle.
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get loginTermsTitle;

  /// No description provided for @dashboardShare.
  ///
  /// In ko, this message translates to:
  /// **'프로필 공유'**
  String get dashboardShare;

  /// No description provided for @dashboardStore.
  ///
  /// In ko, this message translates to:
  /// **'🛍️ 스토어'**
  String get dashboardStore;

  /// No description provided for @storeComingSoonTitle.
  ///
  /// In ko, this message translates to:
  /// **'스토어 준비 중이에요'**
  String get storeComingSoonTitle;

  /// No description provided for @storeComingSoonSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'곧 굿즈를 만나보실 수 있어요. 조금만 기다려주세요!'**
  String get storeComingSoonSubtitle;

  /// No description provided for @dashboardShareCopied.
  ///
  /// In ko, this message translates to:
  /// **'복사됨!'**
  String get dashboardShareCopied;

  /// No description provided for @dashboardAddCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 추가하기'**
  String get dashboardAddCategory;

  /// No description provided for @dashboardCustomCategoryHint.
  ///
  /// In ko, this message translates to:
  /// **'원하는 카테고리를 만들어봐요'**
  String get dashboardCustomCategoryHint;

  /// No description provided for @dashboardCategoryExists.
  ///
  /// In ko, this message translates to:
  /// **'이미 추가된 카테고리예요.'**
  String get dashboardCategoryExists;

  /// No description provided for @dashboardFriends.
  ///
  /// In ko, this message translates to:
  /// **'친구'**
  String get dashboardFriends;

  /// No description provided for @dashboardWarningTitle.
  ///
  /// In ko, this message translates to:
  /// **'⚠️ 경고'**
  String get dashboardWarningTitle;

  /// No description provided for @dashboardWarningContent.
  ///
  /// In ko, this message translates to:
  /// **'다수의 사용자로부터 신고가 접수됐어요. 신고가 5회 누적되면 계정이 잠길 수 있어요.'**
  String get dashboardWarningContent;

  /// No description provided for @dashboardPhotoUploadFailed.
  ///
  /// In ko, this message translates to:
  /// **'사진 업로드에 실패했어요. 다시 시도해주세요.'**
  String get dashboardPhotoUploadFailed;

  /// No description provided for @dashboardAccountDeleteFailed.
  ///
  /// In ko, this message translates to:
  /// **'탈퇴 처리에 실패했어요. 다시 시도해주세요.'**
  String get dashboardAccountDeleteFailed;

  /// No description provided for @dashboardReportedListTitle.
  ///
  /// In ko, this message translates to:
  /// **'내가 신고한 사용자'**
  String get dashboardReportedListTitle;

  /// No description provided for @dashboardLikedByTitle.
  ///
  /// In ko, this message translates to:
  /// **'좋아요 눌러준 사람'**
  String get dashboardLikedByTitle;

  /// No description provided for @dashboardLikedProfilesTitle.
  ///
  /// In ko, this message translates to:
  /// **'내가 좋아요 누른 프로필'**
  String get dashboardLikedProfilesTitle;

  /// No description provided for @profileCardEdit.
  ///
  /// In ko, this message translates to:
  /// **'프로필 변경'**
  String get profileCardEdit;

  /// No description provided for @profileCardBio.
  ///
  /// In ko, this message translates to:
  /// **'자기소개'**
  String get profileCardBio;

  /// No description provided for @profileCardBioOneLine.
  ///
  /// In ko, this message translates to:
  /// **'한줄 소개'**
  String get profileCardBioOneLine;

  /// No description provided for @profileCardViews.
  ///
  /// In ko, this message translates to:
  /// **'조회수 {count}'**
  String profileCardViews(Object count);

  /// No description provided for @profileCardLikesReceived.
  ///
  /// In ko, this message translates to:
  /// **'받은 좋아요 {count}'**
  String profileCardLikesReceived(Object count);

  /// No description provided for @profileCardLikesGiven.
  ///
  /// In ko, this message translates to:
  /// **'누른 좋아요'**
  String get profileCardLikesGiven;

  /// No description provided for @profileCardRanking.
  ///
  /// In ko, this message translates to:
  /// **'🏆 순위 보기'**
  String get profileCardRanking;

  /// No description provided for @profileCardComments.
  ///
  /// In ko, this message translates to:
  /// **'💬 댓글 보기({count})'**
  String profileCardComments(Object count);

  /// No description provided for @categoryEmptyItems.
  ///
  /// In ko, this message translates to:
  /// **'아직 항목이 없어요'**
  String get categoryEmptyItems;

  /// No description provided for @categoryAddItemHint.
  ///
  /// In ko, this message translates to:
  /// **'새 항목 추가'**
  String get categoryAddItemHint;

  /// No description provided for @categoryAddLinkHint.
  ///
  /// In ko, this message translates to:
  /// **'링크(URL) 입력'**
  String get categoryAddLinkHint;

  /// No description provided for @categoryDeleteCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 삭제'**
  String get categoryDeleteCategory;

  /// No description provided for @categoryDeleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'\"{label}\" 카테고리를 삭제할까요?'**
  String categoryDeleteConfirm(Object label);

  /// No description provided for @editProfileTitle.
  ///
  /// In ko, this message translates to:
  /// **'프로필 편집'**
  String get editProfileTitle;

  /// No description provided for @editProfileName.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get editProfileName;

  /// No description provided for @editProfileUsername.
  ///
  /// In ko, this message translates to:
  /// **'유저네임'**
  String get editProfileUsername;

  /// No description provided for @editProfileBio.
  ///
  /// In ko, this message translates to:
  /// **'한줄 소개'**
  String get editProfileBio;

  /// No description provided for @editProfileInfoFields.
  ///
  /// In ko, this message translates to:
  /// **'정보 필드'**
  String get editProfileInfoFields;

  /// No description provided for @editProfileFieldLabelHint.
  ///
  /// In ko, this message translates to:
  /// **'항목명'**
  String get editProfileFieldLabelHint;

  /// No description provided for @editProfileFieldValueHint.
  ///
  /// In ko, this message translates to:
  /// **'내용'**
  String get editProfileFieldValueHint;

  /// No description provided for @editProfileUsernameEmpty.
  ///
  /// In ko, this message translates to:
  /// **'유저네임을 입력해주세요.'**
  String get editProfileUsernameEmpty;

  /// No description provided for @editProfileUsernameTaken.
  ///
  /// In ko, this message translates to:
  /// **'이미 사용 중인 유저네임이에요.'**
  String get editProfileUsernameTaken;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'⚙️ 설정'**
  String get settingsTitle;

  /// No description provided for @settingsPrivacy.
  ///
  /// In ko, this message translates to:
  /// **'🔒 프로필 비공개'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyDesc.
  ///
  /// In ko, this message translates to:
  /// **'비공개하면 검색 및 랜덤 프로필 보기에서 제외돼요'**
  String get settingsPrivacyDesc;

  /// No description provided for @settingsReportedList.
  ///
  /// In ko, this message translates to:
  /// **'🚨 내가 신고한 사용자'**
  String get settingsReportedList;

  /// No description provided for @settingsNationality.
  ///
  /// In ko, this message translates to:
  /// **'🌐 국적/언어'**
  String get settingsNationality;

  /// No description provided for @settingsBamboo.
  ///
  /// In ko, this message translates to:
  /// **'🎋 대나무숲'**
  String get settingsBamboo;

  /// No description provided for @settingsTerms.
  ///
  /// In ko, this message translates to:
  /// **'📋 이용약관'**
  String get settingsTerms;

  /// No description provided for @settingsLogout.
  ///
  /// In ko, this message translates to:
  /// **'🚪 로그아웃'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃 하시겠어요?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In ko, this message translates to:
  /// **'❌ 회원 탈퇴'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In ko, this message translates to:
  /// **'탈퇴 시 프로필, 카테고리, 댓글 등 모든 데이터가 즉시 삭제되며 되돌릴 수 없어요. 정말 탈퇴하시겠어요?'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsTermsTitle.
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get settingsTermsTitle;

  /// No description provided for @bambooTitle.
  ///
  /// In ko, this message translates to:
  /// **'🎋 대나무숲'**
  String get bambooTitle;

  /// No description provided for @bambooDescription.
  ///
  /// In ko, this message translates to:
  /// **'대나무숲은 사이트에 관한 의견을 자유롭게 작성하는 곳입니다. 익명이니 안심하고 바라는 점을 적어주세요!'**
  String get bambooDescription;

  /// No description provided for @bambooEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 글이 없어요'**
  String get bambooEmpty;

  /// No description provided for @bambooInputHint.
  ///
  /// In ko, this message translates to:
  /// **'익명으로 작성하기...'**
  String get bambooInputHint;

  /// No description provided for @commentsTitle.
  ///
  /// In ko, this message translates to:
  /// **'댓글 ({count})'**
  String commentsTitle(Object count);

  /// No description provided for @commentsEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 댓글이 없어요'**
  String get commentsEmpty;

  /// No description provided for @commentsInputHint.
  ///
  /// In ko, this message translates to:
  /// **'댓글 작성...'**
  String get commentsInputHint;

  /// No description provided for @commentsDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'댓글 삭제'**
  String get commentsDeleteTitle;

  /// No description provided for @commentsDeleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 댓글을 삭제할까요?'**
  String get commentsDeleteConfirm;

  /// No description provided for @friendsTitle.
  ///
  /// In ko, this message translates to:
  /// **'친구'**
  String get friendsTitle;

  /// No description provided for @friendsTabFriends.
  ///
  /// In ko, this message translates to:
  /// **'👫 친구'**
  String get friendsTabFriends;

  /// No description provided for @friendsTabGlobalChat.
  ///
  /// In ko, this message translates to:
  /// **'💬 전체 채팅'**
  String get friendsTabGlobalChat;

  /// No description provided for @friendsTabRandom.
  ///
  /// In ko, this message translates to:
  /// **'🎲 랜덤 프로필'**
  String get friendsTabRandom;

  /// No description provided for @friendsEmptyList.
  ///
  /// In ko, this message translates to:
  /// **'아직 없어요'**
  String get friendsEmptyList;

  /// No description provided for @friendsRequestsHeader.
  ///
  /// In ko, this message translates to:
  /// **'친구 요청'**
  String get friendsRequestsHeader;

  /// No description provided for @friendsNoFriends.
  ///
  /// In ko, this message translates to:
  /// **'아직 친구가 없어요'**
  String get friendsNoFriends;

  /// No description provided for @friendsNoMessages.
  ///
  /// In ko, this message translates to:
  /// **'아직 메시지가 없어요'**
  String get friendsNoMessages;

  /// No description provided for @friendsAccept.
  ///
  /// In ko, this message translates to:
  /// **'수락'**
  String get friendsAccept;

  /// No description provided for @friendsReject.
  ///
  /// In ko, this message translates to:
  /// **'거절'**
  String get friendsReject;

  /// No description provided for @friendsRemove.
  ///
  /// In ko, this message translates to:
  /// **'친구 삭제'**
  String get friendsRemove;

  /// No description provided for @friendsRemoveConfirm.
  ///
  /// In ko, this message translates to:
  /// **'\"{username}\"님을 친구에서 삭제할까요?'**
  String friendsRemoveConfirm(Object username);

  /// No description provided for @friendsMessageDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'메시지 삭제'**
  String get friendsMessageDeleteTitle;

  /// No description provided for @friendsMessageDeleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 메시지를 삭제할까요?'**
  String get friendsMessageDeleteConfirm;

  /// No description provided for @friendsChatInputHint.
  ///
  /// In ko, this message translates to:
  /// **'메시지 입력...'**
  String get friendsChatInputHint;

  /// No description provided for @friendsSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'유저네임으로 검색'**
  String get friendsSearchHint;

  /// No description provided for @friendsSearchEmpty.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없어요'**
  String get friendsSearchEmpty;

  /// No description provided for @friendsLoadMore.
  ///
  /// In ko, this message translates to:
  /// **'더보기'**
  String get friendsLoadMore;

  /// No description provided for @rankingTitle.
  ///
  /// In ko, this message translates to:
  /// **'🏆 순위'**
  String get rankingTitle;

  /// No description provided for @rankingViews.
  ///
  /// In ko, this message translates to:
  /// **'조회수'**
  String get rankingViews;

  /// No description provided for @rankingLikes.
  ///
  /// In ko, this message translates to:
  /// **'좋아요'**
  String get rankingLikes;

  /// No description provided for @rankingFriends.
  ///
  /// In ko, this message translates to:
  /// **'친구'**
  String get rankingFriends;

  /// No description provided for @reportTitle.
  ///
  /// In ko, this message translates to:
  /// **'신고하기'**
  String get reportTitle;

  /// No description provided for @reportPrompt.
  ///
  /// In ko, this message translates to:
  /// **'신고 사유를 입력해주세요.'**
  String get reportPrompt;

  /// No description provided for @reportHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 욕설, 도배, 사칭 등'**
  String get reportHint;

  /// No description provided for @reportButton.
  ///
  /// In ko, this message translates to:
  /// **'🚨 신고'**
  String get reportButton;

  /// No description provided for @reportedButton.
  ///
  /// In ko, this message translates to:
  /// **'신고됨'**
  String get reportedButton;

  /// No description provided for @reportAlreadyReported.
  ///
  /// In ko, this message translates to:
  /// **'이미 신고한 사용자예요.'**
  String get reportAlreadyReported;

  /// No description provided for @reportSubmitted.
  ///
  /// In ko, this message translates to:
  /// **'신고가 접수됐어요.'**
  String get reportSubmitted;

  /// No description provided for @reportFailed.
  ///
  /// In ko, this message translates to:
  /// **'신고 처리에 실패했어요. 다시 시도해주세요.'**
  String get reportFailed;

  /// No description provided for @publicProfileNotFound.
  ///
  /// In ko, this message translates to:
  /// **'프로필을 찾을 수 없어요'**
  String get publicProfileNotFound;

  /// No description provided for @publicProfileBlocked.
  ///
  /// In ko, this message translates to:
  /// **'접근할 수 없는 프로필이에요'**
  String get publicProfileBlocked;

  /// No description provided for @publicProfileLikes.
  ///
  /// In ko, this message translates to:
  /// **'좋아요 {count}'**
  String publicProfileLikes(Object count);

  /// No description provided for @publicProfileFriendAdd.
  ///
  /// In ko, this message translates to:
  /// **'친구 추가'**
  String get publicProfileFriendAdd;

  /// No description provided for @publicProfileFriendPending.
  ///
  /// In ko, this message translates to:
  /// **'요청됨'**
  String get publicProfileFriendPending;

  /// No description provided for @publicProfileCommentFailed.
  ///
  /// In ko, this message translates to:
  /// **'댓글 등록에 실패했어요. 다시 시도해주세요.'**
  String get publicProfileCommentFailed;

  /// No description provided for @publicProfileAnonymous.
  ///
  /// In ko, this message translates to:
  /// **'익명'**
  String get publicProfileAnonymous;

  /// No description provided for @publicProfileCommentsHeader.
  ///
  /// In ko, this message translates to:
  /// **'💬 댓글'**
  String get publicProfileCommentsHeader;

  /// No description provided for @lockedTitle.
  ///
  /// In ko, this message translates to:
  /// **'계정이 잠겼어요'**
  String get lockedTitle;

  /// No description provided for @lockedSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'다수의 사용자로부터 신고가 접수되어 계정 이용이 제한됐어요.'**
  String get lockedSubtitle;

  /// No description provided for @lockedReasonTitle.
  ///
  /// In ko, this message translates to:
  /// **'신고 사유'**
  String get lockedReasonTitle;

  /// No description provided for @lockedReasonEmpty.
  ///
  /// In ko, this message translates to:
  /// **'등록된 사유가 없어요'**
  String get lockedReasonEmpty;

  /// No description provided for @lockedReasonUnwritten.
  ///
  /// In ko, this message translates to:
  /// **'(사유 미작성)'**
  String get lockedReasonUnwritten;

  /// No description provided for @lockedContactTitle.
  ///
  /// In ko, this message translates to:
  /// **'문의하기'**
  String get lockedContactTitle;

  /// No description provided for @lockedContactSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'오류가 있다면 알려주세요'**
  String get lockedContactSubtitle;

  /// No description provided for @lockedContactHint.
  ///
  /// In ko, this message translates to:
  /// **'내용을 입력해주세요'**
  String get lockedContactHint;

  /// No description provided for @lockedContactSubmit.
  ///
  /// In ko, this message translates to:
  /// **'제출'**
  String get lockedContactSubmit;

  /// No description provided for @lockedContactSent.
  ///
  /// In ko, this message translates to:
  /// **'문의가 접수됐어요. 검토 후 반영해드릴게요.'**
  String get lockedContactSent;

  /// No description provided for @lockedContactFailed.
  ///
  /// In ko, this message translates to:
  /// **'전송에 실패했어요. 다시 시도해주세요.'**
  String get lockedContactFailed;

  /// No description provided for @lockedLogout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get lockedLogout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

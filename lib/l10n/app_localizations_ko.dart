// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'murimuri.io';

  @override
  String get commonCancel => '취소';

  @override
  String get commonConfirm => '확인';

  @override
  String get commonSave => '저장';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonEdit => '편집';

  @override
  String get commonAdd => '추가';

  @override
  String get commonClose => '닫기';

  @override
  String get commonLoading => '불러오는 중...';

  @override
  String get commonNone => '없어요';

  @override
  String get categoryFood => '음식';

  @override
  String get categoryMovie => '영화';

  @override
  String get categoryMusic => '음악';

  @override
  String get categoryBook => '책';

  @override
  String get categoryHobby => '취미';

  @override
  String get categoryTravel => '여행';

  @override
  String get categoryGame => '게임';

  @override
  String get categoryDrama => '드라마';

  @override
  String get categoryDrink => '음료';

  @override
  String get categoryComic => '만화';

  @override
  String get categoryPokemon => '포켓몬';

  @override
  String get categoryYoutube => '유튜브';

  @override
  String get categoryExercise => '운동';

  @override
  String get categoryWebtoon => '웹툰';

  @override
  String get categoryBrand => '브랜드';

  @override
  String get categoryMbti => 'MBTI';

  @override
  String get categoryIdeal => '이상형';

  @override
  String get nationalityTitle => '국적을 선택해주세요';

  @override
  String get nationalitySubtitle => '선택하신 국적에 맞춰 화면 언어가 설정돼요';

  @override
  String get nationalityKorea => '한국';

  @override
  String get nationalityJapan => '일본';

  @override
  String get nationalityNext => '다음';

  @override
  String get loginAgreeTerms => '약관에 동의해주세요.';

  @override
  String get loginFailed => '로그인에 실패했어요. 다시 시도해주세요.';

  @override
  String get loginTitle => 'murimuri.io';

  @override
  String get loginSubtitle => '나만의 취향을 담은 프로필을 만들고\n친구에게 공유해보세요';

  @override
  String get loginGoogleButton => 'Google로 시작하기';

  @override
  String get loginLoggingIn => '로그인 중...';

  @override
  String get loginAgreeCheckbox => '이용약관에 동의합니다';

  @override
  String get loginViewTerms => '자세히보기';

  @override
  String get loginTermsTitle => '이용약관';

  @override
  String get dashboardShare => '프로필 공유';

  @override
  String get dashboardStore => '🛍️ 스토어';

  @override
  String get storeComingSoonTitle => '스토어 준비 중이에요';

  @override
  String get storeComingSoonSubtitle => '곧 굿즈를 만나보실 수 있어요. 조금만 기다려주세요!';

  @override
  String get dashboardShareCopied => '복사됨!';

  @override
  String get dashboardAddCategory => '카테고리 추가하기';

  @override
  String get dashboardCustomCategoryHint => '원하는 카테고리를 만들어봐요';

  @override
  String get dashboardCategoryExists => '이미 추가된 카테고리예요.';

  @override
  String get dashboardFriends => '친구';

  @override
  String get dashboardWarningTitle => '⚠️ 경고';

  @override
  String get dashboardWarningContent =>
      '다수의 사용자로부터 신고가 접수됐어요. 신고가 5회 누적되면 계정이 잠길 수 있어요.';

  @override
  String get dashboardPhotoUploadFailed => '사진 업로드에 실패했어요. 다시 시도해주세요.';

  @override
  String get dashboardAccountDeleteFailed => '탈퇴 처리에 실패했어요. 다시 시도해주세요.';

  @override
  String get dashboardReportedListTitle => '내가 신고한 사용자';

  @override
  String get dashboardLikedByTitle => '좋아요 눌러준 사람';

  @override
  String get dashboardLikedProfilesTitle => '내가 좋아요 누른 프로필';

  @override
  String get profileCardEdit => '프로필 변경';

  @override
  String get profileCardBio => '자기소개';

  @override
  String get profileCardBioOneLine => '한줄 소개';

  @override
  String profileCardViews(Object count) {
    return '조회수 $count';
  }

  @override
  String profileCardLikesReceived(Object count) {
    return '받은 좋아요 $count';
  }

  @override
  String get profileCardLikesGiven => '누른 좋아요';

  @override
  String get profileCardRanking => '🏆 순위 보기';

  @override
  String profileCardComments(Object count) {
    return '💬 댓글 보기($count)';
  }

  @override
  String get categoryEmptyItems => '아직 항목이 없어요';

  @override
  String get categoryAddItemHint => '새 항목 추가';

  @override
  String get categoryAddLinkHint => '링크(URL) 입력';

  @override
  String get categoryDeleteCategory => '카테고리 삭제';

  @override
  String categoryDeleteConfirm(Object label) {
    return '\"$label\" 카테고리를 삭제할까요?';
  }

  @override
  String get editProfileTitle => '프로필 편집';

  @override
  String get editProfileName => '이름';

  @override
  String get editProfileUsername => '유저네임';

  @override
  String get editProfileBio => '한줄 소개';

  @override
  String get editProfileInfoFields => '정보 필드';

  @override
  String get editProfileFieldLabelHint => '항목명';

  @override
  String get editProfileFieldValueHint => '내용';

  @override
  String get editProfileUsernameEmpty => '유저네임을 입력해주세요.';

  @override
  String get editProfileUsernameTaken => '이미 사용 중인 유저네임이에요.';

  @override
  String get settingsTitle => '⚙️ 설정';

  @override
  String get settingsPrivacy => '🔒 프로필 비공개';

  @override
  String get settingsPrivacyDesc => '비공개하면 검색 및 랜덤 프로필 보기에서 제외돼요';

  @override
  String get settingsReportedList => '🚨 내가 신고한 사용자';

  @override
  String get settingsNationality => '🌐 국적/언어';

  @override
  String get settingsBamboo => '🎋 대나무숲';

  @override
  String get settingsTerms => '📋 이용약관';

  @override
  String get settingsLogout => '🚪 로그아웃';

  @override
  String get settingsLogoutConfirm => '로그아웃 하시겠어요?';

  @override
  String get settingsDeleteAccount => '❌ 회원 탈퇴';

  @override
  String get settingsDeleteAccountConfirm =>
      '탈퇴 시 프로필, 카테고리, 댓글 등 모든 데이터가 즉시 삭제되며 되돌릴 수 없어요. 정말 탈퇴하시겠어요?';

  @override
  String get settingsTermsTitle => '이용약관';

  @override
  String get bambooTitle => '🎋 대나무숲';

  @override
  String get bambooDescription =>
      '대나무숲은 사이트에 관한 의견을 자유롭게 작성하는 곳입니다. 익명이니 안심하고 바라는 점을 적어주세요!';

  @override
  String get bambooEmpty => '아직 글이 없어요';

  @override
  String get bambooInputHint => '익명으로 작성하기...';

  @override
  String commentsTitle(Object count) {
    return '댓글 ($count)';
  }

  @override
  String get commentsEmpty => '아직 댓글이 없어요';

  @override
  String get commentsInputHint => '댓글 작성...';

  @override
  String get commentsDeleteTitle => '댓글 삭제';

  @override
  String get commentsDeleteConfirm => '이 댓글을 삭제할까요?';

  @override
  String get friendsTitle => '친구';

  @override
  String get friendsTabFriends => '👫 친구';

  @override
  String get friendsTabGlobalChat => '💬 전체 채팅';

  @override
  String get friendsTabRandom => '🎲 랜덤 프로필';

  @override
  String get friendsEmptyList => '아직 없어요';

  @override
  String get friendsRequestsHeader => '친구 요청';

  @override
  String get friendsNoFriends => '아직 친구가 없어요';

  @override
  String get friendsNoMessages => '아직 메시지가 없어요';

  @override
  String get friendsAccept => '수락';

  @override
  String get friendsReject => '거절';

  @override
  String get friendsRemove => '친구 삭제';

  @override
  String friendsRemoveConfirm(Object username) {
    return '\"$username\"님을 친구에서 삭제할까요?';
  }

  @override
  String get friendsMessageDeleteTitle => '메시지 삭제';

  @override
  String get friendsMessageDeleteConfirm => '이 메시지를 삭제할까요?';

  @override
  String get friendsChatInputHint => '메시지 입력...';

  @override
  String get friendsSearchHint => '유저네임으로 검색';

  @override
  String get friendsSearchEmpty => '검색 결과가 없어요';

  @override
  String get friendsLoadMore => '더보기';

  @override
  String get rankingTitle => '🏆 순위';

  @override
  String get rankingViews => '조회수';

  @override
  String get rankingLikes => '좋아요';

  @override
  String get rankingFriends => '친구';

  @override
  String get reportTitle => '신고하기';

  @override
  String get reportPrompt => '신고 사유를 입력해주세요.';

  @override
  String get reportHint => '예: 욕설, 도배, 사칭 등';

  @override
  String get reportButton => '🚨 신고';

  @override
  String get reportedButton => '신고됨';

  @override
  String get reportAlreadyReported => '이미 신고한 사용자예요.';

  @override
  String get reportSubmitted => '신고가 접수됐어요.';

  @override
  String get reportFailed => '신고 처리에 실패했어요. 다시 시도해주세요.';

  @override
  String get publicProfileNotFound => '프로필을 찾을 수 없어요';

  @override
  String get publicProfileBlocked => '접근할 수 없는 프로필이에요';

  @override
  String publicProfileLikes(Object count) {
    return '좋아요 $count';
  }

  @override
  String get publicProfileFriendAdd => '친구 추가';

  @override
  String get publicProfileFriendPending => '요청됨';

  @override
  String get publicProfileCommentFailed => '댓글 등록에 실패했어요. 다시 시도해주세요.';

  @override
  String get publicProfileAnonymous => '익명';

  @override
  String get publicProfileCommentsHeader => '💬 댓글';

  @override
  String get lockedTitle => '계정이 잠겼어요';

  @override
  String get lockedSubtitle => '다수의 사용자로부터 신고가 접수되어 계정 이용이 제한됐어요.';

  @override
  String get lockedReasonTitle => '신고 사유';

  @override
  String get lockedReasonEmpty => '등록된 사유가 없어요';

  @override
  String get lockedReasonUnwritten => '(사유 미작성)';

  @override
  String get lockedContactTitle => '문의하기';

  @override
  String get lockedContactSubtitle => '오류가 있다면 알려주세요';

  @override
  String get lockedContactHint => '내용을 입력해주세요';

  @override
  String get lockedContactSubmit => '제출';

  @override
  String get lockedContactSent => '문의가 접수됐어요. 검토 후 반영해드릴게요.';

  @override
  String get lockedContactFailed => '전송에 실패했어요. 다시 시도해주세요.';

  @override
  String get lockedLogout => '로그아웃';
}

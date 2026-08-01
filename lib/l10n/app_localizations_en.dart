// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'murimuri.io';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonClose => 'Close';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonNone => 'None yet';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryMovie => 'Movies';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryBook => 'Books';

  @override
  String get categoryHobby => 'Hobbies';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryGame => 'Games';

  @override
  String get categoryDrama => 'Dramas';

  @override
  String get categoryDrink => 'Drinks';

  @override
  String get categoryComic => 'Comics';

  @override
  String get categoryPokemon => 'Pokemon';

  @override
  String get categoryYoutube => 'YouTube';

  @override
  String get categoryExercise => 'Exercise';

  @override
  String get categoryWebtoon => 'Webtoons';

  @override
  String get categoryBrand => 'Brands';

  @override
  String get categoryMbti => 'MBTI';

  @override
  String get categoryIdeal => 'Ideal Type';

  @override
  String get nationalityTitle => 'Select your nationality';

  @override
  String get nationalitySubtitle =>
      'The app language will be set based on your nationality';

  @override
  String get nationalityKorea => 'Korea';

  @override
  String get nationalityJapan => 'Japan';

  @override
  String get nationalityNext => 'Next';

  @override
  String get loginAgreeTerms => 'Please agree to the terms.';

  @override
  String get loginFailed => 'Login failed. Please try again.';

  @override
  String get loginTitle => 'murimuri.io';

  @override
  String get loginSubtitle =>
      'Build a profile that\'s all about your taste\nand share it with friends';

  @override
  String get loginGoogleButton => 'Continue with Google';

  @override
  String get loginLoggingIn => 'Signing in...';

  @override
  String get loginAgreeCheckbox => 'I agree to the Terms of Service';

  @override
  String get loginViewTerms => 'View details';

  @override
  String get loginTermsTitle => 'Terms of Service';

  @override
  String get dashboardShare => 'Share profile';

  @override
  String get dashboardStore => '🛍️ Store';

  @override
  String get storeComingSoonTitle => 'The store is coming soon';

  @override
  String get storeComingSoonSubtitle =>
      'Merch is on the way — check back soon!';

  @override
  String get dashboardShareCopied => 'Copied!';

  @override
  String get dashboardAddCategory => 'Add a category';

  @override
  String get dashboardCustomCategoryHint => 'Create a category of your own';

  @override
  String get dashboardCategoryExists => 'This category has already been added.';

  @override
  String get dashboardFriends => 'Friends';

  @override
  String get dashboardWarningTitle => '⚠️ Warning';

  @override
  String get dashboardWarningContent =>
      'You\'ve received reports from multiple users. Your account may be locked after 5 reports.';

  @override
  String get dashboardPhotoUploadFailed =>
      'Photo upload failed. Please try again.';

  @override
  String get dashboardAccountDeleteFailed =>
      'Failed to delete your account. Please try again.';

  @override
  String get dashboardReportedListTitle => 'Users you\'ve reported';

  @override
  String get dashboardLikedByTitle => 'People who liked you';

  @override
  String get dashboardLikedProfilesTitle => 'Profiles you\'ve liked';

  @override
  String get profileCardEdit => 'Edit profile';

  @override
  String get profileCardBio => 'About me';

  @override
  String get profileCardBioOneLine => 'One-line bio';

  @override
  String profileCardViews(Object count) {
    return '$count views';
  }

  @override
  String profileCardLikesReceived(Object count) {
    return '$count likes received';
  }

  @override
  String get profileCardLikesGiven => 'Likes given';

  @override
  String get profileCardRanking => '🏆 View rankings';

  @override
  String profileCardComments(Object count) {
    return '💬 View comments ($count)';
  }

  @override
  String get categoryEmptyItems => 'No items yet';

  @override
  String get categoryAddItemHint => 'Add a new item';

  @override
  String get categoryAddLinkHint => 'Enter a link (URL)';

  @override
  String get categoryDeleteCategory => 'Delete category';

  @override
  String categoryDeleteConfirm(Object label) {
    return 'Delete the \"$label\" category?';
  }

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileName => 'Name';

  @override
  String get editProfileUsername => 'Username';

  @override
  String get editProfileBio => 'One-line bio';

  @override
  String get editProfileInfoFields => 'Info fields';

  @override
  String get editProfileFieldLabelHint => 'Field name';

  @override
  String get editProfileFieldValueHint => 'Value';

  @override
  String get editProfileUsernameEmpty => 'Please enter a username.';

  @override
  String get editProfileUsernameTaken => 'This username is already taken.';

  @override
  String get settingsTitle => '⚙️ Settings';

  @override
  String get settingsPrivacy => '🔒 Private profile';

  @override
  String get settingsPrivacyDesc =>
      'When private, you\'re excluded from search and random profile suggestions';

  @override
  String get settingsReportedList => '🚨 Users you\'ve reported';

  @override
  String get settingsBamboo => '🎋 Suggestion box';

  @override
  String get settingsTerms => '📋 Terms of Service';

  @override
  String get settingsLogout => '🚪 Log out';

  @override
  String get settingsLogoutConfirm => 'Log out?';

  @override
  String get settingsDeleteAccount => '❌ Delete account';

  @override
  String get settingsDeleteAccountConfirm =>
      'Deleting your account will immediately and permanently remove your profile, categories, comments, and all other data. Are you sure you want to delete your account?';

  @override
  String get settingsTermsTitle => 'Terms of Service';

  @override
  String get bambooTitle => '🎋 Suggestion box';

  @override
  String get bambooDescription =>
      'The suggestion box is a place to freely share feedback about the site. It\'s anonymous, so feel free to write what you\'d like to see!';

  @override
  String get bambooEmpty => 'No posts yet';

  @override
  String get bambooInputHint => 'Write anonymously...';

  @override
  String commentsTitle(Object count) {
    return 'Comments ($count)';
  }

  @override
  String get commentsEmpty => 'No comments yet';

  @override
  String get commentsInputHint => 'Write a comment...';

  @override
  String get commentsDeleteTitle => 'Delete comment';

  @override
  String get commentsDeleteConfirm => 'Delete this comment?';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get friendsTabFriends => '👫 Friends';

  @override
  String get friendsTabGlobalChat => '💬 Global chat';

  @override
  String get friendsTabRandom => '🎲 Random profiles';

  @override
  String get friendsEmptyList => 'Nothing here yet';

  @override
  String get friendsRequestsHeader => 'Friend requests';

  @override
  String get friendsNoFriends => 'No friends yet';

  @override
  String get friendsNoMessages => 'No messages yet';

  @override
  String get friendsAccept => 'Accept';

  @override
  String get friendsReject => 'Decline';

  @override
  String get friendsRemove => 'Remove friend';

  @override
  String friendsRemoveConfirm(Object username) {
    return 'Remove \"$username\" from your friends?';
  }

  @override
  String get friendsMessageDeleteTitle => 'Delete message';

  @override
  String get friendsMessageDeleteConfirm => 'Delete this message?';

  @override
  String get friendsChatInputHint => 'Type a message...';

  @override
  String get friendsSearchHint => 'Search by username';

  @override
  String get friendsSearchEmpty => 'No results found';

  @override
  String get friendsLoadMore => 'Load more';

  @override
  String get rankingTitle => '🏆 Rankings';

  @override
  String get rankingViews => 'Views';

  @override
  String get rankingLikes => 'Likes';

  @override
  String get rankingFriends => 'Friends';

  @override
  String get reportTitle => 'Report';

  @override
  String get reportPrompt => 'Please enter a reason for the report.';

  @override
  String get reportHint => 'e.g. abusive language, spam, impersonation';

  @override
  String get reportButton => '🚨 Report';

  @override
  String get reportedButton => 'Reported';

  @override
  String get reportAlreadyReported => 'You\'ve already reported this user.';

  @override
  String get reportSubmitted => 'Your report has been submitted.';

  @override
  String get reportFailed => 'Failed to submit the report. Please try again.';

  @override
  String get publicProfileNotFound => 'Profile not found';

  @override
  String get publicProfileBlocked => 'This profile isn\'t accessible';

  @override
  String publicProfileLikes(Object count) {
    return '$count likes';
  }

  @override
  String get publicProfileFriendAdd => 'Add friend';

  @override
  String get publicProfileFriendPending => 'Requested';

  @override
  String get publicProfileCommentFailed =>
      'Failed to post your comment. Please try again.';

  @override
  String get publicProfileAnonymous => 'Anonymous';

  @override
  String get publicProfileCommentsHeader => '💬 Comments';

  @override
  String get lockedTitle => 'Your account is locked';

  @override
  String get lockedSubtitle =>
      'Your account has been restricted after being reported by multiple users.';

  @override
  String get lockedReasonTitle => 'Report reasons';

  @override
  String get lockedReasonEmpty => 'No reasons on file';

  @override
  String get lockedReasonUnwritten => '(no reason given)';

  @override
  String get lockedContactTitle => 'Contact us';

  @override
  String get lockedContactSubtitle => 'Let us know if there\'s been a mistake';

  @override
  String get lockedContactHint => 'Enter your message';

  @override
  String get lockedContactSubmit => 'Submit';

  @override
  String get lockedContactSent =>
      'Your message has been received. We\'ll follow up after review.';

  @override
  String get lockedContactFailed => 'Failed to send. Please try again.';

  @override
  String get lockedLogout => 'Log out';
}

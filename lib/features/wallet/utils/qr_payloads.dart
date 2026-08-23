/// Shared QR payload formats used across the app's scan flows. Each has a
/// distinct prefix so the scanner can tell what kind of code it's looking at
/// (vendor payment requests use their own prefix — see PaymentRequestModel).
const String receiveQrPrefix = 'redhawkwallet:receive:';
const String studentIdQrPrefix = 'redhawkwallet:studentid:';
const String redeemQrPrefix = 'redhawkwallet:redeem:';

/// Static — a student's own uid, meant to be shown indefinitely (like a
/// Venmo/PayPal.me QR) so others can always scan it to pay them.
String receiveQrPayload(String uid) => '$receiveQrPrefix$uid';

String? receiveUidFromQr(String value) =>
    value.startsWith(receiveQrPrefix) ? value.substring(receiveQrPrefix.length) : null;

/// Rotating — a short-lived token minted by issueStudentIdToken, not the
/// uid itself. See PaymentRequestModel's qrPayload for why: the scanner
/// looks the token up server-side rather than trusting client-claimed identity.
String studentIdQrPayload(String token) => '$studentIdQrPrefix$token';

String? studentIdTokenFromQr(String value) =>
    value.startsWith(studentIdQrPrefix) ? value.substring(studentIdQrPrefix.length) : null;

/// Static — just a pointer to the offers/{offerId}/redemptions/{uid} doc
/// redeemOffer already wrote server-side. The vendor's scanner looks that
/// doc up (via verifyOfferRedemption) rather than trusting these claimed
/// ids, same reasoning as studentIdQrPrefix above.
String redeemQrPayload(String offerId, String uid) => '$redeemQrPrefix$offerId:$uid';

({String offerId, String uid})? redeemInfoFromQr(String value) {
  if (!value.startsWith(redeemQrPrefix)) return null;
  final parts = value.substring(redeemQrPrefix.length).split(':');
  if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) return null;
  return (offerId: parts[0], uid: parts[1]);
}

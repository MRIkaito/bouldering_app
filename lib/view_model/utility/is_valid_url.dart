/// ■ メソッド
/// - URLが有効な形式かを確認する
bool isValidUrl(String? url) {
  if (url == null) return false;
  return url.startsWith('http://') || url.startsWith('https://');
}

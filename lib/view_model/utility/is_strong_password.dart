/// ■ メソッド
/// - パスワードバリデーター
/// - パスワードが指定の条件を満たしているかを確認するメソッド
/// - 条件：英大文字/英小文字/数字を1つずつ使用すること
/// - 条件(続き)：パスワードは最低8文字以上であること
/// - 条件を満たしていれば, trueを返す
/// - 条件を満たしていなければ，falseを返す
bool isStrongPassword(String password) {
  final RegExp strongPasswordRegExp =
      RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d@\$!%*?&]{8,}$');
  return strongPasswordRegExp.hasMatch(password);
}


const CLOCK_INTERVAL = Duration(microseconds: 1000);
const ChineseWeekDays = <int, String>{
  1: '一',
  2: '二',
  3: '三',
  4: '四',
  5: '五',
  6: '六',
  7: '日',
};
String pad0(int num) {
  if (num < 10) {
    return '0${num.toString()}';
  }
  return num.toString();
}

const monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

export function formatDate(unixtime) {
  const date = new Date(unixtime);
  return twoDigit(date.getDate()) + '-' + monthNames[date.getMonth()] + '-' + (''+date.getFullYear()).slice(2) + ' ' + twoDigit(date.getHours()) + ':' + twoDigit(date.getMinutes());
}

function twoDigit(x) {
  return ('0'+x).slice(-2);
}
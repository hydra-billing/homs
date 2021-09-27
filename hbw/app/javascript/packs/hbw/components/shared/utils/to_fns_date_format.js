// date-fns uses 'd' and 'y' for month days and calendar years
// as opposed to moment.js that uses capital 'D' and 'Y'
const convertToDateFNSDateFormat = dateFormat => dateFormat.replaceAll('Y', 'y').replaceAll('D', 'd');

export default convertToDateFNSDateFormat;

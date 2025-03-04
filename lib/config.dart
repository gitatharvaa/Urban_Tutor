const url = 'http://192.168.0.102:3000';

// User endpoints
const registration = '$url/api/user/registration';
const login = '$url/api/user/login';

// Notes endpoints
const uploadNote = '$url/api/notes';
const getNotes = '$url/api/notes';
const getNotesByGrade = '$url/api/notes/grade';
const downloadNote = '$url/api/notes'; // Add /{id}/download for specific note
const incrementDownloads = '$url/api/notes'; // Add /{id}/increment-downloads for specific note
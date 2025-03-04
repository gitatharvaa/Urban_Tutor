const express = require('express');
const router = express.Router();
const noteController = require('../controllers/note.controller');

router.post('/', noteController.createNote);
router.get('/', noteController.getAllNotes);
router.get('/grade/:grade', noteController.getNotesByGrade);
router.get('/:id', noteController.getNoteById);
router.put('/:id', noteController.updateNote);
router.delete('/:id', noteController.deleteNote);
router.get('/:id/download', noteController.downloadPdf);
router.post('/:id/increment-downloads', noteController.incrementDownloads);

module.exports = router;
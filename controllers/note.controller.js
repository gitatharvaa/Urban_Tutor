const multer = require('multer');
const path = require('path');
const fs = require('fs');
const NoteModel = require('../models/note.model');

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = 'uploads/notes';
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB max file size
    },
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
        if (allowedTypes.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error('Only PDF and Word documents are allowed!'));
        }
    }
}).single('file'); // Changed from 'pdf' to 'file' to match Flutter implementation

class NoteController {
    async createNote(req, res) {
        try {
          upload(req, res, async (err) => {
            if (err instanceof multer.MulterError) {
              return res.status(400).json({
                status: false,
                message: 'File upload error',
                error: err.message
              });
            } else if (err) {
              return res.status(400).json({
                status: false,
                message: err.message
              });
            }
      
            try {
              const { 
                title, 
                description, 
                subject,
                difficulty,
                grade,
                schoolName,
                uploaderName,
                fileSize 
              } = req.body;
      
              // Log the request body
              console.log('Request body:', req.body);
      
              // Validate required fields
              if (!title || !grade || !subject) {
                return res.status(400).json({
                  status: false,
                  message: 'Title, grade, and subject are required'
                });
              }
      
              // Create note object
              const noteData = {
                title,
                description,
                subject,
                difficulty,
                grade,
                schoolName,
                uploaderName,
                fileSize: parseInt(fileSize),
                fileUrl: req.file ? `/uploads/notes/${req.file.filename}` : null,
                downloads: 0,
                pages: 10 // Default value
              };
      
              // Log the note data
              console.log('Note data:', noteData);
      
              // Save to database
              const note = new NoteModel(noteData);
              const savedNote = await note.save();
      
              // Log the saved note
              console.log('Saved note:', savedNote);
      
              res.status(201).json({
                status: true,
                message: 'Note created successfully',
                data: savedNote
              });
            } catch (error) {
              if (req.file) {
                fs.unlinkSync(req.file.path);
              }
              console.error('Error creating note:', error);
              throw error;
            }
          });
        } catch (error) {
          res.status(500).json({
            status: false,
            message: 'Error creating note',
            error: error.message
          });
        }
      }

    // Get notes by grade
    async getNotesByGrade(req, res) {
        try {
            const { grade } = req.params;
            const notes = await NoteModel.find({ grade })
                .sort({ createdAt: -1 });

            res.status(200).json({
                status: true,
                data: notes
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error fetching notes',
                error: error.message
            });
        }
    }

    // Get all notes
    async getAllNotes(req, res) {
        try {
            const { userId } = req.query;
            let query = {};

            // If userId is provided, filter by it
            if (userId) {
                query.userId = userId;
            }

            const notes = await NoteModel.find(query)
                .sort({ createdAt: -1 }) // Sort by newest first
                .populate('userId', 'name email'); // Populate user details

            res.status(200).json({
                status: true,
                data: notes
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error fetching notes',
                error: error.message
            });
        }
    }

    // Get single note by ID
    async getNoteById(req, res) {
        try {
            const note = await NoteModel.findById(req.params.id)
                .populate('userId', 'name email');

            if (!note) {
                return res.status(404).json({
                    status: false,
                    message: 'Note not found'
                });
            }

            res.status(200).json({
                status: true,
                data: note
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error fetching note',
                error: error.message
            });
        }
    }

    // Update note
    async updateNote(req, res) {
        try {
            upload(req, res, async (err) => {
                if (err) {
                    return res.status(400).json({
                        status: false,
                        message: err.message
                    });
                }

                try {
                    const noteId = req.params.id;
                    const { title, content } = req.body;

                    // Find existing note
                    const existingNote = await NoteModel.findById(noteId);
                    if (!existingNote) {
                        if (req.file) {
                            fs.unlinkSync(req.file.path);
                        }
                        return res.status(404).json({
                            status: false,
                            message: 'Note not found'
                        });
                    }

                    // Update note data
                    const updateData = {
                        title,
                        content
                    };

                    // If new file is uploaded
                    if (req.file) {
                        // Delete old file if it exists
                        if (existingNote.pdfUrl) {
                            const oldFilePath = path.join(__dirname, '..', existingNote.pdfUrl);
                            if (fs.existsSync(oldFilePath)) {
                                fs.unlinkSync(oldFilePath);
                            }
                        }
                        updateData.pdfUrl = `/uploads/${req.file.filename}`;
                    }

                    // Update in database
                    const updatedNote = await NoteModel.findByIdAndUpdate(
                        noteId,
                        updateData,
                        { new: true }
                    ).populate('userId', 'name email');

                    res.status(200).json({
                        status: true,
                        message: 'Note updated successfully',
                        data: updatedNote
                    });
                } catch (error) {
                    if (req.file) {
                        fs.unlinkSync(req.file.path);
                    }
                    throw error;
                }
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error updating note',
                error: error.message
            });
        }
    }

    // Delete note
    async deleteNote(req, res) {
        try {
            const note = await NoteModel.findById(req.params.id);

            if (!note) {
                return res.status(404).json({
                    status: false,
                    message: 'Note not found'
                });
            }

            // Delete associated PDF file if it exists
            if (note.pdfUrl) {
                const filePath = path.join(__dirname, '..', note.pdfUrl);
                if (fs.existsSync(filePath)) {
                    fs.unlinkSync(filePath);
                }
            }

            // Delete note from database
            await NoteModel.findByIdAndDelete(req.params.id);

            res.status(200).json({
                status: true,
                message: 'Note deleted successfully'
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error deleting note',
                error: error.message
            });
        }
    }

    // Download PDF
    async downloadPdf(req, res) {
        try {
            const note = await NoteModel.findById(req.params.id);

            if (!note || !note.pdfUrl) {
                return res.status(404).json({
                    status: false,
                    message: 'PDF not found'
                });
            }

            const filePath = path.join(__dirname, '..', note.pdfUrl);
            if (!fs.existsSync(filePath)) {
                return res.status(404).json({
                    status: false,
                    message: 'PDF file not found'
                });
            }

            res.download(filePath);
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error downloading PDF',
                error: error.message
            });
        }
    }
    async incrementDownloads(req, res) {
        try {
            const note = await NoteModel.findByIdAndUpdate(
                req.params.id,
                { $inc: { downloads: 1 } },
                { new: true }
            );

            if (!note) {
                return res.status(404).json({
                    status: false,
                    message: 'Note not found'
                });
            }

            res.status(200).json({
                status: true,
                data: note
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error incrementing downloads',
                error: error.message
            });
        }
    }
}

module.exports = new NoteController();
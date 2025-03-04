const Note = require('./note.model');

class NoteService {
  async createNote(noteData, fileUrl) {
    try {
      const note = new Note({
        ...noteData,
        fileUrl,
        createdAt: Date.now(),
        updatedAt: Date.now()
      });
      return await note.save();
    } catch (error) {
      throw new Error(`Error creating note: ${error.message}`);
    }
  }

  async getNotesByGrade(grade) {
    try {
      return await Note.find({ grade }).sort({ createdAt: -1 });
    } catch (error) {
      throw new Error(`Error fetching notes for grade ${grade}: ${error.message}`);
    }
  }

  async getAllNotes() {
    try {
      return await Note.find().sort({ createdAt: -1 });
    } catch (error) {
      throw new Error(`Error fetching notes: ${error.message}`);
    }
  }

  async getNoteById(id) {
    try {
      return await Note.findById(id);
    } catch (error) {
      throw new Error(`Error fetching note: ${error.message}`);
    }
  }

  async updateNote(id, updateData) {
    try {
      return await Note.findByIdAndUpdate(
        id,
        { ...updateData, updatedAt: Date.now() },
        { new: true }
      );
    } catch (error) {
      throw new Error(`Error updating note: ${error.message}`);
    }
  }

  async deleteNote(id) {
    try {
      return await Note.findByIdAndDelete(id);
    } catch (error) {
      throw new Error(`Error deleting note: ${error.message}`);
    }
  }
}

module.exports = new NoteService();
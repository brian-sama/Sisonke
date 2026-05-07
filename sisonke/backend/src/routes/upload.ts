import express from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { authMiddleware } from '../middleware/auth';

const router = express.Router();
const uploadDir = path.join(__dirname, '../../uploads');

// Ensure upload directory exists
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `vn_${Date.now()}_${Math.floor(Math.random() * 1000)}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: {
    fileSize: 15 * 1024 * 1024, // 15MB max
  },
  fileFilter: (req, file, cb) => {
    // Only allow common audio/media types for voice notes
    const mimeRegex = /^(audio|video|application\/octet-stream)/;
    if (mimeRegex.test(file.mimetype) || file.originalname.endsWith('.m4a') || file.originalname.endsWith('.mp3')) {
      cb(null, true);
    } else {
      cb(new Error('Only audio and media files are allowed'));
    }
  },
});

// Protect voice note upload so only authenticated guest sessions / users can upload
router.post('/', authMiddleware as any, upload.single('file'), (req: any, res) => {
  if (!req.file) {
    return res.status(400).json({ success: false, error: 'No audio file provided' });
  }

  // Construct standard host URL to retrieve this static file
  const fileUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
  
  res.status(201).json({
    success: true,
    data: {
      url: fileUrl,
      filename: req.file.filename,
      mimetype: req.file.mimetype,
      size: req.file.size,
    }
  });
});

export default router;

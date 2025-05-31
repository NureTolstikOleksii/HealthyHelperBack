import { Router } from 'express';
import { BackupService } from './backup.service.js';
import path from 'node:path';
import fs from 'node:fs';

const router = Router();
const backupService = new BackupService();

// отримати дату останнього бекапу
router.get('/last', async (req, res) => {
    try {
        const last = await backupService.getLastBackup();
        if (!last) return res.json({ lastBackup: null });
        return res.json({ lastBackup: last });
    } catch (err) {
        console.error('Помилка при отриманні останнього бекапу:', err);
        res.status(500).json({ error: 'Серверна помилка' });
    }
});

// створити ручний бекап
router.post('/manual', async (req, res) => {
    try {
        const backup = await backupService.createBackup('manual');

        const timestamp = backup.timestamp.replace(/[:.]/g, '-');
        const fileName = `backup-${timestamp}.sql`;
        const filePath = path.resolve('backups', fileName);

        if (!fs.existsSync(filePath)) {
            return res.status(404).json({ error: 'Файл бекапу не знайдено' });
        }

        // Примусове завантаження файлу
        res.download(filePath, fileName, (err) => {
            if (err) {
                console.error('Помилка при надсиланні файлу:', err);
                if (!res.headersSent) {
                    res.status(500).json({ error: 'Не вдалося надіслати файл' });
                }
            }
        });
    } catch (err) {
        console.error('Помилка при створенні бекапу:', err);
        res.status(500).json({ error: 'Не вдалося створити копію' });
    }
});

export const backupRouter = router;

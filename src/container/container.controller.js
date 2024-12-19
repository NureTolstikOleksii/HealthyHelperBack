import { Router } from 'express';
import { ContainerService } from './container.service.js';

const router = Router();
const containerService = new ContainerService();

router.post('/decrementQuantity/:id_inventory', async (req, res) => {
    try {
        const { id_inventory } = req.params;

        if (!id_inventory) {
            return res.status(400).json({ message: 'Необхідно вказати ID інвентаря' });
        }

        const updatedInventory = await containerService.decrementInventoryQuantity(req.db, id_inventory);

        res.json({
            message: 'success',
            id_inventory: updatedInventory.id_inventory,
            new_quantity: updatedInventory.new_quantity,
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

router.get('/inventoryByMedicationAndContainer/:id_medication/:id_container', async (req, res) => {
    try {
        const { id_medication, id_container } = req.params;

        // Перевірка вхідних даних
        if (!id_medication || !id_container) {
            return res.status(400).json({ message: 'Необхідно вказати id ліків та id контейнера' });
        }

        // Пошук відсіку, який містить ліки у контейнері
        const inventory = await req.db.inventory.findFirst({
            where: {
                id_container: Number(id_container),
                id_medication: Number(id_medication),
            },
            select: {
                id_inventory: true,
                quantity: true,
                inventory_number: true,
            },
        });

        if (!inventory) {
            return res.status(404).json({ message: 'Ліки не знайдено у вказаному контейнері' });
        }

        // Повернення знайденого відсіку як об’єкта
        res.json(inventory);
    } catch (error) {
        console.error('Помилка при пошуку відсіку:', error);
        res.status(500).json({ message: 'Не вдалося отримати інформацію про відсік' });
    }
});


// Отримання id ліків за назвою
router.post('/medicationId', async (req, res) => {
    try {
        const { medication_name } = req.body;

        if (!medication_name) {
            return res.status(400).json({ message: 'Необхідно вказати назву препарату' });
        }

        const medicationId = await containerService.getMedicationIdByName(req.db, medication_name);

        res.json({ id_medication: medicationId });
    } catch (error) {
        console.error('Помилка при пошуку id ліків за назвою:', error);
        res.status(500).json({ message: 'Не вдалося знайти id ліків за назвою' });
    }
});


// Отримання найближчого MedicationIntakeSchedule для пацієнта
router.get('/nearestIntake/:id_patient', async (req, res) => {
    try {
        const { id_patient } = req.params;
        const nearestIntake = await containerService.getNearestMedicationIntake(req.db, id_patient);

        if (!nearestIntake) {
            return res.status(404).json({ message: 'No untaken medications' });
        }

        res.json(nearestIntake);
    } catch (error) {
        console.error('Error fetching nearest medication intake:', error);
        res.status(500).json({ message: 'Failed to fetch nearest medication intake' });
    }
});

// Оновлення статусу прийому ліків
router.post('/updateMedicationIntakeStatus/:id_intake_schedule', async (req, res) => {
    try {
        const { id_intake_schedule } = req.params;
        const { status } = req.body;

        if (status === undefined) {
            return res.status(400).json({ message: 'Необхідно вказати статус' });
        }

        const updatedIntake = await containerService.updateMedicationIntakeStatus(req.db, id_intake_schedule, status);
        res.json({ message: 'Статус прийому ліків успішно оновлено', intake: updatedIntake });
    } catch (error) {
        console.error('Error updating medication intake status:', error);
        res.status(500).json({ message: 'Помилка при оновленні статусу прийому ліків' });
    }
});

// отримання пацієнта закріаленого за контейнером
router.get('/:id/getPatientId', async (req, res) => {
    try {
        const { id } = req.params;
        const patientId = await containerService.getPatientIdByContainer(req.db, id);
        
        if (!patientId) {
            return res.status(404).json({ message: 'No patient found for this container' });
        }

        res.json({ id_patient: patientId });
    } catch (error) {
        console.error('Error fetching patient ID:', error);
        res.status(500).json({ message: 'Помилка при отриманні ID пацієнта' });
    }
});

// оновлення статусу роботи та підключення контейнера
router.post('/:id/updateStatus', async (req, res) => {
    try {
        const { id } = req.params;
        const { operational_status, network_status } = req.body;

        if (operational_status === undefined || network_status === undefined) {
            return res.status(400).json({ message: 'Необхідно вказати статус роботи та підключення' });
        }

        const updatedStatus = await containerService.updateContainerStatus(req.db, id, operational_status, network_status);
        res.json({ message: 'Статус успішно оновлено', container: updatedStatus });
    } catch (error) {
        console.error('Error updating container status:', error);
        res.status(500).json({ message: 'Помилка при оновленні статусу контейнера' });
    }
});





// додавання нового контейнера
router.post('/add', async (req, res) => {
    try {
        const newContainer = await containerService.addContainer(req.db);
        res.status(201).json({ message: 'Новий контейнер успішно додано', container: newContainer });
    } catch (error) {
        console.error('Error adding container:', error);
        res.status(500).json({ message: 'Не вдалося додати контейнер' });
    }
});

// отримання інформації про контейнер
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const containerDetails = await containerService.getContainerDetails(req.db, id);
        res.json(containerDetails);
    } catch (error) {
        console.error('Error fetching container details:', error);
        res.status(500).json({ message: 'Помилка при отриманні інформації про контейнер' });
    }
});

// закріплення пацієнта за контейнером
router.post('/:id/addPatient', async (req, res) => {
    try {
        const { id } = req.params;
        const { patient_id } = req.body;
      
        if (!patient_id) {
            console.error('patient_id is required')
            return res.status(401).json({ message: 'Обов\'язково оберіть пацієнта для додавання' });
        }

        const addingDetails = await containerService.addPatientToContainer(req.db, id, patient_id);
        res.json(addingDetails);
    } catch (error) {
        console.error('Error adding patient:', error);
        res.status(500).json({ message: 'Помилка при додаванні пацієнта' });
    }
});

// додати ліки до відсіку
router.post('/addMedicationToInventory/:id_inventory', async (req, res) => {
    try {
        const { id_inventory } = req.params;
        const { quantity, id_medication } = req.body;

        if (!quantity || !id_medication){
            console.error('quantity and id_medication is required')
            return res.status(401).json({ message: 'Обов\'язково заповніть обидва поля' });
        }

        const addingDetails = await containerService.addMedicationToInventory(req.db, id_inventory, quantity, id_medication);
        res.json(addingDetails);
    } catch (error) {
        console.error('Error adding medication:', error);
        res.status(500).json({ message: 'Помилка при додаванні медикаментів' });
    }
});

// отримання списку призначених препаратів
router.post('/prescribedMedications', async (req, res) => {
    try {
        const { id_patient } = req.body;

        if (!id_patient){
            console.error('id_patient is required')
            return res.status(401).json({ message: 'Пацієнта не знайдено' });
        }

        const medicationInfo = await containerService.getPrescribedMedications(req.db, id_patient);
        res.json(medicationInfo);
    } catch (error) {
        console.error('Error getting medication:', error);
        res.status(500).json({ message: 'Помилка при отриманні медикаментів' });
    }
});

// отримання типу відсіку
router.post('/inventoryUnit/:id_inventory', async (req, res) => {
    try {
        const { id_inventory } = req.params;

        if (!id_inventory){
            console.error('id_inventory is required')
            return res.status(401).json({ message: 'Відсік не знайдено' });
        }

        const unitInfo = await containerService.getInventoryUnit(req.db, id_inventory);
        res.json(unitInfo);    
    } catch (error) {
        console.error('Error getting unit:', error);
        res.status(500).json({ message: 'Помилка при отриманні данних' });
    }
});

export const containerRouter = router;

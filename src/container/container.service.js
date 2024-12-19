export class ContainerService {
    // Знаходження id ліків за назвою
    async getMedicationIdByName(db, medication_name) {
        try {
            const medication = await db.medication.findFirst({
                where: {
                    medication_name: medication_name,
                },
                select: {
                    id_medication: true,
                },
            });

            if (!medication) {
                throw new Error(`Медикамент із назвою '${medication_name}' не знайдено`);
            }

            return medication.id_medication;
        } catch (error) {
            console.error('Помилка при пошуку id препарату за назвою:', error);
            throw new Error('Не вдалося знайти препарат за назвою');
        }
    }

    // отримання наступного часу прийняття    
    async getNearestMedicationIntake(db, id_patient) {
        try {
            const nowUTC = new Date();
            const utcOffsetHours = 2;
            const nowLocal = new Date(nowUTC.getTime() + utcOffsetHours * 60 * 60 * 1000);
    
            // Отримуємо всі призначення пацієнта
            const prescriptions = await db.prescription.findMany({
                where: {
                    id_patient: Number(id_patient),
                },
                select: {
                    id_prescription: true,
                    prescription_date: true,
                    MedicationInPrescription: {
                        select: {
                            id_medication_in_prescription: true,
                            dosage_duration: true,
                            Medication: {
                                select: {
                                    medication_name: true, // Отримуємо назву препарату
                                },
                            },
                            MedicationIntakeSchedule: {
                                where: {
                                    status: 0,
                                    intake_time: {
                                        gt: nowLocal,
                                    },
                                },
                                orderBy: {
                                    intake_time: "asc",
                                },
                            },
                        },
                    },
                },
            });
    
            if (!prescriptions || prescriptions.length === 0) {
                return null; // Немає призначень
            }
    
            // Перевіряємо кожне призначення
            for (const prescription of prescriptions) {
                const prescriptionDate = new Date(prescription.prescription_date);
    
                for (const medication of prescription.MedicationInPrescription) {
                    // Визначаємо тривалість прийому (наприклад, "10 днів")
                    const durationDays = parseInt(medication.dosage_duration.split(" ")[0], 10);
                    const validUntil = new Date(prescriptionDate);
                    validUntil.setDate(validUntil.getDate() + durationDays);
    
                    // Якщо термін дії препарату ще не вийшов
                    if (nowLocal <= validUntil) {
                        // Знайти найближчий розклад для цього препарату
                        const nearestSchedule = medication.MedicationIntakeSchedule[0];
                        if (nearestSchedule) {
                            return {
                                id_intake_schedule: nearestSchedule.id_intake_schedule, // Додаємо ID розкладу
                                intake_time: nearestSchedule.intake_time,
                                medication_name: medication.Medication.medication_name, // Назва препарату
                            };
                        }
                    }
                }
            }
    
            return null; // Немає найближчого прийому
        } catch (error) {
            console.error("Помилка при отриманні найближчого прийому ліків:", error);
            throw new Error("Не вдалося знайти найближчий прийом ліків");
        }
    }
    
    
    // Оновлення статусу прийому ліків у MedicationIntakeSchedule
    async updateMedicationIntakeStatus(db, id_intake_schedule, status) {
        try {
            const intake = await db.medicationIntakeSchedule.findUnique({
                where: { id_intake_schedule: Number(id_intake_schedule) },
            });

            if (!intake) {
                throw new Error(`Запис з ID ${id_intake_schedule} не знайдено`);
            }

            const updatedIntake = await db.medicationIntakeSchedule.update({
                where: { id_intake_schedule: Number(id_intake_schedule) },
                data: { status: Number(status) },
            });

            return updatedIntake;
        } catch (error) {
            console.error('Помилка при оновленні статусу прийому ліків:', error);
            throw new Error('Не вдалося оновити статус прийому ліків');
        }
    }

    // отримати id пацієнта, закріпленого за контейнером
    async getPatientIdByContainer(db, id_container) {
        try {
            const container = await db.container.findUnique({
                where: { id_container: Number(id_container) },
                select: { id_patient: true },
            });

            if (!container) {
                throw new Error(`Контейнер з ID ${id_container} не знайдено`);
            }

            return container.id_patient;
        } catch (error) {
            console.error('Помилка при отриманні ID пацієнта:', error);
            throw new Error('Не вдалося отримати ID пацієнта');
        }
    }

    // оновлення статусу роботи та підключення контейнера
    async updateContainerStatus(db, id, operational_status, network_status) {
        try {
            const container = await db.container.findUnique({
                where: { id_container: Number(id) },
            });

            if (!container) {
                throw new Error('Контейнер не знайдено');
            }

            const updatedContainer = await db.container.update({
                where: { id_container: Number(id) },
                data: {
                    operational_status: Number(operational_status),
                    network_status: Number(network_status),
                },
            });

            return {
                id_container: updatedContainer.id_container,
                operational_status: updatedContainer.operational_status,
                network_status: updatedContainer.network_status,
            };
        } catch (error) {
            console.error('Помилка при оновленні статусу:', error);
            throw new Error('Не вдалося оновити статус контейнера');
        }
    }

    //додавання нового контейнера до бд
    async addContainer(db) {
        try {
            const result = await db.container.aggregate({
                _max: {
                    container_number: true,
                },
            });

            const lastNumber = result._max.container_number || 0;
            const newNumber = lastNumber + 1;

            const newContainer = await db.container.create({
                data: {
                    container_number: newNumber,
                    operational_status: 0,
                    network_status: 0,
                    id_patient: null,
                },
            });
    
            return newContainer;
        } catch (error) {
            console.error('Помилка при додаванні контейнера:', error);
            throw new Error('Не вдалося додати контейнер');
        }
    }
    
    // отримання детальної інформації про контейнер
    async getContainerDetails(db, id) {
        try {
            const container = await db.container.findUnique({
                where: { id_container: Number(id) },
                include: {
                    User: {
                        select: {
                            last_name: true,
                            first_name: true,
                            patronymic: true,
                        },
                    },
                    Inventory: {
                        select: {
                            inventory_number: true,
                        }
                    },
                    Inventory: {
                        include: {
                            Medication: {
                                select: {
                                    medication_name: true,
                                },
                            },
                            Type: {
                                select: {
                                    type_name: true,
                                },
                            },
                        },
                    },
                },
            });

            if (!container) {
                throw new Error('Контейнер не знайдено');
            }

            const response = {
                id: container.id_container,
                status: container.operational_status ? 'Активний' : 'Неактивний',
                network_status: container.network_status ? 'Підключено' : 'Не підключено',
                patient: container.User ? `${container.User.last_name} ${container.User.first_name} ${container.User.patronymic}` : 'Немає пацієнта',
                compartments: container.Inventory.map(inventory => ({
                    id_compartment: inventory.id_inventory,
                    inventory_number: inventory.inventory_number,
                    medication: inventory.Medication ? inventory.Medication.medication_name : 'Невідомо',
                    quantity: inventory.quantity || 0,
                    type: inventory.Type ? inventory.Type.type_name : 'Невідомо',
                })),
            };

            return response;
        } catch (error) {
            console.error('Помилка при отриманні даних контейнера:', error);
            throw new Error('Помилка при отриманні інформації про контейнер');
        }
    }

    // закріпити контейнер за пацієнтом
    async addPatientToContainer(db, id, patient_id) {
        try {
            const container = await db.container.findUnique({
                where: {
                    id_container: Number(id),
                },
            });
    
            if (!container) {
                throw new Error('Контейнер не знайдено');
            }
    
            const updatedContainer = await db.container.update({
                where: {
                    id_container: Number(id),
                },
                data: {
                    id_patient: Number(patient_id), 
                },
            });
    
            const newPatient = await db.User.findUnique({
                where: {
                    id_user: Number(patient_id),
                },
                select: {
                    last_name: true,
                    first_name: true,
                    patronymic: true,
                },
            });
    
            if (!newPatient) {
                throw new Error('Пацієнт не знайдений');
            }
    
            const response = {
                id: updatedContainer.id_container,
                patient: newPatient,
                message: 'Пацієнта додано успішно',
            };
    
            return response;
        } catch (error) {
            console.error('Помилка при додаванні пацієнта', error);
            throw new Error('Помилка при додаванні пацієнта');
        }
    }

    // додати медичний препарати до відсіку
    async addMedicationToInventory(db, id_inventory, quantity, id_medication){
        try {
            const updateInventory = await db.inventory.update({
                where: {
                    id_inventory: Number(id_inventory),
                },
                data: {
                    quantity: Number(quantity), 
                    id_medication: Number(id_medication),
                },
            });      
    
            const response = {
                id: updateInventory.id_inventory,
                message: 'Препарати додано успішно',
            };
    
            return response;
        } catch (error) {
            console.error('Помилка при додаванні препарату', error);
            throw new Error('Помилка при додаванні препарату');
        }
    } 
    
    // отримати інформацію про призначені медикаменти
    async getPrescribedMedications(db, patient_id) {
        try {
            const medications = await db.medicationInPrescription.findMany({
                where: {
                    Prescription: {
                        id_patient: Number(patient_id),
                    },
                },
                include: {
                    Medication: {
                        select: {
                            medication_name: true,
                        },
                    },
                },
            });

            const response = medications.map((item) => ({
                medication_name: item.Medication.medication_name,
            }));

            return response;
        } catch (error) {
            console.error('Помилка при отриманні медикаментів:', error);
            throw new Error('Не вдалося отримати інформацію про медикаменти');
        }
    }

    // отримати інформацію про тип відсіку
    async getInventoryUnit(db, id_inventory) {
        try {
            const inventoryUnit = await db.inventory.findUnique({
                where: {
                    id_inventory: Number(id_inventory),
                },
                include: {
                    Type: {
                        select: {
                            unit: true,
                        },
                    },
                },
            });

            if (!inventoryUnit) {
                throw new Error(`Відсік з ID ${id_inventory} не знайдено`);
            }

            const response = {
                id_inventory: inventoryUnit.id_inventory,
                type_unit: inventoryUnit.Type?.unit || null,
            };

            return response;
        } catch (error) {
            console.error('Помилка при отриманні типу:', error);
            throw new Error('Не вдалося отримати тип відсіку');
        }
    }
}

import bcrypt from 'bcryptjs';

export class LoginService {
    async loginUser(db, roleId, email, password) {
        const user = await db.user.findFirst({
            where: { 
                email: email,
                id_role: roleId,
             },
        });

        if (user && bcrypt.compareSync(password, user.password)) {
            const { password, ...userWithoutPassword } = user; // Видаляємо поле пароля
            return userWithoutPassword; // Повертаємо користувача без пароля
        }
        return null;
    }
}

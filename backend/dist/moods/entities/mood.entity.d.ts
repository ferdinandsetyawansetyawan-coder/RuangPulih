import { User } from '../../users/entities/user.entity';
export declare class Mood {
    id: number;
    userId: number;
    user: User;
    label: string;
    emoji: string;
    createdAt: Date;
}

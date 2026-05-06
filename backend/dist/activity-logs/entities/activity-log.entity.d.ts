import { User } from '../../users/entities/user.entity';
export declare class ActivityLog {
    id: number;
    userId: number | null;
    user: User;
    action: string;
    description: string | null;
    ipAddress: string | null;
    createdAt: Date;
}

import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { ActivityLogsService } from '../activity-logs/activity-logs.service';
export declare class AuthService {
    private usersService;
    private jwtService;
    private activityLogsService;
    constructor(usersService: UsersService, jwtService: JwtService, activityLogsService: ActivityLogsService);
    register(email: string, pass: string, fullName?: string): Promise<{
        id: number;
        email: string;
        fullName: string;
        isActive: boolean;
        createdAt: Date;
        updatedAt: Date;
    }>;
    validateUser(email: string, pass: string): Promise<any>;
    login(user: any): Promise<{
        access_token: string;
        user: any;
    }>;
}

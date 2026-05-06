import { Repository } from 'typeorm';
import { ActivityLog } from './entities/activity-log.entity';
export declare class ActivityLogsService {
    private logsRepository;
    constructor(logsRepository: Repository<ActivityLog>);
    log(userId: number | null, action: string, description?: string, ipAddress?: string): Promise<ActivityLog>;
    findAll(): Promise<ActivityLog[]>;
}

import { ActivityLogsService } from './activity-logs.service';
export declare class ActivityLogsController {
    private readonly activityLogsService;
    constructor(activityLogsService: ActivityLogsService);
    findAll(): Promise<import("./entities/activity-log.entity").ActivityLog[]>;
}

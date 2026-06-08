import { MoodsService } from './moods.service';
export declare class MoodsController {
    private readonly moodsService;
    constructor(moodsService: MoodsService);
    create(body: {
        userId: number;
        label: string;
        emoji: string;
    }): Promise<import("./entities/mood.entity").Mood>;
    findLatest(userId: string): Promise<import("./entities/mood.entity").Mood | null>;
    findAll(userId: string): Promise<import("./entities/mood.entity").Mood[]>;
}

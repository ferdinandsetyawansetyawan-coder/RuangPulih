import { Repository } from 'typeorm';
import { Mood } from './entities/mood.entity';
export declare class MoodsService {
    private moodsRepository;
    constructor(moodsRepository: Repository<Mood>);
    create(userId: number, moodData: {
        label: string;
        emoji: string;
    }): Promise<Mood>;
    findLatestByUser(userId: number): Promise<Mood | null>;
    findAllByUser(userId: number): Promise<Mood[]>;
}

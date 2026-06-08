"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MoodsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const mood_entity_1 = require("./entities/mood.entity");
let MoodsService = class MoodsService {
    moodsRepository;
    constructor(moodsRepository) {
        this.moodsRepository = moodsRepository;
    }
    async create(userId, moodData) {
        const latestMood = await this.findLatestByUser(userId);
        if (latestMood) {
            return latestMood;
        }
        const mood = this.moodsRepository.create({
            userId,
            ...moodData,
        });
        return this.moodsRepository.save(mood);
    }
    async findLatestByUser(userId) {
        const latestMood = await this.moodsRepository.findOne({
            where: { userId },
            order: { createdAt: 'DESC' },
        });
        if (!latestMood)
            return null;
        const todayStr = new Date().toISOString().split('T')[0];
        const moodDateStr = new Date(latestMood.createdAt).toISOString().split('T')[0];
        if (todayStr === moodDateStr) {
            return latestMood;
        }
        return null;
    }
    async findAllByUser(userId) {
        return this.moodsRepository.find({
            where: { userId },
            order: { createdAt: 'DESC' },
        });
    }
};
exports.MoodsService = MoodsService;
exports.MoodsService = MoodsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(mood_entity_1.Mood)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], MoodsService);
//# sourceMappingURL=moods.service.js.map
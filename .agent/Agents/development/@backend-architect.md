# @backend-architect - Backend Implementation Agent

> Designs and implements scalable NestJS backend services based on frontend requirements and domain models.

---

## Workflow Position

```
PRD → @ux-researcher → @ui-designer → @frontend-developer → [@backend-architect]
                                                                    ↑
                                                               YOU ARE HERE
```

### Receives From: @frontend-developer
- API endpoint requirements
- DTO contracts (data shapes)
- Validation rules
- Auth requirements per endpoint
- Real-time/WebSocket needs

### Produces:
- NestJS modules, controllers, services
- TypeORM entities
- DTOs with class-validator
- API documentation

---

## Capabilities

- Design RESTful APIs with NestJS
- Implement TypeORM entities and repositories
- Create DTOs with class-validator decorators
- Build authentication and authorization
- Implement business logic in services
- Configure database connections and migrations

---

## Required Knowledge

Before implementing, read:
- `.agent/System/typescript_clean_code.md`
- `.agent/System/libs_architecture_pattern.md`
- `.agent/System/interface-dto-architecture.md`

---

## Invocation Pattern

```markdown
@backend-architect
  task: [implementation task]
  input: [API requirements from @frontend-developer]
  context: [domain lib, existing entities]
  constraints: [architecture rules]
  output: [controllers, services, entities, DTOs]
```

---

## Example: Implement API from Frontend Requirements

```markdown
@backend-architect
  task: Implement user management API
  input:
    - GET /api/users (list with pagination)
    - GET /api/users/:id
    - POST /api/users
    - PUT /api/users/:id
    - DELETE /api/users/:id
  context: libs/user/data-source
  constraints:
    - TypeORM with PostgreSQL
    - JWT authentication
    - Role-based access
  output:
    - user.controller.ts
    - user.service.ts
    - user.entity.ts
    - DTOs with validation
```

---

## Implementation Workflow

### Step 1: Analyze Frontend Requirements

```markdown
## API Requirements Received
- [ ] Endpoints understood
- [ ] DTO shapes defined
- [ ] Validation rules identified
- [ ] Auth requirements clear
- [ ] Real-time needs documented
```

### Step 2: Create Lib Structure

```
libs/[scope]/data-source/
├── src/
│   ├── lib/
│   │   ├── controllers/
│   │   │   └── [name].controller.ts
│   │   ├── services/
│   │   │   └── [name].service.ts
│   │   ├── entities/
│   │   │   └── [name].entity.ts
│   │   ├── dtos/
│   │   │   ├── create-[name].dto.ts
│   │   │   └── update-[name].dto.ts
│   │   └── [name].module.ts
│   └── index.ts
└── project.json
```

### Step 3: Create Domain Interface (in domain lib)

```typescript
// libs/[scope]/domain/src/lib/interfaces/[name].interface.ts
export interface I[Name] {
  id: string;
  name: string;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface ICreate[Name] {
  name: string;
  description?: string;
}

export interface IUpdate[Name] {
  name?: string;
  description?: string;
}
```

### Step 4: Create Entity

```typescript
// libs/[scope]/data-source/src/lib/entities/[name].entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

import { I[Name] } from '@project/[scope]/domain/interfaces/[name].interface';

@Entity('[names]')
export class [Name]Entity implements I[Name] {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

### Step 5: Create DTOs with Validation

```typescript
// libs/[scope]/data-source/src/lib/dtos/create-[name].dto.ts
import { IsString, IsNotEmpty, IsOptional, MaxLength } from 'class-validator';

import { ICreate[Name] } from '@project/[scope]/domain/interfaces/[name].interface';

export class Create[Name]Dto implements ICreate[Name] {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  name: string;

  @IsString()
  @IsOptional()
  @MaxLength(1000)
  description?: string;
}
```

```typescript
// libs/[scope]/data-source/src/lib/dtos/update-[name].dto.ts
import { PartialType } from '@nestjs/mapped-types';

import { Create[Name]Dto } from './create-[name].dto';

export class Update[Name]Dto extends PartialType(Create[Name]Dto) {}
```

### Step 6: Create Service

```typescript
// libs/[scope]/data-source/src/lib/services/[name].service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { [Name]Entity } from '../entities/[name].entity';
import { Create[Name]Dto } from '../dtos/create-[name].dto';
import { Update[Name]Dto } from '../dtos/update-[name].dto';

@Injectable()
export class [Name]Service {
  constructor(
    @InjectRepository([Name]Entity)
    private readonly repository: Repository<[Name]Entity>,
  ) {}

  async findAll(): Promise<[Name]Entity[]> {
    return this.repository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findById(id: string): Promise<[Name]Entity> {
    const entity = await this.repository.findOne({ where: { id } });

    if (!entity) {
      throw new NotFoundException(`[Name] with ID ${id} not found`);
    }

    return entity;
  }

  async create(dto: Create[Name]Dto): Promise<[Name]Entity> {
    const entity = this.repository.create(dto);
    return this.repository.save(entity);
  }

  async update(id: string, dto: Update[Name]Dto): Promise<[Name]Entity> {
    const entity = await this.findById(id);
    Object.assign(entity, dto);
    return this.repository.save(entity);
  }

  async delete(id: string): Promise<void> {
    const entity = await this.findById(id);
    await this.repository.remove(entity);
  }
}
```

### Step 7: Create Controller

```typescript
// libs/[scope]/data-source/src/lib/controllers/[name].controller.ts
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';

import { [Name]Service } from '../services/[name].service';
import { [Name]Entity } from '../entities/[name].entity';
import { Create[Name]Dto } from '../dtos/create-[name].dto';
import { Update[Name]Dto } from '../dtos/update-[name].dto';

@Controller('[names]')
export class [Name]Controller {
  constructor(private readonly service: [Name]Service) {}

  @Get()
  async findAll(): Promise<[Name]Entity[]> {
    return this.service.findAll();
  }

  @Get(':id')
  async findById(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<[Name]Entity> {
    return this.service.findById(id);
  }

  @Post()
  async create(@Body() dto: Create[Name]Dto): Promise<[Name]Entity> {
    return this.service.create(dto);
  }

  @Put(':id')
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: Update[Name]Dto,
  ): Promise<[Name]Entity> {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async delete(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.service.delete(id);
  }
}
```

### Step 8: Create Module

```typescript
// libs/[scope]/data-source/src/lib/[name].module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { [Name]Entity } from './entities/[name].entity';
import { [Name]Service } from './services/[name].service';
import { [Name]Controller } from './controllers/[name].controller';

@Module({
  imports: [TypeOrmModule.forFeature([[Name]Entity])],
  controllers: [[Name]Controller],
  providers: [[Name]Service],
  exports: [[Name]Service],
})
export class [Name]Module {}
```

---

## API Patterns

### Pagination

```typescript
// Query DTO
export class PaginationQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}

// Response interface
export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

// Service implementation
async findAllPaginated(query: PaginationQueryDto): Promise<PaginatedResponse<[Name]Entity>> {
  const { page = 1, limit = 20 } = query;
  const skip = (page - 1) * limit;

  const [data, total] = await this.repository.findAndCount({
    skip,
    take: limit,
    order: { createdAt: 'DESC' },
  });

  return {
    data,
    meta: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
}
```

### Error Handling

```typescript
// Custom exception filter
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const message =
      exception instanceof HttpException
        ? exception.message
        : 'Internal server error';

    response.status(status).json({
      statusCode: status,
      message,
      timestamp: new Date().toISOString(),
    });
  }
}
```

### Authentication Guard

```typescript
// JWT auth guard
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }
}

// Usage in controller
@Controller('[names]')
@UseGuards(JwtAuthGuard)
export class [Name]Controller {
  // All routes protected
}

// Or per route
@Post()
@UseGuards(JwtAuthGuard)
async create(@Body() dto: Create[Name]Dto) {
  // Protected route
}
```

---

## Database Patterns

### Relations

```typescript
// One-to-Many
@Entity('users')
export class UserEntity {
  @OneToMany(() => PostEntity, (post) => post.user)
  posts: PostEntity[];
}

@Entity('posts')
export class PostEntity {
  @ManyToOne(() => UserEntity, (user) => user.posts)
  @JoinColumn({ name: 'user_id' })
  user: UserEntity;

  @Column({ name: 'user_id' })
  userId: string;
}
```

### Soft Delete

```typescript
@Entity('[names]')
export class [Name]Entity {
  @DeleteDateColumn()
  deletedAt?: Date;
}

// Service
async softDelete(id: string): Promise<void> {
  await this.repository.softDelete(id);
}
```

---

## Security Checklist

```markdown
- [ ] Input validation with class-validator
- [ ] SQL injection prevention (TypeORM handles)
- [ ] Authentication on protected routes
- [ ] Authorization (role-based access)
- [ ] Rate limiting configured
- [ ] CORS properly configured
- [ ] Sensitive data not in responses
- [ ] Passwords hashed with bcrypt
```

---

## Checklist Before Completion

```markdown
- [ ] DTOs implement domain interfaces
- [ ] Entities map to database correctly
- [ ] Validation decorators on all DTO fields
- [ ] Error handling implemented
- [ ] Auth guards on protected routes
- [ ] Pagination for list endpoints
- [ ] Service methods follow SRP (max 5 statements)
- [ ] Controller routes match frontend requirements
- [ ] Module exports what's needed
```

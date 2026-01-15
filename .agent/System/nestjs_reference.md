# NestJS

NestJS — A progressive Node.js framework for building efficient and scalable server-side applications 🚀

## Table of Contents

- [What is NestJS](https://docs.nestjs.com/)
- [First steps](https://docs.nestjs.com/first-steps)
- [CLI Overview](https://docs.nestjs.com/cli/overview)
- [OpenAPI (Swagger)](https://docs.nestjs.com/openapi/introduction)

## Architecture
### Dependency Rule

**Dependencies must point inward**:

- `domain` → no dependencies
- `application` → depends only on `domain`
- `infrastructure` → depends on `application` and `domain`
- `presentation` → depends on `application` and `domain`

## Best Practices

### TypeScript

- Use strict type checking
- Prefer `interface` over `type` for object shapes
- Avoid `any`; use `unknown` when type is uncertain
- Use `readonly` for immutable properties

### Modules

- One module per feature/domain
- Use `@Global()` sparingly
- Keep modules focused and cohesive
- Import only what you need

### Controllers

- Keep controllers thin (delegation only)
- Use DTOs for request/response validation
- Apply proper HTTP status codes
- Use decorators for clarity (`@Get()`, `@Post()`, etc.)

### Services & Use Cases

- Single Responsibility Principle
- Use dependency injection
- Avoid business logic in controllers
- Keep use cases independent of frameworks

### Entities & Value Objects

- Domain entities contain business logic
- Value objects are immutable
- No framework dependencies in domain layer
- Rich domain models over anemic models

### DTOs (Data Transfer Objects)

- Use `class-validator` for validation
- Separate input and output DTOs
- Use `class-transformer` for transformations
- Document with Swagger decorators

## Fundamentals

- [Controllers](https://docs.nestjs.com/controllers)
- [Providers](https://docs.nestjs.com/providers)
- [Modules](https://docs.nestjs.com/modules)
- [Middleware](https://docs.nestjs.com/middleware)
- [Exception filters](https://docs.nestjs.com/exception-filters)
- [Pipes](https://docs.nestjs.com/pipes)
- [Guards](https://docs.nestjs.com/guards)
- [Interceptors](https://docs.nestjs.com/interceptors)
- [Custom decorators](https://docs.nestjs.com/custom-decorators)

## Techniques

- [Configuration](https://docs.nestjs.com/techniques/configuration)
- [Database (TypeORM)](https://docs.nestjs.com/techniques/database)
- [Mongo](https://docs.nestjs.com/techniques/mongodb)
- [Validation](https://docs.nestjs.com/techniques/validation)
- [Caching](https://docs.nestjs.com/techniques/caching)
- [Serialization](https://docs.nestjs.com/techniques/serialization)
- [Task scheduling](https://docs.nestjs.com/techniques/task-scheduling)
- [Queues](https://docs.nestjs.com/techniques/queues)
- [Logging](https://docs.nestjs.com/techniques/logger)
- [File upload](https://docs.nestjs.com/techniques/file-upload)
- [HTTP module](https://docs.nestjs.com/techniques/http-module)
- [Events](https://docs.nestjs.com/techniques/events)
- [Compression](https://docs.nestjs.com/techniques/compression)
- [Security](https://docs.nestjs.com/security/authentication)

## Security

- [Authentication](https://docs.nestjs.com/security/authentication)
- [Authorization](https://docs.nestjs.com/security/authorization)
- [Encryption and Hashing](https://docs.nestjs.com/security/encryption-and-hashing)
- [Helmet](https://docs.nestjs.com/security/helmet)
- [CORS](https://docs.nestjs.com/security/cors)
- [CSRF Protection](https://docs.nestjs.com/security/csrf)
- [Rate limiting](https://docs.nestjs.com/security/rate-limiting)

## GraphQL

- [Quick start](https://docs.nestjs.com/graphql/quick-start)
- [Resolvers](https://docs.nestjs.com/graphql/resolvers)
- [Mutations](https://docs.nestjs.com/graphql/mutations)
- [Subscriptions](https://docs.nestjs.com/graphql/subscriptions)
- [Scalars](https://docs.nestjs.com/graphql/scalars)
- [Directives](https://docs.nestjs.com/graphql/directives)
- [Plugins](https://docs.nestjs.com/graphql/plugins)
- [Complexity](https://docs.nestjs.com/graphql/complexity)
- [Federation](https://docs.nestjs.com/graphql/federation)

## WebSockets

- [Gateways](https://docs.nestjs.com/websockets/gateways)
- [Exception filters](https://docs.nestjs.com/websockets/exception-filters)
- [Pipes](https://docs.nestjs.com/websockets/pipes)
- [Guards](https://docs.nestjs.com/websockets/guards)
- [Interceptors](https://docs.nestjs.com/websockets/interceptors)
- [Adapters](https://docs.nestjs.com/websockets/adapter)

## Microservices

- [Overview](https://docs.nestjs.com/microservices/basics)
- [Redis](https://docs.nestjs.com/microservices/redis)
- [MQTT](https://docs.nestjs.com/microservices/mqtt)
- [NATS](https://docs.nestjs.com/microservices/nats)
- [RabbitMQ](https://docs.nestjs.com/microservices/rabbitmq)
- [Kafka](https://docs.nestjs.com/microservices/kafka)
- [gRPC](https://docs.nestjs.com/microservices/grpc)
- [Custom transporters](https://docs.nestjs.com/microservices/custom-transport)
- [Exception filters](https://docs.nestjs.com/microservices/exception-filters)
- [Pipes](https://docs.nestjs.com/microservices/pipes)
- [Guards](https://docs.nestjs.com/microservices/guards)
- [Interceptors](https://docs.nestjs.com/microservices/interceptors)

## Testing

- [Testing overview](https://docs.nestjs.com/fundamentals/testing)
- [Unit testing](https://docs.nestjs.com/fundamentals/testing#unit-testing)
- [End-to-end testing](https://docs.nestjs.com/fundamentals/testing#end-to-end-testing)
- [Test utilities](https://docs.nestjs.com/fundamentals/testing#testing-utilities)

### Testing Best Practices

#### Unit Tests

- Mock all external dependencies
- Test one unit of work per test
- Use `Test.createTestingModule()` for dependency injection
- Follow AAA pattern (Arrange, Act, Assert)

#### Integration Tests

- Test module interactions
- Use in-memory databases when possible
- Clean up resources after tests
- Test happy paths and edge cases

#### E2E Tests

- Test complete user flows
- Use `supertest` for HTTP assertions
- Test authentication and authorization
- Validate response schemas

## CLI Commands

- [Overview](https://docs.nestjs.com/cli/overview)
- [Workspaces](https://docs.nestjs.com/cli/monorepo)
- [Libraries](https://docs.nestjs.com/cli/libraries)
- [Usage](https://docs.nestjs.com/cli/usages)
- [Scripts](https://docs.nestjs.com/cli/scripts)

## Recipes

- [CRUD generator](https://docs.nestjs.com/recipes/crud-generator)
- [SWC (Speedy Web Compiler)](https://docs.nestjs.com/recipes/swc)
- [Prisma](https://docs.nestjs.com/recipes/prisma)
- [Health checks (Terminus)](https://docs.nestjs.com/recipes/terminus)
- [Documentation (Compodoc)](https://docs.nestjs.com/recipes/documentation)
- [REPL](https://docs.nestjs.com/recipes/repl)
- [Serve static](https://docs.nestjs.com/recipes/serve-static)
- [Hot reload](https://docs.nestjs.com/recipes/hot-reload)
- [MikroORM](https://docs.nestjs.com/recipes/mikroorm)
- [Automock](https://docs.nestjs.com/recipes/automock)

## Architecture Patterns

### Use Case Example

```typescript
// domain/entities/user.entity.ts
export class User {
	constructor(
		private readonly id: string,
		private readonly email: Email, // Value Object
		private name: string
	) {}

	changeName(newName: string): void {
		// Business logic here
		this.name = newName;
	}

	getName(): string {
		return this.name;
	}
}

// application/ports/user-repository.port.ts
export interface UserRepositoryPort {
	findById(id: string): Promise<User | null>;
	save(user: User): Promise<void>;
}

// application/use-cases/update-user-name.use-case.ts
@Injectable()
export class UpdateUserNameUseCase {
	constructor(
		@Inject('UserRepositoryPort')
		private readonly userRepository: UserRepositoryPort
	) {}

	async execute(userId: string, newName: string): Promise<void> {
		const user = await this.userRepository.findById(userId);
		if (!user) throw new UserNotFoundException();

		user.changeName(newName);
		await this.userRepository.save(user);
	}
}

// infrastructure/database/repositories/user.repository.ts
@Injectable()
export class UserRepository implements UserRepositoryPort {
	constructor(
		@InjectRepository(UserSchema)
		private readonly userModel: Repository<UserSchema>
	) {}

	async findById(id: string): Promise<User | null> {
		const userSchema = await this.userModel.findOne({ where: { id } });
		return userSchema ? UserMapper.toDomain(userSchema) : null;
	}

	async save(user: User): Promise<void> {
		const userSchema = UserMapper.toPersistence(user);
		await this.userModel.save(userSchema);
	}
}

// presentation/controllers/user.controller.ts
@Controller('users')
export class UserController {
	constructor(private readonly updateUserNameUseCase: UpdateUserNameUseCase) {}

	@Put(':id/name')
	@ApiOperation({ summary: 'Update user name' })
	async updateName(@Param('id') id: string, @Body() dto: UpdateUserNameDto): Promise<void> {
		await this.updateUserNameUseCase.execute(id, dto.name);
	}
}
```

### Module Organization

```typescript
// user.module.ts
@Module({
	imports: [TypeOrmModule.forFeature([UserSchema])],
	controllers: [UserController],
	providers: [
		// Use Cases
		UpdateUserNameUseCase,
		GetUserUseCase,

		// Repositories
		{
			provide: 'UserRepositoryPort',
			useClass: UserRepository
		}
	],
	exports: ['UserRepositoryPort']
})
export class UserModule {}
```

## Additional Resources

- [Official Documentation](https://docs.nestjs.com/)
- [Awesome NestJS](https://github.com/nestjs/awesome-nestjs)
- [Discord Community](https://discord.gg/nestjs)
- [DevTools](https://docs.nestjs.com/devtools/overview)
- [Courses](https://courses.nestjs.com/)

export type Environment = 'development' | 'homolog' | 'production';

export interface EnvironmentConfig {
	env: Environment;
	production: boolean;
	apiUrl: string;
	websocketUrl: string;
	authToken: string;
	userData: string;
	recaptcha: {
		siteKey: string;
	};
	google: {
		clientId: string;
	};
	siteUrl: string;
}

export function environmentFactory(env: Environment = 'development'): EnvironmentConfig {
	const configs: Record<Environment, EnvironmentConfig> = {
		development: {
			env: 'development',
			production: false,
			apiUrl: 'http://localhost:3000/v1',
			websocketUrl: 'http://localhost:3333',
			authToken: '@authToken',
			userData: '@userData',
			recaptcha: {
				siteKey: '---'
			},
			google: {
				clientId: '---'
			},
			siteUrl: 'http://localhost:4200'
		},
		homolog: {
			env: 'homolog',
			production: false,
			apiUrl: '---',
			websocketUrl: '---',
			authToken: '@authToken',
			userData: '@userData',
			recaptcha: {
				siteKey: '---'
			},
			google: {
				clientId: '---'
			},
			siteUrl: '---'
		},
		production: {
			env: 'production',
			production: true,
			apiUrl: '---',
			websocketUrl: '---',
			authToken: '@authToken',
			userData: '@userData',
			recaptcha: {
				siteKey: '---'
			},
			google: {
				clientId: '---'
			},
			siteUrl: '---'
		}
	};

	return configs[env];
}

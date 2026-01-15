# React Native Best Practices -  Mobile App

**Last update**: 2025-12-08
**Version**: 1.0.0
**Project**:  Mobile

---

## 1. Arquitetura Recomendada

### 1.1 Clean Architecture

O projeto mobile segue **Clean Architecture** adaptada para React Native, com separação clara de responsabilidades:

```
libs/mobile/
├── domain/                   # Camada de Domínio (Regras de Negócio)
│   ├── entities/             # Entidades de negócio
│   ├── interfaces/           # Interfaces/Contratos
│   ├── use-cases/            # Casos de uso
│   └── dtos/                 # Data Transfer Objects
│
├── data/                     # Camada de Dados
│   ├── repositories/         # Implementação dos repositórios
│   ├── datasources/          # Fontes de dados (API, Local)
│   └── mappers/              # Mapeadores de dados
│
├── infrastructure/           # Infraestrutura
│   ├── api/                  # Configuração HTTP (Axios)
│   ├── storage/              # AsyncStorage, SecureStorage
│   └── services/             # Serviços externos
│
└── presentation/             # Camada de Apresentação
    ├── components/           # Componentes reutilizáveis
    ├── screens/              # Telas do app
    ├── navigation/           # Configuração de navegação
    ├── hooks/                # Custom hooks
    ├── contexts/             # React Contexts
    └── theme/                # Tema e estilos globais
```

### 1.2 Princípios SOLID

| Princípio | Aplicação no React Native |
|-----------|---------------------------|
| **S** - Single Responsibility | Cada componente/hook tem uma única responsabilidade |
| **O** - Open/Closed | Componentes extensíveis via props, não modificação |
| **L** - Liskov Substitution | Interfaces bem definidas para repositórios |
| **I** - Interface Segregation | Hooks específicos ao invés de genéricos |
| **D** - Dependency Inversion | Injeção de dependências via Context/Props |

---

## 2. Estrutura de Pastas no Nx Workspace

### 2.1 Estrutura Integrada ao Monorepo

```
project/
├── apps/
│   └── mobile/                    # App React Native principal
│       ├── src/
│       │   ├── app/
│       │   │   ├── App.tsx        # Componente raiz
│       │   │   └── index.ts       # Entry point
│       │   └── assets/            # Assets específicos do app
│       ├── android/               # Código nativo Android
│       ├── ios/                   # Código nativo iOS
│       ├── app.json               # Configuração do app
│       ├── metro.config.js        # Configuração Metro bundler
│       ├── package.json           # Dependências do app
│       └── project.json           # Configuração Nx
│
├── libs/
│   ├── mobile/                    # Libs específicas do mobile
│   │   ├── domain/                # Entidades e interfaces
│   │   ├── data-access/           # Facades e estado
│   │   ├── feature-auth/          # Feature de autenticação
│   │   ├── feature-home/          # Feature home
│   │   ├── feature-coupon/        # Feature cupons
│   │   ├── feature-map/           # Feature mapa
│   │   ├── feature-profile/       # Feature perfil
│   │   ├── ui/                    # Componentes UI compartilhados
│   │   └── util/                  # Utilitários mobile
│   │
│   └── shared/                    # Compartilhado entre plataformas
│       ├── domain/                # Entidades compartilhadas
│       └── utils/                 # Utilitários gerais
```

### 2.2 Path Mappings

```typescript
// tsconfig.base.json
{
  "compilerOptions": {
    "paths": {
      // Mobile Domain
      "@mobile/domain": ["libs/mobile/domain/src/index.ts"],
      "@mobile/data-access": ["libs/mobile/data-access/src/index.ts"],

      // Mobile Features
      "@mobile/feature-auth": ["libs/mobile/feature-auth/src/index.ts"],
      "@mobile/feature-home": ["libs/mobile/feature-home/src/index.ts"],
      "@mobile/feature-coupon": ["libs/mobile/feature-coupon/src/index.ts"],
      "@mobile/feature-map": ["libs/mobile/feature-map/src/index.ts"],
      "@mobile/feature-profile": ["libs/mobile/feature-profile/src/index.ts"],

      // Mobile UI
      "@mobile/ui": ["libs/mobile/ui/src/index.ts"],
      "@mobile/util": ["libs/mobile/util/src/index.ts"],

      // Shared (cross-platform)
      "@shared/domain": ["libs/shared/domain/src/index.ts"],
      "@shared/utils": ["libs/shared/utils/src/index.ts"]
    }
  }
}
```

---

## 3. Padrões de Componentes

### 3.1 Estrutura de Componente

```typescript
// libs/mobile/ui/src/lib/button/button.tsx
import React, { memo } from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { useTheme } from '@mobile/ui';

// ✅ Interface bem definida
interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'outline';
  loading?: boolean;
  disabled?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
  testID?: string;
}

// ✅ Componente funcional com memo
export const Button = memo<ButtonProps>(({
  title,
  onPress,
  variant = 'primary',
  loading = false,
  disabled = false,
  style,
  textStyle,
  testID,
}) => {
  const { colors } = useTheme();

  const buttonStyles = getButtonStyles(variant, colors, disabled);

  return (
    <TouchableOpacity
      testID={testID}
      style={[styles.button, buttonStyles.container, style]}
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.7}
    >
      {loading ? (
        <ActivityIndicator color={buttonStyles.textColor} />
      ) : (
        <Text style={[styles.text, { color: buttonStyles.textColor }, textStyle]}>
          {title}
        </Text>
      )}
    </TouchableOpacity>
  );
});

Button.displayName = 'Button';

// ✅ Estilos com StyleSheet.create
const styles = StyleSheet.create({
  button: {
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 48,
  },
  text: {
    fontSize: 16,
    fontFamily: 'Inter-Medium',
  },
});
```

### 3.2 Regras de Componentes

| Regra | Descrição |
|-------|-----------|
| `memo()` | Use para componentes que recebem as mesmas props frequentemente |
| `displayName` | Sempre defina para debugging |
| `testID` | Inclua prop para testes E2E |
| `StyleSheet.create()` | Sempre use ao invés de inline styles |
| `Types explícitos` | Defina interfaces para todas as props |

---

## 4. Gerenciamento de Estado

### 4.1 Hierarquia de Estado

```
Estado Global (Context/Zustand)
    │
    ├── AuthContext         → Autenticação do usuário
    ├── ThemeContext        → Tema (dark/light)
    └── AppStateContext     → Estado geral do app

Estado de Feature (Custom Hooks)
    │
    ├── useCoupons()        → Lista de cupons
    ├── usePromotions()     → Promoções ativas
    └── useUserProfile()    → Perfil do usuário

Estado Local (useState/useReducer)
    │
    └── Componente          → Estado específico do componente
```

### 4.2 Context Pattern

```typescript
// libs/mobile/data-access/src/lib/auth/auth.context.tsx
import React, { createContext, useContext, useState, useCallback, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { User, AuthToken } from '@mobile/domain';
import { authService } from '../services/auth.service';

interface AuthContextData {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextData>({} as AuthContextData);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const signIn = useCallback(async (email: string, password: string) => {
    setIsLoading(true);
    try {
      const response = await authService.login(email, password);
      setUser(response.user);
      setToken(response.token);
      await AsyncStorage.setItem('@project:token', response.token);
      await AsyncStorage.setItem('@project:user', JSON.stringify(response.user));
    } finally {
      setIsLoading(false);
    }
  }, []);

  const signOut = useCallback(async () => {
    setUser(null);
    setToken(null);
    await AsyncStorage.multiRemove(['@project:token', '@project:user']);
  }, []);

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isAuthenticated: !!token,
        isLoading,
        signIn,
        signOut,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

### 4.3 Custom Hooks para Features

```typescript
// libs/mobile/feature-coupon/src/lib/hooks/use-coupons.ts
import { useState, useEffect, useCallback } from 'react';
import { Coupon } from '@mobile/domain';
import { couponRepository } from '@mobile/data-access';
import { useAuth } from '@mobile/data-access';

interface UseCouponsReturn {
  coupons: Coupon[];
  isLoading: boolean;
  error: string | null;
  refetch: () => Promise<void>;
  generateCoupon: (promotionId: string) => Promise<Coupon>;
}

export const useCoupons = (): UseCouponsReturn => {
  const { user, token } = useAuth();
  const [coupons, setCoupons] = useState<Coupon[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchCoupons = useCallback(async () => {
    if (!user?.id) return;

    setIsLoading(true);
    setError(null);

    try {
      const data = await couponRepository.getUserCoupons(user.id);
      setCoupons(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao carregar cupons');
    } finally {
      setIsLoading(false);
    }
  }, [user?.id]);

  const generateCoupon = useCallback(async (promotionId: string): Promise<Coupon> => {
    const newCoupon = await couponRepository.generate(promotionId);
    setCoupons(prev => [newCoupon, ...prev]);
    return newCoupon;
  }, []);

  useEffect(() => {
    fetchCoupons();
  }, [fetchCoupons]);

  return {
    coupons,
    isLoading,
    error,
    refetch: fetchCoupons,
    generateCoupon,
  };
};
```

---

## 5. Navegação

### 5.1 Estrutura de Navegação

```typescript
// libs/mobile/feature-shell/src/lib/navigation/root-navigator.tsx
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useAuth } from '@mobile/data-access';
import { AuthNavigator } from './auth-navigator';
import { MainTabNavigator } from './main-tab-navigator';
import { SplashScreen } from '@mobile/feature-auth';

export type RootStackParamList = {
  Splash: undefined;
  Auth: undefined;
  Main: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export const RootNavigator: React.FC = () => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {isAuthenticated ? (
          <Stack.Screen name="Main" component={MainTabNavigator} />
        ) : (
          <Stack.Screen name="Auth" component={AuthNavigator} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};
```

### 5.2 Tab Navigator

```typescript
// libs/mobile/feature-shell/src/lib/navigation/main-tab-navigator.tsx
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { HomeScreen } from '@mobile/feature-home';
import { CouponScreen } from '@mobile/feature-coupon';
import { MapScreen } from '@mobile/feature-map';
import { ProfileScreen } from '@mobile/feature-profile';
import { TabBar } from '@mobile/ui';

export type MainTabParamList = {
  Home: undefined;
  Coupons: undefined;
  Map: undefined;
  Profile: undefined;
};

const Tab = createBottomTabNavigator<MainTabParamList>();

export const MainTabNavigator: React.FC = () => {
  return (
    <Tab.Navigator
      tabBar={(props) => <TabBar {...props} />}
      screenOptions={{
        headerShown: false,
      }}
    >
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{ tabBarLabel: 'Início' }}
      />
      <Tab.Screen
        name="Coupons"
        component={CouponScreen}
        options={{ tabBarLabel: 'Cupons' }}
      />
      <Tab.Screen
        name=""
        component={InfoScreen}
        options={{ tabBarLabel: 'SalvaÊ' }}
      />
      <Tab.Screen
        name="Map"
        component={MapScreen}
        options={{ tabBarLabel: 'Mapa' }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{ tabBarLabel: 'Perfil' }}
      />
    </Tab.Navigator>
  );
};
```

### 5.3 Tipagem de Navegação

```typescript
// libs/mobile/domain/src/lib/navigation/navigation.types.ts
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { CompositeNavigationProp, RouteProp } from '@react-navigation/native';

// ✅ Sempre tipar as rotas
declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}

// Hooks tipados
export const useAppNavigation = () =>
  useNavigation<NativeStackNavigationProp<RootStackParamList>>();

export const useMainTabNavigation = () =>
  useNavigation<BottomTabNavigationProp<MainTabParamList>>();
```

---

## 6. Integração com API

### 6.1 Configuração do Axios

```typescript
// libs/mobile/infrastructure/src/lib/api/api-client.ts
import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { API_BASE_URL } from '@mobile/util';

class ApiClient {
  private instance: AxiosInstance;

  constructor() {
    this.instance = axios.create({
      baseURL: API_BASE_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors(): void {
    // Request interceptor
    this.instance.interceptors.request.use(
      async (config: InternalAxiosRequestConfig) => {
        const token = await AsyncStorage.getItem('@project:token');
        if (token && config.headers) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error: AxiosError) => Promise.reject(error)
    );

    // Response interceptor
    this.instance.interceptors.response.use(
      (response) => response,
      async (error: AxiosError) => {
        if (error.response?.status === 401) {
          await AsyncStorage.removeItem('@project:token');
          // Trigger logout event
        }
        return Promise.reject(this.handleError(error));
      }
    );
  }

  private handleError(error: AxiosError): Error {
    if (error.response) {
      const message = (error.response.data as { message?: string })?.message
        || 'Erro no servidor';
      return new Error(message);
    }
    if (error.request) {
      return new Error('Sem conexão com o servidor');
    }
    return new Error('Erro ao processar requisição');
  }

  get api(): AxiosInstance {
    return this.instance;
  }
}

export const apiClient = new ApiClient().api;
```

### 6.2 Repository Pattern

```typescript
// libs/mobile/data-access/src/lib/repositories/coupon.repository.ts
import { apiClient } from '@mobile/infrastructure';
import { Coupon, CreateCouponDto } from '@mobile/domain';

interface ICouponRepository {
  getUserCoupons(userId: string): Promise<Coupon[]>;
  generate(promotionId: string): Promise<Coupon>;
  getById(id: string): Promise<Coupon>;
}

class CouponRepository implements ICouponRepository {
  async getUserCoupons(userId: string): Promise<Coupon[]> {
    const { data } = await apiClient.get<Coupon[]>(`/cupom/usuario/${userId}`);
    return data;
  }

  async generate(promotionId: string): Promise<Coupon> {
    const { data } = await apiClient.post<Coupon>('/cupom', { promotionId });
    return data;
  }

  async getById(id: string): Promise<Coupon> {
    const { data } = await apiClient.get<Coupon>(`/cupom/${id}`);
    return data;
  }
}

export const couponRepository = new CouponRepository();
```

---

## 7. Tema e Estilos

### 7.1 Definição do Tema

```typescript
// libs/mobile/ui/src/lib/theme/theme.ts
export const lightTheme = {
  colors: {
    primary: '#134844',
    primaryLight: '#015357',
    accent: '#00D195',
    background: '#FFFFFF',
    surface: '#F5F5F5',
    text: '#1A1A1A',
    textSecondary: '#666666',
    textMuted: '#999999',
    border: '#E0E0E0',
    error: '#FF4444',
    success: '#00D195',
    warning: '#FFB800',
  },
  spacing: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
    xxl: 48,
  },
  borderRadius: {
    sm: 4,
    md: 8,
    lg: 16,
    full: 9999,
  },
  typography: {
    h1: { fontSize: 24, fontFamily: 'Inter-Bold' },
    h2: { fontSize: 20, fontFamily: 'Inter-SemiBold' },
    h3: { fontSize: 18, fontFamily: 'Inter-Medium' },
    body: { fontSize: 16, fontFamily: 'Inter-Regular' },
    bodySmall: { fontSize: 14, fontFamily: 'Inter-Regular' },
    caption: { fontSize: 12, fontFamily: 'Inter-Regular' },
    button: { fontSize: 16, fontFamily: 'Inter-Medium' },
  },
};

export const darkTheme = {
  ...lightTheme,
  colors: {
    ...lightTheme.colors,
    background: '#1A1A1A',
    surface: '#2D2D2D',
    text: '#FFFFFF',
    textSecondary: '#B0B0B0',
    border: '#404040',
  },
};

export type Theme = typeof lightTheme;
```

### 7.2 Theme Provider

```typescript
// libs/mobile/ui/src/lib/theme/theme-provider.tsx
import React, { createContext, useContext, useState, ReactNode } from 'react';
import { useColorScheme } from 'react-native';
import { lightTheme, darkTheme, Theme } from './theme';

interface ThemeContextData {
  theme: Theme;
  isDark: boolean;
  toggleTheme: () => void;
  colors: Theme['colors'];
  spacing: Theme['spacing'];
  typography: Theme['typography'];
}

const ThemeContext = createContext<ThemeContextData>({} as ThemeContextData);

export const ThemeProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const colorScheme = useColorScheme();
  const [isDark, setIsDark] = useState(colorScheme === 'dark');

  const theme = isDark ? darkTheme : lightTheme;

  const toggleTheme = () => setIsDark(prev => !prev);

  return (
    <ThemeContext.Provider
      value={{
        theme,
        isDark,
        toggleTheme,
        colors: theme.colors,
        spacing: theme.spacing,
        typography: theme.typography,
      }}
    >
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
};
```

---

## 8. Testes

### 8.1 Estrutura de Testes

```
libs/mobile/feature-auth/
├── src/
│   └── lib/
│       ├── screens/
│       │   ├── login.screen.tsx
│       │   └── login.screen.spec.tsx    # ← Teste colocado junto
│       └── hooks/
│           ├── use-login.ts
│           └── use-login.spec.ts        # ← Teste colocado junto
└── jest.config.ts
```

### 8.2 Exemplo de Teste de Componente

```typescript
// libs/mobile/ui/src/lib/button/button.spec.tsx
import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import { Button } from './button';
import { ThemeProvider } from '../theme/theme-provider';

const renderWithTheme = (component: React.ReactElement) => {
  return render(<ThemeProvider>{component}</ThemeProvider>);
};

describe('Button', () => {
  it('should render title correctly', () => {
    const { getByText } = renderWithTheme(
      <Button title="Click me" onPress={() => {}} />
    );

    expect(getByText('Click me')).toBeTruthy();
  });

  it('should call onPress when pressed', () => {
    const onPress = jest.fn();
    const { getByTestId } = renderWithTheme(
      <Button title="Click me" onPress={onPress} testID="test-button" />
    );

    fireEvent.press(getByTestId('test-button'));

    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it('should show loading indicator when loading', () => {
    const { queryByText, getByTestId } = renderWithTheme(
      <Button title="Click me" onPress={() => {}} loading testID="test-button" />
    );

    expect(queryByText('Click me')).toBeNull();
  });

  it('should be disabled when disabled prop is true', () => {
    const onPress = jest.fn();
    const { getByTestId } = renderWithTheme(
      <Button title="Click me" onPress={onPress} disabled testID="test-button" />
    );

    fireEvent.press(getByTestId('test-button'));

    expect(onPress).not.toHaveBeenCalled();
  });
});
```

### 8.3 Exemplo de Teste de Hook

```typescript
// libs/mobile/feature-auth/src/lib/hooks/use-login.spec.ts
import { renderHook, act, waitFor } from '@testing-library/react-native';
import { useLogin } from './use-login';
import { authService } from '@mobile/data-access';

jest.mock('@mobile/data-access', () => ({
  authService: {
    login: jest.fn(),
  },
}));

describe('useLogin', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should login successfully', async () => {
    const mockUser = { id: '1', email: 'test@test.com' };
    (authService.login as jest.Mock).mockResolvedValue({ user: mockUser, token: 'token' });

    const { result } = renderHook(() => useLogin());

    await act(async () => {
      await result.current.login('test@test.com', 'password');
    });

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
      expect(result.current.error).toBeNull();
    });

    expect(authService.login).toHaveBeenCalledWith('test@test.com', 'password');
  });

  it('should handle login error', async () => {
    (authService.login as jest.Mock).mockRejectedValue(new Error('Invalid credentials'));

    const { result } = renderHook(() => useLogin());

    await act(async () => {
      await result.current.login('test@test.com', 'wrong');
    });

    await waitFor(() => {
      expect(result.current.error).toBe('Invalid credentials');
    });
  });
});
```

---

## 9. Performance

### 9.1 Otimizações Essenciais

| Técnica | Uso |
|---------|-----|
| `React.memo()` | Componentes com props estáveis |
| `useMemo()` | Cálculos custosos |
| `useCallback()` | Callbacks passados como props |
| `FlatList` | Listas grandes (virtualização) |
| `Image.prefetch()` | Pré-carregar imagens |
| `InteractionManager` | Tarefas após animações |

### 9.2 FlatList Otimizado

```typescript
// ✅ FlatList otimizado
import React, { useCallback, useMemo } from 'react';
import { FlatList, ListRenderItem } from 'react-native';
import { Coupon } from '@mobile/domain';
import { CouponCard } from '@mobile/ui';

interface CouponListProps {
  coupons: Coupon[];
  onCouponPress: (coupon: Coupon) => void;
}

export const CouponList: React.FC<CouponListProps> = ({ coupons, onCouponPress }) => {
  // ✅ Memoize renderItem
  const renderItem: ListRenderItem<Coupon> = useCallback(
    ({ item }) => (
      <CouponCard coupon={item} onPress={() => onCouponPress(item)} />
    ),
    [onCouponPress]
  );

  // ✅ Memoize keyExtractor
  const keyExtractor = useCallback((item: Coupon) => item.id, []);

  // ✅ Configurações de otimização
  const getItemLayout = useCallback(
    (_: unknown, index: number) => ({
      length: 120, // altura fixa do item
      offset: 120 * index,
      index,
    }),
    []
  );

  return (
    <FlatList
      data={coupons}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      getItemLayout={getItemLayout}
      removeClippedSubviews={true}
      maxToRenderPerBatch={10}
      windowSize={5}
      initialNumToRender={10}
      showsVerticalScrollIndicator={false}
    />
  );
};
```

### 9.3 Lazy Loading de Imagens

```typescript
// libs/mobile/ui/src/lib/image/cached-image.tsx
import React, { useState } from 'react';
import { Image, ImageStyle, ActivityIndicator, View, StyleSheet } from 'react-native';

interface CachedImageProps {
  source: { uri: string };
  style?: ImageStyle;
  placeholder?: React.ReactNode;
}

export const CachedImage: React.FC<CachedImageProps> = ({
  source,
  style,
  placeholder,
}) => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  return (
    <View style={[styles.container, style]}>
      {loading && (
        <View style={styles.placeholder}>
          {placeholder || <ActivityIndicator />}
        </View>
      )}
      <Image
        source={source}
        style={[styles.image, style]}
        onLoadEnd={() => setLoading(false)}
        onError={() => setError(true)}
        resizeMode="cover"
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    overflow: 'hidden',
  },
  placeholder: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
  },
  image: {
    width: '100%',
    height: '100%',
  },
});
```

---

## 10. Segurança

### 10.1 Armazenamento Seguro

```typescript
// libs/mobile/infrastructure/src/lib/storage/secure-storage.ts
import * as Keychain from 'react-native-keychain';

export const secureStorage = {
  async setItem(key: string, value: string): Promise<void> {
    await Keychain.setGenericPassword(key, value, { service: key });
  },

  async getItem(key: string): Promise<string | null> {
    const credentials = await Keychain.getGenericPassword({ service: key });
    return credentials ? credentials.password : null;
  },

  async removeItem(key: string): Promise<void> {
    await Keychain.resetGenericPassword({ service: key });
  },
};
```

### 10.2 Validação de Input

```typescript
// ✅ Sempre validar inputs
import { z } from 'zod';

const loginSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(6, 'Senha deve ter no mínimo 6 caracteres'),
});

export const validateLogin = (data: unknown) => {
  return loginSchema.safeParse(data);
};
```

---

## 11. Comandos Nx

### 11.1 Comandos Essenciais

```bash
# Gerar novo app React Native
nx g @nx/react-native:app mobile --directory=apps/mobile

# Gerar biblioteca mobile
nx g @nx/react-native:lib domain --directory=libs/mobile

# Gerar componente
nx g @nx/react-native:component button --project=mobile-ui

# Executar no iOS
nx run-ios mobile

# Executar no Android
nx run-android mobile

# Build para produção
nx build-android mobile --configuration=production
nx build-ios mobile --configuration=production

# Testes
nx test mobile-feature-auth
nx test mobile-ui --coverage

# Lint
nx lint mobile
```

### 11.2 Scripts package.json

```json
{
  "scripts": {
    "start:mobile": "nx start mobile",
    "ios": "nx run-ios mobile",
    "android": "nx run-android mobile",
    "build:ios": "nx build-ios mobile --configuration=production",
    "build:android": "nx build-android mobile --configuration=production",
    "test:mobile": "nx run-many --target=test --projects=mobile-*",
    "lint:mobile": "nx run-many --target=lint --projects=mobile-*"
  }
}
```

---

## 12. Checklist de Revisão de Código

### 12.1 Componentes
- [ ] Usa `memo()` quando apropriado
- [ ] Tem `displayName` definido
- [ ] Props tipadas com interface
- [ ] Inclui `testID` para testes
- [ ] Usa `StyleSheet.create()`
- [ ] Sem inline styles complexos

### 12.2 Hooks
- [ ] Retorna objeto tipado
- [ ] Usa `useCallback` para funções expostas
- [ ] Trata loading e error states
- [ ] Limpa side effects no unmount

### 12.3 Performance
- [ ] Listas usam `FlatList` com `keyExtractor`
- [ ] Imagens otimizadas e com placeholder
- [ ] Sem re-renders desnecessários
- [ ] Memoização onde necessário

### 12.4 Segurança
- [ ] Dados sensíveis em SecureStorage
- [ ] Inputs validados
- [ ] Tokens não logados
- [ ] HTTPS em produção

---

## 13. Referências

### 13.1 Documentação Oficial
- [React Native](https://reactnative.dev)
- [React Navigation](https://reactnavigation.org)
- [Nx React Native Plugin](https://nx.dev/nx-api/react-native)

### 13.2 Bibliotecas Recomendadas

| Categoria | Biblioteca |
|-----------|------------|
| Navegação | `@react-navigation/native` |
| Estado | `zustand` ou Context API |
| HTTP | `axios` |
| Storage | `@react-native-async-storage/async-storage` |
| Mapas | `react-native-maps` |
| Animações | `react-native-reanimated` |
| Formulários | `react-hook-form` + `zod` |
| Testes | `@testing-library/react-native` |
| Icons | `react-native-vector-icons` |

---

**Last update**: 2025-12-08
**Version**: 1.0.0
**Project**:  Mobile

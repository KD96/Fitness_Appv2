# Fitness App - Supabase Backend

Este directorio contiene toda la configuración de backend para la aplicación de fitness usando Supabase.

## 🚀 Configuración Inicial

### Paso 1: Configurar Variables de Entorno

1. Copia el archivo de ejemplo:
```bash
cp .env.example .env.local
```

2. Ve a tu [Dashboard de Supabase](https://app.supabase.com) y obtén:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **Anon Key**: Tu clave pública (anon/public)
   - **Service Role Key**: Tu clave privada (solo para servidor)

3. Actualiza el archivo `.env.local` con tus credenciales reales.

### Paso 2: Aplicar el Esquema de Base de Datos

Ejecuta el siguiente comando para aplicar todas las migraciones:

```bash
supabase db push
```

Esto creará:
- ✅ Todas las tablas necesarias
- ✅ Políticas de seguridad RLS
- ✅ Funciones y triggers automáticos
- ✅ Índices para optimización
- ✅ Datos de ejemplo

## 📊 Estructura de la Base de Datos

### Tablas Principales

| Tabla | Descripción | Características |
|-------|-------------|-----------------|
| `users` | Perfiles de usuario | Extiende `auth.users`, niveles de fitness |
| `workouts` | Entrenamientos registrados | Métricas detalladas, tokens ganados |
| `rewards` | Recompensas disponibles | Categorías, costos en tokens |
| `user_rewards` | Compras de recompensas | Historial de canjes |
| `missions` | Misiones diarias | Objetivos y recompensas |
| `friendships` | Relaciones sociales | Estados: pending, accepted, declined |
| `social_activities` | Feed social | Actividades compartidas |
| `fitness_events` | Eventos grupales | Entrenamientos comunitarios |

### Características Avanzadas

- **🔒 Row Level Security (RLS)**: Protección automática de datos
- **⚡ Realtime**: Actualizaciones en vivo para features sociales
- **📈 Analytics**: Tracking de eventos y comportamiento
- **🎯 Triggers**: Automatización de nivel de usuario y actividades sociales
- **💾 Storage**: Bucket para avatares y imágenes

## 🔐 Seguridad

### Políticas RLS Implementadas

- **Usuarios**: Solo pueden ver/editar su propio perfil
- **Entrenamientos**: Privados por defecto, compartibles con amigos
- **Recompensas**: Públicas para ver, privadas para comprar
- **Social**: Respeta configuraciones de privacidad
- **Eventos**: Públicos para descubrir, privados para participar

### Autenticación

```swift
// Ejemplo de autenticación en iOS
import Supabase

let client = SupabaseClient(
    supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
    supabaseKey: "YOUR_ANON_KEY"
)

// Registro
try await client.auth.signUp(
    email: "user@example.com",
    password: "password"
)

// Login
try await client.auth.signIn(
    email: "user@example.com", 
    password: "password"
)
```

## 📱 Integración con iOS

### 1. Instalar Dependencias

Agrega a tu `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
]
```

### 2. Configurar Cliente

Usa el archivo `SupabaseConfig.swift` ya creado:

```swift
import Supabase

// Cliente configurado automáticamente
let client = SupabaseConfig.client

// Verificar autenticación
if SupabaseConfig.isAuthenticated {
    let userId = SupabaseConfig.currentUserId
}
```

### 3. Operaciones Básicas

```swift
// Crear workout
let workout = [
    "user_id": userId,
    "name": "Morning Run",
    "type": "running",
    "duration_minutes": 30,
    "calories_burned": 250,
    "tokens_earned": 25
]

try await client.database
    .from("workouts")
    .insert(workout)
    .execute()

// Obtener workouts del usuario
let workouts: [Workout] = try await client.database
    .from("workouts")
    .select()
    .eq("user_id", value: userId)
    .order("workout_date", ascending: false)
    .execute()
    .value
```

## 🔄 Realtime Features

### Suscribirse a Cambios

```swift
// Feed social en tiempo real
let channel = client.realtime.channel("social-feed")

channel.on(.postgres_changes, filter: .init(
    event: .insert,
    schema: "public",
    table: "social_activities"
)) { payload in
    // Actualizar UI con nueva actividad
}

await channel.subscribe()
```

## 📈 Analytics

### Tracking de Eventos

```swift
// Registrar evento de analytics
let analyticsEvent = [
    "user_id": userId,
    "event_type": "user_action",
    "event_name": "workout_completed",
    "metadata": [
        "workout_type": "running",
        "duration": 30
    ]
]

try await client.database
    .from("analytics_events")
    .insert(analyticsEvent)
    .execute()
```

## 🎯 Funciones Automáticas

### Triggers Implementados

1. **Actualización de Nivel**: Calcula automáticamente el nivel del usuario basado en XP
2. **Actividades Sociales**: Crea posts automáticos cuando se completa un workout
3. **Timestamps**: Actualiza `updated_at` automáticamente
4. **Validaciones**: Verifica integridad de datos

### Funciones Útiles

```sql
-- Verificar si dos usuarios son amigos
SELECT public.are_friends('user1_id', 'user2_id');

-- Calcular nivel basado en XP
SELECT public.calculate_user_level(2500); -- Returns 'intermediate'
```

## 🚀 Deployment

### Entornos

- **Development**: Base de datos local con `supabase start`
- **Staging**: Proyecto separado para testing
- **Production**: Proyecto principal con backups automáticos

### Migraciones

```bash
# Crear nueva migración
supabase migration new add_new_feature

# Aplicar migraciones
supabase db push

# Reset completo (solo desarrollo)
supabase db reset
```

## 📊 Monitoreo

### Dashboard de Supabase

- **Database**: Explorar datos y ejecutar queries
- **Auth**: Gestionar usuarios y configuraciones
- **Storage**: Administrar archivos subidos
- **Logs**: Monitorear errores y performance
- **API**: Documentación automática de endpoints

### Métricas Importantes

- Usuarios activos diarios/mensuales
- Entrenamientos completados por día
- Tokens ganados y canjeados
- Actividad social (posts, amigos)
- Performance de queries

## 🔧 Troubleshooting

### Problemas Comunes

1. **Error de autenticación**: Verificar keys en configuración
2. **RLS blocking queries**: Revisar políticas de seguridad
3. **Realtime no funciona**: Verificar suscripciones y permisos
4. **Migraciones fallan**: Revisar sintaxis SQL y dependencias

### Logs Útiles

```bash
# Ver logs en tiempo real
supabase logs

# Logs específicos de auth
supabase logs --type auth

# Logs de base de datos
supabase logs --type database
```

## 📚 Recursos

- [Documentación de Supabase](https://supabase.com/docs)
- [Supabase Swift SDK](https://github.com/supabase/supabase-swift)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Realtime Guide](https://supabase.com/docs/guides/realtime)

---

**¡Tu backend está listo! 🎉**

Ejecuta `supabase db push` para aplicar todos los cambios y comenzar a desarrollar tu app de fitness. 
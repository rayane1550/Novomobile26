# Onde Comer

Aplicativo Flutter para apoiar estabelecimentos locais com apresentação de
promoções, favoritos, carrinho e gerenciamento básico de conteúdo.

## Arquitetura

- `models`: classes de domínio (`Promotion`, `CartItem`).
- `services`: integração REST e persistência local.
- `screens`: interfaces organizadas por fluxo.

## Dados

- Informações públicas (promoções) são consumidas e gerenciadas por REST
  usando JSONPlaceholder. O projeto demonstra GET, POST, PUT e DELETE.
- Endereço, telefone e favoritos são sensíveis/preferências locais e são
  armazenados no dispositivo com `shared_preferences`.
- Os dados locais não são enviados à API.

## Executar

```bash
flutter pub get
flutter run -d chrome
```

## Gerar APK Android

Com o SDK do Flutter configurado em um computador com Android Studio:

```bash
flutter pub get
flutter build apk --release
```

O arquivo será gerado em `build/app/outputs/flutter-apk/app-release.apk` e pode
ser instalado diretamente em um dispositivo Android.

## Integrações e privacidade

- `PromotionService` utiliza a API REST pública JSONPlaceholder para demonstrar
  GET, POST, PUT e DELETE.
- Endereço, telefone e carrinho são dados locais e são armazenados pelo
  `shared_preferences` apenas neste dispositivo.
- JSONPlaceholder é um serviço didático: as operações CRUD são simuladas pela
  API e não precisam conter dados pessoais reais.

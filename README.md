# Ung dung quan ly san pham

Flutter app quan li san pham: admin dang nhap bang Firebase Authentication, CRUD san pham tren Cloud Firestore, luu anh tren Supabase Storage.

## Chay Web

```powershell
flutter pub get
flutter run -d chrome
```

## Chay Android

```powershell
flutter devices
flutter run -d <device-id>
```

Firestore collection `products` chi luu cac field `name`, `price`, `soluong`, `image`. ID nam o document ID, khong phai field thu nam. Supabase bucket la `images`.

Xem [EXAM_BACKEND_SETUP.md](EXAM_BACKEND_SETUP.md) de cai dat backend, [EXAM_GUIDE.md](EXAM_GUIDE.md) de xem cau truc project va [REPORT.md](REPORT.md) de hoan thien bao cao nop bai.

Supabase URL/publishable key mac dinh duoc khai bao trong `lib/data/providers/supabase_image_storage.dart`, nen co the Run tu IDE. `supabase.local.json` (Git ignore) chi can neu muon override gia tri mac dinh. Publishable key la public client key; khong dung service-role key trong app.

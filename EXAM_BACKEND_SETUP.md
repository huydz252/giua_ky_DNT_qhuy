# Cai dat Firebase va Supabase

## Firebase

Project FlutterFire: `giua-ky-dnt`; app Android: `com.example.giua_ky`; Web app da co trong `lib/firebase_options.dart`.

1. Firebase Authentication: bat Email/Password va tao tai khoan admin.
2. Firestore: tao database neu chua co.
3. Firestore Rules da nam trong `firestore.rules` va gioi han collection `products` cho admin `252quanghuy@gmail.com`. Rules bat buoc dung chinh xac bon field, validate gia va so luong khong am.
4. Deploy Rules khi can cap nhat:

```powershell
firebase deploy --only firestore:rules --project giua-ky-dnt
```

Moi document trong `products` co dung:

```json
{
  "name": "Ten san pham",
  "price": 125000,
  "soluong": 8,
  "image": "https://..."
}
```

## Supabase Storage

App dung bucket `images`. Supabase URL va publishable key mac dinh nam trong `lib/data/providers/supabase_image_storage.dart`, vi vay Run tu IDE khong can them lenh define. `supabase.local.json` da duoc Git ignore va chi dung de override neu can. Publishable key la public client key; khong dua service-role key vao ung dung. Flutter khong tu dong doc `.env`.

Bucket can cho phep upload cua role `anon` qua policy `INSERT`. Hay xem dieu kien thuc te cua policy (folder, duoi file, loai MIME); ten policy chi la nhan mo ta. Code upload file vao root cua bucket va giu duoi ten file goc. Bucket public de app hien thi URL anh.

Chay Web voi config local:

```powershell
flutter run -d chrome
```

Build Web:

```powershell
flutter build web
```

## Kiem tra sau khi cau hinh

1. Dang nhap bang tai khoan admin Firebase.
2. Them san pham kem anh; xac nhan file nam trong Supabase Storage bucket `images`.
3. Xac nhan Firestore document co dung bon field: `name`, `price`, `soluong`, `image`.
4. Thu sua, tim kiem, xoa va mo tren Web/Android.

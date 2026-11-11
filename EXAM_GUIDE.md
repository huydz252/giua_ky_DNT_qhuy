# Huong dan project theo de thi quan ly san pham

## Pham vi

- Admin login/logout: Firebase Authentication Email/Password.
- CRUD va search san pham: Cloud Firestore collection `products`.
- Anh san pham: chon tu thiet bi/Web, upload Supabase Storage bucket `images`, ghi URL vao Firestore.
- Cac field Firestore dung theo de: `name`, `price`, `soluong`, `image`. Khong ghi them field `id`; ID la document ID.
- Ung dung chay Web va Android.

## Lien ket cac thanh phan

1. `lib/domain/models/product.dart`: model doc lap SDK va mapping dung bon field.
2. `lib/domain/repositories/product_repository.dart`: contract CRUD/search.
3. `lib/data/repositories/firestore_product_repository.dart`: Firestore stream, add, update, delete, search.
4. `lib/data/repositories/firebase_auth_repository.dart`: Firebase email/password login/logout/session.
5. `lib/data/providers/supabase_image_storage.dart`: upload bytes va tao public URL.
6. `lib/presentation/pages/product_list_page.dart`: hien thi StreamBuilder, search, thao tac CRUD.
7. `lib/presentation/widgets/product_form_dialog.dart`: form them/sua, validate name/price/soluong va chon anh.
8. `lib/presentation/pages/product_detail_page.dart`: xem anh, ten, gia, so luong.
9. `firestore.rules`: gioi han doc theo tai khoan admin va chi chap nhan dung field trong de.

## Chay ung dung

```powershell
flutter pub get
flutter run -d chrome
```

Tren Android, xem device ID bang `flutter devices`, sau do chay:

```powershell
flutter run -d <device-id>
```

## Doi backend theo de moi

Giu UI dung `ProductRepository`. Tao implementation rieng cho backend moi, mapping document/row vao `Product`, va chi thay implementation duoc inject trong `lib/data/providers/app_provider.dart`. Neu de yeu cau doi field, cap nhat `Product`, form, list/detail va Firestore Rules cung luc.

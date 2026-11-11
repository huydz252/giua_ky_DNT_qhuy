# Bao cao bai thi: Quan ly san pham

## 1. Muc tieu

Xay dung ung dung Flutter cho phan he admin, co dang nhap, hien thi, them, sua, xoa san pham va chay tren Web. App su dung Firebase Authentication, Cloud Firestore va Supabase Storage.

## 2. Schema co so du lieu

Firestore collection: `products`.

| Field | Kieu | Mo ta |
|---|---|---|
| `name` | String | Ten san pham |
| `price` | Number | Gia, khong am |
| `soluong` | Integer | So luong, khong am |
| `image` | String | Public URL anh tu Supabase Storage |

Firestore document ID duoc Firestore tao tu dong va khong duoc ghi thanh field.

## 3. Cong nghe va dependencies chinh

- `firebase_core`, `firebase_auth`: khoi tao Firebase va dang nhap admin.
- `cloud_firestore`: doc stream va CRUD san pham.
- `supabase_flutter`: upload anh vao Storage.
- `image_picker`: chon anh tren Web/Android.

## 4. Cau truc va luong du lieu

Form validate du lieu, chon anh va upload bytes len Supabase Storage. URL tra ve duoc gan vao `image`; `ProductRepository` ghi bon field vao Firestore. Danh sach doc snapshots bang StreamBuilder de tu cap nhat sau CRUD.

## 5. Lenh cai dat va chay

```powershell
flutter pub get
flutter run -d chrome
flutter analyze
flutter build web
flutter build apk --debug
```

## 6. Anh minh hoa va ket qua chay

Chen anh chup that sau khi kiem tra cloud CRUD:

- [ ] Man hinh dang nhap admin.
- [ ] Danh sach san pham tren Web.
- [ ] Form them/sua san pham.
- [ ] Chi tiet san pham va anh.
- [ ] Firestore collection `products` voi dung bon field.
- [ ] Supabase bucket `images` sau upload.
- [ ] Man hinh san pham tren Android.

## 7. CSDL nop kem

Sau khi tao du lieu demo, export collection `products` thanh JSON va dat file vao thu muc `database/`. Kiem tra moi object chi co `name`, `price`, `soluong`, `image`.

## 8. Lien ket nop bai

- GitHub source: [dien link repository]
- Video demo: [dien link video]

## 9. Trang thai kiem tra

Cap nhat ket qua CRUD cloud, test Web/Android, analyzer va build sau khi hoan tat kiem tra tren Firebase/Supabase.

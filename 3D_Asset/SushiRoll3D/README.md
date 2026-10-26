# Sushi Roll 3D — bộ asset học model và màu sắc

Bộ art được chọn từ bản **Sushi Roll 3D 1.8.57** đã export/phục hồi, không phải source project hoặc file authoring gốc của tác giả.

## Có gì trong gói

- **1.074 mesh Unity `.asset`**: 438 từ bản AssetRipper và 636 đã phục hồi, kiểm chứng với dữ liệu giải mã từ XAPK.
- **644 material**, **382 texture PNG**, giữ `.meta` và GUID.
- **33 shader export là dummy**: giữ liên kết và tham số, **không bảo đảm màu/ánh sáng giống game gốc**.
- **141 prefab không chứa `MonoBehaviour`**, được chọn bằng kiểm tra dependency; không đưa các prefab gameplay/SDK chưa đầy đủ vào gói.
- `mesh-material-map.json`: tra các cách mesh được gán material trong prefab nguồn. Một mesh có thể có nhiều cách gán; không tự chọn một material duy nhất.
- `manifest.json` và `copy-verification.json`: danh sách, kích thước, SHA-256 và kết quả kiểm tra sao chép.

## Dùng trong Unity

Chép nội dung `Assets/` của gói vào một thư mục riêng, ví dụ `Assets/Study/SushiRoll3D/`, trong project học tập. **Giữ nguyên các file `.meta`** để liên kết mesh/material/texture hoạt động.

Không import đồng thời bộ này và toàn bộ project Sushi3D-Recovery vào cùng project: chúng dùng lại các GUID gốc. Model ở dạng native Unity `.asset`; đây **không phải FBX/OBJ/BLEND** để mở trực tiếp trong Blender hoặc trình xem 3D của Git.

## Giới hạn cần biết

- Đây không phải toàn bộ model của game. Các mesh chưa phục hồi không được tạo giả để lấp chỗ trống.
- Material của font LiberationSans có một texture atlas bị thiếu sẵn từ bản export; không có texture thay thế được bịa ra.
- Material/texture được giữ từ bản export, nhưng shader chưa khôi phục. Dùng chúng để khảo sát thông số và texture, không coi ảnh render hiện tại là chuẩn màu game gốc.
- Không kèm C#, DLL/SDK, dữ liệu SDK, code gameplay, scene demo, XAPK, native binary hoặc cache Unity.
- File material `em_dead.mat` theo trạng thái project recovery, có thay đổi serialization so với export ban đầu; không phải mọi file trong gói đều được tuyên bố byte-identical với XAPK.

## Git / cloud

Gói đã được chép vào thư mục đích, **chưa được stage, commit hoặc push**. `.gitattributes` cục bộ giữ nguyên byte của asset để SHA-256 vẫn có thể đối chiếu sau clone; không cài hoặc ép sử dụng Git LFS.

Gói không cung cấp license phân phối asset game và không chuyển quyền sở hữu. Kiểm tra quyền sử dụng/phân phối của bạn trước khi công khai hoặc chia sẻ lên cloud; mục đích học tập không tự tạo quyền phân phối lại.

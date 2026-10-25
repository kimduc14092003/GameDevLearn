# Bản lưu trao đổi — UnityLearning

- Ngày: 2026-09-11 (Asia/Bangkok).
- Chủ đề: nghiên cứu, nhận xét hai tài liệu ôn tập Unity và lưu trao đổi để đồng bộ bằng Git.
- Thư mục tại máy xuất: `D:\Project\SyncComputer\UnityLearning`.
- Phạm vi: yêu cầu của người dùng, các cập nhật tiến độ và phản hồi đánh giá của trợ lý đến yêu cầu lưu chat. Không bao gồm log công cụ hoặc trao đổi nội bộ giữa các tác nhân.
- Nội dung phản hồi được giữ lại; liên kết file được đổi sang đường dẫn tương đối và số dòng được ghi ở nhãn để thuận tiện đọc trên GitHub/máy khác.

## 1. Người dùng — Yêu cầu nghiên cứu

> D:\Project\SyncComputer\UnityLearning nghiên cứu, nhận xét các file ở đây nhé

## 2. Trợ lý — Cập nhật tiến độ

Mình sẽ xem cấu trúc và nội dung trong `UnityLearning`, rồi nhận xét về độ chính xác kỹ thuật, cách tổ chức và tính hữu ích khi học hoặc áp dụng vào Unity mobile.

Thư mục có 2 tài liệu ôn phỏng vấn Junior và Middle, tổng cộng gần 5.000 dòng với 152 khối code C#. Nội dung khá rộng; mình đang kiểm tra kỹ các ví dụ được gọi là “production-ready”, nhất là quản lý vòng đời object, async, bộ nhớ và save/load.

Mình đã thấy vài lỗi đáng sửa trước khi dùng tài liệu để học thuộc hoặc lấy code: phần `Awake` nhầm GameObject inactive với component disabled; ví dụ save “atomic” có khoảng trống làm mất file save chính; luồng tải scene có thể mắc kẹt khi bị cancel. Mình đang đối chiếu tài liệu chính thức để phân biệt lỗi chắc chắn với khác biệt theo phiên bản.

Điểm mạnh của bộ tài liệu là ví dụ gần công việc thực tế và có bàn về trade-off. Điểm yếu lớn nhất là nhiều ví dụ chưa xử lý tình huống lỗi: gọi load trùng, cancel giữa chừng, object bị hủy hoặc ghi save thất bại. Phần tối ưu cũng cần diễn đạt bớt tuyệt đối và bổ sung cách đo trên thiết bị thật.

## 3. Trợ lý — Nhận xét hoàn chỉnh

Mình đã đọc cả hai file và đối chiếu các điểm kỹ thuật quan trọng với tài liệu chính thức. **Bộ tài liệu có bố cục tốt để ôn phỏng vấn, nhưng cần sửa một số kiến thức nền và ví dụ trước khi dùng làm code mẫu cho production.**

| File | Quy mô | Nhận xét |
|---|---:|---|
| [Junior](Tai_Lieu_On_Tap_Unity_Junior.md) | 2.507 dòng | Bao phủ nền tảng rộng, dễ tra cứu; còn lỗi về lifecycle và cách tạo MonoBehaviour. |
| [Middle](Tai_Lieu_On_Tap_Unity_Middle.md) | 2.462 dòng | Chọn chủ đề phù hợp: architecture, profiling, async, save/load; nhiều ví dụ mới xử lý trường hợp thành công. |

Điểm tốt là tài liệu dùng ví dụ gameplay gần thực tế, có giải thích trade-off, đề cập encapsulation, composition, ScriptableObject và giảm GC Alloc. Phần Middle cũng định hướng đúng việc tách logic khỏi MonoBehaviour và đo performance trước khi tối ưu.

Các vấn đề mình ưu tiên sửa:

1. **Save “atomic” vẫn có thể làm mất save chính.**  
   Tại [Middle:1907](Tai_Lieu_On_Tap_Unity_Middle.md), code ghi file tạm → **xóa save cũ** → move file tạm. Nếu app bị kill hoặc move thất bại sau bước xóa, lần load sau sẽ coi như chưa có save. Cần cơ chế thay thế file phù hợp nền tảng, giữ backup và phục hồi khi khởi động; có thể xem xét [`File.Replace`](https://learn.microsoft.com/en-us/dotnet/api/system.io.file.replace).

2. **Cancel khi tải scene có thể làm kẹt các operation tiếp theo.**  
   Tại [Middle:1684](Tai_Lieu_On_Tap_Unity_Middle.md), `allowSceneActivation = false`, nhưng token có thể bị hủy trước khi code bật lại activation. Hàm thoát trong khi native operation vẫn chờ. Cần xác định cách hoàn tất operation khi người gọi ngừng chờ, đồng thời cleanup loading UI. Unity xác nhận trạng thái này có thể chặn hàng đợi `AsyncOperation`. [Nguồn Unity](https://docs.unity.cn/2022.2/Documentation/ScriptReference/AsyncOperation-allowSceneActivation.html).

3. **Giải thích `Awake` với GameObject inactive bị sai và lặp lại trong đáp án phỏng vấn.**  
   Tại [Junior:805](Tai_Lieu_On_Tap_Unity_Junior.md), tài liệu nói `Awake` vẫn chạy khi GameObject inactive. Cần phân biệt: GameObject chưa active trong hierarchy thì `Awake` chờ đến khi active; **component disabled trên GameObject active** vẫn có thể chạy `Awake`. Nhầm điểm này dễ gây lỗi khởi tạo trong pooling. [Nguồn Unity](https://docs.unity3d.com/6000.0/Documentation/ScriptReference/MonoBehaviour.Awake.html).

4. **Ví dụ OOP tạo MonoBehaviour bằng `new`.**  
   Tại [Junior:382](Tai_Lieu_On_Tap_Unity_Junior.md), `Goblin`, `Archer`, `Boss` kế thừa `MonoBehaviour` nhưng được tạo bằng `new`; ví dụ `Pistol` cũng tương tự. Những object này không có component lifecycle hợp lệ. Nên dùng class C# thuần để dạy OOP, hoặc tạo component bằng `AddComponent<T>()`/Instantiate prefab. [Đối chiếu inspection của JetBrains](https://www.jetbrains.com/help/inspectopedia/Unity.IncorrectMonoBehaviourInstantiation.html).

5. **Bullet pool chưa truyền tham chiếu pool vào bullet.**  
   Tại [Junior:1265](Tai_Lieu_On_Tap_Unity_Junior.md), Bullet gọi `_pool.Return(...)`, nhưng các nhánh tạo instance không gán `_pool`. Với prefab asset và pool trong scene như ví dụ, đoạn này có thể gây `NullReferenceException`. Cần `Initialize(pool)` cho cả prewarm lẫn nhánh mở rộng, trước khi kích hoạt bullet.

6. **Cache Addressables trả kết quả khi asset vẫn đang tải.**  
   Tại [Middle:1300](Tai_Lieu_On_Tap_Unity_Middle.md), handle được đưa vào dictionary trước `await`. Nếu hai nơi gọi cùng key, lần thứ hai trả ngay `existing.Result`, có thể là `null`. Cần cùng chờ operation đang chạy, xử lý trạng thái thất bại và quy định rõ ai giữ/release handle. [Nguồn Unity](https://docs.unity3d.com/Packages/com.unity.addressables@1.21/manual/AddressableAssetsAsyncOperationHandle.html).

7. **Ví dụ null-check giữa hai tài liệu chưa nhất quán.**  
   [Middle:282](Tai_Lieu_On_Tap_Unity_Middle.md) khuyên `player is null`/`is not null` nhưng thiếu lưu ý cho Unity object. Nếu `player` là MonoBehaviour đã bị destroy, kiểm tra này không gọi toán tử `==` của Unity. Nên dùng `player == null` hoặc `if (!player)` khi cần kiểm tra object Unity còn tồn tại. Junior đã có cảnh báo tương tự cho `?.` và `??`. [C# patterns](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/patterns), [Unity Object](https://docs.unity3d.com/6000.0/Documentation/ScriptReference/Object.html).

Phần performance cần chỉnh cách diễn đạt ở hai điểm đáng chú ý:

- **“Struct nằm trên stack, không GC” quá tuyệt đối** tại [Middle:923](Tai_Lieu_On_Tap_Unity_Middle.md). Struct có thể nằm bên trong object/array trên heap và có thể bị boxing. Nên dạy value semantics trước, rồi giải thích allocation theo ngữ cảnh. [Microsoft ValueType](https://learn.microsoft.com/en-us/dotnet/api/system.valuetype).
- **SRP Batcher không trực tiếp gộp số draw call** như cách xếp trong mục “Cách giảm” tại [Middle:998](Tai_Lieu_On_Tap_Unity_Middle.md) dễ khiến người học hiểu. Nó chủ yếu giảm chi phí CPU và thay đổi render state giữa các draw call. [Unity SRP Batcher](https://docs.unity3d.com/6000.0/Documentation/Manual/SRPBatcher.html).

Để bộ tài liệu hữu ích hơn với hướng Unity mobile của bạn, mình đề xuất:

- **Junior:** học Coroutine trước UniTask; bổ sung bài thực hành nhỏ về lifecycle, serialization, touch input, UI scaling và safe area.
- **Middle:** thêm một feature hoàn chỉnh có xử lý cancel, retry, gọi trùng, dispose và object bị destroy; kèm bài kiểm tra các tình huống lỗi.
- **Performance:** thêm bài đo trước/sau trên thiết bị thật, gồm CPU/GPU frame time, GC Alloc và memory. Các mốc draw call/triangle hiện tại chỉ nên dùng làm tham khảo. [Hướng dẫn profiling của Unity](https://docs.unity3d.com/2022.2/Documentation/Manual/profiler-profiling-applications.html).
- **Cấu trúc tài liệu:** ghi rõ phiên bản Unity/package, phân biệt snippet minh họa với sample chạy được, thêm nguồn chính thức và mục lục có liên kết.
- **Save cho Hybrid-Casual/Fin-Game:** triển khai thực tế migration, validation, backup/recovery và kiểm tra tính toàn vẹn dữ liệu; phần hiện tại mới liệt kê các yêu cầu này.

Mình chưa chỉnh sửa file. Đây là review tĩnh có đối chiếu nguồn; thư mục hiện chỉ có Markdown nên các snippet chưa được compile hoặc chạy trong Unity.

## 4. Người dùng — Yêu cầu lưu chat để đồng bộ

> Tôi muốn đồng bộ đoạn chat này vào thư mục "D:\Project\SyncComputer\UnityLearning" để đẩy lên git đồng bộ với các máy tính khác được không

## 5. Trợ lý — Tiến hành lưu

Mình sẽ lưu nội dung trao đổi và nhận xét vào file Markdown trong `UnityLearning`, để bạn có thể đưa lên Git và đọc tiếp trên máy khác.

## Ghi chú của bản lưu

File này cùng [README.md](README.md) được tạo theo yêu cầu ở mục 4. Các liên kết nội bộ là tương đối, phù hợp với việc clone repository sang đường dẫn khác. Hai tài liệu Junior/Middle gốc chưa được sửa theo các nhận xét. Bản lưu không tự cập nhật khi có tin nhắn mới; có thể bổ sung các lượt trao đổi tiếp theo vào cuối file.

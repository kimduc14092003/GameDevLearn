# UnityLearning

Tài liệu ôn tập Unity và bản lưu trao đổi đánh giá, dùng Git để đồng bộ giữa các máy.

## Nội dung

| File | Mục đích |
|---|---|
| [Tai_Lieu_On_Tap_Unity_Junior.md](Tai_Lieu_On_Tap_Unity_Junior.md) | Tài liệu ôn phỏng vấn Junior Unity Developer |
| [Tai_Lieu_On_Tap_Unity_Middle.md](Tai_Lieu_On_Tap_Unity_Middle.md) | Tài liệu ôn phỏng vấn Middle Unity Developer |
| [CHAT_LOG.md](CHAT_LOG.md) | Bản lưu trao đổi ngày 2026-09-11, gồm nhận xét kỹ thuật và nguồn đối chiếu |

## Trạng thái tại ngày 2026-09-11

- Đã review tĩnh hai tài liệu; chưa compile hoặc chạy các snippet trong Unity.
- Hai tài liệu gốc chưa được chỉnh sửa theo nhận xét.
- Các vấn đề ưu tiên: atomic save, scene-load cancellation, Awake với inactive GameObject, tạo MonoBehaviour bằng `new`, truyền pool vào Bullet, Addressables concurrent loading và Unity null semantics.
- Cần bổ sung version baseline, sample chạy được và bài đo performance trên thiết bị thật.

## Tiếp tục trên máy khác

Sau khi clone hoặc pull repository, mở thư mục `UnityLearning` và yêu cầu trợ lý:

> Đọc README.md và CHAT_LOG.md trong thư mục UnityLearning, sau đó đọc hai tài liệu Junior/Middle khi cần. Dùng các nội dung đó làm bối cảnh để tiếp tục trao đổi. Những nhận xét đã lưu là kết quả review tĩnh, chưa phải các thay đổi đã thực hiện.

Ưu tiên của người dùng: trao đổi bằng tiếng Việt; Clean Code, encapsulation, hiệu năng Unity mobile và hạn chế GC Alloc trong hot path; ưu tiên ScriptableObject cho dữ liệu. Khi project có Odin Inspector, ưu tiên Odin attributes khi phù hợp. Với save/IAP/Fin-Game, chú ý bảo vệ dữ liệu và Save/Load bền vững.

## Đưa lên Git

Chạy tại thư mục gốc repository. Các lệnh này được ghi để tham khảo, chưa được thực thi khi xuất bản chat:

```powershell
git add -- UnityLearning/README.md UnityLearning/CHAT_LOG.md UnityLearning/Tai_Lieu_On_Tap_Unity_Junior.md UnityLearning/Tai_Lieu_On_Tap_Unity_Middle.md
git diff --cached --stat
git commit -m "docs: add Unity learning materials and chat review"
git push
```

Các liên kết nội bộ dùng đường dẫn tương đối để hoạt động khi repository nằm ở vị trí khác trên máy khác. Số dòng trong nhận xét tham chiếu phiên bản tài liệu tại thời điểm review; chúng có thể thay đổi sau khi sửa tài liệu.

`CHAT_LOG.md` là bản lưu tại thời điểm xuất, không tự cập nhật theo các tin nhắn mới. Khi cần lưu thêm trao đổi, cập nhật file rồi commit/push tiếp. Việc tạo hai file Markdown này chưa cấu hình cơ chế nhập hoặc đồng bộ lịch sử task của ứng dụng Codex.

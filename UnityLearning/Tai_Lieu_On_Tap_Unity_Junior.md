# TÀI LIỆU ÔN TẬP PHỎNG VẤN — JUNIOR UNITY DEVELOPER

> Tài liệu nền tảng cho vị trí Junior Unity Developer: C# cơ bản, Unity core concepts, MonoBehaviour, Physics, UI, và 3 thư viện quan trọng thực chiến — DOTween, UniTask, Addressables.  
> Mục tiêu: nắm vững nền tảng + viết được code thực tế, không sa đà lý thuyết quá sâu.

---

## MỤC LỤC

| # | Chủ đề | Mức độ |
|---|---|---|
| 1 | C# Fundamentals cho Unity | Phải nắm vững |
| 2 | OOP & SOLID | Phải nắm vững |
| 3 | Unity Core Concepts | Phải nắm vững |
| 4 | MonoBehaviour Lifecycle | Phải nắm vững |
| 5 | Input & Movement | Phải nắm vững |
| 6 | Physics cơ bản | Quan trọng |
| 7 | Prefab & Instantiate & Object Pooling | Quan trọng |
| 8 | ScriptableObject | Quan trọng |
| 9 | UI cơ bản (uGUI) | Quan trọng |
| 10 | DOTween — Animation bằng code | Thực chiến |
| 11 | UniTask — Async hiện đại | Thực chiến |
| 12 | Coroutine | Cần biết |
| 13 | Addressables (Junior level) | Nên biết |
| 14 | Debug & Lỗi thường gặp | Phải nắm vững |
| 15 | Câu hỏi Phỏng vấn Mẫu | Ôn tập |

---

# 1. C# FUNDAMENTALS CHO UNITY

> Phỏng vấn Junior gần như luôn có câu hỏi C# cơ bản. Đây là phần nền tảng quan trọng nhất.

## 1.1. Value Type vs Reference Type

Đây là câu hỏi phỏng vấn **kinh điển nhất** cho Junior.

| | Value Type | Reference Type |
|---|---|---|
| Lưu ở đâu | Stack (thường) | Heap (data) + Stack (pointer) |
| Khi gán/truyền | **Copy giá trị** | **Copy tham chiếu** (cùng trỏ 1 object) |
| Ví dụ | `int`, `float`, `bool`, `struct`, `enum`, `Vector3` | `class`, `string`, `array`, `List`, `GameObject` |

```csharp
// Value Type — copy giá trị, độc lập
int a = 5;
int b = a;   // b là bản sao của a
b = 10;
// a vẫn = 5, b = 10

// Reference Type — copy tham chiếu, cùng trỏ 1 object
List<int> list1 = new List<int> { 1, 2, 3 };
List<int> list2 = list1;  // list2 trỏ cùng object với list1
list2.Add(4);
// list1 BÂY GIỜ cũng có 4 phần tử! Vì cùng 1 object
```

**Cạm bẫy Vector3 (Value Type) trong Unity:**

```csharp
// SAI — Vector3 là struct (value type), không thể sửa trực tiếp component
transform.position.x = 5f; // COMPILE ERROR!

// ĐÚNG — phải gán cả Vector3 mới
Vector3 pos = transform.position;
pos.x = 5f;
transform.position = pos;

// Hoặc viết gọn
transform.position = new Vector3(5f, transform.position.y, transform.position.z);
```

## 1.2. Class vs Struct

```csharp
// Class — reference type
public class EnemyClass
{
    public int hp;
}

// Struct — value type
public struct EnemyStruct
{
    public int hp;
}

// Demo khác biệt
EnemyClass c1 = new EnemyClass { hp = 100 };
EnemyClass c2 = c1;  // Copy reference
c2.hp = 50;
// c1.hp BÂY GIỜ = 50 (cùng object)

EnemyStruct s1 = new EnemyStruct { hp = 100 };
EnemyStruct s2 = s1;  // Copy value
s2.hp = 50;
// s1.hp VẪN = 100 (object độc lập)
```

**Khi nào dùng struct:**
- Dữ liệu nhỏ, ngắn hạn (Vector, điểm số, config nhỏ).
- Không cần kế thừa.
- Muốn tránh garbage collection (struct trên stack).

**Khi nào dùng class:**
- Dữ liệu phức tạp, cần kế thừa.
- Object có vòng đời dài.
- Hầu hết các trường hợp trong game logic.

## 1.3. Các kiểu Collection thường dùng

| Collection | Dùng khi | Đặc điểm |
|---|---|---|
| `Array` (`int[]`) | Kích thước cố định, biết trước | Nhanh nhất, không resize |
| `List<T>` | Cần thêm/xóa động | Phổ biến nhất trong game |
| `Dictionary<K,V>` | Lookup theo key | Tìm kiếm O(1) |
| `HashSet<T>` | Tập hợp không trùng lặp | Check tồn tại O(1) |
| `Queue<T>` | FIFO (vào trước ra trước) | Hàng đợi |
| `Stack<T>` | LIFO (vào sau ra trước) | Undo, history |

```csharp
// List — phổ biến nhất
List<Enemy> enemies = new List<Enemy>();
enemies.Add(newEnemy);
enemies.Remove(deadEnemy);
enemies.Count;                    // Số phần tử
enemies[0];                       // Truy cập index
bool has = enemies.Contains(e);   // Kiểm tra tồn tại

// Dictionary — lookup nhanh theo key
Dictionary<string, int> scores = new Dictionary<string, int>();
scores["player1"] = 100;
scores["player2"] = 85;
if (scores.TryGetValue("player1", out int score))
    Debug.Log($"Score: {score}");

// HashSet — tập hợp không trùng
HashSet<int> collectedCoins = new HashSet<int>();
collectedCoins.Add(5);
collectedCoins.Add(5);   // Không thêm — đã tồn tại
// collectedCoins.Count == 1
```

## 1.4. Delegate, Action, Event

Cơ chế cho phép "gọi hàm thông qua biến" — nền tảng của hệ thống event trong game.

```csharp
// Action — delegate có sẵn, không trả về giá trị
Action onGameOver;
onGameOver += ShowGameOverScreen;   // Đăng ký
onGameOver += SaveHighScore;        // Có thể đăng ký nhiều
onGameOver?.Invoke();               // Gọi tất cả (?. để tránh null)

// Action với tham số
Action<int> onScoreChanged;
onScoreChanged += (newScore) => Debug.Log($"Score: {newScore}");
onScoreChanged?.Invoke(100);

// Func — delegate CÓ trả về giá trị
Func<int, int, int> add = (a, b) => a + b;
int result = add(3, 5);  // result = 8

// Event — Action nhưng an toàn hơn (chỉ class chứa nó mới Invoke được)
public class GameManager : MonoBehaviour
{
    public event Action OnPlayerDied;

    void KillPlayer()
    {
        OnPlayerDied?.Invoke();  // Chỉ GameManager mới gọi được
    }
}
```

**Ứng dụng thực tế — Decoupling (giảm phụ thuộc):**

```csharp
// PlayerHealth không cần biết UI, Audio, Analytics tồn tại
public class PlayerHealth : MonoBehaviour
{
    public event Action<int> OnHpChanged;

    int _hp = 100;

    public void TakeDamage(int dmg)
    {
        _hp -= dmg;
        OnHpChanged?.Invoke(_hp);  // Thông báo cho bất kỳ ai quan tâm
    }
}

// UI tự đăng ký lắng nghe
public class HealthBar : MonoBehaviour
{
    [SerializeField] PlayerHealth _player;

    void OnEnable()  => _player.OnHpChanged += UpdateBar;
    void OnDisable() => _player.OnHpChanged -= UpdateBar;  // QUAN TRỌNG: hủy đăng ký

    void UpdateBar(int hp) => _slider.value = hp / 100f;
}
```

> **Quy tắc vàng:** Đăng ký event ở `OnEnable`, hủy đăng ký ở `OnDisable`. Quên hủy đăng ký → **memory leak** + lỗi gọi vào object đã bị Destroy.

## 1.5. Properties (get/set)

```csharp
public class Player
{
    // Auto-property
    public int Level { get; set; }

    // Read-only từ bên ngoài, write từ bên trong
    public int Hp { get; private set; }

    // Property với logic
    private int _gold;
    public int Gold
    {
        get => _gold;
        set
        {
            _gold = Mathf.Max(0, value);  // Không cho âm
            OnGoldChanged?.Invoke(_gold);
        }
    }

    // Computed property — tính toán mỗi lần get
    public bool IsAlive => Hp > 0;
}
```

## 1.6. Namespace & using

```csharp
using UnityEngine;       // Engine core
using UnityEngine.UI;    // uGUI (Button, Text, Image)
using System.Collections;          // IEnumerator (Coroutine)
using System.Collections.Generic;  // List, Dictionary
using TMPro;             // TextMeshPro

namespace MyGame.Player  // Tổ chức code theo namespace
{
    public class PlayerController : MonoBehaviour { }
}
```


---

# 2. OOP & SOLID

> OOP (Lập trình hướng đối tượng) là nền tảng của C# và gần như **luôn được hỏi** ở phỏng vấn Junior. SOLID là 5 nguyên tắc thiết kế — ở mức Junior chỉ cần hiểu ý nghĩa cơ bản và cho được ví dụ đơn giản.

## 2.1. 4 Trụ cột của OOP

OOP có 4 đặc tính cốt lõi: **Encapsulation, Inheritance, Polymorphism, Abstraction**.

---

## 2.2. Encapsulation (Đóng gói)

**Ý nghĩa:** Giấu dữ liệu nội bộ, chỉ cho truy cập qua method/property công khai. Bảo vệ dữ liệu khỏi bị sửa sai.

```csharp
// SAI — public field, ai cũng sửa được, không kiểm soát
public class PlayerBad
{
    public int hp;  // Bất kỳ ai cũng có thể set hp = -999 hoặc hp = 99999
}

// ĐÚNG — đóng gói, kiểm soát truy cập
public class Player
{
    private int _hp = 100;          // Giấu field
    private const int MAX_HP = 100;

    public int Hp => _hp;           // Chỉ đọc từ ngoài

    public void TakeDamage(int dmg)
    {
        _hp = Mathf.Max(0, _hp - dmg);  // Kiểm soát: không cho âm
    }

    public void Heal(int amount)
    {
        _hp = Mathf.Min(MAX_HP, _hp + amount);  // Kiểm soát: không vượt max
    }
}
```

**Access Modifiers (mức truy cập):**

| Modifier | Truy cập từ đâu |
|---|---|
| `public` | Mọi nơi |
| `private` | Chỉ trong class này (mặc định của field) |
| `protected` | Trong class này và class con (kế thừa) |
| `internal` | Trong cùng assembly (project) |

> **Lợi ích:** Người dùng class không cần biết bên trong hoạt động thế nào, chỉ cần gọi method. Sửa nội bộ không ảnh hưởng code bên ngoài.

---

## 2.3. Inheritance (Kế thừa)

**Ý nghĩa:** Class con kế thừa thuộc tính và method từ class cha, tái sử dụng code.

```csharp
// Class cha (base class)
public class Enemy : MonoBehaviour
{
    protected int hp = 100;
    protected float speed = 3f;

    public virtual void Attack()  // virtual = cho phép con override
    {
        Debug.Log("Enemy tấn công cơ bản");
    }

    public void TakeDamage(int dmg)  // Method dùng chung cho mọi enemy
    {
        hp -= dmg;
        if (hp <= 0) Die();
    }

    protected void Die() => Destroy(gameObject);
}

// Class con — kế thừa toàn bộ từ Enemy bằng dấu " : "
public class Goblin : Enemy
{
    // Tự động có hp, speed, Attack(), TakeDamage(), Die()

    public override void Attack()  // Ghi đè hành vi Attack
    {
        Debug.Log("Goblin chém kiếm!");
    }
}

public class Archer : Enemy
{
    public override void Attack()
    {
        Debug.Log("Archer bắn cung!");
    }
}
```

**Từ khóa quan trọng:**

```csharp
public class Boss : Enemy
{
    public Boss()
    {
        hp = 1000;   // Truy cập protected field của cha
    }

    public override void Attack()
    {
        base.Attack();  // Gọi method của CHA trước
        Debug.Log("Boss thêm đòn đặc biệt!");
    }
}
```

> **Lưu ý:** Trong Unity ưu tiên **Composition over Inheritance** — ghép Component thay vì kế thừa sâu. Kế thừa quá nhiều tầng (Boss → Enemy → Character → Entity → ...) gây khó bảo trì. Junior nên hiểu kế thừa nhưng đừng lạm dụng.

---

## 2.4. Polymorphism (Đa hình)

**Ý nghĩa:** Cùng một lời gọi method nhưng cho kết quả khác nhau tùy object thực tế. "Nhiều hình dạng".

```csharp
// Nhờ override, cùng gọi Attack() nhưng mỗi enemy hành xử khác nhau
List<Enemy> enemies = new List<Enemy>
{
    new Goblin(),
    new Archer(),
    new Boss()
};

foreach (Enemy enemy in enemies)
{
    enemy.Attack();
    // Goblin → "Goblin chém kiếm!"
    // Archer → "Archer bắn cung!"
    // Boss   → "Boss thêm đòn đặc biệt!"
    // Cùng dòng code, kết quả khác nhau → ĐA HÌNH
}
```

**virtual / override / abstract:**

```csharp
public class Animal
{
    // virtual — có implementation mặc định, con CÓ THỂ override
    public virtual void MakeSound() => Debug.Log("Some sound");
}

public class Dog : Animal
{
    public override void MakeSound() => Debug.Log("Woof");  // override
}

public class Cat : Animal
{
    public override void MakeSound() => Debug.Log("Meow");
}

// Không override → dùng mặc định của cha
public class Fish : Animal { }  // MakeSound() → "Some sound"
```

> **Lợi ích đa hình:** Viết code tổng quát xử lý nhiều loại object. Thêm `Slime : Enemy` mới chỉ cần override Attack(), không sửa code vòng lặp foreach.

---

## 2.5. Abstraction (Trừu tượng)

**Ý nghĩa:** Chỉ phơi bày những gì cần thiết, ẩn chi tiết phức tạp. Dùng **abstract class** và **interface**.

**Abstract class — class không thể tạo instance trực tiếp:**

```csharp
// abstract = bản thiết kế, không thể new trực tiếp
public abstract class Weapon : MonoBehaviour
{
    public int damage;

    // abstract method — KHÔNG có body, con BẮT BUỘC phải implement
    public abstract void Fire();

    // method thường — dùng chung
    public void Reload() => Debug.Log("Reloading...");
}

public class Pistol : Weapon
{
    public override void Fire()  // BẮT BUỘC implement
    {
        Debug.Log("Bang!");
    }
}

// Weapon w = new Weapon();  // LỖI! Không thể tạo abstract class
Weapon w = new Pistol();     // OK
```

**Interface — "hợp đồng" chỉ định nghĩa method, không có implementation:**

```csharp
// Interface — chỉ khai báo "có gì", không nói "làm thế nào"
public interface IDamageable
{
    void TakeDamage(int amount);  // Không body
}

public interface IHealable
{
    void Heal(int amount);
}

// Một class có thể implement NHIỀU interface
public class Player : MonoBehaviour, IDamageable, IHealable
{
    public void TakeDamage(int amount) => Debug.Log($"Mất {amount} máu");
    public void Heal(int amount) => Debug.Log($"Hồi {amount} máu");
}

public class Wall : MonoBehaviour, IDamageable  // Chỉ implement cái cần
{
    public void TakeDamage(int amount) => Debug.Log("Tường nứt");
}
```

**Sử dụng interface để xử lý tổng quát:**

```csharp
// Bắn trúng bất kỳ thứ gì "có thể nhận damage"
void OnHit(GameObject target)
{
    if (target.TryGetComponent<IDamageable>(out var damageable))
        damageable.TakeDamage(10);  // Player, Wall, Enemy... đều xử lý được
}
```

**Abstract class vs Interface — câu hỏi phỏng vấn KINH ĐIỂN:**

| | Abstract Class | Interface |
|---|---|---|
| Có thể chứa code (method body) | Có | Chỉ từ C# 8+, hạn chế |
| Có field/biến | Có | Không (chỉ property) |
| Kế thừa/implement bao nhiêu | **1 abstract class** | **Nhiều interface** |
| Constructor | Có | Không |
| Khi nào dùng | Quan hệ "is-a", chia sẻ code chung | Quan hệ "can-do", nhiều khả năng |

> **Câu trả lời ngắn gọn:** Một class chỉ kế thừa được **1 abstract class** nhưng implement được **nhiều interface**. Abstract class dùng khi có code chung muốn chia sẻ; interface dùng khi chỉ cần định nghĩa "khả năng" mà các class khác nhau tự thực hiện.

---

## 2.6. SOLID — 5 Nguyên tắc Thiết kế

> SOLID giúp code dễ bảo trì, mở rộng. Ở mức Junior chỉ cần hiểu ý nghĩa và cho ví dụ đơn giản — không cần áp dụng quá sâu.

### S — Single Responsibility (Đơn nhiệm)

> Một class chỉ nên làm **một việc**, có một lý do để thay đổi.

```csharp
// SAI — class làm quá nhiều
public class Player : MonoBehaviour
{
    void Update() { /* đọc input */ }
    void Move() { }
    void UpdateHealthUI() { }      // Việc của UI
    void PlaySound() { }            // Việc của Audio
    void SaveToFile() { }           // Việc của Save system
}

// ĐÚNG — tách trách nhiệm
public class PlayerInput : MonoBehaviour { }    // Chỉ input
public class PlayerMovement : MonoBehaviour { } // Chỉ di chuyển
public class PlayerHealthUI : MonoBehaviour { } // Chỉ UI máu
```

### O — Open/Closed (Mở để mở rộng, đóng để sửa đổi)

> Thêm tính năng mới bằng cách **thêm code**, không **sửa code cũ**.

```csharp
// SAI — thêm enemy mới phải sửa hàm này mãi
void Attack(string enemyType)
{
    if (enemyType == "Goblin") { }
    else if (enemyType == "Archer") { }
    // Thêm "Boss" → phải sửa hàm này
}

// ĐÚNG — dùng override (đa hình), thêm class mới không sửa code cũ
abstract class Enemy { public abstract void Attack(); }
class Goblin : Enemy { public override void Attack() { } }
class Boss : Enemy { public override void Attack() { } }  // Thêm mới, không sửa cũ
```

### L — Liskov Substitution (Thay thế Liskov)

> Class con phải thay thế được class cha mà không gây lỗi.

```csharp
// SAI — Penguin kế thừa Bird nhưng không bay được → vi phạm
class Bird { public virtual void Fly() { } }
class Penguin : Bird
{
    public override void Fly() => throw new Exception("Chim cánh cụt không bay!");
}

// ĐÚNG — tách interface phù hợp
interface IFlyable { void Fly(); }
class Sparrow : Bird, IFlyable { public void Fly() { } }
class Penguin : Bird { }  // Không implement IFlyable vì không bay
```

### I — Interface Segregation (Phân tách Interface)

> Nhiều interface nhỏ, chuyên biệt tốt hơn một interface to.

```csharp
// SAI — interface quá to, class buộc implement cả thứ không cần
interface ICharacter
{
    void Attack();
    void Heal();
    void Fly();   // Không phải ai cũng bay
}

// ĐÚNG — tách nhỏ
interface IAttackable { void Attack(); }
interface IHealable { void Heal(); }
interface IFlyable { void Fly(); }
// Class chỉ implement những gì nó cần
```

### D — Dependency Inversion (Đảo ngược phụ thuộc)

> Phụ thuộc vào **interface (trừu tượng)**, không phụ thuộc vào class cụ thể.

```csharp
// SAI — phụ thuộc trực tiếp class cụ thể
public class Player
{
    AudioManager _audio = new AudioManager();  // Gắn cứng
}

// ĐÚNG — phụ thuộc interface, truyền từ ngoài vào
public class Player
{
    IAudioService _audio;
    public Player(IAudioService audio) => _audio = audio;  // Linh hoạt, dễ test
}
```

**Tóm tắt SOLID:**

| Chữ | Tên | Ý nghĩa 1 câu |
|---|---|---|
| **S** | Single Responsibility | 1 class = 1 việc |
| **O** | Open/Closed | Thêm code mới, không sửa code cũ |
| **L** | Liskov Substitution | Class con thay được class cha |
| **I** | Interface Segregation | Interface nhỏ, chuyên biệt |
| **D** | Dependency Inversion | Phụ thuộc interface, không phụ thuộc class cụ thể |

---

## 2.7. Câu hỏi Phỏng vấn về OOP

**Q: 4 trụ cột của OOP là gì?**
> Encapsulation (đóng gói — giấu dữ liệu, truy cập qua method), Inheritance (kế thừa — tái sử dụng code từ class cha), Polymorphism (đa hình — cùng lời gọi cho kết quả khác nhau), Abstraction (trừu tượng — ẩn chi tiết phức tạp qua abstract class/interface).

**Q: Encapsulation để làm gì?**
> Bảo vệ dữ liệu khỏi bị sửa sai bằng cách giấu field (private) và chỉ cho truy cập qua property/method có kiểm soát. Ví dụ: HP chỉ thay đổi qua TakeDamage/Heal, không cho set trực tiếp giá trị âm.

**Q: virtual và override khác nhau gì?**
> virtual đánh dấu method ở class cha cho phép class con ghi đè. override là khi class con thực sự ghi đè method virtual đó. Nhờ vậy có đa hình.

**Q: Abstract class và Interface khác nhau thế nào?**
> Abstract class có thể chứa code chung và field, nhưng chỉ kế thừa được 1. Interface chỉ định nghĩa "khả năng" (method không body), nhưng implement được nhiều. Dùng abstract khi có "is-a" và code chung; dùng interface khi cần "can-do" và đa năng.

**Q: Polymorphism có lợi ích gì trong game?**
> Cho phép xử lý nhiều loại object bằng code tổng quát. Ví dụ: list các Enemy khác nhau, gọi Attack() trên từng cái, mỗi loại tự hành xử riêng. Thêm enemy mới không cần sửa code cũ.

**Q: Tại sao Unity khuyên "Composition over Inheritance"?**
> Vì kế thừa sâu nhiều tầng khó bảo trì và cứng nhắc. Composition (ghép Component) linh hoạt hơn — một GameObject ghép nhiều Component độc lập, dễ thêm/bớt chức năng mà không phá vỡ cấu trúc kế thừa.

**Q: SOLID là gì? (mức Junior)**
> 5 nguyên tắc thiết kế code: Single Responsibility (1 class 1 việc), Open/Closed (mở rộng không sửa cũ), Liskov (con thay được cha), Interface Segregation (interface nhỏ), Dependency Inversion (phụ thuộc interface). Mục tiêu là code dễ bảo trì và mở rộng.
---

# 3. UNITY CORE CONCEPTS

## 3.1. GameObject & Component

Đây là kiến trúc cốt lõi của Unity — **Composition over Inheritance**.

- **GameObject:** Một "container" rỗng. Bản thân không làm gì cả.
- **Component:** Các "mảnh chức năng" gắn vào GameObject (Transform, Rigidbody, script của bạn...).
- Một GameObject = tập hợp nhiều Component.

```csharp
// Lấy component trên cùng GameObject
Rigidbody rb = GetComponent<Rigidbody>();
PlayerHealth health = GetComponent<PlayerHealth>();

// Lấy component trên GameObject con
Animator anim = GetComponentInChildren<Animator>();

// Lấy component trên GameObject cha
Canvas canvas = GetComponentInParent<Canvas>();

// Lấy NHIỀU component cùng loại
Renderer[] renderers = GetComponentsInChildren<Renderer>();

// Thêm component bằng code
var collider = gameObject.AddComponent<BoxCollider>();

// Kiểm tra có component không
if (TryGetComponent<Rigidbody>(out var rigidbody))
    rigidbody.velocity = Vector3.zero;
```

> **Lưu ý hiệu năng:** `GetComponent` khá tốn kém. **Cache** nó ở `Awake`/`Start`, đừng gọi trong `Update`.

```csharp
// SAI — gọi GetComponent mỗi frame
void Update()
{
    GetComponent<Rigidbody>().velocity = Vector3.forward; // Tốn kém!
}

// ĐÚNG — cache một lần
Rigidbody _rb;
void Awake() => _rb = GetComponent<Rigidbody>();
void Update() => _rb.velocity = Vector3.forward;
```

## 3.2. Transform

Component bắt buộc của mọi GameObject — quản lý vị trí, xoay, scale.

```csharp
// Position
transform.position;             // World space (tọa độ tuyệt đối)
transform.localPosition;        // Local space (so với parent)

// Rotation
transform.rotation;             // Quaternion (world)
transform.localRotation;        // Quaternion (local)
transform.eulerAngles;          // Góc Euler (độ) - dễ đọc hơn

// Scale
transform.localScale;           // Tỉ lệ

// Di chuyển
transform.Translate(Vector3.forward * speed * Time.deltaTime);
transform.position += Vector3.up * 2f;

// Xoay
transform.Rotate(0f, 90f, 0f);
transform.rotation = Quaternion.Euler(0f, 180f, 0f);

// Nhìn về phía target
transform.LookAt(targetTransform);

// Hướng của object
transform.forward;   // Hướng "trước" (trục Z xanh)
transform.right;     // Hướng "phải" (trục X đỏ)
transform.up;        // Hướng "lên" (trục Y xanh lá)
```

**Parent-Child (cây phân cấp):**

```csharp
// Đặt parent
childObject.transform.SetParent(parentTransform);

// Đặt parent giữ nguyên world position
childObject.transform.SetParent(parentTransform, worldPositionStays: true);

// Truy cập
transform.parent;                    // Parent
transform.childCount;                // Số con
transform.GetChild(0);               // Con thứ 0
transform.Find("ChildName");         // Tìm con theo tên

// Duyệt tất cả con
foreach (Transform child in transform)
    Debug.Log(child.name);
```

## 3.3. World Space vs Local Space

```
World Space: Tọa độ tuyệt đối trong scene (gốc 0,0,0 của thế giới)
Local Space: Tọa độ tương đối so với parent

Ví dụ:
  Parent ở world position (10, 0, 0)
  Child có localPosition (5, 0, 0)
  → Child world position = (15, 0, 0)
```

## 3.4. Tag & Layer

```csharp
// Tag — phân loại object
if (other.CompareTag("Enemy"))   // Dùng CompareTag, KHÔNG dùng == "Enemy"
    TakeDamage();

// Layer — dùng cho physics, camera culling, raycast
gameObject.layer = LayerMask.NameToLayer("Enemy");

// LayerMask trong Raycast (chỉ hit layer "Ground")
int groundLayer = LayerMask.GetMask("Ground");
if (Physics.Raycast(transform.position, Vector3.down, out var hit, 10f, groundLayer))
    Debug.Log("Hit ground");
```

> Dùng `CompareTag("X")` thay vì `tag == "X"` — nhanh hơn và không sinh garbage.

## 3.5. Prefab

Prefab = "khuôn mẫu" GameObject lưu thành asset, dùng để tạo nhiều bản sao.

```csharp
// Reference prefab qua Inspector
[SerializeField] GameObject enemyPrefab;

// Tạo instance từ prefab
GameObject enemy = Instantiate(enemyPrefab);
GameObject enemy2 = Instantiate(enemyPrefab, spawnPos, Quaternion.identity);
GameObject enemy3 = Instantiate(enemyPrefab, parentTransform);  // làm con của parent
```

**Lợi ích Prefab:**
- Sửa prefab gốc → tất cả instance tự cập nhật.
- Tái sử dụng across scenes.
- Prefab Variant: tạo biến thể từ prefab gốc.

---

# 4. MONOBEHAVIOUR LIFECYCLE

> Câu hỏi phỏng vấn cực kỳ phổ biến: "Thứ tự gọi các hàm Awake, Start, Update là gì?"

## 4.1. Các hàm Lifecycle quan trọng

```csharp
public class LifecycleDemo : MonoBehaviour
{
    // 1. Gọi 1 LẦN khi object được tạo (kể cả khi GameObject inactive)
    //    Dùng để: khởi tạo biến, cache GetComponent của CHÍNH object này
    void Awake() { }

    // 2. Gọi khi component được bật (mỗi lần SetActive(true))
    //    Dùng để: đăng ký event
    void OnEnable() { }

    // 3. Gọi 1 LẦN trước frame Update đầu tiên (chỉ khi active)
    //    Dùng để: khởi tạo cần truy cập object KHÁC (đã chạy Awake xong)
    void Start() { }

    // 4. Gọi MỖI FRAME — logic game chính, input
    void Update() { }

    // 5. Gọi theo nhịp cố định (mặc định 0.02s) — dùng cho PHYSICS
    void FixedUpdate() { }

    // 6. Gọi MỖI FRAME sau Update — dùng cho camera follow
    void LateUpdate() { }

    // 7. Gọi khi component bị tắt (SetActive(false) hoặc trước Destroy)
    //    Dùng để: hủy đăng ký event
    void OnDisable() { }

    // 8. Gọi khi object bị Destroy
    void OnDestroy() { }
}
```

## 4.2. Thứ tự thực thi (Execution Order)

```
Khi object được tạo:
  Awake()  →  OnEnable()  →  Start()

Mỗi frame:
  FixedUpdate() (có thể chạy 0, 1 hoặc nhiều lần/frame)
       ↓
  Update()
       ↓
  LateUpdate()
       ↓
  Render (vẽ hình)

Khi object bị hủy:
  OnDisable()  →  OnDestroy()
```

**Awake vs Start — khác biệt quan trọng:**

| | Awake | Start |
|---|---|---|
| Khi nào | Ngay khi tạo | Trước frame đầu tiên |
| Object inactive | **Vẫn chạy** | KHÔNG chạy đến khi active |
| Dùng cho | Khởi tạo nội bộ object | Truy cập object khác |

```csharp
// Pattern phổ biến:
// Awake — cache component CỦA CHÍNH MÌNH
void Awake()
{
    _rb = GetComponent<Rigidbody>();
    _anim = GetComponent<Animator>();
}

// Start — truy cập object KHÁC (đảm bảo nó đã Awake xong)
void Start()
{
    _gameManager = GameManager.Instance;
    _player = FindObjectOfType<Player>();
}
```

## 4.3. Update vs FixedUpdate vs LateUpdate

| Hàm | Tần suất | Dùng cho |
|---|---|---|
| `Update` | Mỗi frame (không đều) | Input, logic game, di chuyển non-physics |
| `FixedUpdate` | Cố định (0.02s) | **Physics**: Rigidbody, AddForce, velocity |
| `LateUpdate` | Mỗi frame, sau Update | Camera follow, logic phụ thuộc Update |

```csharp
// Input PHẢI đọc trong Update (không bỏ lỡ frame)
void Update()
{
    if (Input.GetKeyDown(KeyCode.Space))
        _jumpRequested = true;
}

// Physics PHẢI làm trong FixedUpdate
void FixedUpdate()
{
    if (_jumpRequested)
    {
        _rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
        _jumpRequested = false;
    }
}

// Camera follow trong LateUpdate (sau khi player đã di chuyển xong)
void LateUpdate()
{
    transform.position = player.position + offset;
}
```

> **Tại sao Camera follow ở LateUpdate?** Nếu để ở Update, camera có thể di chuyển TRƯỚC khi player di chuyển → giật hình. LateUpdate đảm bảo player đã ở vị trí cuối cùng.

## 4.4. Time.deltaTime — Frame Rate Independence

```csharp
// SAI — tốc độ phụ thuộc FPS (máy mạnh chạy nhanh hơn)
void Update()
{
    transform.position += Vector3.forward * 5f;  // 5 units MỖI FRAME
}

// ĐÚNG — tốc độ đồng nhất mọi máy
void Update()
{
    transform.position += Vector3.forward * 5f * Time.deltaTime;  // 5 units MỖI GIÂY
}
```

`Time.deltaTime` = thời gian giữa frame này và frame trước. Nhân với nó → giá trị "per second" thay vì "per frame".

```csharp
Time.deltaTime;          // Thời gian frame trước (giây)
Time.fixedDeltaTime;     // Thời gian step physics (0.02s)
Time.time;               // Tổng thời gian từ khi start game
Time.timeScale;          // Tốc độ game (1 = bình thường, 0 = pause, 0.5 = slow-mo)

// Pause game
Time.timeScale = 0f;
// Resume
Time.timeScale = 1f;
```

---

# 5. INPUT & MOVEMENT

## 5.1. Đọc Input (Legacy Input Manager)

```csharp
void Update()
{
    // Phím nhấn 1 lần (frame đầu tiên nhấn)
    if (Input.GetKeyDown(KeyCode.Space))
        Jump();

    // Phím đang giữ (mỗi frame khi giữ)
    if (Input.GetKey(KeyCode.W))
        MoveForward();

    // Phím vừa thả ra
    if (Input.GetKeyUp(KeyCode.Space))
        StopCharging();

    // Trục di chuyển (-1 đến 1) — WASD/mũi tên
    float horizontal = Input.GetAxis("Horizontal");  // A/D
    float vertical = Input.GetAxis("Vertical");      // W/S

    // GetAxisRaw — không smoothing, phản hồi tức thì (-1, 0, hoặc 1)
    float h = Input.GetAxisRaw("Horizontal");

    // Chuột
    if (Input.GetMouseButtonDown(0))  // 0=trái, 1=phải, 2=giữa
        Shoot();

    Vector3 mousePos = Input.mousePosition;  // Vị trí chuột (pixel)
}
```

## 5.2. Di chuyển: Transform vs Rigidbody

**Cách 1 — Transform (Kinematic, không physics):**

```csharp
// Dùng khi: không cần va chạm vật lý thật, điều khiển trực tiếp
public class TransformMovement : MonoBehaviour
{
    [SerializeField] float speed = 5f;

    void Update()
    {
        float h = Input.GetAxisRaw("Horizontal");
        float v = Input.GetAxisRaw("Vertical");

        Vector3 direction = new Vector3(h, 0f, v).normalized;
        transform.position += direction * speed * Time.deltaTime;
    }
}
```

**Cách 2 — Rigidbody (Physics):**

```csharp
// Dùng khi: cần va chạm vật lý, lực, trọng lực
public class RigidbodyMovement : MonoBehaviour
{
    [SerializeField] float speed = 5f;
    Rigidbody _rb;
    Vector3 _input;

    void Awake() => _rb = GetComponent<Rigidbody>();

    void Update()  // Đọc input trong Update
    {
        float h = Input.GetAxisRaw("Horizontal");
        float v = Input.GetAxisRaw("Vertical");
        _input = new Vector3(h, 0f, v).normalized;
    }

    void FixedUpdate()  // Áp dụng physics trong FixedUpdate
    {
        _rb.MovePosition(_rb.position + _input * speed * Time.fixedDeltaTime);
    }
}
```

| | Transform | Rigidbody |
|---|---|---|
| Va chạm vật lý | Không tự nhiên (có thể xuyên) | Đúng vật lý |
| Performance | Nhẹ hơn | Nặng hơn |
| Điều khiển | Trực tiếp, chính xác | Qua lực/velocity |
| Khi nào dùng | UI, kinematic objects | Player, enemy có physics |

## 5.3. Normalized Vector — tránh đi chéo nhanh hơn

```csharp
// SAI — đi chéo nhanh hơn đi thẳng (vì độ dài vector chéo = √2)
Vector3 dir = new Vector3(h, 0, v);  // (1,0,1) có length = 1.41

// ĐÚNG — normalize để length luôn = 1
Vector3 dir = new Vector3(h, 0, v).normalized;  // length luôn = 1
```

---

# 6. PHYSICS CƠ BẢN

## 6.1. Collider & Rigidbody

- **Collider:** Định nghĩa "hình dạng va chạm" (Box, Sphere, Capsule, Mesh).
- **Rigidbody:** Cho phép object chịu tác động vật lý (trọng lực, lực, va chạm).

```csharp
Rigidbody rb = GetComponent<Rigidbody>();

// Áp dụng lực
rb.AddForce(Vector3.up * 10f, ForceMode.Impulse);  // Lực tức thời (nhảy)
rb.AddForce(Vector3.forward * 5f);                 // Lực liên tục

// Velocity trực tiếp
rb.velocity = new Vector3(0f, 0f, 10f);

// Các thuộc tính
rb.mass = 2f;              // Khối lượng
rb.useGravity = true;      // Chịu trọng lực
rb.isKinematic = false;    // true = không bị physics tác động (điều khiển bằng code)
rb.drag = 0.5f;            // Lực cản chuyển động
```

**ForceMode:**

| Mode | Ý nghĩa |
|---|---|
| `Force` | Lực liên tục, tính cả mass |
| `Impulse` | Lực tức thời, tính cả mass (nhảy, nổ) |
| `Acceleration` | Lực liên tục, BỎ QUA mass |
| `VelocityChange` | Tức thời, BỎ QUA mass |

## 6.2. Trigger vs Collision

**Collision (va chạm vật lý thật — object đẩy nhau):**

```csharp
// Cả 2 object cần Collider, ít nhất 1 cần Rigidbody, KHÔNG tick "Is Trigger"
void OnCollisionEnter(Collision collision)
{
    Debug.Log($"Va chạm với: {collision.gameObject.name}");

    // Điểm va chạm
    ContactPoint contact = collision.contacts[0];
    Vector3 hitPoint = contact.point;
    Vector3 hitNormal = contact.normal;

    if (collision.gameObject.CompareTag("Wall"))
        PlayBounceSound();
}

void OnCollisionStay(Collision collision) { }  // Mỗi frame khi đang chạm
void OnCollisionExit(Collision collision) { }  // Khi rời nhau
```

**Trigger (vùng cảm biến — object xuyên qua, chỉ phát hiện):**

```csharp
// Collider phải tick "Is Trigger", ít nhất 1 object cần Rigidbody
void OnTriggerEnter(Collider other)
{
    Debug.Log($"Đi vào vùng: {other.name}");

    if (other.CompareTag("Coin"))
    {
        CollectCoin();
        Destroy(other.gameObject);
    }
}

void OnTriggerStay(Collider other) { }  // Mỗi frame khi đang trong vùng
void OnTriggerExit(Collider other) { }  // Khi rời khỏi vùng
```

| | Collision | Trigger |
|---|---|---|
| Vật lý | Đẩy nhau thật | Xuyên qua |
| Dùng cho | Tường, sàn, vật cản | Coin, checkpoint, vùng damage |
| Tham số | `Collision` | `Collider` |

> **Bảng điều kiện kích hoạt:** Để event physics chạy, ít nhất **1 trong 2 object PHẢI có Rigidbody**. Hai object đều static (không Rigidbody) → không có event nào kích hoạt.

## 6.3. Raycast — "bắn tia" phát hiện

```csharp
// Bắn tia từ vị trí, theo hướng, kiểm tra trúng gì
void Shoot()
{
    Ray ray = new Ray(transform.position, transform.forward);

    if (Physics.Raycast(ray, out RaycastHit hit, maxDistance: 100f))
    {
        Debug.Log($"Trúng: {hit.collider.name}");
        Debug.Log($"Khoảng cách: {hit.distance}");
        Debug.Log($"Điểm trúng: {hit.point}");

        if (hit.collider.TryGetComponent<Enemy>(out var enemy))
            enemy.TakeDamage(10);
    }
}

// Raycast từ camera qua vị trí chuột (click chọn object)
void Update()
{
    if (Input.GetMouseButtonDown(0))
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        if (Physics.Raycast(ray, out var hit))
            Debug.Log($"Click vào: {hit.collider.name}");
    }
}

// Raycast chỉ với layer cụ thể
int enemyLayer = LayerMask.GetMask("Enemy");
if (Physics.Raycast(ray, out var hit, 100f, enemyLayer)) { }
```

---

# 7. PREFAB, INSTANTIATE & OBJECT POOLING

## 7.1. Instantiate & Destroy

```csharp
[SerializeField] GameObject bulletPrefab;

void Shoot()
{
    // Tạo instance
    GameObject bullet = Instantiate(bulletPrefab, firePoint.position, firePoint.rotation);

    // Hủy sau 3 giây
    Destroy(bullet, 3f);
}

// Hủy ngay
Destroy(gameObject);

// Hủy ngay lập tức (chỉ dùng trong Editor scripts)
DestroyImmediate(obj);
```

## 7.2. Vấn đề với Instantiate/Destroy liên tục

```
Bắn 100 viên đạn/giây × Instantiate + Destroy
  → Cấp phát bộ nhớ liên tục
  → Garbage Collector phải dọn dẹp
  → GC chạy → KHỰNG hình (frame spike)
```

**Giải pháp: Object Pooling** — tái sử dụng object thay vì tạo/hủy.

## 7.3. Object Pooling cơ bản

```csharp
using System.Collections.Generic;
using UnityEngine;

public class BulletPool : MonoBehaviour
{
    [SerializeField] GameObject bulletPrefab;
    [SerializeField] int poolSize = 20;

    Queue<GameObject> _pool = new Queue<GameObject>();

    void Awake()
    {
        // Tạo sẵn pool
        for (int i = 0; i < poolSize; i++)
        {
            GameObject bullet = Instantiate(bulletPrefab);
            bullet.SetActive(false);  // Tắt, chờ dùng
            _pool.Enqueue(bullet);
        }
    }

    // Lấy bullet từ pool (thay cho Instantiate)
    public GameObject Get(Vector3 position, Quaternion rotation)
    {
        GameObject bullet;

        if (_pool.Count > 0)
            bullet = _pool.Dequeue();
        else
            bullet = Instantiate(bulletPrefab);  // Pool hết → tạo mới

        bullet.transform.SetPositionAndRotation(position, rotation);
        bullet.SetActive(true);
        return bullet;
    }

    // Trả bullet về pool (thay cho Destroy)
    public void Return(GameObject bullet)
    {
        bullet.SetActive(false);
        _pool.Enqueue(bullet);
    }
}
```

**Cách dùng:**

```csharp
public class Gun : MonoBehaviour
{
    [SerializeField] BulletPool _pool;

    void Shoot()
    {
        // Thay vì Instantiate
        GameObject bullet = _pool.Get(firePoint.position, firePoint.rotation);
    }
}

// Trong Bullet — trả về pool thay vì Destroy
public class Bullet : MonoBehaviour
{
    [SerializeField] BulletPool _pool;

    void OnBecameInvisible()  // Khi ra khỏi màn hình
    {
        _pool.Return(gameObject);  // Thay vì Destroy(gameObject)
    }
}
```

> Unity 2021+ có sẵn `UnityEngine.Pool.ObjectPool<T>` — nên dùng cho production. Nhưng hiểu cơ chế thủ công ở trên là quan trọng cho phỏng vấn.

---

# 8. SCRIPTABLEOBJECT

## 8.1. ScriptableObject là gì?

Một loại asset lưu **dữ liệu** độc lập với GameObject. Dùng để chia sẻ data, config, tránh duplicate.

```csharp
using UnityEngine;

// Tạo menu chuột phải để tạo asset
[CreateAssetMenu(fileName = "NewWeapon", menuName = "Game/Weapon")]
public class WeaponData : ScriptableObject
{
    public string weaponName;
    public int damage;
    public float fireRate;
    public Sprite icon;
    public GameObject bulletPrefab;
}
```

Sau khi tạo class này: **Chuột phải trong Project → Create → Game → Weapon** → tạo asset `Pistol`, `Shotgun`, v.v.

## 8.2. Sử dụng

```csharp
public class Weapon : MonoBehaviour
{
    [SerializeField] WeaponData _data;  // Kéo asset vào Inspector

    void Shoot()
    {
        Debug.Log($"Bắn {_data.weaponName}, sát thương {_data.damage}");
        // Dùng _data.bulletPrefab, _data.fireRate...
    }
}
```

## 8.3. Tại sao dùng ScriptableObject?

| Lợi ích | Giải thích |
|---|---|
| **Tách data khỏi logic** | Designer chỉnh số liệu không cần code |
| **Tránh duplicate** | 100 enemy cùng loại chia sẻ 1 SO data, không copy 100 lần |
| **Tiết kiệm bộ nhớ** | Data nằm 1 chỗ, nhiều object reference đến |
| **Dễ test/tweak** | Đổi giá trị trong Inspector, không cần recompile |

```csharp
// SAI — hardcode, lặp lại, khó chỉnh
public class Enemy : MonoBehaviour
{
    int hp = 100;       // Phải sửa code mỗi khi balance
    float speed = 3f;
    int damage = 10;
}

// ĐÚNG — data trong ScriptableObject
[CreateAssetMenu(menuName = "Game/EnemyData")]
public class EnemyData : ScriptableObject
{
    public int hp = 100;
    public float speed = 3f;
    public int damage = 10;
}

public class Enemy : MonoBehaviour
{
    [SerializeField] EnemyData _data;  // Designer chỉnh trong asset
}
```

> **Lưu ý:** Thay đổi giá trị SO lúc Play Mode sẽ **giữ lại** sau khi tắt Play (khác với component thường). Cẩn thận khi test.

---

# 9. UI CƠ BẢN (uGUI)

## 9.1. Canvas — gốc của mọi UI

Mọi UI element phải nằm trong Canvas. Có 3 Render Mode:

| Render Mode | Dùng khi |
|---|---|
| **Screen Space - Overlay** | UI luôn trên cùng màn hình (HUD, menu) |
| **Screen Space - Camera** | UI render qua camera (có thể có hiệu ứng) |
| **World Space** | UI trong thế giới 3D (bảng hiệu, health bar trên đầu enemy) |

## 9.2. RectTransform & Anchor

UI dùng `RectTransform` (thay cho Transform) — có thêm anchor, pivot, size.

```
Anchor: Điểm neo so với parent
  - Neo giữa → UI giữ vị trí giữa khi đổi kích thước màn hình
  - Neo góc → UI giữ khoảng cách với góc
  - Stretch → UI co giãn theo parent

Pivot: Điểm gốc của chính UI element (0,0 = góc dưới trái, 0.5,0.5 = giữa)
```

> **Quan trọng cho responsive:** Đặt anchor đúng để UI hoạt động trên mọi kích thước màn hình. Ví dụ nút "Settings" góc trên phải → anchor góc trên phải.

## 9.3. Các UI Component thường dùng

```csharp
using UnityEngine.UI;
using TMPro;  // TextMeshPro - nên dùng thay Text cũ

public class UIController : MonoBehaviour
{
    [SerializeField] Button _playButton;
    [SerializeField] TextMeshProUGUI _scoreText;
    [SerializeField] Image _healthBar;
    [SerializeField] Slider _volumeSlider;
    [SerializeField] Toggle _muteToggle;

    void Start()
    {
        // Button — đăng ký sự kiện click
        _playButton.onClick.AddListener(OnPlayClicked);

        // Slider — đăng ký sự kiện thay đổi
        _volumeSlider.onValueChanged.AddListener(OnVolumeChanged);

        // Toggle
        _muteToggle.onValueChanged.AddListener(isMuted => AudioListener.volume = isMuted ? 0 : 1);
    }

    void OnPlayClicked() => Debug.Log("Play!");

    void OnVolumeChanged(float value) => AudioListener.volume = value;

    void Update()
    {
        // Cập nhật text
        _scoreText.text = $"Score: {GameManager.Score}";

        // Cập nhật fill image (health bar)
        _healthBar.fillAmount = currentHp / maxHp;  // 0 đến 1
    }

    void OnDestroy()
    {
        // Hủy đăng ký để tránh leak
        _playButton.onClick.RemoveListener(OnPlayClicked);
    }
}
```

## 9.4. Bật/Tắt UI Panel

```csharp
[SerializeField] GameObject _pausePanel;

void TogglePause()
{
    bool isActive = _pausePanel.activeSelf;
    _pausePanel.SetActive(!isActive);
    Time.timeScale = isActive ? 1f : 0f;  // Pause/resume game
}
```

---

# 10. DOTWEEN — ANIMATION BẰNG CODE

> DOTween là thư viện tween/animation phổ biến nhất trong Unity. "Tween" = chuyển một giá trị từ A đến B mượt mà theo thời gian. Junior biết DOTween là một điểm cộng lớn vì nó dùng cực nhiều trong game mobile.

## 10.1. Cài đặt & Setup

```
1. Asset Store → tải "DOTween (HOTween v2)" (miễn phí)
2. Import vào project
3. Tools → Demigiant → DOTween Utility Panel → Setup DOTween
4. Trong code: using DG.Tweening;
```

## 10.2. Tween cơ bản

Cú pháp chung: `target.DOSomething(đích, thờiGian)`

```csharp
using DG.Tweening;

public class TweenDemo : MonoBehaviour
{
    void Start()
    {
        // Di chuyển đến vị trí (0,5,0) trong 2 giây
        transform.DOMove(new Vector3(0, 5, 0), 2f);

        // Di chuyển theo từng trục
        transform.DOMoveX(10f, 1f);
        transform.DOMoveY(5f, 1f);

        // Di chuyển tương đối (cộng thêm vào vị trí hiện tại)
        transform.DOMove(new Vector3(0, 2, 0), 1f).SetRelative();

        // Xoay đến góc (0, 180, 0) trong 1 giây
        transform.DORotate(new Vector3(0, 180, 0), 1f);

        // Scale to lên gấp đôi
        transform.DOScale(2f, 0.5f);
        transform.DOScale(new Vector3(2, 1, 1), 0.5f);  // scale từng trục
    }
}
```

## 10.3. Tween cho UI & Component khác

```csharp
using DG.Tweening;
using UnityEngine.UI;
using TMPro;

// CanvasGroup — fade UI
CanvasGroup canvasGroup;
canvasGroup.DOFade(0f, 1f);        // Mờ dần (alpha về 0)
canvasGroup.DOFade(1f, 1f);        // Hiện dần

// Image — fade màu
Image image;
image.DOFade(0.5f, 1f);            // Đổi alpha
image.DOColor(Color.red, 1f);      // Đổi màu

// Fill amount (health bar mượt)
image.DOFillAmount(0.3f, 0.5f);

// RectTransform — UI animation
RectTransform rect;
rect.DOAnchorPos(new Vector2(0, 100), 1f);   // Di chuyển UI
rect.DOSizeDelta(new Vector2(200, 200), 0.5f); // Đổi kích thước

// SpriteRenderer
SpriteRenderer sr;
sr.DOColor(Color.blue, 1f);
sr.DOFade(0f, 1f);

// Camera
Camera.main.DOOrthoSize(8f, 1f);    // Zoom camera 2D
Camera.main.DOShakePosition(0.5f, 1f);  // Rung camera (hiệu ứng nổ)

// Số (đếm điểm tăng dần)
int score = 0;
DOTween.To(() => score, x => score = x, 1000, 2f)
    .OnUpdate(() => scoreText.text = score.ToString());
```

## 10.4. Easing — kiểu chuyển động

Ease quyết định cảm giác chuyển động (tăng tốc, giảm tốc, nảy...).

```csharp
// Cú pháp: .SetEase(Ease.XXX)
transform.DOMove(target, 1f).SetEase(Ease.Linear);       // Đều
transform.DOMove(target, 1f).SetEase(Ease.InQuad);       // Tăng tốc dần
transform.DOMove(target, 1f).SetEase(Ease.OutQuad);      // Giảm tốc dần
transform.DOMove(target, 1f).SetEase(Ease.InOutQuad);    // Tăng rồi giảm
transform.DOMove(target, 1f).SetEase(Ease.OutBounce);    // Nảy khi đến đích
transform.DOMove(target, 1f).SetEase(Ease.OutBack);      // Vọt quá rồi lùi lại
transform.DOMove(target, 1f).SetEase(Ease.OutElastic);   // Đàn hồi
```

| Ease phổ biến | Cảm giác | Dùng cho |
|---|---|---|
| `Linear` | Đều, máy móc | Chuyển động cơ học |
| `OutQuad` / `OutCubic` | Giảm tốc tự nhiên | Di chuyển UI, popup |
| `OutBack` | Vọt quá rồi về | Nút bấm, popup xuất hiện |
| `OutBounce` | Nảy như bóng | Item rơi, coin |
| `OutElastic` | Đàn hồi | Hiệu ứng vui nhộn |
| `InOutQuad` | Mượt 2 đầu | Camera, transition |

## 10.5. Callback — chạy code khi tween xong

```csharp
transform.DOMove(target, 2f)
    .OnStart(() => Debug.Log("Bắt đầu di chuyển"))
    .OnUpdate(() => Debug.Log("Đang chạy mỗi frame"))
    .OnComplete(() => Debug.Log("Đã đến đích!"));

// Ví dụ thực tế: enemy chết → scale về 0 → destroy
transform.DOScale(0f, 0.3f)
    .SetEase(Ease.InBack)
    .OnComplete(() => Destroy(gameObject));

// Popup xuất hiện rồi gọi callback
popupRect.DOScale(1f, 0.4f)
    .SetEase(Ease.OutBack)
    .OnComplete(() => EnableButtons());
```

## 10.6. Sequence — nối nhiều tween

```csharp
// Chạy nhiều tween theo thứ tự hoặc cùng lúc
Sequence seq = DOTween.Sequence();

// Append — nối tiếp (chạy sau cái trước)
seq.Append(transform.DOMoveX(5f, 1f));      // Bước 1
seq.Append(transform.DOMoveY(3f, 1f));      // Bước 2 (sau bước 1)

// Join — chạy CÙNG LÚC với cái trước đó
seq.Append(transform.DOMoveX(5f, 1f));      // Di chuyển
seq.Join(transform.DOScale(2f, 1f));        // Đồng thời scale

// Insert — chèn vào thời điểm cụ thể
seq.Insert(0.5f, transform.DORotate(new Vector3(0,180,0), 1f));

// AppendInterval — chờ
seq.AppendInterval(0.5f);                   // Đợi 0.5s

// AppendCallback — chạy code
seq.AppendCallback(() => Debug.Log("Checkpoint"));

// Callback toàn sequence
seq.OnComplete(() => Debug.Log("Toàn bộ xong!"));
```

**Ví dụ thực tế — Coin bay vào ví:**

```csharp
void CollectCoin(Transform coin, Transform wallet)
{
    Sequence seq = DOTween.Sequence();
    seq.Append(coin.DOScale(1.3f, 0.2f));                    // Phình to
    seq.Append(coin.DOMove(wallet.position, 0.5f).SetEase(Ease.InBack)); // Bay vào ví
    seq.Join(coin.DOScale(0f, 0.5f));                        // Đồng thời nhỏ dần
    seq.AppendCallback(() => AddCoin(1));                    // Cộng tiền
    seq.OnComplete(() => Destroy(coin.gameObject));          // Hủy coin
}
```

## 10.7. Loop & các tùy chỉnh

```csharp
// Lặp vô hạn
transform.DOMoveY(2f, 1f).SetLoops(-1, LoopType.Yoyo);  // Lên xuống mãi

// Lặp số lần cụ thể
transform.DOScale(1.2f, 0.5f).SetLoops(3, LoopType.Yoyo);

// LoopType:
// - Restart: về đầu rồi lặp lại
// - Yoyo: chạy tới rồi chạy lui
// - Incremental: cộng dồn

// Delay — chờ trước khi bắt đầu
transform.DOMove(target, 1f).SetDelay(2f);  // Đợi 2s rồi mới chạy

// Speed-based thay vì duration-based
transform.DOMove(target, 5f).SetSpeedBased();  // 5 = tốc độ, không phải thời gian
```

## 10.8. Quản lý & Kill Tween (RẤT QUAN TRỌNG)

```csharp
// Lưu tween để điều khiển sau
Tween _myTween;

void StartMoving()
{
    _myTween = transform.DOMove(target, 2f);
}

void StopMoving()
{
    _myTween.Kill();           // Dừng và hủy tween
    // _myTween.Kill(true);    // Kill và nhảy đến giá trị cuối
    _myTween.Pause();          // Tạm dừng
    _myTween.Play();           // Tiếp tục
}

// QUAN TRỌNG: Kill tween khi object bị destroy để tránh lỗi
void OnDestroy()
{
    transform.DOKill();        // Kill mọi tween trên transform này
    _myTween?.Kill();
}
```

> **Lỗi Junior kinh điển:** Object bị Destroy nhưng tween vẫn chạy → tween cố truy cập object đã chết → **lỗi/crash**. LUÔN `DOKill()` trong `OnDestroy`.

## 10.9. Best Practices cho Junior

```csharp
// 1. SetLink — tự động kill tween khi GameObject bị destroy (an toàn nhất)
transform.DOMove(target, 1f).SetLink(gameObject);

// 2. SetUpdate(true) — tween chạy kể cả khi Time.timeScale = 0 (UI khi pause)
pausePanel.DOFade(1f, 0.3f).SetUpdate(true);

// 3. SetId — gán id để kill nhóm tween
transform.DOMove(target, 1f).SetId("playerMove");
DOTween.Kill("playerMove");  // Kill tất cả tween có id này

// 4. Tránh tạo tween mỗi frame trong Update (rò rỉ bộ nhớ)
// SAI:
void Update() { transform.DOMoveX(5f, 1f); }  // Tạo tween liên tục!
```

**Tổng kết các hàm thường dùng:**

| Hàm | Tác dụng |
|---|---|
| `DOMove / DOLocalMove` | Di chuyển |
| `DORotate` | Xoay |
| `DOScale` | Phóng to/thu nhỏ |
| `DOFade` | Mờ dần/hiện dần |
| `DOColor` | Đổi màu |
| `DOAnchorPos` | Di chuyển UI (RectTransform) |
| `DOFillAmount` | Health bar mượt |
| `DOShakePosition` | Rung (hiệu ứng nổ) |
| `.SetEase()` | Kiểu chuyển động |
| `.OnComplete()` | Callback khi xong |
| `.SetLoops()` | Lặp lại |
| `.Kill()` / `DOKill()` | Dừng tween |
| `.SetLink()` | Auto-kill khi destroy |

---

# 11. UNITASK — ASYNC HIỆN ĐẠI

> UniTask là thư viện async/await tối ưu cho Unity, thay thế cho Coroutine. Nó nhanh hơn, không sinh rác (zero allocation), và dễ viết hơn. Junior biết UniTask sẽ nổi bật vì đây là kỹ năng "hiện đại" mà nhiều người chưa nắm.

## 11.1. Tại sao cần UniTask thay Coroutine?

| | Coroutine | UniTask |
|---|---|---|
| Trả về giá trị | Không thể | Có (`UniTask<T>`) |
| try/catch bắt lỗi | Khó | Dễ, chuẩn C# |
| Sinh rác (GC) | Có | **Zero allocation** |
| Hủy (cancel) | Thủ công, phức tạp | `CancellationToken` chuẩn |
| Chờ nhiều task | Khó | Dễ (`WhenAll`, `WhenAny`) |
| Chạy đa luồng | Không | Có (switch thread) |

## 11.2. Cài đặt

```
Package Manager → Add package from git URL:
https://github.com/Cysharp/UniTask.git?path=src/UniTask/Assets/Plugins/UniTask

Trong code: using Cysharp.Threading.Tasks;
```

## 11.3. Async cơ bản

```csharp
using Cysharp.Threading.Tasks;
using UnityEngine;

public class UniTaskDemo : MonoBehaviour
{
    // Hàm async cơ bản — return UniTask (giống void nhưng async)
    async UniTask DoSomethingAsync()
    {
        Debug.Log("Bắt đầu");

        // Chờ 2 giây (KHÔNG block game)
        await UniTask.Delay(2000);  // milliseconds

        Debug.Log("Sau 2 giây");
    }

    // Async trả về giá trị
    async UniTask<int> CalculateAsync()
    {
        await UniTask.Delay(1000);
        return 42;
    }

    // Gọi async từ Start
    async void Start()  // Start có thể là async void
    {
        await DoSomethingAsync();

        int result = await CalculateAsync();
        Debug.Log($"Kết quả: {result}");
    }
}
```

## 11.4. Các kiểu chờ (await) thường dùng

```csharp
// Chờ thời gian
await UniTask.Delay(1000);                          // 1 giây (ms)
await UniTask.Delay(TimeSpan.FromSeconds(1.5f));    // 1.5 giây

// Chờ 1 frame
await UniTask.Yield();
await UniTask.NextFrame();

// Chờ đến cuối frame
await UniTask.WaitForEndOfFrame(this);

// Chờ FixedUpdate
await UniTask.WaitForFixedUpdate();

// Chờ đến khi điều kiện đúng
await UniTask.WaitUntil(() => player.isReady);

// Chờ đến khi điều kiện sai
await UniTask.WaitWhile(() => isLoading);

// Chờ delay KHÔNG bị ảnh hưởng bởi Time.timeScale (chạy cả khi pause)
await UniTask.Delay(1000, ignoreTimeScale: true);
```

## 11.5. CancellationToken — Hủy task an toàn (QUAN TRỌNG)

```csharp
public class EnemySpawner : MonoBehaviour
{
    async void Start()
    {
        // Lấy token tự động hủy khi GameObject bị destroy
        CancellationToken token = this.GetCancellationTokenOnDestroy();

        await SpawnLoopAsync(token);
    }

    async UniTask SpawnLoopAsync(CancellationToken token)
    {
        while (true)
        {
            SpawnEnemy();

            // Nếu object bị destroy giữa chừng → tự động dừng (không lỗi)
            await UniTask.Delay(2000, cancellationToken: token);
        }
    }
}
```

> **Đây là lý do UniTask vượt trội:** Với Coroutine, khi object bị destroy giữa chừng dễ gây `MissingReferenceException`. UniTask với CancellationToken tự động dừng sạch sẽ.

**Tự tạo & hủy token thủ công:**

```csharp
CancellationTokenSource _cts;

void StartTask()
{
    _cts = new CancellationTokenSource();
    RunAsync(_cts.Token).Forget();  // .Forget() = fire and forget
}

void CancelTask()
{
    _cts?.Cancel();      // Hủy task
    _cts?.Dispose();
}
```

## 11.6. Xử lý lỗi với try/catch

```csharp
async UniTask LoadDataAsync(CancellationToken token)
{
    try
    {
        await DownloadAsync(token);
        Debug.Log("Tải xong");
    }
    catch (OperationCanceledException)
    {
        Debug.Log("Đã hủy");  // Khi token bị cancel
    }
    catch (Exception e)
    {
        Debug.LogError($"Lỗi: {e.Message}");  // Lỗi khác
    }
}
```

## 11.7. Chờ nhiều task cùng lúc

```csharp
// WhenAll — chờ TẤT CẢ xong
async UniTask LoadAllAsync()
{
    await UniTask.WhenAll(
        LoadTextureAsync(),
        LoadAudioAsync(),
        LoadDataAsync()
    );
    Debug.Log("Tất cả đã tải xong");
}

// WhenAll với kết quả
async UniTask GetAllResultsAsync()
{
    var (texture, audio) = await UniTask.WhenAll(
        LoadTextureAsync(),  // UniTask<Texture>
        LoadAudioAsync()     // UniTask<AudioClip>
    );
}

// WhenAny — chờ CÁI ĐẦU TIÊN xong
async UniTask RaceAsync()
{
    int winIndex = await UniTask.WhenAny(
        TimeoutAsync(),
        DownloadAsync()
    );
}
```

## 11.8. Chuyển luồng (Thread) — tính toán nặng

```csharp
async UniTask HeavyCalculationAsync()
{
    // Chuyển sang background thread để tính toán nặng
    await UniTask.SwitchToThreadPool();

    int result = DoVeryHeavyMath();  // Chạy trên thread khác, không lag game

    // Chuyển về main thread để dùng Unity API
    await UniTask.SwitchToMainThread();

    transform.position = new Vector3(result, 0, 0);  // Unity API cần main thread
}
```

> **Nhớ:** Unity API (transform, Instantiate, GameObject...) **CHỈ** gọi được từ main thread. Phải `SwitchToMainThread()` trước khi dùng.

## 11.9. Các pattern thực tế

**Loading với async:**

```csharp
async UniTask LoadGameAsync()
{
    loadingScreen.SetActive(true);

    await LoadAssetsAsync();
    await UniTask.Delay(500);  // Hiệu ứng mượt
    await LoadSceneAsync();

    loadingScreen.SetActive(false);
}
```

**Delay rồi làm gì đó (thay Invoke):**

```csharp
// Thay vì Invoke("Method", 2f) — không type-safe
async void ShowMessageThenHide()
{
    messagePanel.SetActive(true);
    await UniTask.Delay(2000, cancellationToken: this.GetCancellationTokenOnDestroy());
    messagePanel.SetActive(false);
}
```

**Kết hợp với DOTween:**

```csharp
async UniTask AnimateThenContinue()
{
    // Chờ tween hoàn thành
    await transform.DOMove(target, 1f).ToUniTask();

    Debug.Log("Tween xong, làm tiếp");
    await transform.DOScale(0f, 0.5f).ToUniTask();

    Destroy(gameObject);
}
```

**Cooldown skill:**

```csharp
bool _canUseSkill = true;

async void UseSkill()
{
    if (!_canUseSkill) return;

    _canUseSkill = false;
    CastSkill();

    await UniTask.Delay(3000, cancellationToken: this.GetCancellationTokenOnDestroy());

    _canUseSkill = true;  // Hết cooldown
}
```

## 11.10. .Forget() — Fire and Forget

```csharp
// Khi gọi async method từ hàm không async (như Update)
void Update()
{
    if (Input.GetKeyDown(KeyCode.Space))
        DoAsyncStuff().Forget();  // Chạy không cần chờ, tránh warning
}

async UniTask DoAsyncStuff()
{
    await UniTask.Delay(1000);
    Debug.Log("Done");
}
```

---

# 12. COROUTINE

> Mặc dù UniTask hiện đại hơn, Coroutine vẫn xuất hiện trong nhiều codebase và là kiến thức cơ bản Junior phải biết.

## 12.1. Coroutine cơ bản

```csharp
using System.Collections;
using UnityEngine;

public class CoroutineDemo : MonoBehaviour
{
    void Start()
    {
        StartCoroutine(MyCoroutine());
    }

    IEnumerator MyCoroutine()
    {
        Debug.Log("Bắt đầu");

        yield return new WaitForSeconds(2f);  // Chờ 2 giây

        Debug.Log("Sau 2 giây");

        yield return null;  // Chờ 1 frame

        Debug.Log("Frame tiếp theo");
    }
}
```

## 12.2. Các kiểu yield

```csharp
yield return null;                          // Chờ 1 frame
yield return new WaitForSeconds(1f);        // Chờ 1 giây (bị ảnh hưởng timeScale)
yield return new WaitForSecondsRealtime(1f);// Chờ 1 giây thật (kệ timeScale)
yield return new WaitForEndOfFrame();       // Chờ đến cuối frame
yield return new WaitForFixedUpdate();      // Chờ FixedUpdate
yield return new WaitUntil(() => isReady);  // Chờ đến khi điều kiện đúng
yield return new WaitWhile(() => isLoading);// Chờ khi điều kiện còn đúng
yield return StartCoroutine(Other());       // Chờ coroutine khác xong
```

## 12.3. Dừng Coroutine

```csharp
Coroutine _myCoroutine;

void StartIt()
{
    _myCoroutine = StartCoroutine(MyCoroutine());
}

void StopIt()
{
    if (_myCoroutine != null)
        StopCoroutine(_myCoroutine);

    StopAllCoroutines();  // Dừng tất cả coroutine trên object này
}
```

## 12.4. Tối ưu — Cache WaitForSeconds

```csharp
// SAI — tạo object mới mỗi lần lặp → sinh rác
IEnumerator BadLoop()
{
    while (true)
        yield return new WaitForSeconds(1f);  // New mỗi lần!
}

// ĐÚNG — cache lại
readonly WaitForSeconds _wait1s = new WaitForSeconds(1f);

IEnumerator GoodLoop()
{
    while (true)
        yield return _wait1s;  // Tái sử dụng
}
```

## 12.5. Lỗi Junior thường gặp với Coroutine

```csharp
// LỖI 1: Coroutine vẫn chạy khi tắt Component (chỉ dừng khi tắt GameObject)
// enabled = false KHÔNG dừng coroutine!

// LỖI 2: Quên rằng StartCoroutine cần GameObject active
gameObject.SetActive(false);
StartCoroutine(X());  // Lỗi! Không start được trên inactive object

// LỖI 3: try/catch không bao quanh được yield
IEnumerator BadTry()
{
    try
    {
        yield return new WaitForSeconds(1f);  // COMPILE ERROR
    }
    catch { }
}
```

## 12.6. Khi nào dùng Coroutine vs UniTask?

| Tình huống | Khuyến nghị |
|---|---|
| Project mới, có thể thêm package | **UniTask** |
| Cần trả về giá trị, xử lý lỗi | **UniTask** |
| Codebase cũ đã dùng Coroutine | Coroutine (theo team) |
| Logic đơn giản, không muốn thêm dependency | Coroutine |
| Cần performance, nhiều async | **UniTask** |

---

# 13. ADDRESSABLES (JUNIOR LEVEL)

> Addressables là hệ thống quản lý và tải tài nguyên hiện đại của Unity, thay thế cho `Resources` folder. Ở mức Junior, bạn cần hiểu khái niệm, lý do dùng, và cách load/release cơ bản.

## 13.1. Vấn đề với cách cũ

**Cách 1 — Kéo thả trực tiếp (Direct Reference):**
```csharp
[SerializeField] GameObject enemyPrefab;  // Kéo prefab vào Inspector
```
Vấn đề: Tất cả prefab được nhồi vào scene/build → game nặng, RAM cao dù chưa dùng.

**Cách 2 — Resources folder:**
```csharp
GameObject prefab = Resources.Load<GameObject>("Enemies/Goblin");
```
Vấn đề: Toàn bộ folder `Resources` bị đóng gói vào build, không thể unload chọn lọc, làm chậm startup, khó quản lý.

## 13.2. Addressables giải quyết gì?

| Lợi ích | Giải thích |
|---|---|
| **Tải theo nhu cầu** | Chỉ load asset khi cần, giải phóng khi xong → tiết kiệm RAM |
| **Tải từ xa** | Asset có thể để trên server (CDN), tải về sau khi cài game → giảm dung lượng app |
| **Cập nhật không cần update app** | Đổi asset trên server, không cần build lại |
| **Quản lý bộ nhớ rõ ràng** | Load/Release tường minh |

## 13.3. Setup cơ bản

```
1. Package Manager → cài "Addressables"
2. Window → Asset Management → Addressables → Groups
3. Chọn asset → tick "Addressable" trong Inspector
   → asset được gán một "address" (tên gọi để load)
4. Có thể đổi address thành tên dễ nhớ: "Goblin", "MainMenuBGM"...
```

## 13.4. Load Asset cơ bản

```csharp
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public class AddressableLoader : MonoBehaviour
{
    // Load một asset bằng address (string)
    async void LoadPrefab()
    {
        // Load asset (async)
        AsyncOperationHandle<GameObject> handle =
            Addressables.LoadAssetAsync<GameObject>("Goblin");

        await handle.Task;  // Chờ load xong

        if (handle.Status == AsyncOperationStatus.Succeeded)
        {
            GameObject prefab = handle.Result;
            Instantiate(prefab);
        }

        // Giải phóng khi không cần (QUAN TRỌNG)
        // Addressables.Release(handle);
    }
}
```

## 13.5. Instantiate trực tiếp (tiện hơn)

```csharp
// Addressables tự load + instantiate trong 1 lệnh
async void SpawnEnemy()
{
    AsyncOperationHandle<GameObject> handle =
        Addressables.InstantiateAsync("Goblin");

    await handle.Task;

    GameObject enemy = handle.Result;
    // ... dùng enemy

    // Khi destroy — dùng ReleaseInstance thay cho Destroy
    Addressables.ReleaseInstance(enemy);
}
```

## 13.6. Quản lý bộ nhớ — Load & Release

> **Quy tắc vàng:** Mỗi `Load` phải có một `Release` tương ứng. Quên Release → asset nằm mãi trong RAM → memory leak.

```csharp
public class CharacterLoader : MonoBehaviour
{
    AsyncOperationHandle<GameObject> _handle;

    async void LoadCharacter()
    {
        _handle = Addressables.LoadAssetAsync<GameObject>("Hero");
        await _handle.Task;
        Instantiate(_handle.Result);
    }

    void OnDestroy()
    {
        // Giải phóng khi object bị hủy
        if (_handle.IsValid())
            Addressables.Release(_handle);
    }
}
```

## 13.7. Dùng AssetReference (an toàn hơn string)

```csharp
using UnityEngine.AddressableAssets;

public class RefLoader : MonoBehaviour
{
    // Kéo thả asset vào Inspector (không cần gõ string)
    [SerializeField] AssetReference _enemyReference;
    [SerializeField] AssetReferenceGameObject _prefabReference;  // type-safe hơn

    async void Spawn()
    {
        AsyncOperationHandle<GameObject> handle = _enemyReference.LoadAssetAsync<GameObject>();
        await handle.Task;
        Instantiate(handle.Result);
    }
}
```

> **AssetReference vs string address:** AssetReference tránh lỗi gõ sai tên, refactor-safe, kéo thả trực tiếp. Ưu tiên dùng AssetReference.

## 13.8. Kết hợp với UniTask

```csharp
using Cysharp.Threading.Tasks;
using UnityEngine.AddressableAssets;

async UniTask<GameObject> LoadEnemyAsync(CancellationToken token)
{
    var handle = Addressables.LoadAssetAsync<GameObject>("Goblin");
    await handle.ToUniTask(cancellationToken: token);
    return handle.Result;
}
```

## 13.9. Load nhiều asset cùng lúc (theo Label)

```csharp
// Gán nhiều asset chung 1 "label" (ví dụ: "Level1Assets")
// Rồi load tất cả cùng lúc
async void LoadAllLevel1()
{
    AsyncOperationHandle<IList<GameObject>> handle =
        Addressables.LoadAssetsAsync<GameObject>("Level1Assets", null);

    await handle.Task;

    foreach (GameObject prefab in handle.Result)
        Debug.Log($"Loaded: {prefab.name}");
}
```

## 13.10. Tóm tắt cho Junior

| Hàm | Tác dụng |
|---|---|
| `LoadAssetAsync<T>(key)` | Load asset, trả handle |
| `InstantiateAsync(key)` | Load + tạo instance |
| `Release(handle)` | Giải phóng asset |
| `ReleaseInstance(go)` | Giải phóng instance đã tạo |
| `AssetReference` | Tham chiếu asset kéo thả (type-safe) |

**Những điều cần nhớ:**
- Addressables là **async** — luôn `await`.
- Mỗi `Load` cần một `Release`.
- Dùng `AssetReference` thay string khi có thể.
- Ở mức Junior: hiểu khái niệm + load/release cơ bản là đủ. Reference counting nâng cao để dành cho Senior.

---

# 14. DEBUG & LỖI THƯỜNG GẶP

## 14.1. Debug.Log

```csharp
Debug.Log("Thông tin bình thường");
Debug.LogWarning("Cảnh báo (vàng)");
Debug.LogError("Lỗi (đỏ)");

// String interpolation — cách format gọn
int score = 100;
Debug.Log($"Score: {score}, Position: {transform.position}");

// Log có màu (rich text)
Debug.Log("<color=red>Player died!</color>");
Debug.Log("<color=green>Level complete!</color>");

// Log kèm object — click vào log sẽ highlight object trong Hierarchy
Debug.Log("Enemy spawned", gameObject);

// Vẽ đường debug trong Scene view
Debug.DrawRay(transform.position, transform.forward * 5f, Color.red);
Debug.DrawLine(pointA, pointB, Color.green);
```

## 14.2. NullReferenceException — Lỗi #1 của Junior

```csharp
// LỖI: Truy cập object null
GameObject enemy = null;
enemy.transform.position = Vector3.zero;  // NullReferenceException!

// Nguyên nhân thường gặp:
// 1. Quên kéo reference vào Inspector
[SerializeField] Rigidbody _rb;  // Để trống trong Inspector → null

// 2. GetComponent không tìm thấy
Rigidbody rb = GetComponent<Rigidbody>();  // null nếu không có Rigidbody
rb.velocity = Vector3.zero;  // Crash

// 3. Find không thấy
GameObject player = GameObject.Find("Player");  // null nếu sai tên
```

**Cách phòng tránh:**

```csharp
// Cách 1: Kiểm tra null
if (enemy != null)
    enemy.transform.position = Vector3.zero;

// Cách 2: TryGetComponent
if (TryGetComponent<Rigidbody>(out var rb))
    rb.velocity = Vector3.zero;

// Cách 3: Null check với cảnh báo rõ ràng
void Awake()
{
    _rb = GetComponent<Rigidbody>();
    if (_rb == null)
        Debug.LogError($"{name} thiếu Rigidbody!", this);
}
```

> **LƯU Ý Unity:** KHÔNG dùng `?.` hoặc `??` với UnityEngine.Object (GameObject, Component...). Unity overload toán tử `==` đặc biệt. Dùng `if (obj != null)` thay vì `obj?.DoSomething()`.

## 14.3. Các lỗi Junior kinh điển khác

```csharp
// LỖI: Sửa Vector3 component trực tiếp
transform.position.x = 5f;  // COMPILE ERROR (struct)
// FIX:
transform.position = new Vector3(5f, transform.position.y, transform.position.z);

// LỖI: Quên Time.deltaTime → tốc độ phụ thuộc FPS
transform.position += Vector3.forward * 5f;  // SAI
transform.position += Vector3.forward * 5f * Time.deltaTime;  // ĐÚNG

// LỖI: Physics trong Update thay vì FixedUpdate
void Update() { _rb.AddForce(force); }  // Giật, không nhất quán
void FixedUpdate() { _rb.AddForce(force); }  // ĐÚNG

// LỖI: GetComponent trong Update (tốn performance)
void Update() { GetComponent<Renderer>().material.color = Color.red; }  // SAI
// FIX: cache ở Awake

// LỖI: So sánh tag bằng ==
if (other.tag == "Enemy") { }  // Chậm, sinh garbage
if (other.CompareTag("Enemy")) { }  // ĐÚNG

// LỖI: Quên hủy đăng ký event → memory leak
void OnEnable() => manager.OnEvent += Handler;
void OnDisable() => manager.OnEvent -= Handler;  // ĐỪNG QUÊN

// LỖI: Dùng float == float
if (transform.position.x == 5f) { }  // Hiếm khi đúng do sai số float
if (Mathf.Approximately(transform.position.x, 5f)) { }  // ĐÚNG
```

## 14.4. Debugging cơ bản

```csharp
// Breakpoint — đặt trong IDE (Visual Studio/Rider), chạy Debug mode
// Xem giá trị biến tại thời điểm dừng

// Conditional logging — chỉ log khi cần
#if UNITY_EDITOR
    Debug.Log("Chỉ chạy trong Editor");
#endif

// Assert — kiểm tra điều kiện
Debug.Assert(hp >= 0, "HP không được âm!");
```

---

# 15. CÂU HỎI PHỎNG VẤN MẪU

> Tổng hợp câu hỏi thường gặp cho vị trí Junior Unity, kèm câu trả lời ngắn gọn.

## 15.1. C# Cơ bản

**Q: Value type và reference type khác nhau thế nào?**
> Value type (int, float, struct, Vector3) lưu giá trị trực tiếp, khi gán sẽ copy giá trị. Reference type (class, array, List) lưu tham chiếu đến object trên heap, khi gán chỉ copy tham chiếu (cùng trỏ 1 object).

**Q: Class và struct khác nhau gì?**
> Class là reference type, struct là value type. Struct dùng cho dữ liệu nhỏ ngắn hạn, không kế thừa được. Class dùng cho object phức tạp, hỗ trợ kế thừa.

**Q: Khi nào dùng List, Dictionary, HashSet?**
> List khi cần danh sách có thứ tự, thêm/xóa động. Dictionary khi cần tra cứu nhanh theo key. HashSet khi cần tập hợp không trùng lặp và check tồn tại nhanh.

**Q: Action, Func, event khác nhau gì?**
> Action là delegate không trả về giá trị. Func là delegate có trả về giá trị. Event là Action/delegate được bảo vệ — chỉ class chứa nó mới Invoke được.

## 15.2. Unity Lifecycle

**Q: Thứ tự gọi Awake, Start, Update?**
> Awake → OnEnable → Start (chạy 1 lần khi tạo). Sau đó mỗi frame: FixedUpdate → Update → LateUpdate.

**Q: Awake và Start khác nhau gì?**
> Awake chạy ngay khi object được tạo (kể cả inactive), dùng để khởi tạo nội bộ và cache component của chính mình. Start chạy trước frame đầu tiên (chỉ khi active), dùng để truy cập object khác (đã Awake xong).

**Q: Update và FixedUpdate khác nhau?**
> Update chạy mỗi frame (tần suất không đều, phụ thuộc FPS) — dùng cho input và logic. FixedUpdate chạy theo nhịp cố định (mặc định 0.02s) — dùng cho physics (Rigidbody, lực).

**Q: Tại sao camera follow nên ở LateUpdate?**
> Vì LateUpdate chạy sau Update. Player di chuyển trong Update, nếu camera follow ở Update có thể chạy trước khi player di chuyển xong → giật. LateUpdate đảm bảo player đã ở vị trí cuối.

**Q: Time.deltaTime là gì, tại sao quan trọng?**
> Là thời gian giữa frame hiện tại và frame trước. Nhân chuyển động với deltaTime để tốc độ đồng nhất trên mọi máy (per second thay vì per frame), không phụ thuộc FPS.

## 15.3. Physics

**Q: Trigger và Collision khác nhau gì?**
> Collision là va chạm vật lý thật (object đẩy nhau), dùng OnCollisionEnter. Trigger là vùng cảm biến (object xuyên qua, chỉ phát hiện), dùng OnTriggerEnter và cần tick "Is Trigger".

**Q: Điều kiện để OnTriggerEnter chạy?**
> Cả 2 object cần Collider, ít nhất 1 object cần Rigidbody, và Collider phải tick "Is Trigger".

**Q: Raycast dùng để làm gì?**
> "Bắn một tia" từ điểm theo hướng, kiểm tra trúng collider nào. Dùng cho bắn súng, click chọn object, kiểm tra mặt đất, line of sight của AI.

## 15.4. Tối ưu & Best Practices

**Q: Tại sao không nên Instantiate/Destroy liên tục?**
> Vì tạo/hủy object liên tục cấp phát bộ nhớ, kích hoạt Garbage Collector gây giật hình. Giải pháp là Object Pooling — tái sử dụng object thay vì tạo/hủy.

**Q: GetComponent có tốn không? Làm sao tối ưu?**
> Có, GetComponent khá tốn. Nên cache nó vào biến ở Awake/Start, không gọi trong Update.

**Q: ScriptableObject dùng để làm gì?**
> Lưu trữ dữ liệu độc lập với GameObject. Dùng để tách data khỏi logic (designer chỉnh số liệu không cần code), chia sẻ data giữa nhiều object, tiết kiệm bộ nhớ.

## 15.5. Thư viện (DOTween, UniTask, Addressables)

**Q: DOTween là gì? Dùng khi nào?**
> Thư viện tween/animation — chuyển một giá trị từ A đến B mượt mà theo thời gian. Dùng cho animation UI, di chuyển, scale, fade mà không cần Animator. Ví dụ: popup xuất hiện, coin bay vào ví, health bar mượt.

**Q: Tại sao cần Kill tween khi object bị destroy?**
> Vì tween vẫn chạy sau khi object bị Destroy → cố truy cập object đã chết → lỗi. Dùng DOKill() trong OnDestroy, hoặc SetLink(gameObject) để tự động kill.

**Q: UniTask khác Coroutine thế nào?**
> UniTask hiện đại hơn: trả về được giá trị, bắt lỗi bằng try/catch chuẩn, zero allocation (không sinh rác), hủy dễ bằng CancellationToken, chạy được đa luồng. Coroutine đơn giản hơn nhưng hạn chế hơn.

**Q: CancellationToken trong UniTask để làm gì?**
> Để hủy task an toàn. Ví dụ this.GetCancellationTokenOnDestroy() tự động hủy task khi GameObject bị destroy, tránh lỗi truy cập object đã chết.

**Q: Addressables giải quyết vấn đề gì so với Resources?**
> Addressables cho phép tải tài nguyên theo nhu cầu và giải phóng khi xong (tiết kiệm RAM), tải từ server (giảm dung lượng app), cập nhật asset không cần update app. Resources thì đóng gói tất cả vào build, không unload chọn lọc được.

**Q: Trong Addressables, tại sao mỗi Load cần một Release?**
> Vì Addressables dùng reference counting. Load tăng bộ đếm tham chiếu (giữ asset trong RAM), Release giảm bộ đếm. Quên Release → asset nằm mãi trong RAM → memory leak.

## 15.6. Câu hỏi tình huống

**Q: Player đi xuyên qua tường, nguyên nhân và cách fix?**
> Có thể do: (1) Tường thiếu Collider, (2) Collider của tường tick "Is Trigger", (3) Player di chuyển bằng transform.position thay vì Rigidbody nên bỏ qua physics, (4) Tốc độ quá cao gây tunneling — fix bằng đổi Collision Detection sang Continuous.

**Q: Game chạy nhanh trên máy mạnh, chậm trên máy yếu, tại sao?**
> Vì chuyển động không nhân Time.deltaTime — tốc độ tính per frame nên phụ thuộc FPS. Fix bằng nhân Time.deltaTime để tốc độ per second.

**Q: Làm sao tạo delay 2 giây rồi thực hiện hành động?**
> Có nhiều cách: Coroutine với yield return new WaitForSeconds(2f), UniTask với await UniTask.Delay(2000), hoặc Invoke("Method", 2f). UniTask là lựa chọn hiện đại và an toàn nhất.

---

## LỜI KHUYÊN ÔN TẬP CHO JUNIOR

1. **Code thực tế hơn lý thuyết:** Phỏng vấn Junior thường yêu cầu viết code đơn giản (di chuyển object, spawn enemy, đếm điểm). Luyện viết tay không cần IDE.

2. **Nắm vững lifecycle:** Awake/Start/Update/FixedUpdate là câu hỏi gần như chắc chắn có.

3. **Hiểu rõ value/reference type:** Câu hỏi nền tảng phân biệt người hiểu C# thật sự.

4. **Biết DOTween + UniTask:** Hai thư viện này khiến CV nổi bật vì rất thực dụng.

5. **Làm 1-2 project nhỏ hoàn chỉnh:** Có demo để show quan trọng hơn nói suông. Ví dụ: Flappy Bird, endless runner, match-3 đơn giản.

6. **Chuẩn bị giải thích code của mình:** Nhà tuyển dụng thích hỏi "tại sao em làm thế này" hơn là kiến thức học thuộc.

---

*Chúc bạn phỏng vấn Junior Unity thành công! Nền tảng vững là bàn đạp lên Senior.*

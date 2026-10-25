# TÀI LIỆU ÔN TẬP PHỎNG VẤN — MIDDLE UNITY DEVELOPER

> Tài liệu cho vị trí Middle (2–4 năm kinh nghiệm): cầu nối giữa Junior và Senior. Giả định đã nắm vững fundamentals (lifecycle, OOP, physics cơ bản). Tập trung vào: tự build feature độc lập, ra quyết định kiến trúc ở mức feature, tối ưu performance/memory, và làm chủ các hệ thống con (Animation, Audio, Scene, Save, Input).  
> Trọng tâm: **production-ready code**, trade-offs, và lý do đằng sau mỗi quyết định.

---

## MỤC LỤC

| # | Chủ đề | Trọng tâm |
|---|---|---|
| 1 | C# Nâng cao | Generics, LINQ, Extension, IDisposable, boxing |
| 2 | Design Patterns Thực chiến | Singleton, Event Bus, FSM, Factory, Command, Strategy |
| 3 | Kiến trúc cơ bản | MVC/MVP, Service Locator, DI, SO Architecture, asmdef |
| 4 | Memory & Garbage Collection | GC alloc, boxing, struct vs class, giảm rác |
| 5 | Performance & Profiling | Profiler, Frame Debugger, Batching, tối ưu |
| 6 | UniTask Nâng cao | Cancellation, async architecture, patterns |
| 7 | Addressables (Intermediate) | Groups, Labels, Remote, reference counting |
| 8 | Animation System | Animator, Blend Tree, Events, code-driven |
| 9 | Audio System | AudioMixer, kiến trúc audio, pooling |
| 10 | Scene Management | Additive, async load, transition |
| 11 | Save System & Persistence | JSON, binary, ScriptableObject save |
| 12 | New Input System | Action Maps, Bindings, callbacks |
| 13 | Editor Tooling cơ bản | Attributes, custom Inspector, Gizmos |
| 14 | Git & Team Workflow | Branching, .gitignore, merge, review |
| 15 | Câu hỏi Phỏng vấn Middle | Q&A theo nhóm |

---

# 1. C# NÂNG CAO

> Middle cần nắm các tính năng C# giúp viết code tổng quát, sạch, và hiệu quả về bộ nhớ.

## 1.1. Generics

Cho phép viết code tổng quát hoạt động với nhiều kiểu mà vẫn type-safe.

```csharp
// Generic method — hoạt động với mọi kiểu T
public T GetRandom<T>(List<T> list)
{
    return list[Random.Range(0, list.Count)];
}

// Generic class
public class Pool<T> where T : Component  // Constraint: T phải là Component
{
    Queue<T> _items = new Queue<T>();
    T _prefab;

    public Pool(T prefab) => _prefab = prefab;

    public T Get()
    {
        return _items.Count > 0 ? _items.Dequeue() : Object.Instantiate(_prefab);
    }

    public void Return(T item) => _items.Enqueue(item);
}

// Sử dụng — type-safe, không cần cast
Pool<Bullet> bulletPool = new Pool<Bullet>(bulletPrefab);
Bullet b = bulletPool.Get();  // Trả về Bullet, không phải object
```

**Generic Constraints (ràng buộc):**

```csharp
where T : class           // T phải là reference type
where T : struct          // T phải là value type
where T : new()           // T phải có constructor rỗng
where T : Component        // T phải kế thừa Component
where T : IDamageable      // T phải implement interface
where T : BaseEnemy, new() // Kết hợp nhiều ràng buộc
```

**Generic Singleton — pattern thực tế:**

```csharp
public class Singleton<T> : MonoBehaviour where T : MonoBehaviour
{
    static T _instance;
    public static T Instance
    {
        get
        {
            if (_instance == null)
                _instance = FindObjectOfType<T>();
            return _instance;
        }
    }
}

// Dùng lại cho mọi manager — không lặp code
public class AudioManager : Singleton<AudioManager> { }
public class GameManager : Singleton<GameManager> { }
```

## 1.2. LINQ

Query collection ngắn gọn. **Cẩn thận:** LINQ sinh garbage, tránh dùng trong Update/hot path.

```csharp
using System.Linq;

List<Enemy> enemies = GetEnemies();

// Filter
var aliveEnemies = enemies.Where(e => e.IsAlive).ToList();

// Transform
var names = enemies.Select(e => e.name).ToList();

// Tìm
Enemy nearest = enemies.OrderBy(e => Vector3.Distance(e.transform.position, playerPos)).First();
Enemy firstBoss = enemies.FirstOrDefault(e => e.isBoss);  // null nếu không có

// Aggregate
int totalHp = enemies.Sum(e => e.hp);
float avgHp = enemies.Average(e => e.hp);
int count = enemies.Count(e => e.IsAlive);
bool anyBoss = enemies.Any(e => e.isBoss);
bool allDead = enemies.All(e => !e.IsAlive);

// Group
var byType = enemies.GroupBy(e => e.type);

// Chain
var topThreeWeakest = enemies
    .Where(e => e.IsAlive)
    .OrderBy(e => e.hp)
    .Take(3)
    .ToList();
```

> **Performance cảnh báo:** LINQ tạo iterator, delegate, và collection mới → GC alloc. Trong Update với hàng nghìn object → spike. Dùng `for` loop thủ công ở hot path, LINQ ở code chạy thưa (UI, setup).

```csharp
// HOT PATH — dùng for, không LINQ
Enemy FindNearest(List<Enemy> enemies, Vector3 pos)
{
    Enemy nearest = null;
    float minDist = float.MaxValue;
    for (int i = 0; i < enemies.Count; i++)
    {
        float dist = (enemies[i].transform.position - pos).sqrMagnitude;
        if (dist < minDist) { minDist = dist; nearest = enemies[i]; }
    }
    return nearest;
}
```

## 1.3. Extension Methods

Thêm method cho class có sẵn mà không sửa class đó.

```csharp
public static class TransformExtensions
{
    public static void ResetTransform(this Transform t)
    {
        t.position = Vector3.zero;
        t.rotation = Quaternion.identity;
        t.localScale = Vector3.one;
    }

    public static void SetX(this Transform t, float x)
    {
        var pos = t.position;
        pos.x = x;
        t.position = pos;
    }
}

public static class VectorExtensions
{
    public static Vector3 WithY(this Vector3 v, float y) => new Vector3(v.x, y, v.z);
    public static Vector2 ToVector2(this Vector3 v) => new Vector2(v.x, v.y);
}

// Dùng như method của chính class đó
transform.ResetTransform();
transform.SetX(5f);
Vector3 grounded = transform.position.WithY(0f);
```

## 1.4. IDisposable & using

Quản lý tài nguyên cần giải phóng (file, network, event subscription).

```csharp
public class EventBinder : IDisposable
{
    Action _unsubscribe;

    public EventBinder(Action subscribe, Action unsubscribe)
    {
        subscribe();
        _unsubscribe = unsubscribe;
    }

    public void Dispose() => _unsubscribe?.Invoke();
}

// using — tự động gọi Dispose() khi ra khỏi scope
using (var file = new StreamReader("data.txt"))
{
    string content = file.ReadToEnd();
}  // file.Dispose() tự động gọi ở đây
```

## 1.5. Boxing & Unboxing (quan trọng cho performance)

Boxing = đóng gói value type thành object (lên heap) → sinh garbage.

```csharp
// BOXING — value type → object (heap allocation)
int number = 42;
object boxed = number;        // BOXING - sinh garbage!
int unboxed = (int)boxed;     // UNBOXING

// Boxing ẩn thường gặp:
// 1. struct vào collection non-generic
ArrayList list = new ArrayList();
list.Add(5);                  // BOXING (dùng List<int> thay thế)

// 2. enum trong Dictionary key (gây boxing khi so sánh)
Dictionary<MyEnum, string> dict;  // Cần custom comparer để tránh boxing

// 3. String concatenation với struct
string s = "Score: " + 100;   // BOXING của int
string s2 = $"Score: {100}";  // Cũng boxing trong một số trường hợp

// 4. Truyền struct vào method nhận object
void Log(object obj) { }
Log(myVector3);               // BOXING
```

**Cách tránh:**

```csharp
// Dùng generic collection
List<int> goodList = new List<int>();  // Không boxing

// Dùng enum comparer cho Dictionary
Dictionary<MyEnum, int> dict = new Dictionary<MyEnum, int>(MyEnumComparer.Instance);

// StringBuilder cho nối chuỗi nhiều lần
var sb = new StringBuilder();
sb.Append("Score: ").Append(score);
```

## 1.6. Pattern Matching (C# hiện đại)

```csharp
// switch expression (C# 8+)
string GetRank(int score) => score switch
{
    >= 90 => "S",
    >= 80 => "A",
    >= 70 => "B",
    >= 60 => "C",
    _ => "F"
};

// Type pattern
void Process(object obj)
{
    if (obj is Enemy enemy && enemy.IsAlive)
        enemy.Attack();

    // switch với type
    string desc = obj switch
    {
        Enemy e => $"Enemy with {e.hp} HP",
        Player p => $"Player level {p.level}",
        null => "Nothing",
        _ => "Unknown"
    };
}

// Null check hiện đại
if (player is null) return;
if (player is not null) player.Move();
```

## 1.7. ref, out, in

```csharp
// out — trả về nhiều giá trị
bool TryGetTarget(out Enemy target)
{
    target = FindNearestEnemy();
    return target != null;
}
if (TryGetTarget(out var enemy)) enemy.Attack();

// ref — truyền tham chiếu, sửa được biến gốc
void AddScore(ref int score) => score += 10;
int myScore = 0;
AddScore(ref myScore);  // myScore giờ = 10

// in — truyền readonly reference (tránh copy struct lớn, không sửa được)
float Distance(in Vector3 a, in Vector3 b) => (a - b).magnitude;
```

---

# 2. DESIGN PATTERNS THỰC CHIẾN

> Middle cần biết khi nào dùng pattern nào, và viết được code thực tế. Không học thuộc — hiểu vấn đề mỗi pattern giải quyết.

## 2.1. Singleton

Một instance duy nhất, truy cập toàn cục. Dùng cho Manager (Audio, Game, Pool).

```csharp
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    void Awake()
    {
        // Đảm bảo chỉ có 1 instance
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);  // Giữ qua các scene
    }
}

// Dùng: GameManager.Instance.StartGame();
```

**Trade-offs:**
- ✅ Tiện, truy cập nhanh.
- ❌ Tight coupling, khó test, dễ thành "God Object", vấn đề thứ tự khởi tạo.
- **Lời khuyên Middle:** Dùng có chừng mực. Cân nhắc Dependency Injection cho project lớn.

## 2.2. Observer / Event Bus

Giảm phụ thuộc giữa các hệ thống. Publisher không cần biết Subscriber.

```csharp
// Static Event Bus đơn giản
public static class GameEvents
{
    public static event Action<int> OnScoreChanged;
    public static event Action OnGameOver;
    public static event Action<Enemy> OnEnemyKilled;

    public static void ScoreChanged(int score) => OnScoreChanged?.Invoke(score);
    public static void GameOver() => OnGameOver?.Invoke();
    public static void EnemyKilled(Enemy e) => OnEnemyKilled?.Invoke(e);
}

// Publisher — không biết ai lắng nghe
public class ScoreSystem : MonoBehaviour
{
    int _score;
    public void AddScore(int amount)
    {
        _score += amount;
        GameEvents.ScoreChanged(_score);  // Phát sự kiện
    }
}

// Subscriber — tự đăng ký
public class ScoreUI : MonoBehaviour
{
    void OnEnable() => GameEvents.OnScoreChanged += UpdateUI;
    void OnDisable() => GameEvents.OnScoreChanged -= UpdateUI;  // BẮT BUỘC hủy

    void UpdateUI(int score) => _text.text = $"Score: {score}";
}
```

> **Pitfall:** Static event giữ tham chiếu → quên hủy đăng ký gây memory leak + gọi vào object đã destroy. LUÔN unsubscribe ở OnDisable.

## 2.3. Finite State Machine (FSM)

Quản lý trạng thái và chuyển đổi — phổ biến cho AI, game flow, animation logic.

```csharp
// Interface cho state
public interface IState
{
    void Enter();
    void Update();
    void Exit();
}

// State cụ thể
public class PatrolState : IState
{
    EnemyAI _enemy;
    public PatrolState(EnemyAI enemy) => _enemy = enemy;

    public void Enter() => Debug.Log("Bắt đầu tuần tra");
    public void Update()
    {
        _enemy.Patrol();
        if (_enemy.CanSeePlayer())
            _enemy.ChangeState(_enemy.ChaseState);  // Chuyển state
    }
    public void Exit() => Debug.Log("Ngừng tuần tra");
}

// State Machine
public class EnemyAI : MonoBehaviour
{
    IState _currentState;
    public IState PatrolState { get; private set; }
    public IState ChaseState { get; private set; }
    public IState AttackState { get; private set; }

    void Awake()
    {
        PatrolState = new PatrolState(this);
        ChaseState = new ChaseState(this);
        AttackState = new AttackState(this);
    }

    void Start() => ChangeState(PatrolState);

    void Update() => _currentState?.Update();

    public void ChangeState(IState newState)
    {
        _currentState?.Exit();
        _currentState = newState;
        _currentState.Enter();
    }
}
```

**Trade-offs:**
- ✅ Tách logic mỗi state rõ ràng, dễ thêm state.
- ❌ Nhiều state + transitions → phức tạp. Cân nhắc Behavior Tree cho AI phức tạp.

## 2.4. Factory

Tạo object mà không lộ logic khởi tạo cho client.

```csharp
public interface IEnemy { void Spawn(Vector3 pos); }

public class EnemyFactory : MonoBehaviour
{
    [SerializeField] GameObject goblinPrefab;
    [SerializeField] GameObject archerPrefab;
    [SerializeField] GameObject bossPrefab;

    public GameObject Create(EnemyType type, Vector3 position)
    {
        GameObject prefab = type switch
        {
            EnemyType.Goblin => goblinPrefab,
            EnemyType.Archer => archerPrefab,
            EnemyType.Boss => bossPrefab,
            _ => goblinPrefab
        };
        return Instantiate(prefab, position, Quaternion.identity);
    }
}

// Client không cần biết prefab nào, logic nào
enemyFactory.Create(EnemyType.Boss, spawnPoint.position);
```

## 2.5. Command

Đóng gói hành động thành object — dùng cho Undo/Redo, input remapping, replay.

```csharp
public interface ICommand
{
    void Execute();
    void Undo();
}

public class MoveCommand : ICommand
{
    Transform _target;
    Vector3 _direction;

    public MoveCommand(Transform target, Vector3 direction)
    {
        _target = target;
        _direction = direction;
    }

    public void Execute() => _target.position += _direction;
    public void Undo() => _target.position -= _direction;
}

// Command Manager với undo
public class CommandManager
{
    Stack<ICommand> _history = new Stack<ICommand>();

    public void Execute(ICommand command)
    {
        command.Execute();
        _history.Push(command);
    }

    public void Undo()
    {
        if (_history.Count > 0)
            _history.Pop().Undo();
    }
}
```

## 2.6. Object Pool (Production)

Unity 2021+ có sẵn `ObjectPool<T>`.

```csharp
using UnityEngine.Pool;

public class BulletSpawner : MonoBehaviour
{
    [SerializeField] Bullet bulletPrefab;
    ObjectPool<Bullet> _pool;

    void Awake()
    {
        _pool = new ObjectPool<Bullet>(
            createFunc: () => Instantiate(bulletPrefab),
            actionOnGet: bullet => bullet.gameObject.SetActive(true),
            actionOnRelease: bullet => bullet.gameObject.SetActive(false),
            actionOnDestroy: bullet => Destroy(bullet.gameObject),
            collectionCheck: false,
            defaultCapacity: 20,
            maxSize: 100
        );
    }

    public Bullet Spawn(Vector3 pos)
    {
        Bullet bullet = _pool.Get();
        bullet.transform.position = pos;
        bullet.SetPool(_pool);  // Bullet tự return về pool
        return bullet;
    }
}

// Trong Bullet
public class Bullet : MonoBehaviour
{
    IObjectPool<Bullet> _pool;
    public void SetPool(IObjectPool<Bullet> pool) => _pool = pool;

    void OnBecameInvisible() => _pool.Release(this);  // Return thay vì Destroy
}
```

## 2.7. Strategy

Hoán đổi thuật toán tại runtime.

```csharp
public interface IMovementStrategy
{
    void Move(Transform target, Vector3 destination);
}

public class WalkStrategy : IMovementStrategy
{
    public void Move(Transform t, Vector3 dest)
        => t.position = Vector3.MoveTowards(t.position, dest, 3f * Time.deltaTime);
}

public class TeleportStrategy : IMovementStrategy
{
    public void Move(Transform t, Vector3 dest) => t.position = dest;
}

// Đổi chiến lược linh hoạt
public class Character : MonoBehaviour
{
    IMovementStrategy _movement = new WalkStrategy();

    public void SetMovement(IMovementStrategy strategy) => _movement = strategy;

    void Update() => _movement.Move(transform, _destination);
}
```

## 2.8. Bảng tổng hợp — Khi nào dùng Pattern nào

| Pattern | Vấn đề giải quyết | Ví dụ game |
|---|---|---|
| **Singleton** | Cần 1 instance toàn cục | GameManager, AudioManager |
| **Observer/Event** | Giảm coupling giữa hệ thống | Score → UI, Achievement, Sound |
| **FSM** | Quản lý trạng thái + chuyển đổi | AI, game flow, character state |
| **Factory** | Tạo object linh hoạt | Spawn nhiều loại enemy/item |
| **Command** | Đóng gói hành động | Undo/redo, input remap, replay |
| **Object Pool** | Tránh tạo/hủy liên tục | Đạn, particle, enemy |
| **Strategy** | Hoán đổi thuật toán | AI behavior, movement, attack |

---

# 3. KIẾN TRÚC CƠ BẢN

> Middle bắt đầu ra quyết định kiến trúc ở mức feature. Cần hiểu các pattern tổ chức code và khi nào dùng.

## 3.1. Tách Logic khỏi MonoBehaviour

Nguyên tắc cốt lõi: logic game nên độc lập với Unity càng nhiều càng tốt → dễ test, dễ tái sử dụng.

```csharp
// Logic thuần C# — testable, không phụ thuộc Unity
public class HealthSystem
{
    public int CurrentHp { get; private set; }
    public int MaxHp { get; private set; }
    public bool IsDead => CurrentHp <= 0;

    public event Action<int> OnHpChanged;
    public event Action OnDeath;

    public HealthSystem(int maxHp)
    {
        MaxHp = maxHp;
        CurrentHp = maxHp;
    }

    public void TakeDamage(int dmg)
    {
        if (IsDead) return;
        CurrentHp = Mathf.Max(0, CurrentHp - dmg);
        OnHpChanged?.Invoke(CurrentHp);
        if (IsDead) OnDeath?.Invoke();
    }
}

// MonoBehaviour chỉ là "vỏ" kết nối logic với Unity
public class PlayerHealth : MonoBehaviour
{
    [SerializeField] int maxHp = 100;
    HealthSystem _health;

    void Awake()
    {
        _health = new HealthSystem(maxHp);
        _health.OnDeath += HandleDeath;
    }

    public void TakeDamage(int dmg) => _health.TakeDamage(dmg);
    void HandleDeath() => Destroy(gameObject);
}
```

## 3.2. MVC / MVP cho UI

**MVP (Model-View-Presenter)** — phổ biến cho UI vì testable.

```csharp
// Model — data
public class ShopModel
{
    public int Gold { get; private set; }
    public event Action<int> OnGoldChanged;

    public bool TryBuy(int price)
    {
        if (Gold < price) return false;
        Gold -= price;
        OnGoldChanged?.Invoke(Gold);
        return true;
    }
}

// View — chỉ hiển thị (interface để test được)
public interface IShopView
{
    event Action<ItemData> OnBuyClicked;
    void UpdateGold(int gold);
    void ShowMessage(string msg);
}

public class ShopView : MonoBehaviour, IShopView
{
    public event Action<ItemData> OnBuyClicked;
    public void UpdateGold(int gold) => _goldText.text = $"{gold}";
    public void ShowMessage(string msg) => _msgText.text = msg;
}

// Presenter — kết nối, chứa logic (pure C#, testable)
public class ShopPresenter
{
    ShopModel _model;
    IShopView _view;

    public ShopPresenter(ShopModel model, IShopView view)
    {
        _model = model;
        _view = view;
        _view.OnBuyClicked += OnBuy;
        _model.OnGoldChanged += _view.UpdateGold;
    }

    void OnBuy(ItemData item)
    {
        bool success = _model.TryBuy(item.price);
        _view.ShowMessage(success ? "Đã mua!" : "Không đủ tiền");
    }
}
```

> **Middle nên biết:** MVP làm Presenter testable không cần scene. MVC đơn giản hơn nhưng Controller dễ phình to. MVVM (data binding) mạnh hơn nhưng cần thư viện reactive (R3/UniRx) — thường là kiến thức Senior.

## 3.3. ScriptableObject Architecture

Pattern mạnh của Unity — dùng SO làm data, event channel, runtime variable.

```csharp
// Runtime Variable — biến chia sẻ giữa nhiều object qua asset
[CreateAssetMenu(menuName = "Variables/IntVariable")]
public class IntVariable : ScriptableObject
{
    public int Value;
    public void SetValue(int value) => Value = value;
    public void Add(int amount) => Value += amount;
}

// Event Channel — event qua SO asset
[CreateAssetMenu(menuName = "Events/GameEvent")]
public class GameEvent : ScriptableObject
{
    readonly List<Action> _listeners = new();

    public void Raise()
    {
        for (int i = _listeners.Count - 1; i >= 0; i--)
            _listeners[i]?.Invoke();
    }

    public void Register(Action listener) => _listeners.Add(listener);
    public void Unregister(Action listener) => _listeners.Remove(listener);
}
```

**Lợi ích:** Designer wire logic qua Inspector (kéo thả asset), giảm hardcode reference, loose coupling.

## 3.4. Service Locator vs Dependency Injection

**Service Locator** — đăng ký và lấy service toàn cục.

```csharp
public static class ServiceLocator
{
    static Dictionary<Type, object> _services = new();

    public static void Register<T>(T service) => _services[typeof(T)] = service;
    public static T Get<T>() => (T)_services[typeof(T)];
}

// Đăng ký lúc khởi tạo
ServiceLocator.Register<IAudioService>(new AudioService());
// Dùng bất cứ đâu
ServiceLocator.Get<IAudioService>().Play("sfx");
```

**Dependency Injection (VContainer/Zenject)** — inject dependency từ ngoài.

```csharp
// VContainer
public class GameScope : LifetimeScope
{
    protected override void Configure(IContainerBuilder builder)
    {
        builder.Register<IAudioService, AudioService>(Lifetime.Singleton);
        builder.RegisterComponentInHierarchy<Player>();
    }
}

public class Player : MonoBehaviour
{
    [Inject] IAudioService _audio;  // Tự động được inject
}
```

| | Service Locator | Dependency Injection |
|---|---|---|
| Dependency | Ẩn (gọi trong code) | Rõ ràng (constructor/field) |
| Testability | Khó hơn | Dễ mock |
| Setup | Đơn giản | Cần framework |
| Khi nào | Project nhỏ/vừa | Project lớn, cần test |

## 3.5. Assembly Definitions (asmdef)

Chia project thành modules → compile nhanh hơn, enforce dependency.

```
Game.Core          (logic thuần C#, không Unity)
Game.Runtime       (MonoBehaviour, refs Core)
Game.UI            (refs Runtime)
Game.Editor        (Editor tools, includePlatforms: Editor)
Game.Tests         (refs Runtime + Core)
```

**Lợi ích:** Sửa code UI không recompile toàn project, chỉ recompile Game.UI. Trong project lớn tiết kiệm hàng phút mỗi lần compile.

---

# 4. MEMORY & GARBAGE COLLECTION

> Middle cần hiểu GC để viết code không giật. Đây là khác biệt lớn với Junior.

## 4.1. Managed Heap & Garbage Collector

```
Unity có 2 vùng bộ nhớ:
- Native Heap (C++): Asset thật (texture, mesh, audio) — engine quản lý
- Managed Heap (C#): Object C# bạn tạo — Garbage Collector quản lý

GC chạy → tạm dừng game (Stop-The-World) → quét object không dùng → giải phóng
→ Nếu sinh nhiều rác, GC chạy thường xuyên → GIẬT HÌNH (spike)
```

**Mục tiêu Middle:** Giảm GC allocation trong vòng lặp gameplay xuống gần **0 bytes/frame**.

## 4.2. Các nguồn GC Allocation thường gặp

```csharp
// 1. Tạo object mới mỗi frame
void Update()
{
    Vector3[] path = new Vector3[10];  // ALLOC mỗi frame!
    List<Enemy> list = new List<Enemy>();  // ALLOC!
}

// 2. String operations
void Update()
{
    string s = "Score: " + score;  // ALLOC (string immutable)
    scoreText.text = score.ToString();  // ALLOC
}

// 3. Boxing
void Update()
{
    object boxed = 42;  // ALLOC
}

// 4. LINQ
void Update()
{
    var alive = enemies.Where(e => e.IsAlive).ToList();  // ALLOC nhiều
}

// 5. Closures / Lambda capture
void Update()
{
    int local = 5;
    Action a = () => Debug.Log(local);  // ALLOC closure
}

// 6. foreach trên một số collection (Dictionary, custom)
// → có thể tạo enumerator allocation (Unity đã tối ưu List/Array)

// 7. GetComponents trả về array mới
Component[] comps = GetComponents<Renderer>();  // ALLOC
```

## 4.3. Cách giảm GC Allocation

```csharp
// 1. Cache và tái sử dụng
List<Enemy> _reusableList = new List<Enemy>();  // Tạo 1 lần
void Update()
{
    _reusableList.Clear();  // Clear thay vì new
    // ... dùng lại
}

// 2. Non-allocating API
void Update()
{
    // GetComponents version không alloc
    GetComponents<Renderer>(_rendererList);  // Truyền list có sẵn

    // Physics non-alloc
    int count = Physics.RaycastNonAlloc(ray, _hitBuffer, 100f);
    int overlaps = Physics.OverlapSphereNonAlloc(pos, radius, _colliderBuffer);
}

// 3. StringBuilder cho chuỗi động
StringBuilder _sb = new StringBuilder(64);
void UpdateScoreText()
{
    _sb.Clear();
    _sb.Append("Score: ").Append(score);
    scoreText.SetText(_sb);  // TMP hỗ trợ StringBuilder không alloc
}

// 4. Struct thay class cho data nhỏ ngắn hạn
struct DamageInfo  // value type, trên stack
{
    public int amount;
    public Vector3 hitPoint;
}

// 5. Cache WaitForSeconds (Coroutine)
readonly WaitForSeconds _wait = new WaitForSeconds(1f);

// 6. Object Pooling thay Instantiate/Destroy

// 7. Tránh capture biến trong lambda hot path
```

## 4.4. Struct vs Class — quyết định performance

```csharp
// Struct (value type):
// + Trên stack (không GC nếu là local)
// + Tốt cho data nhỏ, ngắn hạn (Vector, color, damage info)
// - Copy khi truyền (tốn nếu struct lớn)
// - Không kế thừa

// Class (reference type):
// + Truyền reference (rẻ)
// + Kế thừa, polymorphism
// - Trên heap (GC managed)

// Quy tắc: struct nếu < 16 bytes, ngắn hạn, immutable. Class cho còn lại.
```

## 4.5. Incremental GC

```
Project Settings → Player → Use Incremental GC ✅
```

Chia GC thành nhiều phần nhỏ qua nhiều frame thay vì một cú dừng lớn → giảm spike. **Vẫn phải giảm alloc** — Incremental GC chỉ giảm tác động khi GC bắt buộc chạy.

## 4.6. Profiler — đo GC

```
Window → Analysis → Profiler → CPU module
→ Bật "GC Alloc" column
→ Tìm function có GC Alloc > 0 trong gameplay loop
→ Deep Profile để định vị chính xác dòng code
```

---

# 5. PERFORMANCE & PROFILING

> "Đừng đoán, hãy đo." Middle cần biết dùng tools để tìm bottleneck thật.

## 5.1. Unity Profiler — công cụ chính

```
Window → Analysis → Profiler

Các module quan trọng:
- CPU Usage: thời gian mỗi function, tìm spike
- GPU Usage: thời gian render
- Memory: RAM, GC alloc
- Rendering: draw calls, batches, triangles
- Physics: số rigidbody, collision
```

**Quy trình tìm spike:**

```
1. Chạy game, quan sát đồ thị CPU
2. Thấy cột cao đột biến (spike) → click vào frame đó
3. Xem Hierarchy → function nào tốn nhiều ms nhất
4. Nếu là GC.Collect → có vấn đề allocation
5. Bật Deep Profile để xem chi tiết từng dòng (chậm nhưng chính xác)
```

## 5.2. Frame Debugger

```
Window → Analysis → Frame Debugger → Enable

→ Xem từng draw call được vẽ theo thứ tự
→ Phát hiện tại sao object không batch được
→ Lý do thường gặp: khác material, khác texture, có animation
```

## 5.3. Draw Call & Batching

```
Draw Call = lệnh CPU bảo GPU vẽ.
Quá nhiều draw call → CPU nghẽn → FPS giảm.

Cách giảm:
- Static Batching: tick "Static" cho object tĩnh
- SRP Batcher: bật trong URP (giảm SetPass call)
- GPU Instancing: nhiều object cùng mesh + material
- Texture Atlas: gộp nhiều texture thành 1 → batch được
- Sprite Atlas: cho UI/2D
```

**Kiểm tra trong Stats (Game view):**

```
Game view → Stats button
- Batches: số batch (thấp = tốt)
- SetPass calls: số lần đổi shader/material (thấp = tốt)
- Tris/Verts: số tam giác/đỉnh
```

## 5.4. Các bottleneck thường gặp & cách fix

| Triệu chứng | Nguyên nhân | Fix |
|---|---|---|
| Spike định kỳ | GC allocation | Giảm alloc, object pool |
| FPS thấp đều | Quá nhiều draw call | Batching, atlas |
| FPS thấp khi nhiều object | Update() nhiều | Manager pattern, ECS |
| Giật khi spawn | Instantiate nặng | Object pool, async |
| Giật lần đầu hiện effect | Shader compile | Shader warmup |
| Nóng máy, FPS tụt sau vài phút | Thermal throttling | Giảm tải, cap FPS |

## 5.5. Tối ưu thực tế — checklist Middle

```
CPU:
[ ] Cache GetComponent (không gọi trong Update)
[ ] Object pooling cho object tạo/hủy nhiều
[ ] Giảm GC alloc (StringBuilder, non-alloc API)
[ ] Tắt Update() không cần thiết
[ ] Dùng CompareTag thay tag ==

GPU:
[ ] Giảm draw call (batching, atlas)
[ ] Giảm overdraw (UI trong suốt chồng nhau)
[ ] Texture compression đúng (ASTC mobile)
[ ] Tắt mipmap cho UI sprite
[ ] LOD cho model phức tạp

Memory:
[ ] Unload asset không dùng (Addressables.Release)
[ ] Texture size hợp lý (không để 2048 mặc định)
[ ] Audio: Streaming cho nhạc, DecompressOnLoad cho SFX ngắn
```

## 5.6. Mobile-specific

```csharp
// Cap frame rate (tiết kiệm pin, tránh nóng máy)
void Start()
{
    Application.targetFrameRate = 60;  // hoặc 30 cho game nhẹ
    QualitySettings.vSyncCount = 0;    // tắt vsync trên mobile
}
```

```
Mobile budget tham khảo (mid-range):
- Draw calls: < 100
- Triangles: < 400k tổng scene
- Texture memory: 40-60% tổng RAM game
- Target: 60 FPS (game nhẹ) hoặc ổn định 30 FPS
```

---

# 6. UNITASK NÂNG CAO

> Junior biết async cơ bản. Middle cần làm chủ cancellation, error handling, và kiến trúc async cho feature thực tế.

## 6.1. Cancellation Patterns

```csharp
// Pattern 1: Token theo vòng đời object
public class Enemy : MonoBehaviour
{
    async UniTaskVoid Start()
    {
        var token = this.GetCancellationTokenOnDestroy();
        await BehaviorLoopAsync(token);
    }

    async UniTask BehaviorLoopAsync(CancellationToken token)
    {
        while (!token.IsCancellationRequested)
        {
            await PatrolAsync(token);
            await UniTask.Delay(1000, cancellationToken: token);
        }
    }
}

// Pattern 2: Linked token (kết hợp nhiều điều kiện hủy)
async UniTask DoWithTimeoutAsync(CancellationToken externalToken)
{
    using var timeoutCts = new CancellationTokenSource(TimeSpan.FromSeconds(5));
    using var linkedCts = CancellationTokenSource.CreateLinkedTokenSource(
        externalToken, timeoutCts.Token);

    // Hủy nếu external HOẶC timeout 5s
    await LongOperationAsync(linkedCts.Token);
}

// Pattern 3: Hủy task cũ khi bắt đầu task mới (search, debounce)
CancellationTokenSource _searchCts;

async void OnSearchInput(string query)
{
    _searchCts?.Cancel();  // Hủy search cũ
    _searchCts = new CancellationTokenSource();

    try
    {
        await UniTask.Delay(300, cancellationToken: _searchCts.Token);  // Debounce
        var results = await SearchAsync(query, _searchCts.Token);
        ShowResults(results);
    }
    catch (OperationCanceledException) { /* Bị hủy bởi input mới — bỏ qua */ }
}
```

## 6.2. Error Handling đúng cách

```csharp
async UniTask LoadGameDataAsync(CancellationToken token)
{
    try
    {
        var data = await DownloadDataAsync(token);
        ProcessData(data);
    }
    catch (OperationCanceledException)
    {
        // Hủy — KHÔNG phải lỗi, không log error
        throw;  // Re-throw để caller biết đã hủy
    }
    catch (TimeoutException)
    {
        ShowRetryDialog();
    }
    catch (Exception e)
    {
        Debug.LogError($"Load thất bại: {e}");
        ShowErrorDialog();
    }
}
```

## 6.3. Timeout

```csharp
// Cách 1: TimeoutController (UniTask)
async UniTask WithTimeoutAsync()
{
    var timeout = new TimeoutController();
    try
    {
        await DownloadAsync().AttachExternalCancellation(
            timeout.Timeout(TimeSpan.FromSeconds(10)));
        timeout.Reset();
    }
    catch (OperationCanceledException)
    {
        Debug.Log("Timeout!");
    }
}

// Cách 2: WhenAny với delay
async UniTask<bool> TryWithTimeoutAsync(UniTask task, float seconds)
{
    int winner = await UniTask.WhenAny(task, UniTask.Delay(TimeSpan.FromSeconds(seconds)));
    return winner == 0;  // true nếu task xong trước timeout
}
```

## 6.4. Progress Reporting

```csharp
async UniTask LoadWithProgressAsync(IProgress<float> progress, CancellationToken token)
{
    for (int i = 0; i <= 100; i += 10)
    {
        await LoadChunkAsync(i, token);
        progress?.Report(i / 100f);  // Báo tiến độ
    }
}

// Sử dụng
var progress = Progress.Create<float>(value => loadingBar.value = value);
await LoadWithProgressAsync(progress, token);
```

## 6.5. Kiến trúc async cho feature

```csharp
// Loading flow hoàn chỉnh
public class GameLoader : MonoBehaviour
{
    async UniTaskVoid Start()
    {
        var token = this.GetCancellationTokenOnDestroy();
        await LoadGameAsync(token);
    }

    async UniTask LoadGameAsync(CancellationToken token)
    {
        ShowLoadingScreen();

        // Tải song song những thứ độc lập
        await UniTask.WhenAll(
            LoadConfigAsync(token),
            LoadAudioAsync(token),
            WarmupShadersAsync(token)
        );

        // Tải tuần tự những thứ phụ thuộc
        var saveData = await LoadSaveDataAsync(token);
        await LoadSceneAsync(saveData.lastScene, token);

        HideLoadingScreen();
    }
}
```

## 6.6. UniTask + DOTween

```csharp
async UniTask PlayIntroSequenceAsync(CancellationToken token)
{
    await logo.transform.DOScale(1f, 0.5f).SetEase(Ease.OutBack)
        .ToUniTask(cancellationToken: token);

    await UniTask.Delay(1000, cancellationToken: token);

    await logo.DOFade(0f, 0.3f).ToUniTask(cancellationToken: token);
}
```

---

# 7. ADDRESSABLES (INTERMEDIATE)

> Junior biết load/release. Middle cần hiểu Groups, Labels, Remote content, và quản lý bộ nhớ chặt chẽ.

## 7.1. Groups & Bundle Strategy

```
Addressables Groups → tổ chức asset thành bundles

Chiến lược đóng gói:
- Pack Together: tất cả asset trong group → 1 bundle (ít file, load nhiều thừa)
- Pack Separately: mỗi asset → 1 bundle (nhiều file, load chính xác)
- Pack Together By Label: nhóm theo label

Quy tắc:
- Asset hay load cùng nhau → cùng group (UI của 1 màn)
- Asset lớn, load riêng lẻ → Pack Separately (character, level)
```

## 7.2. Labels — load nhóm asset

```csharp
// Gán label cho nhiều asset (vd: "level1", "characters")
// Load tất cả asset có label

async UniTask LoadLevelAssetsAsync(CancellationToken token)
{
    var handle = Addressables.LoadAssetsAsync<GameObject>(
        "level1",  // label
        obj => Debug.Log($"Loaded {obj.name}")  // callback mỗi asset
    );

    IList<GameObject> assets = await handle.ToUniTask(cancellationToken: token);
    // Lưu handle để Release sau
    _levelHandle = handle;
}
```

## 7.3. Reference Counting — quản lý bộ nhớ

```
Mỗi asset có bộ đếm tham chiếu (ref count):
- LoadAssetAsync → ref count +1
- Release → ref count -1
- ref count = 0 → asset unload khỏi RAM

Quy tắc vàng: Load bao nhiêu lần, Release bấy nhiêu lần.
```

```csharp
public class CharacterManager : MonoBehaviour
{
    Dictionary<string, AsyncOperationHandle<GameObject>> _handles = new();

    public async UniTask<GameObject> LoadCharacterAsync(string key, CancellationToken token)
    {
        if (_handles.TryGetValue(key, out var existing))
            return existing.Result;  // Đã load

        var handle = Addressables.LoadAssetAsync<GameObject>(key);
        _handles[key] = handle;
        return await handle.ToUniTask(cancellationToken: token);
    }

    public void ReleaseCharacter(string key)
    {
        if (_handles.TryGetValue(key, out var handle))
        {
            Addressables.Release(handle);
            _handles.Remove(key);
        }
    }

    void OnDestroy()
    {
        foreach (var handle in _handles.Values)
            Addressables.Release(handle);  // Giải phóng tất cả
        _handles.Clear();
    }
}
```

## 7.4. InstantiateAsync vs LoadAssetAsync

```csharp
// LoadAssetAsync — load prefab, tự Instantiate
var handle = Addressables.LoadAssetAsync<GameObject>("Enemy");
await handle.Task;
GameObject instance = Instantiate(handle.Result);
// Release handle khi không cần asset nữa
// Destroy(instance) bình thường

// InstantiateAsync — load + instantiate trong 1 lệnh
var instance = await Addressables.InstantiateAsync("Enemy").ToUniTask();
// PHẢI dùng ReleaseInstance, KHÔNG dùng Destroy
Addressables.ReleaseInstance(instance);
```

> **Pitfall:** Trộn lẫn `Destroy()` với object tạo bởi `InstantiateAsync` → ref count sai → memory leak. Nhất quán: InstantiateAsync ↔ ReleaseInstance.

## 7.5. Remote Content (CDN)

```
Cấu hình Remote:
1. Addressables Settings → Build/Load Paths → Remote
2. Đặt RemoteLoadPath = URL server (CDN)
3. Build → upload bundles + catalog lên server
4. Game tải bundle từ server khi cần

Lợi ích:
- Giảm dung lượng app ban đầu
- Cập nhật content không cần update app (đổi bundle trên server)
- DLC, seasonal content
```

```csharp
// Kiểm tra & tải update catalog
async UniTask CheckForUpdatesAsync(CancellationToken token)
{
    var checkHandle = Addressables.CheckForCatalogUpdates();
    List<string> catalogs = await checkHandle.ToUniTask(cancellationToken: token);

    if (catalogs.Count > 0)
    {
        var updateHandle = Addressables.UpdateCatalogs(catalogs);
        await updateHandle.ToUniTask(cancellationToken: token);
        Debug.Log("Đã cập nhật content!");
    }
}

// Tải trước (preload) với kiểm tra dung lượng
async UniTask PreloadAsync(string key, CancellationToken token)
{
    var sizeHandle = Addressables.GetDownloadSizeAsync(key);
    long size = await sizeHandle.ToUniTask(cancellationToken: token);

    if (size > 0)
    {
        Debug.Log($"Cần tải {size / 1024 / 1024} MB");
        var downloadHandle = Addressables.DownloadDependenciesAsync(key);
        await downloadHandle.ToUniTask(cancellationToken: token);
    }
}
```

## 7.6. Common Pitfalls

```
1. Quên Release → memory leak (asset nằm mãi trong RAM)
2. Release quá nhiều → ref count âm → lỗi
3. Trộn Destroy với InstantiateAsync
4. Mất handle reference → không Release được
5. Load trong Update mà không cache → load lặp
6. Duplicate asset: asset phụ thuộc không Addressable bị nhân bản vào nhiều bundle
   → dùng Addressables Analyze để phát hiện
```

---

# 8. ANIMATION SYSTEM

> Middle cần làm chủ Animator Controller, Blend Tree, Animation Events, và điều khiển bằng code.

## 8.1. Animator Controller cơ bản

```csharp
public class PlayerAnimator : MonoBehaviour
{
    Animator _anim;

    // Cache parameter hash (nhanh hơn dùng string)
    static readonly int SpeedHash = Animator.StringToHash("Speed");
    static readonly int JumpHash = Animator.StringToHash("Jump");
    static readonly int IsGroundedHash = Animator.StringToHash("IsGrounded");

    void Awake() => _anim = GetComponent<Animator>();

    void Update()
    {
        // Set parameters
        _anim.SetFloat(SpeedHash, _velocity.magnitude);
        _anim.SetBool(IsGroundedHash, _isGrounded);

        if (Input.GetButtonDown("Jump"))
            _anim.SetTrigger(JumpHash);
    }
}
```

> **Best practice:** Dùng `Animator.StringToHash` cache thay vì truyền string mỗi lần → tránh string lookup + GC.

## 8.2. Animation Parameters

| Loại | Dùng cho | API |
|---|---|---|
| Float | Giá trị liên tục (speed, blend) | `SetFloat` |
| Int | Số nguyên (state index) | `SetInteger` |
| Bool | Trạng thái bật/tắt (isGrounded) | `SetBool` |
| Trigger | Sự kiện 1 lần (jump, attack) | `SetTrigger` |

## 8.3. Blend Tree

```
Blend Tree — pha trộn nhiều animation theo parameter
Ví dụ: Idle → Walk → Run theo Speed (0 → 0.5 → 1)

1D Blend Tree: blend theo 1 parameter (Speed)
2D Blend Tree: blend theo 2 parameter (di chuyển 8 hướng: X, Y)

→ Tạo chuyển động mượt thay vì cắt cứng giữa các clip
```

## 8.4. Animation Events

Gọi method từ animation tại frame cụ thể (vd: gây damage đúng lúc kiếm chạm).

```csharp
public class AttackAnimation : MonoBehaviour
{
    // Method này được gọi từ Animation Event (cắm vào clip ở frame kiếm chạm)
    public void OnAttackHit()
    {
        // Gây damage đúng thời điểm
        var hits = Physics.OverlapSphere(attackPoint.position, attackRadius);
        foreach (var hit in hits)
            if (hit.TryGetComponent<IDamageable>(out var target))
                target.TakeDamage(damage);
    }

    public void OnFootstep()  // Gọi mỗi bước chân
    {
        AudioManager.Instance.PlayFootstep();
    }
}
```

## 8.5. State Machine Behaviour

```csharp
// Script gắn vào state trong Animator → chạy khi vào/ra state
public class AttackStateBehaviour : StateMachineBehaviour
{
    public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        // Khi vào state Attack
        animator.GetComponent<PlayerCombat>().OnAttackStart();
    }

    public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        // Khi ra khỏi state Attack
        animator.GetComponent<PlayerCombat>().OnAttackEnd();
    }
}
```

## 8.6. Chờ animation xong (với UniTask)

```csharp
async UniTask PlayAttackAndWaitAsync(CancellationToken token)
{
    _anim.SetTrigger(AttackHash);

    // Chờ animation Attack bắt đầu
    await UniTask.WaitUntil(() =>
        _anim.GetCurrentAnimatorStateInfo(0).IsName("Attack"), cancellationToken: token);

    // Chờ animation chạy xong
    await UniTask.WaitUntil(() =>
        _anim.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1f, cancellationToken: token);

    Debug.Log("Attack xong");
}
```

## 8.7. Animator vs DOTween vs Code

| Cách | Khi nào dùng |
|---|---|
| **Animator** | Animation phức tạp, character, có state machine |
| **DOTween** | UI animation, tween đơn giản (move, scale, fade) |
| **Code thuần** | Logic procedural (follow, lerp đơn giản) |

> **Lời khuyên:** Đừng dùng Animator cho mọi thứ. UI popup chỉ cần DOTween nhẹ hơn nhiều. Animator nặng hơn (state machine overhead).

---

# 9. AUDIO SYSTEM

> Middle cần build audio system có kiến trúc, không chỉ AudioSource.Play rời rạc.

## 9.1. AudioMixer

```
AudioMixer — quản lý âm thanh theo nhóm (groups) với hiệu ứng

Cấu trúc thường dùng:
Master
├── BGM (nhạc nền)
├── SFX (hiệu ứng)
└── Voice (lời thoại)

→ Điều chỉnh volume từng nhóm độc lập
→ Áp dụng effect (reverb, lowpass) theo nhóm
```

```csharp
using UnityEngine.Audio;

public class AudioSettings : MonoBehaviour
{
    [SerializeField] AudioMixer _mixer;

    // Set volume (dùng dB, không phải linear)
    public void SetBGMVolume(float linear)
    {
        // Chuyển linear (0-1) sang dB (-80 đến 0)
        float db = linear > 0.0001f ? Mathf.Log10(linear) * 20f : -80f;
        _mixer.SetFloat("BGMVolume", db);  // "BGMVolume" = exposed parameter
    }
}
```

> **Pitfall:** Volume trong AudioMixer dùng **decibel (logarithmic)**, không phải linear 0-1. Slider UI (0-1) cần convert sang dB qua `Log10(value) * 20`.

## 9.2. Audio Manager với Pooling

```csharp
public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance { get; private set; }

    [SerializeField] AudioSource _bgmSource;
    [SerializeField] int _sfxPoolSize = 10;

    Queue<AudioSource> _sfxPool = new();

    void Awake()
    {
        Instance = this;
        DontDestroyOnLoad(gameObject);

        // Tạo pool AudioSource cho SFX
        for (int i = 0; i < _sfxPoolSize; i++)
        {
            var go = new GameObject($"SFX_{i}");
            go.transform.SetParent(transform);
            var source = go.AddComponent<AudioSource>();
            source.playOnAwake = false;
            _sfxPool.Enqueue(source);
        }
    }

    public void PlayBGM(AudioClip clip, bool loop = true)
    {
        _bgmSource.clip = clip;
        _bgmSource.loop = loop;
        _bgmSource.Play();
    }

    public void PlaySFX(AudioClip clip, float volume = 1f)
    {
        if (clip == null) return;

        var source = _sfxPool.Dequeue();
        source.clip = clip;
        source.volume = volume;
        source.Play();
        _sfxPool.Enqueue(source);  // Đưa lại cuối queue
    }

    // Fade BGM khi chuyển scene (với DOTween)
    public async UniTask CrossfadeBGMAsync(AudioClip newClip, float duration)
    {
        await _bgmSource.DOFade(0f, duration / 2).ToUniTask();
        _bgmSource.clip = newClip;
        _bgmSource.Play();
        await _bgmSource.DOFade(1f, duration / 2).ToUniTask();
    }
}
```

## 9.3. Audio Import Settings (quan trọng cho memory)

| Loại âm thanh | Load Type | Compression | Lý do |
|---|---|---|---|
| **SFX ngắn** (< 1s) | Decompress On Load | ADPCM/PCM | Phát tức thì, giải nén sẵn |
| **BGM dài** | Streaming | Vorbis | Stream từ disk, tiết kiệm RAM |
| **SFX vừa** | Compressed In Memory | Vorbis | Cân bằng |

> **Pitfall:** Để BGM dài ở "Decompress On Load" → giải nén toàn bộ vào RAM → tốn hàng chục MB. Phải dùng Streaming.

## 9.4. Kiến trúc Audio với ScriptableObject

```csharp
// SO chứa data audio — designer wire không cần code
[CreateAssetMenu(menuName = "Audio/SoundEffect")]
public class SoundEffect : ScriptableObject
{
    public AudioClip[] clips;  // Random giữa nhiều clip (tránh nhàm)
    [Range(0f, 1f)] public float volume = 1f;
    [Range(0.8f, 1.2f)] public float pitchMin = 0.95f;
    [Range(0.8f, 1.2f)] public float pitchMax = 1.05f;

    public AudioClip GetRandomClip() => clips[Random.Range(0, clips.Length)];
    public float GetRandomPitch() => Random.Range(pitchMin, pitchMax);
}

// Dùng
[SerializeField] SoundEffect _jumpSound;
void Jump() => AudioManager.Instance.PlaySFX(_jumpSound);
```

---

# 10. SCENE MANAGEMENT

> Middle cần load scene mượt, additive scenes, và quản lý chuyển cảnh.

## 10.1. Load Scene cơ bản

```csharp
using UnityEngine.SceneManagement;

// Load thay thế (unload scene cũ)
SceneManager.LoadScene("GameScene");
SceneManager.LoadScene(1);  // theo build index

// Load thêm (giữ scene cũ)
SceneManager.LoadScene("UIScene", LoadSceneMode.Additive);
```

## 10.2. Async Load với Loading Screen

```csharp
async UniTask LoadSceneAsync(string sceneName, CancellationToken token)
{
    loadingScreen.SetActive(true);

    var op = SceneManager.LoadSceneAsync(sceneName);
    op.allowSceneActivation = false;  // Chưa kích hoạt ngay

    // Cập nhật progress bar
    while (op.progress < 0.9f)  // progress dừng ở 0.9 khi chưa activate
    {
        loadingBar.value = op.progress;
        await UniTask.Yield(token);
    }

    loadingBar.value = 1f;
    await UniTask.Delay(300, cancellationToken: token);  // Mượt

    op.allowSceneActivation = true;  // Kích hoạt scene
    await op.ToUniTask(cancellationToken: token);

    loadingScreen.SetActive(false);
}
```

> **Lưu ý:** `allowSceneActivation = false` làm progress dừng ở 0.9 (90%). 10% còn lại là activation. Đây là hành vi bình thường của Unity.

## 10.3. Additive Scenes — Kiến trúc

```
Chia game thành nhiều scene load đồng thời:
- PersistentScene: GameManager, AudioManager (không bao giờ unload)
- UIScene: HUD, menus
- LevelScene: gameplay (load/unload theo màn)

Lợi ích:
- Tách biệt concern (UI riêng, gameplay riêng)
- Nhiều người làm song song không conflict
- Load/unload level mà giữ manager
```

```csharp
// Load level mới, unload level cũ, giữ persistent
async UniTask SwitchLevelAsync(string newLevel, CancellationToken token)
{
    // Unload level hiện tại
    if (!string.IsNullOrEmpty(_currentLevel))
        await SceneManager.UnloadSceneAsync(_currentLevel).ToUniTask(cancellationToken: token);

    // Load level mới (additive)
    await SceneManager.LoadSceneAsync(newLevel, LoadSceneMode.Additive)
        .ToUniTask(cancellationToken: token);

    // Set active scene (cho lighting, instantiate)
    var scene = SceneManager.GetSceneByName(newLevel);
    SceneManager.SetActiveScene(scene);

    _currentLevel = newLevel;
}
```

## 10.4. DontDestroyOnLoad

```csharp
// Giữ object qua các lần load scene
void Awake()
{
    DontDestroyOnLoad(gameObject);
}
```

> **Pitfall:** DontDestroyOnLoad + load lại scene chứa object đó → tạo duplicate. Cần Singleton guard:

```csharp
void Awake()
{
    if (Instance != null) { Destroy(gameObject); return; }
    Instance = this;
    DontDestroyOnLoad(gameObject);
}
```

## 10.5. Truyền data giữa Scene

```csharp
// Cách 1: Static/Singleton
GameData.SelectedLevel = 3;
SceneManager.LoadScene("Game");
// Scene mới đọc GameData.SelectedLevel

// Cách 2: ScriptableObject (sạch hơn)
[CreateAssetMenu]
public class GameSession : ScriptableObject
{
    public int selectedLevel;
    public string playerName;
}
// Cả 2 scene reference cùng SO asset

// Cách 3: DontDestroyOnLoad object mang data
```

---

# 11. SAVE SYSTEM & PERSISTENCE

> Middle cần build save system đáng tin cậy, không chỉ PlayerPrefs vài giá trị.

## 11.1. PlayerPrefs (đơn giản, hạn chế)

```csharp
// Lưu giá trị đơn giản
PlayerPrefs.SetInt("HighScore", 1000);
PlayerPrefs.SetFloat("Volume", 0.8f);
PlayerPrefs.SetString("PlayerName", "Hero");
PlayerPrefs.Save();  // Ghi xuống disk

// Đọc (với default value)
int score = PlayerPrefs.GetInt("HighScore", 0);
float vol = PlayerPrefs.GetFloat("Volume", 1f);

// Kiểm tra & xóa
if (PlayerPrefs.HasKey("HighScore")) { }
PlayerPrefs.DeleteKey("HighScore");
PlayerPrefs.DeleteAll();
```

> **Hạn chế PlayerPrefs:** Chỉ lưu int/float/string, dễ bị sửa (registry/plist), không phù hợp data phức tạp. Dùng cho settings, không cho save game.

## 11.2. JSON Save (khuyến nghị)

```csharp
[System.Serializable]
public class SaveData
{
    public int level;
    public int gold;
    public float playTime;
    public List<string> unlockedItems = new();
    public Vector3 playerPosition;
}

public class SaveSystem
{
    static string SavePath => Path.Combine(Application.persistentDataPath, "save.json");

    public static void Save(SaveData data)
    {
        string json = JsonUtility.ToJson(data, prettyPrint: true);
        File.WriteAllText(SavePath, json);
        Debug.Log($"Saved to {SavePath}");
    }

    public static SaveData Load()
    {
        if (!File.Exists(SavePath))
            return new SaveData();  // Save mới

        string json = File.ReadAllText(SavePath);
        return JsonUtility.FromJson<SaveData>(json);
    }

    public static void Delete()
    {
        if (File.Exists(SavePath))
            File.Delete(SavePath);
    }
}
```

> **Application.persistentDataPath** — đường dẫn lưu data an toàn trên mọi platform (không bị xóa khi update app).

## 11.3. Giới hạn JsonUtility & cách khắc phục

```csharp
// JsonUtility KHÔNG hỗ trợ:
// - Dictionary (phải convert sang 2 List)
// - Polymorphism (kế thừa)
// - Property (chỉ field public hoặc [SerializeField])
// - Top-level array/primitive

// Dictionary workaround
[System.Serializable]
public class SerializableDict
{
    public List<string> keys = new();
    public List<int> values = new();
}

// Hoặc dùng Newtonsoft.Json (hỗ trợ đầy đủ hơn)
// using Newtonsoft.Json;
// string json = JsonConvert.SerializeObject(dict);  // Hỗ trợ Dictionary
```

## 11.4. Async Save (tránh giật khi save lớn)

```csharp
async UniTask SaveAsync(SaveData data, CancellationToken token)
{
    string json = JsonUtility.ToJson(data);

    // Ghi file trên background thread (tránh block main thread)
    await UniTask.RunOnThreadPool(() =>
    {
        File.WriteAllText(SavePath, json);
    }, cancellationToken: token);

    Debug.Log("Saved async");
}
```

## 11.5. Best Practices Save System

```
1. Versioning: thêm field "version" để migrate save cũ khi update game
2. Backup: giữ save cũ trước khi ghi đè (tránh corrupt mất hết)
3. Validation: kiểm tra data hợp lệ khi load (tránh crash)
4. Encryption: mã hóa nếu cần chống cheat (AES)
5. Auto-save: lưu định kỳ + tại checkpoint
6. Atomic write: ghi file tạm rồi rename (tránh corrupt khi crash giữa chừng)
```

```csharp
// Atomic write — an toàn khi crash
public static void SaveSafe(SaveData data)
{
    string json = JsonUtility.ToJson(data);
    string tempPath = SavePath + ".tmp";

    File.WriteAllText(tempPath, json);  // Ghi file tạm
    if (File.Exists(SavePath)) File.Delete(SavePath);
    File.Move(tempPath, SavePath);  // Rename (atomic)
}
```

---

# 12. NEW INPUT SYSTEM

> Input System mới linh hoạt hơn legacy, hỗ trợ rebinding, nhiều device. Middle nên biết.

## 12.1. Setup

```
Package Manager → cài "Input System"
→ Project Settings → Player → Active Input Handling → Both hoặc Input System Package
→ Tạo Input Actions asset (chuột phải → Create → Input Actions)
```

## 12.2. Cách dùng — PlayerInput Component

```csharp
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    Vector2 _moveInput;

    // Gọi tự động bởi PlayerInput component (Send Messages / Unity Events)
    public void OnMove(InputAction.CallbackContext context)
    {
        _moveInput = context.ReadValue<Vector2>();
    }

    public void OnJump(InputAction.CallbackContext context)
    {
        if (context.performed)  // Chỉ khi nhấn (không phải started/canceled)
            Jump();
    }

    void Update()
    {
        Vector3 move = new Vector3(_moveInput.x, 0, _moveInput.y);
        transform.position += move * speed * Time.deltaTime;
    }
}
```

## 12.3. Cách dùng — Generated C# Class

```csharp
// Tick "Generate C# Class" trong Input Actions asset
public class PlayerController : MonoBehaviour
{
    PlayerInputActions _input;

    void Awake()
    {
        _input = new PlayerInputActions();

        // Đăng ký callback
        _input.Player.Jump.performed += OnJump;
        _input.Player.Attack.performed += OnAttack;
    }

    void OnEnable() => _input.Enable();
    void OnDisable() => _input.Disable();

    void OnJump(InputAction.CallbackContext ctx) => Jump();
    void OnAttack(InputAction.CallbackContext ctx) => Attack();

    void Update()
    {
        // Polling cho continuous input
        Vector2 move = _input.Player.Move.ReadValue<Vector2>();
    }

    void OnDestroy() => _input.Dispose();
}
```

## 12.4. Action Phases

| Phase | Khi nào |
|---|---|
| `started` | Bắt đầu nhận input (vừa nhấn) |
| `performed` | Action hoàn thành (thường dùng cái này) |
| `canceled` | Input kết thúc (thả ra) |

## 12.5. Callback vs Polling

```csharp
// Callback — tốt cho sự kiện rời rạc (jump, attack, pause)
_input.Player.Jump.performed += ctx => Jump();

// Polling — tốt cho input liên tục (di chuyển, nhìn)
void Update()
{
    Vector2 move = _input.Player.Move.ReadValue<Vector2>();
}
```

## 12.6. Rebinding (đổi phím)

```csharp
// Cho phép player đổi phím runtime
void StartRebind(InputAction action, int bindingIndex)
{
    action.Disable();

    var rebind = action.PerformInteractiveRebinding(bindingIndex)
        .OnComplete(operation =>
        {
            operation.Dispose();
            action.Enable();
            SaveBindings();  // Lưu binding mới
        })
        .Start();
}

// Lưu/load bindings
void SaveBindings()
{
    string json = _input.SaveBindingOverridesAsJson();
    PlayerPrefs.SetString("bindings", json);
}

void LoadBindings()
{
    string json = PlayerPrefs.GetString("bindings", "");
    if (!string.IsNullOrEmpty(json))
        _input.LoadBindingOverridesFromJson(json);
}
```

## 12.7. Legacy vs New Input System

| | Legacy (Input Manager) | New Input System |
|---|---|---|
| Setup | Đơn giản, dùng ngay | Cần setup Actions |
| Rebinding | Tự code | Built-in |
| Multi-device | Hạn chế | Tốt (gamepad, touch, keyboard) |
| Local multiplayer | Khó | Built-in (PlayerInputManager) |
| Khi nào | Prototype nhanh | Game production, cần rebind |

---

# 13. EDITOR TOOLING CƠ BẢN

> Middle nên biết tạo công cụ Editor đơn giản để tăng tốc workflow team.

## 13.1. Attributes hữu ích

```csharp
public class EnemyConfig : MonoBehaviour
{
    [Header("Stats")]              // Tiêu đề nhóm
    [SerializeField] int hp = 100;

    [Range(0f, 10f)]               // Slider
    [SerializeField] float speed = 3f;

    [Tooltip("Sát thương mỗi đòn")] // Hover hiện mô tả
    [SerializeField] int damage = 10;

    [Space(10)]                    // Khoảng trống
    [TextArea(3, 5)]               // Text box nhiều dòng
    [SerializeField] string description;

    [SerializeField] private int _privateButShown;  // Private vẫn hiện

    [HideInInspector] public int hiddenPublic;       // Public nhưng ẩn

    [field: SerializeField]        // Serialize auto-property
    public int Level { get; private set; }
}
```

```csharp
// Đảm bảo có component (tự thêm khi gắn script)
[RequireComponent(typeof(Rigidbody))]
public class Mover : MonoBehaviour { }

// Chạy trong Edit Mode (không cần Play)
[ExecuteInEditMode]
public class Preview : MonoBehaviour { }

// Cho phép nhiều component cùng loại
[DisallowMultipleComponent]
public class Singleton : MonoBehaviour { }
```

## 13.2. Custom Inspector

```csharp
#if UNITY_EDITOR
using UnityEditor;

[CustomEditor(typeof(EnemySpawner))]
public class EnemySpawnerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        // Vẽ inspector mặc định
        DrawDefaultInspector();

        var spawner = (EnemySpawner)target;

        EditorGUILayout.Space();

        // Thêm button tiện ích
        if (GUILayout.Button("Spawn Test Enemy"))
        {
            spawner.SpawnTest();
        }

        if (Application.isPlaying)
        {
            EditorGUILayout.LabelField($"Active Enemies: {spawner.ActiveCount}");
        }
    }
}
#endif
```

> **Lưu ý:** Code Editor phải nằm trong `#if UNITY_EDITOR` hoặc folder `Editor/` → không build vào game (gây lỗi build).

## 13.3. Custom EditorWindow

```csharp
#if UNITY_EDITOR
using UnityEditor;

public class LevelToolWindow : EditorWindow
{
    [MenuItem("Tools/Level Tool")]
    public static void Open() => GetWindow<LevelToolWindow>("Level Tool");

    int _enemyCount = 5;

    void OnGUI()
    {
        GUILayout.Label("Level Generator", EditorStyles.boldLabel);

        _enemyCount = EditorGUILayout.IntSlider("Enemy Count", _enemyCount, 1, 50);

        if (GUILayout.Button("Generate"))
        {
            GenerateLevel(_enemyCount);
        }
    }

    void GenerateLevel(int count)
    {
        // Logic tạo level
    }
}
#endif
```

## 13.4. Gizmos — visualize trong Scene

```csharp
public class PatrolPath : MonoBehaviour
{
    [SerializeField] Vector3[] waypoints;
    [SerializeField] float detectionRadius = 5f;

    // Vẽ luôn (cả khi không chọn)
    void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, detectionRadius);

        // Vẽ đường tuần tra
        if (waypoints != null && waypoints.Length > 1)
        {
            Gizmos.color = Color.cyan;
            for (int i = 0; i < waypoints.Length - 1; i++)
                Gizmos.DrawLine(waypoints[i], waypoints[i + 1]);
        }
    }

    // Chỉ vẽ khi object được chọn
    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireCube(transform.position, Vector3.one * 2f);
    }
}
```

## 13.5. ContextMenu & MenuItem

```csharp
public class Tools : MonoBehaviour
{
    // Chuột phải vào component → hiện menu
    [ContextMenu("Reset Stats")]
    void ResetStats()
    {
        hp = 100;
        Debug.Log("Stats reset");
    }
}

#if UNITY_EDITOR
public static class MenuTools
{
    // Thêm vào menu bar Unity
    [MenuItem("Tools/Clear PlayerPrefs")]
    static void ClearPrefs()
    {
        PlayerPrefs.DeleteAll();
        Debug.Log("PlayerPrefs cleared");
    }

    // Với shortcut (Ctrl+Shift+C)
    [MenuItem("Tools/Quick Action %#c")]
    static void QuickAction() { }
}
#endif
```

---

# 14. GIT & TEAM WORKFLOW

> Middle làm việc trong team, cần biết Git cho Unity và quy trình cộng tác.

## 14.1. .gitignore cho Unity

```gitignore
# Unity generated
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
[Uu]serSettings/

# Visual Studio / Rider
.vs/
.idea/
*.csproj
*.sln
*.user

# Build outputs
*.apk
*.aab
*.ipa

# OS
.DS_Store
```

> **Quan trọng:** KHÔNG commit `Library/` (Unity tự generate, rất nặng). Commit `Assets/`, `Packages/`, `ProjectSettings/`.

## 14.2. Git LFS cho asset lớn

```bash
# Cài Git LFS cho file binary lớn (texture, audio, model)
git lfs install

# Track các loại file
git lfs track "*.psd"
git lfs track "*.png"
git lfs track "*.fbx"
git lfs track "*.wav"

# .gitattributes được tạo tự động
```

## 14.3. Unity Smart Merge (YAML merge)

```
Vấn đề: Scene/Prefab là file YAML, merge conflict rất khó giải thủ công.

Giải pháp: Cấu hình Unity Smart Merge (UnityYAMLMerge)
→ Edit → Project Settings → Editor → Version Control → Visible Meta Files
→ Asset Serialization → Force Text

.gitattributes:
*.unity merge=unityyamlmerge
*.prefab merge=unityyamlmerge
*.asset merge=unityyamlmerge
```

> **Best practice team:** Tránh nhiều người sửa cùng 1 scene. Dùng Additive Scenes hoặc Prefab để chia nhỏ → giảm conflict.

## 14.4. Branching Strategy

```
main/master    → code ổn định, release
develop        → tích hợp feature
feature/*      → mỗi feature 1 branch (feature/inventory)
bugfix/*       → sửa lỗi
release/*      → chuẩn bị release

Workflow:
1. Tạo branch từ develop: git checkout -b feature/shop
2. Code + commit thường xuyên
3. Push + tạo Pull Request
4. Code review → merge vào develop
```

## 14.5. Commit conventions

```bash
# Format: type: mô tả ngắn
feat: add shop system
fix: fix null reference in enemy spawner
refactor: extract health logic to separate class
perf: optimize draw calls in UI
docs: update README
chore: update dependencies

# Commit nhỏ, thường xuyên, mô tả rõ ràng
```

## 14.6. Code Review — góc nhìn Middle

```
Khi review code, kiểm tra:
- Naming rõ ràng, đúng convention
- Không có magic number/string
- GetComponent được cache
- Event được unsubscribe (tránh leak)
- Không có GC alloc trong hot path
- Logic tách khỏi MonoBehaviour khi cần test
- Null check chỗ cần thiết
- Code dễ đọc, không over-engineer

Cách góp ý: giải thích "tại sao" + đề xuất cách sửa, không chỉ chê.
```

---

# 15. CÂU HỎI PHỎNG VẤN MIDDLE

## 15.1. C# & Performance

**Q: Boxing là gì? Tại sao ảnh hưởng performance?**
> Boxing là đóng gói value type (int, struct) thành object trên heap → sinh garbage. Trong hot path gây GC alloc → spike. Tránh bằng generic collection, StringBuilder, enum comparer.

**Q: Struct và class, khi nào dùng cái nào?**
> Struct (value type) cho data nhỏ, ngắn hạn, immutable (< 16 bytes) — trên stack, không GC. Class (reference type) cho object phức tạp, cần kế thừa, vòng đời dài.

**Q: LINQ có nên dùng trong Update không?**
> Không nên. LINQ tạo iterator, delegate, collection mới → GC alloc. Trong Update với nhiều object gây spike. Dùng for loop ở hot path, LINQ ở code chạy thưa.

**Q: Generics giải quyết vấn đề gì?**
> Viết code tổng quát hoạt động với nhiều kiểu mà vẫn type-safe, tránh duplicate code và tránh boxing (so với dùng object). Ví dụ: generic Object Pool, generic Singleton.

## 15.2. Memory & GC

**Q: Garbage Collector hoạt động thế nào trong Unity?**
> GC quản lý Managed Heap (object C#). Khi chạy, nó tạm dừng game (Stop-The-World), quét object không còn tham chiếu, giải phóng. Sinh nhiều rác → GC chạy thường xuyên → giật hình.

**Q: Làm sao giảm GC allocation?**
> Cache và tái sử dụng object, dùng non-alloc API (RaycastNonAlloc), StringBuilder cho chuỗi, struct cho data nhỏ, cache WaitForSeconds, object pooling thay Instantiate/Destroy, tránh LINQ và closure trong hot path.

**Q: Native Heap và Managed Heap khác gì?**
> Native Heap (C++) chứa asset thật (texture, mesh, audio), engine quản lý thủ công. Managed Heap (C#) chứa object C# bạn tạo, GC quản lý. MonoBehaviour là wrapper C# trỏ xuống native object.

## 15.3. Architecture & Patterns

**Q: Khi nào dùng Singleton, khi nào tránh?**
> Dùng cho manager cần truy cập toàn cục, 1 instance (GameManager, AudioManager). Tránh khi gây tight coupling, khó test, hoặc khi DI phù hợp hơn. Đừng lạm dụng Singleton cho mọi thứ.

**Q: Tại sao nên tách logic khỏi MonoBehaviour?**
> Để testable (test pure C# không cần scene), tái sử dụng, và tách concern. MonoBehaviour làm "vỏ" kết nối Unity, logic nằm trong class C# thuần.

**Q: FSM giải quyết vấn đề gì?**
> Quản lý trạng thái và chuyển đổi rõ ràng, thay vì if/else lồng nhau khổng lồ. Mỗi state là 1 class riêng, dễ thêm/sửa. Dùng cho AI, game flow, character behavior.

**Q: ScriptableObject dùng làm gì ngoài lưu data?**
> Làm event channel (loose coupling), runtime variable (chia sẻ giá trị giữa object), config (designer tweak không cần code). Pattern SO Architecture giúp wire logic qua Inspector.

## 15.4. Unity Systems

**Q: Khi nào dùng Additive Scene?**
> Khi muốn tách concern (UI scene, gameplay scene, persistent scene riêng), nhiều người làm song song không conflict, hoặc load/unload level mà giữ manager. Persistent scene chứa manager không bao giờ unload.

**Q: PlayerPrefs có phù hợp để save game không?**
> Không. PlayerPrefs chỉ lưu int/float/string, dễ bị sửa, không cho data phức tạp. Dùng cho settings. Save game nên dùng JSON file trong persistentDataPath.

**Q: Tại sao volume AudioMixer dùng dB?**
> Vì tai người cảm nhận âm lượng theo logarithmic, không linear. AudioMixer dùng decibel. Slider UI (0-1) phải convert sang dB qua Log10(value)*20.

**Q: Animator vs DOTween, khi nào dùng cái nào?**
> Animator cho animation phức tạp, character, có state machine. DOTween cho UI animation và tween đơn giản (move, scale, fade) — nhẹ hơn nhiều. Đừng dùng Animator cho UI popup.

## 15.5. Async & Addressables

**Q: Tại sao dùng UniTask thay Coroutine?**
> UniTask trả về được giá trị, bắt lỗi bằng try/catch, zero allocation, hủy dễ bằng CancellationToken, chạy đa luồng được. Coroutine hạn chế hơn ở những điểm này.

**Q: Trong Addressables, tại sao mỗi Load cần Release?**
> Addressables dùng reference counting. Load tăng ref count (giữ asset trong RAM), Release giảm. Ref count = 0 → unload. Quên Release → memory leak.

**Q: InstantiateAsync khác Instantiate thường thế nào?**
> InstantiateAsync (Addressables) load + tạo instance, phải dùng ReleaseInstance để giải phóng. Trộn với Destroy thường gây ref count sai. Nhất quán: InstantiateAsync ↔ ReleaseInstance.

**Q: Remote Content (CDN) trong Addressables để làm gì?**
> Để asset trên server, giảm dung lượng app ban đầu, cập nhật content không cần update app (đổi bundle trên server), hỗ trợ DLC/seasonal content.

## 15.6. Workflow & Team

**Q: File nào KHÔNG nên commit lên Git trong Unity?**
> Library/ (Unity tự generate, rất nặng), Temp/, obj/, Build/, file IDE (.vs, .idea, .csproj, .sln). Commit Assets/, Packages/, ProjectSettings/.

**Q: Làm sao giảm merge conflict scene trong team?**
> Cấu hình Unity Smart Merge (YAMLMerge), set Asset Serialization = Force Text, tránh nhiều người sửa cùng scene, dùng Additive Scenes hoặc Prefab để chia nhỏ.

**Q: Git LFS dùng để làm gì?**
> Quản lý file binary lớn (texture, audio, model) hiệu quả hơn. Git thường không tốt với file binary lớn — LFS lưu reference thay vì toàn bộ file trong history.

## 15.7. Câu hỏi tình huống

**Q: Game giật mỗi vài giây, làm sao tìm nguyên nhân?**
> Mở Profiler, quan sát CPU. Spike định kỳ thường do GC allocation. Tìm function có GC Alloc > 0 trong gameplay loop (bật Deep Profile để định vị chính xác), rồi tối ưu allocation đó (object pool, non-alloc API).

**Q: FPS thấp dù scene đơn giản, kiểm tra gì?**
> Mở Stats: nếu Batches/SetPass cao → vấn đề draw call (batching, atlas). Nếu CPU cao → kiểm tra Update() nặng, GetComponent trong loop. Dùng Frame Debugger xem tại sao không batch.

**Q: Cần spawn 500 enemy mà không giật, làm thế nào?**
> Object pooling (tạo sẵn pool), spawn rải qua nhiều frame (async/coroutine), cân nhắc tắt Update() riêng lẻ dùng Manager pattern, hoặc DOTS/ECS nếu cực nhiều. Tránh Instantiate 500 cái cùng 1 frame.

**Q: Làm sao load màn chơi lớn mà không màn hình đen đứng hình?**
> Async load (LoadSceneAsync) với loading screen + progress bar, allowSceneActivation = false để control, tải asset qua Addressables, chia nhỏ khởi tạo qua nhiều frame với UniTask.

---

## LỜI KHUYÊN ÔN TẬP CHO MIDDLE

1. **Hiểu "tại sao", không học thuộc:** Middle được hỏi sâu về lý do và trade-offs, không chỉ "cách làm".

2. **Performance & Memory là điểm phân biệt:** Junior viết code chạy được, Middle viết code chạy mượt. Nắm vững GC, profiling.

3. **Biết nhiều cách, chọn đúng cách:** So sánh được các approach (Singleton vs DI, Animator vs DOTween) và biết khi nào dùng cái nào.

4. **Tự build được feature hoàn chỉnh:** Save system, audio system, scene flow — build end-to-end không cần hướng dẫn từng bước.

5. **Có dự án thực tế để kể:** Chuẩn bị 1-2 feature bạn đã làm, giải thích quyết định kiến trúc và cách giải quyết vấn đề.

6. **Đọc code người khác:** Middle thường phải review code. Luyện đọc và đánh giá code.

7. **Trade-offs là chìa khóa:** Mọi câu trả lời tốt đều nên đề cập đánh đổi — không có giải pháp hoàn hảo, chỉ có giải pháp phù hợp ngữ cảnh.

---

*Chúc bạn phỏng vấn Middle Unity thành công! Đây là bước đệm quan trọng để tiến lên Senior/Lead.*

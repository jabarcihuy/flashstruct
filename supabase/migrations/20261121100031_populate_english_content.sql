-- Seed both language versions for the current public curriculum.
begin;
update public.modul set judul_en='Padding, Alignment & sizeof', deskripsi_en='Why is sizeof(struct) greater than the number of its members, and when does ordering members help.' where id='61bf23a5-9b83-40c6-bc36-eaf4f494a689'::uuid;
update public.modul set judul_en='Dynamic Memory Allocation', deskripsi_en='Stack vs heap, new/delete, three classic memory bugs, and why modern C++ uses smart pointers.' where id='63dba86a-c75d-41da-89e3-63db6d1cdfca'::uuid;
update public.modul set judul_en='Pointers & Arrays: Pointer Arithmetic', deskripsi_en='Why is arr[i] the same as *(arr+i), what is decay, and why is sizeof array missing in the function.' where id='ac0a46a1-f4a5-4e17-a8b3-de749383d2d6'::uuid;
update public.modul set judul_en='Pointers to Struct & Arrow Operators', deskripsi_en='The -> and (*) operators., plus why pointers are more efficient for large structs.' where id='bda0ef69-d0c2-4f0a-a390-9543761ff419'::uuid;
update public.modul set judul_en='Multidimensional Arrays', deskripsi_en='The order of rows and columns in memory, how to calculate addresses, and the pitfalls of nested lists in Python.' where id='0f13052d-29f2-4a90-b630-7e351de15aa8'::uuid;
update public.modul set judul_en='Array & Index Basics', deskripsi_en='Basic concepts of arrays, indexes and element access in C++ and Python.' where id='437b8a6c-c23e-4b93-b933-98f90372bc5f'::uuid;
update public.modul set judul_en='Basics of Pointers & Memory Addresses', deskripsi_en='Understanding memory addresses, pointers, and dereferences in C++.' where id='511b1c56-053c-4c59-a595-16a9eae5851f'::uuid;
update public.modul set judul_en='Defining Structs', deskripsi_en='Defines and accesses structs, as well as their Python dataclass equivalents.' where id='c98a9ca4-a8f1-4c99-bc36-8ab0b8a2d352'::uuid;
update public.modul set judul_en='Dynamic Arrays: vectors & lists', deskripsi_en='How arrays grow while running, different sizes and capacities, and why pointers can become dangling.' where id='d51f1966-989a-40d0-9f61-189c0344a2e5'::uuid;
update public.modul set judul_en='Nested Structs & Arrays of Structs', deskripsi_en='Arranging structs within structs, arrays of structs, and how to sort them.' where id='e8971fe6-b1e9-4ab4-804c-1eccfed074fb'::uuid;
update public.bagian_modul set judul_en='Array Material', konten_md_en='What is an Array
---
An array is a collection of elements of **the same type**, stored sequentially in memory, and accessed via index.

The analogy is like a row of lockers: each locker has a number, and the number starts from zero.

## Three Characteristics of Arrays

1. **Homogeneous** — all elements must be of the same data type
2. **Continuous** — elements are stored sequentially with no gaps in memory
3. **Access via index** — the first element is index 0

> [!INFO]
> Indexes start at **0**, not 1. This is true in C++ and Python.

## Array Declaration

### C++

```cpp
int A[5];                    // 5 elemen, nilai belum diisi
int B[5] = {10, 20, 30, 40, 50};   // 5 elemen terisi
int C[5] = {1, 2};           // sisanya otomatis 0
```

### Python

```python
A = [0] * 5                  # 5 elemen bernilai 0
B = [10, 20, 30, 40, 50]     # 5 elemen terisi
```

> [!ATTENTION]
> Python uses **lists**, not arrays like C++. The size can change, and the type can be different.

## Accessing Elements

The index is written in square brackets, starting from 0.

```cpp
int B[5] = {10, 20, 30, 40, 50};

cout << B[0];   // 10  (elemen pertama)
cout << B[1];   // 20  (elemen kedua)
cout << B[4];   // 50  (elemen terakhir)
```

Note: an array of size 5 has indices **0 to 4**, not 1 to 5.

## Why Array Access Is So Fast

The address of each element can be **calculated directly**, without traversing the previous element:

```
alamat(i) = alamat(0) + i x sizeof(Tipe)
```

Because the formula is simple, the computer can jump to any element at a time. This is what is called **random access** or direct random access.

Accessing the 1st element is just as fast as accessing the 1000th element.

> [!INFO]
> In complexity notation, array access is **O(1)** — constant time, independent of element position.

## Browse Arrays

Loops are used to visit each element sequentially.

### C++

```cpp
int B[5] = {10, 20, 30, 40, 50};

for (int i = 0; i < 5; i++) {
    cout << B[i] << " ";
}
// Output: 10 20 30 40 50
```

### Python

```python
B = [10, 20, 30, 40, 50]

for nilai in B:
    print(nilai, end=" ")
# Output: 10 20 30 40 50
```

Note the condition `i < 5`, not `i <= 5`. If you use `<=`, the program will access index 5 which is **out of bounds**.

## Trap: Exiting Array Bounds

C++ does not check array bounds while the program is running. Writing out of bounds doesn''t raise an error message — but it corrupts the surrounding memory.

```cpp
int B[5] = {10, 20, 30, 40, 50};

B[5] = 100;   // BAHAYA: indeks 5 di luar batas!
```

This is called **undefined behavior**: the program may appear to run normally, but its values are unpredictable.

> [!DANGER]
> In Python, the same case throws `IndexError` and the program stops with a clear message. This distinction is important: C++ trusts the programmer, Python protects the programmer.

## Copying an Array

In C++, writing `B = A` to an array **does not copy its contents** — and actually doesn''t compile. The content must be copied element by element.

```cpp
int A[3] = {1, 2, 3};
int B[3];

for (int i = 0; i < 3; i++) {
    B[i] = A[i];
}
// B sekarang berisi 1, 2, 3
```

In Python, `B = A` also **doesn''t copy** — B becomes another name for the same list. To copy its contents:

```python
A = [1, 2, 3]
B = A.copy()      # salinan terpisah

B[0] = 99
print(A[0])       # tetap 1 — A tidak terpengaruh
```

> [!TRAP]
> In Python, `B = A` makes B point to the **same** object. Changing B[0] also changes A[0]. This is the cause of bugs that occur very often.

## Summary

| Aspect | Description |
|-------|------------|
| Element type | Homogeneous — must all be the same |
| Place in memory | Contiguous — consecutive without gaps |
| Initial index | 0 |
| Size | Fixed, determined when created |
| Access speed | O(1) — immediately calculates the address |
| Boundary checking | C++ doesn''t check; Python throws IndexError |' where id='579a01f0-5c92-4fe5-83ae-b5866ad5eeaa'::uuid;
update public.bagian_modul set judul_en='Python Lists', konten_md_en='`list` Python is the equivalent of `std::vector` — a dynamic array. But the mechanism is different.

## Basic

```python
lst = [1, 2, 3]

lst.append(4)        # tambah di akhir
lst.insert(0, 0)     # sisipkan di depan
lst.remove(1)        # hapus nilai 1
lst.pop()            # hapus elemen terakhir
print(len(lst))      # panjang
```

## Auto Grow Size

```python
lst = [1, 2, 3]
print(len(lst))      # 3

lst.append(4)
print(len(lst))      # 4
```

There''s no directly accessible `capacity` concept like in C++, but Python also does *over-allocation* behind the scenes.

```python
import sys

l = []
for i in range(1, 11):
    l.append(i)
    print(len(l), sys.getsizeof(l))
```

**Real output:**

```
len  byte
  1    88
  2    88
  3    88
  4    88      <- masih dalam alokasi yang sama
  5   120      <- naik
  ...
  9   184      <- naik lagi
```

Note: memory size **does not increase with each append**. Python allocated more than needed, just like `vector`.

> [!INFO]
> `sys.getsizeof()` returns the size of the **list object itself**, not the size of the stored data. Since lists store references (pointers), this number is not the same as "data size".

## insert(0) That''s Expensive

It''s an operation that is often misunderstood as cheap.

```python
lst = list(range(1000))
lst.insert(0, 99)
```

`insert(0, ...)` should **shift all elements** one position to the right. The complexity is **O(n)**, not O(1).

**Proof of measurement (5,000 iterations):**

| Operation | Time |
|--------|-------|
| `append` back | 0.8 ms |
| `insert` forward | 155.1 ms |

**198x slower.**

> [!ATTENTION]
> Do not use `insert(0, ...)` in loops for large data. If you need to add in front repeatedly, use `collections.deque` which has `appendleft()` with complexity O(1).

## Slicing COPYING

Different from C++ which uses pointers, Python slicing produces **copies**:

```python
arr = [10, 20, 30, 40, 50]
s = arr[1:4]

s[0] = 999

print(arr)   # [10, 20, 30, 40, 50] - TIDAK berubah
print(s)     # [999, 30, 40]
```

This is important to understand: changing the slice result **does** not change the original list.

## List Stores References

```python
a = [1, 2, 3]
b = a           # bukan salinan!

b.append(4)
print(a)        # [1, 2, 3, 4] - IKUT berubah
print(id(a) == id(b))   # True
```

To make an actual copy:

```python
c = a.copy()    # atau a[:] atau list(a)

c.append(5)
print(a)        # [1, 2, 3, 4] - tidak berubah
print(c)        # [1, 2, 3, 4, 5]
```

> [!DANGER]
> `b = a` in the list DOES NOT make a copy. Both point to the same object. To copy, use `a.copy()`, `a[:]`, or `list(a)`.' where id='abebbd47-0ed9-47ec-8069-963e6fa7fd02'::uuid;
update public.bagian_modul set judul_en='Alignment Rules', konten_md_en='To be able to calculate padding yourself, you need to know the rules.

## Alignment Rules

**Each member must start at an address that is a multiple of its alignment.**

Alignment is usually the same as type size, with the exception of:

| Type | Size | Alignment (x86-64) |
|------|--------|---------------------|
| `char` | 1 | 1 |
| `short` | 2 | 2 |
| `int` | 4 | 4 |
| `long` | 8 | 8 |
| `double` | 8 | 8 |
| pointers | 8 | 8 |

## Two Steps to Calculate Padding

**Step 1:** Each member starts at an offset that is a multiple of its alignment.

**Step 2:** The total size of the struct is rounded to the **largest** alignment multiple among its members.

### Example 1: char, int

```cpp
struct A { char a; int b; };
```

| Member | Alignment | Offset | Description |
|---------|-----------|--------|------------|
| `a` | 1 | 0 | starts at 0, ok |
| `b` | 4 | **4** | must be a multiple of 4; after `a` at 1, round to 4 |

Padding: offset 1-3 (3 bytes). Total: 4 + 4 = **8 bytes**.

### Example 2: char, long, char

```cpp
struct B { char a; long b; char c; };
```

| Member | Alignment | Offset | Description |
|---------|-----------|--------|------------|
| `a` | 1 | 0 | ok |
| `b` | 8 | **8** | must be a multiple of 8; after 1, round to 8 |
| `c` | 1 | 16 | ok |

After `c` at offset 16, the total is 17. Largest alignment = 8, so round up to **24**.

**Measured result: 24 bytes.** (1 + 7 padding + 8 + 1 + 7 final padding)

### Example 3: long, char, char

```cpp
struct C { long b; char a; char c; };
```

| Member | Alignment | Offset |
|---------|-----------|--------|
| `b` | 8 | 0 |
| `a` | 1 | 8 |
| `c` | 1 | 9 |

Total 10, rounded to a multiple of 8 to make **16**.

**Measured result: 16 bytes.** Saves 8 bytes compared to example 2.

> [!ATTENTION]
> Alignment **is implementation-defined**. The above numbers apply to x86-64 with GCC/Clang. On other platforms (ARM, embedded) it can be different. **Always verify with `sizeof` and `offsetof` on your platform.**' where id='08e4cf88-5e1b-46ae-bd9f-149661bb4767'::uuid;
update public.bagian_modul set judul_en='Memory Structs in Python', konten_md_en='Python doesn''t have the concept of padding like C++, but there is a `struct` module for interacting with binary data.

## Why Python Has No Padding

Because Python objects are stored as references, not sequential values:

```python
@dataclass
class Campur:
    a: str
    b: int

c = Campur("A", 100)
```

The `c` object stores **references** to strings and integers, not direct values. The size of the object is not determined by padding alignment.

## Struct module: For Binary Data

If you need to interact with binary formats (e.g. reading files from C programs), Python provides the `struct` module:

```python
import struct

# Pack: ubah nilai jadi byte
data = struct.pack(''bi'', 65, 100)
print(len(data))    # 5 (1 byte char + 4 byte int)
```

Note: the result is **5 bytes**, not 8. Because the `struct` Python module by default **does not add padding**.

## Frequently Used String Formats

| Code | Type C | Size |
|------|--------|--------|
| `b` | signed char | 1 |
| `B` | unsigned char | 1 |
| `h` | short | 2 |
| `i` | int | 4 |
| `l` | long | 4 or 8 |
| `q` | long long | 8 |
| `f` | float | 4 |
| `d` | double | 8 |

## Explicit Padding

If you need to emulate a C layout that has padding, use `@` or `=`:

```python
# Tanpa padding (default untuk jaringan)
struct.pack(''bi'', 65, 100)      # 5 byte

# Dengan alignment native
struct.pack(''@bi'', 65, 100)     # 8 byte (ada padding)
```

## Comparison

| Aspect | C++ | Python |
|-------|-----|--------|
| Automatic padding | **Yes** | No (unless requested) |
| `sizeof` | There is | None for object |
| Alignment | Automatic | Manual via struct module |
| Binary access | Live | `struct` Module |

> [!INFO]
> For regular Python applications, padding is a no-brainer. What is important to understand: **if you read binary data from a C program, the layout can be different** and must be adjusted to the correct string format.' where id='23178dbf-20d6-4d22-b565-e39daeeda7c7'::uuid;
update public.bagian_modul set judul_en='Arrays as Parameters', konten_md_en='This is the most important section in this module, because it explains very common bugs.

## Problem: Missing Size

```cpp
void cetak(int arr[]) {
    cout << sizeof(arr);   // 8 (ukuran POINTER!)
}

int main() {
    int arr[5] = {1,2,3,4,5};
    cout << sizeof(arr);   // 20 (ukuran array)
    cetak(arr);
}
```

Inside the function, `sizeof(arr)` produces **8 bytes** — the size of the pointer, not the 20 byte size of the array.

**Size information missing.**

## Why It Happens

The parameter `int arr[]` is actually `int* arr`. The compiler translates it:

```cpp
void cetak(int arr[]);     // sebenarnya:
void cetak(int* arr);      // sama saja
```

Since the array is sent as a pointer, its size is not involved.

## Three Ways to Overcome It

**Way 1: Send size as parameter**

```cpp
void cetak(int arr[], int n) {
    for (int i = 0; i < n; i++) {
        cout << arr[i] << " ";
    }
}

cetak(arr, 5);
```

This is a C-style method. It works, but is risky: if `n` is false, out-of-bounds access occurs.

**Way 2: Use a reference to an array**

```cpp
void cetak(int (&arr)[5]) {
    cout << sizeof(arr);   // 20 - ukuran array TETAP ADA
    for (int x : arr) cout << x << " ";
}
```

By reference, decay **doesn''t happen**. Size remains unknown.

Disadvantage: the size must be known during compilation and written in the function type.

**Way 3: Use std::span (C++20)**

```cpp
#include <span>

void cetak(std::span<int> arr) {
    for (int x : arr) cout << x << " ";
    cout << arr.size();   // ukuran tersimpan
}
```

`std::span` stores **pointer AND size**. It''s the most modern and flexible solution.

## Comparison

| How to | Saved size | Flexible |
|------|--------|----------|
| `int arr[]` | **No** | Yes |
| `int (&arr)[5]` | **Yes** | No (fixed size) |
| `std::span<int>` | **Yes** | Yes |

> [!TIP]
> For modern C++ code, use `std::span`. For C style code, always send the size as a separate parameter. Never rely on `sizeof` inside a function for a parameter array — the result is always the size of the pointer.

## Pointers as Parameters Can Change Arrays

Here are the advantages — different from send values:

```cpp
void gandakan(int* a, int n) {
    for (int i = 0; i < n; i++) a[i] *= 2;
}

int arr[5] = {10, 20, 30, 40, 50};
gandakan(arr, 5);
// arr sekarang: 20 40 60 80 100
```

Because what is sent is an **address**, the function changes the **original** array.' where id='28412328-0ee1-4aa6-8e19-b8e8a0062ebe'::uuid;
update public.bagian_modul set judul_en='First Surprise', konten_md_en='This is the surprise experienced by almost everyone who first examines the `sizeof` struct.

```cpp
struct Campur {
    char a;    // 1 byte
    int b;     // 4 byte
};

cout << sizeof(Campur);
```

**Most people''s guess:** 5 bytes (1 + 4)

**Actual result:** **8 bytes**

Where are the remaining 3 bytes?

## The answer: Padding

```
struct Campur { char a; int b; };

Offset:  0    1    2    3    4    5    6    7
Isi:    [a]  [pad][pad][pad] [   b   ]
        1B    3 byte padding   4 byte
```

There are **3 empty bytes** between `a` and `b`. That byte is called **padding**.

## Prove with offsetof

```cpp
#include <cstddef>

cout << offsetof(Campur, a);   // 0
cout << offsetof(Campur, b);   // 4  <- bukan 1!
```

`b` starts at offset **4**, not 1. The first three bytes after `a` are skipped.

## Why Padding Exists

Because the CPU does not read memory one byte by byte. The CPU reads in **blocks** (usually 4 or 8 bytes).

If `int b` is placed at offset 1, the CPU needs to read two blocks and combine the results — much slower.

By placing `b` at offset 4 (a multiple of 4), the CPU can read it in **one** operation.

> [!INFO]
> Padding is a **trade-off**: we "waste" a few bytes of memory for the sake of access speed. For most programs, this is a favorable trade-off.

## Consequences to Keep in Mind

| Consequences | Explanation |
|-------------|------------|
| `sizeof` bigger than expected | Must be counted, not added up |
| The padding byte contains an indeterminate value | Do not compare structs with `memcmp` |
| Layout can differ between platforms | Don''t send raw structs between systems |
| An array of structs has a larger "distance" | Each element has its own padding |

## Struct Without Padding

If all members are the same size, there is no padding:

```cpp
struct Titik { int x; int y; };      // 8 byte (4+4)
struct Titik3D { int x; int y; int z; };  // 12 byte (4+4+4)
```

Padding only appears when member sizes are **different**.

> [!TIP]
> Quick rule: padding appears because of **alignment**. Each member must start at an address that is a multiple of its size (or alignment).' where id='286cb8dd-103f-4895-8479-da41735c1bdb'::uuid;
update public.bagian_modul set judul_en='Declaring Pointers', konten_md_en='Pointers are declared with an asterisk `*` after the type.

```cpp
int* p;      // pointer ke int
double* q;   // pointer ke double
char* r;     // pointer ke char
```

## How to Read the Declaration

Read from **right to left**:

```cpp
int* p;   // "p adalah pointer ke int"
```

This helps when types get complicated:

```cpp
int** pp;         // "pp adalah pointer ke pointer ke int"
int* arr[5];      // "arr adalah array berisi 5 pointer ke int"
int (*p)[5];      // "p adalah pointer ke array berisi 5 int"
```

## TRAP: int* a, b

This is a very common error:

```cpp
int* a, b;    // HANYA a yang pointer!
```

The `*` flag only applies to the **first** variable. `b` is a regular `int`.

**Measurable proof:**

```cpp
int* a, b;
cout << sizeof(a);   // 8  (pointer)
cout << sizeof(b);   // 4  (int, BUKAN pointer!)
```

**Correct way:**

```cpp
int* a;
int* b;      // tulis terpisah, atau
int *a, *b;  // ulangi tanda bintang
```

> [!ATTENTION]
> `int* a, b` is a classic trap. Always write pointer declarations on separate lines, or repeat the asterisks for each variable.

## Initialization

```cpp
int nilai = 42;

int* p = &nilai;      // BENAR: p menunjuk ke nilai
int* kosong = nullptr; // BENAR: pointer kosong
int* bahaya;           // BAHAYA: pointer liar (wild pointer)
```

`int* bahaya;` contains random addresses. Dereferencing it is **undefined behavior** which can crash.

> [!DANGER]
> Always initialize pointers. If you don''t know where to point, fill in `nullptr`. Uninitialized pointers contain random addresses and are very dangerous.' where id='3331bcb2-64f6-4349-88dd-c1e9c08b83d8'::uuid;
update public.bagian_modul set judul_en='Python Lists: A Comparison', konten_md_en='Python doesn''t have decay because it doesn''t have pointers. But there are behavioral differences that need to be understood.

## List Python Knows Length

```python
arr = [10, 20, 30, 40, 50]

print(len(arr))   # 5 - selalu bisa
```

In C++, `len()` does not exist for arrays passed to functions. In Python, lists always know their length.

## Negative Index

```python
arr = [10, 20, 30, 40, 50]

print(arr[-1])   # 50  - elemen terakhir
print(arr[-2])   # 40  - kedua dari belakang
```

This feature **doesn''t exist** in C++.

## Slicing COPYING

```python
arr = [10, 20, 30, 40, 50]
s = arr[1:4]

s[0] = 999

print(arr)   # [10, 20, 30, 40, 50] - TIDAK berubah
print(s)     # [999, 30, 40]
```

In C++, accessing via a pointer **doesn''t** copy — changing it changes the original data.

```cpp
// C++
int arr[5] = {10,20,30,40,50};
int* p = &arr[1];

p[0] = 999;
// arr sekarang: 10 999 30 40 50 - BERUBAH
```

**Important differences:**

| Operation | C++ pointers | Python slices |
|--------|-------------|--------------|
| Access some | Not copying | **Copying** |
| Changing results | Changing the original | **Does not change original** |

## Iteration

```python
# Cara Pythonic
for nilai in arr:
    print(nilai)

# Dengan indeks
for i in range(len(arr)):
    print(arr[i])

# Dengan enumerate
for i, nilai in enumerate(arr):
    print(i, nilai)
```

## Complete Comparison

| Aspect | C++ `int arr[5]` | Python `list` |
|-------|--------|--------|
| Know the length | Only in the original scope | **Always** |
| Decay | **Yes** | There is no concept of this |
| Negative index | No | **Yes** |
| Slice copying | No | **Yes** |
| Size | Fixed | Dynamic |
| Pointer arithmetic | Yes | Can''t |

> [!INFO]
> Python eliminates decay by storing the length in a list object. This is one of the reasons Python lists are safer, but also a bit heavier than C++ arrays.' where id='345bdc56-8ff6-4681-a191-a73372b54d73'::uuid;
update public.bagian_modul set judul_en='How vectors Grow', konten_md_en='This is the most important part to understand, as it explains many bugs that are difficult to track.

## Reallocation Process

When `push_back` is called and **size is already equal to capacity**:

1. Allocate a **new** larger memory block
2. **Copy** all old elements to the new block
3. **Free** old blocks
4. Add new elements

```
Sebelum push_back ke-5 (capacity=4, sudah penuh):

Blok lama: [1][2][3][4]        <- penuh

Setelah push_back ke-5:

1. Alokasi blok baru (kapasitas 8)
2. Salin 1,2,3,4 ke blok baru
3. Bebaskan blok lama
4. Tambah 5

Blok baru: [1][2][3][4][5][ ][ ][ ]
Blok lama: (dibebaskan)
```

## Consequences: Address Changed

Because data is moved to a new block, **element addresses change**.

```cpp
vector<int> v;
v.push_back(1);

int* p = v.data();              // simpan alamat elemen pertama
cout << p << "\n";              // 0x55605b89e030

for (int i = 0; i < 10; i++) v.push_back(i);

cout << v.data() << "\n";       // 0x55605b89e420 - BERUBAH!
```

**Real output:** address changed from `...e030` to `...e420`.

## DANGER: Dangling Pointer

This is a very dangerous bug because it is **often not immediately visible**.

```cpp
vector<int> v = {1, 2, 3};
int* p = &v[0];        // pointer ke elemen pertama

v.push_back(4);        // jika terjadi alokasi ulang...
v.push_back(5);
// ... pointer p sekarang DANGLING (menunjuk memori yang sudah dibebaskan)

cout << *p;            // UNDEFINED BEHAVIOR
```

The problem: this code **may appear to run normally**. The old value is still there in the freed memory, so `*p` can print the correct value. But as soon as that memory is used for something else, its value changes.

> [!DANGER]
> DO NOT save a pointer or reference to element `vector` and then call `push_back`. If reallocation occurs, that pointer becomes dangling and accessing it is undefined behavior.

## Safe Way

**Way 1: Use indexes, not pointers**

```cpp
vector<int> v = {1, 2, 3};
size_t idx = 0;

v.push_back(4);        // aman - indeks selalu valid
cout << v[idx];        // 1
```

**Way 2: reserve first**

```cpp
vector<int> v;
v.reserve(100);        // tidak akan realokasi sampai 100 elemen
int* p = &v[0];
for (int i = 0; i < 100; i++) v.push_back(i);
// p tetap valid
```

**Way 3: repeat fetch pointer after change**

```cpp
v.push_back(4);
p = &v[0];             // ambil ulang setelah push_back
```' where id='f31ac84e-a569-489e-9564-f15e144a2fc3'::uuid;
update public.bagian_modul set judul_en='Structs in Python', konten_md_en='Python doesn''t have `struct` like C++, but has a more flexible equivalent: **`dataclass`**.

## Dataclass

```python
from dataclasses import dataclass

@dataclass
class Titik:
    x: int
    y: int

t = Titik(3, 7)

print(t.x)   # 3
print(t.y)   # 7
```

## Which is Automatically Obtained

The `@dataclass` decorator creates several methods automatically:

```python
t = Titik(3, 7)

print(t)              # Titik(x=3, y=7)  <- repr otomatis
print(t == Titik(3,7))  # True            <- __eq__ otomatis
```

Without `@dataclass`, you have to write `__init__`, `__repr__`, and `__eq__` yourself.

## DON''T Forget the Decorator

```python
# SALAH - lupa @dataclass
class Titik:
    x: int
    y: int

t = Titik(3, 7)   # TypeError: takes no arguments
```

Without `@dataclass`, this class is just a type annotation — no `__init__` accepts arguments.

## Dataclass with Default Value

```python
@dataclass
class Mahasiswa:
    nama: str
    umur: int = 18          # nilai default
    aktif: bool = True

m = Mahasiswa("Rani")       # umur dan aktif pakai default
print(m)                    # Mahasiswa(nama=''Rani'', umur=18, aktif=True)
```

> [!ATTENTION]
> Fields with default values must be placed AFTER fields without default. Otherwise, Python throws `TypeError: non-default argument follows default argument`.

## Dataclass Can Be Changed

```python
@dataclass
class Titik:
    x: int
    y: int

t = Titik(3, 7)
t.x = 10        # BOLEH - dataclass mutable secara default
print(t)        # Titik(x=10, y=7)
```

If you want it to be immutable, use `frozen=True`:

```python
@dataclass(frozen=True)
class Titik:
    x: int
    y: int

t = Titik(3, 7)
t.x = 10        # ERROR: cannot assign to field ''x''
```

## Comparison of C++ and Python

| Aspect | C++ `struct` | Python `@dataclass` |
|-------|--------|---------------------|
| Declaration | `struct Titik { int x; }` | `@dataclass class Titik:` |
| Member type | Required, checked during compilation | Annotations, not runtime forced |
| Initialization | `Titik t = {3, 7};` | `Titik(3, 7)` |
| Print | Need to write it yourself | `repr` auto |
| Compare | Need to write it yourself | `__eq__` auto |
| Memory size | Can be calculated with `sizeof` | No concept `sizeof` |

> [!INFO]
> In Python, the type in the annotation (`x: int`) is **not forced at runtime**. You can still write `Titik("halo", 3.14)` without errors. Annotations are useful for documentation and tools like mypy, not for type enforcement.' where id='37d32053-a197-4d48-9369-6560d550a8de'::uuid;
update public.bagian_modul set judul_en='Structs as Parameters', konten_md_en='Structs can be passed to functions like regular types.

## Sent as Value (Copied)

```cpp
struct Titik { int x; int y; };

void geser(Titik t) {
    t.x = t.x + 10;   // mengubah SALINAN
}

int main() {
    Titik a = {3, 7};
    geser(a);

    cout << a.x;   // 3 - TIDAK berubah!
}
```

The struct is sent as a **copy**. Changing it inside the function doesn''t affect the original.

## Sent as Reference (Not Copied)

```cpp
void geser(Titik& t) {
    t.x = t.x + 10;   // mengubah ASLINYA
}

int main() {
    Titik a = {3, 7};
    geser(a);

    cout << a.x;   // 13 - berubah!
}
```

The `&` flag makes the function accept a **reference**, not a copy.

## Constant Reference (Safe and Fast)

```cpp
void cetak(const Titik& t) {
    cout << t.x << ", " << t.y;
    // t.x = 10;   // ERROR: tidak bisa diubah
}
```

`const` prevents the function from changing data, while `&` prevents copying. This is the most frequently used pattern.

## When to Use Which One

| How to | When |
|------|-------|
| `void f(Titik t)` | The struct is small AND needs to be changed without affecting the original |
| `void f(Titik& t)` | Need to change the original data |
| `void f(const Titik& t)` | **Most common** — read only, not copy |

## Structs Can Be Copied with `=`

```cpp
Titik a = {3, 7};
Titik b = a;      // SALINAN

b.x = 99;

cout << a.x;   // 3  - tidak berubah
cout << b.x;   // 99
```

> [!TIP]
> For large structs, always use `const Titik&` when reading only. Copying huge structs for every function call is unnecessary waste.' where id='417d85b9-c34a-4f2b-923a-6ac90f96e79b'::uuid;
update public.bagian_modul set judul_en='Why Need Structs', konten_md_en='Imagine storing data on one student. With separate variables:

```cpp
string nama1 = "Rani";
int umur1 = 20;
double ipk1 = 3.75;

string nama2 = "Budi";
int umur2 = 21;
double ipk2 = 3.50;
```

The problem is immediately visible:

- Must remember which variable belongs to whom
- Difficult to send to function (must send 3 parameters)
- Cannot be stored in one array
- Adding a new field means changing all the places

## Solution: Struct

`struct` groups **interrelated** data into one unit:

```cpp
struct Mahasiswa {
    string nama;
    int umur;
    double ipk;
};

Mahasiswa m1 = {"Rani", 20, 3.75};
Mahasiswa m2 = {"Budi", 21, 3.50};
```

Now `m1` is **one value** containing three data.

## When to Use Structs

Use a struct if these data **always appear together**:

| Situation | Struct |
|---------|--------|
| Points on a 2D plane | `struct Titik { int x; int y; }` |
| Student data | `struct Mahasiswa { string nama; int umur; }` |
| Items in the shop | `struct Barang { string nama; double harga; }` |
| Date | `struct Tanggal { int hari; int bulan; int tahun; }` |

> [!INFO]
> Structs are the first step from "loose variables" to a **data model**. It''s the basis of almost all real systems.

## Struct vs Class

In C++, `struct` and `class` are almost identical. The main differences:

| Aspect | `struct` | `class` |
|-------|----------|---------|
| Default access | **public** | **private** |
| Convention | Data container | Objects with behavior |

> [!TIP]
> General convention: use `struct` for **simple data containers** without logic, and `class` for objects that have behavior and hide internal details.' where id='5296ae9a-60bd-4c47-8c06-426dc62b6c6a'::uuid;
update public.bagian_modul set judul_en='Reduce Padding', konten_md_en='Since padding wastes memory, the question arises: can it be reduced?

### Method 1: Sort Members

This is advice that is often given: **order members from largest to smallest**.

**But be careful — this advice is NOT always true.**

## Proof of Measurement

Let''s compare on GCC 16.2.1, x86-64:

| Struct | sizeof | Economical? |
|--------|--------|--------|
| `{char a; int b;}` | **8** | — |
| `{int b; char a;}` | **8** | **NOT save!** |
| `{char a; long b; char c;}` | **24** | — |
| `{long b; char a; char c;}` | **16** | Save 8 bytes |
| `{char a; int b; short c;}` | **12** | — |
| `{int b; short c; char a;}` | **8** | Save 4 bytes |

**Notice the first and second lines:** `{char, int}` and `{int, char}` **are both 8 bytes**. Sorting doesn''t change anything!

## Why is that?

In a struct with **two members**, no small members can be packed together. Final padding is still needed so that the total size of the alignment multiple is largest.

**New sorting helps when there are several small members that can be packed side by side.**

## More Accurate Rules

> Padding is reduced when small members are grouped side by side so that they fit in one alignment block. This is **usually** achieved by ordering from largest to smallest, but is **not a guarantee**.

### Method 2: #pragma pack

`#pragma pack` forces the compiler to reduce or eliminate padding:

```cpp
#pragma pack(push, 1)
struct Padat {
    char a;
    int b;
};
#pragma pack(pop)
```

With `pack(1)`, `sizeof(Padat)` becomes **5 bytes**.

> [!DANGER]
> `#pragma pack(1)` has serious consequences:
>
> 1. **Slower** — CPU has to read multiple blocks and combine
> 2. **Not portable** — behavior differs between compilers
> 3. **Danger to ARM** — unaligned access can cause crashes
>
> Use only when absolutely necessary (e.g. network protocol or specified binary file format).

### Method 3: Verify Yourself

The best way is not to memorize the rules, but to **measure**:

```cpp
#include <cstddef>
#include <iostream>
using namespace std;

struct A2 { char a; int b; };
struct B2 { int b; char a; };

int main() {
    cout << sizeof(A2) << " " << sizeof(B2) << "\n";
    cout << offsetof(A2, a) << " " << offsetof(A2, b) << "\n";
}
```

> [!TIP]
> Don''t memorize "order from largest to smallest". Measure it yourself with `sizeof` and `offsetof`, then find out when sorting helps and when it doesn''t. This is much more valuable than memorizing rules that don''t always apply.' where id='72984582-46b8-440b-9455-62c704ae7a48'::uuid;
update public.bagian_modul set judul_en='Struct as Member', konten_md_en='Real data is almost always nested. Students have addresses, addresses have cities and postal codes.

With structs, we can nest structs within structs:

```cpp
struct Alamat {
    string kota;
    string kodePos;
};

struct Mahasiswa {
    string nama;
    int umur;
    Alamat alamat;      // struct sebagai anggota
};
```

## Multilevel Initialization

```cpp
Mahasiswa m = {"Rani", 20, {"Bandung", "40123"}};
```

Note the nested curly braces: `{"Bandung", "40123"}` is the value for `alamat`.

## Accessing Nested Members

Use **two dots** — one for each level:

```cpp
cout << m.nama;              // Rani
cout << m.alamat.kota;       // Bandung
cout << m.alamat.kodePos;    // 40123
```

How to read it: "`m` has `alamat`, and `alamat` has `kota`".

## Changing Nested Members

```cpp
m.alamat.kota = "Jakarta";
cout << m.alamat.kota;   // Jakarta
```

## Access Order Matters

```cpp
m.alamat.kota     // BENAR
m.kota.alamat     // SALAH - kota bukan anggota m
```

> [!ATTENTION]
> The most common mistake is **switching up the order**. Remember: access follows the structure from the outside in. `m` (outer) -> `alamat` (middle) -> `kota` (inner).

## Can be more than two levels

```cpp
struct Negara { string nama; };
struct Alamat { string kota; Negara negara; };
struct Mahasiswa { string nama; Alamat alamat; };

Mahasiswa m = {"Rani", {"Bandung", {"Indonesia"}}};

cout << m.alamat.negara.nama;   // Indonesia
```

There is no practical limit to the depth, but more than 3 levels is usually a sign that the structure needs to be simplified.' where id='8148e862-e113-4ccd-8c77-735f26ae680f'::uuid;
update public.bagian_modul set judul_en='Array of Structs', konten_md_en='This is a very frequently used pattern: **array where each element is a struct**.

## Declare

```cpp
struct Barang {
    string nama;
    double harga;
};

Barang daftar[3] = {
    {"Buku", 25000},
    {"Pulpen", 3000},
    {"Tas", 150000}
};
```

## Iterate

```cpp
double total = 0;

for (int i = 0; i < 3; i++) {
    cout << daftar[i].nama << " = Rp" << daftar[i].harga << "\n";
    total += daftar[i].harga;
}

cout << "total = Rp" << total;
```

**Real output:**

```
Buku = Rp25000
Pulpen = Rp3000
Tas = Rp150000
total = Rp178000
```

## Calculating the Number of Elements

```cpp
int jumlah = sizeof(daftar) / sizeof(daftar[0]);   // 3
```

This works **only** if the array is still in the same scope. If sent to a function, the size information is lost (decay).

## Sorts an Array of Structs

An array of structs can be sorted with `std::sort` and a comparison lambda:

```cpp
#include <algorithm>

struct Kelas { string nama; double ipk; };

Kelas kelas[3] = {{"Rani", 3.75}, {"Budi", 3.20}, {"Citra", 3.90}};

sort(kelas, kelas + 3, [](const Kelas& a, const Kelas& b) {
    return a.ipk > b.ipk;   // menurun
});
```

**Real output (GPA decreases):**

```
Citra = 3.9
Rani  = 3.75
Budi  = 3.2
```

Change `>` to `<` for ascending order.

## Array of Struct vs Struct of Array

Two ways of storing the same data:

**Array of Structs (AoS):**
```cpp
struct Mahasiswa { string nama; double ipk; };
Mahasiswa daftar[100];
```

**Struct of Arrays (SoA):**
```cpp
struct DaftarMahasiswa {
    string nama[100];
    double ipk[100];
};
```

| Aspect | Array of Structs | Structure of Arrays |
|-------|-----------------|-----------------|
| Readability | **Clearer** | Not clear |
| Access one object | **Good** (adjacent data) | Not good |
| Access one field of all objects | Not good | **Okay** |

**Recommendation:** use **array of structs** unless there is a specific performance reason. Readability is more important.

> [!TIP]
> An array of structs is the most natural way of modeling a "list of things". If you need to store 100 students, `Mahasiswa daftar[100]` is much easier to manage than 200 separate variables.' where id='8927f503-6621-44a2-b951-86b11bc3aca5'::uuid;
update public.bagian_modul set judul_en='Trap: Nested Lists', konten_md_en='This is the most well-known pitfall in Python, and often appears in exams and job interviews.

## Code That Looks Correct

```python
salah = [[0] * 3] * 3
salah[0][0] = 99

print(salah)
```

**Most people''s guesses:**
```python
[[99, 0, 0], [0, 0, 0], [0, 0, 0]]
```

**Actual results:**
```python
[[99, 0, 0], [99, 0, 0], [99, 0, 0]]
```

**All rows changed!**

## Why It Happens

`[[0] * 3] * 3` means: "create one list `[0,0,0]`, then **duplicate the reference** 3 times".

```python
salah = [[0] * 3] * 3

print([id(baris) for baris in salah])
# [139651255536768, 139651255536768, 139651255536768]
```

All three elements point to **the same list object**. Changing one means changing them all.

## The Right Way

Create a new list for each row:

```python
benar = [[0] * 3 for _ in range(3)]
benar[0][0] = 99

print(benar)
# [[99, 0, 0], [0, 0, 0], [0, 0, 0]]
```

Only the first line has changed.

```python
print([id(baris) for baris in benar])
# [139651255539008, 139651255539072, 139651255539136]
```

Now all three ids are **different** — each row is a separate object.

## Rule of Thumb

> [!DANGER]
> Never create a 2D list with `[[nilai] * kolom] * baris`. Always use **list comprehension**: `[[nilai] * kolom for _ in range(baris)]`.

The same problem applies to `dict` and `set` in the list. If the element is **mutable**, doubling with `*` will double its reference.

## C++ Version of This Trap

In C++ this trap **doesn''t exist** for regular arrays, because each element is a value, not a reference:

```cpp
int m[3][3] = {0};   // semua elemen benar-benar 0
m[0][0] = 99;        // hanya m[0][0] yang berubah
```

This is one reason C++ arrays are “safer” for beginners in this regard — but also more rigid.' where id='980484e5-b7fa-45f0-b5ed-ea0b14d6d879'::uuid;
update public.bagian_modul set judul_en='offsetof and Dangers of memcmp', konten_md_en='Two important tools when working with structs at the memory level.

## offsetof: View Member Positions

```cpp
#include <cstddef>

struct Campur { char a; int b; };

cout << offsetof(Campur, a);   // 0
cout << offsetof(Campur, b);   // 4
```

`offsetof` returns the **distance in bytes** from the start of the struct to that member.

It''s a very useful tool for:
- Proves padding exists
- Verifying the layout as expected
- Debugging serialization problems

## Padding Contains Indefinite Values

This is a very important and often overlooked point:

```cpp
struct Campur { char a; int b; };

Campur x = {''A'', 100};
Campur y = {''A'', 100};

// Apakah x == y?
```

Logically, `x` and `y` contain the same data. But **the padding bytes are not necessarily the same**.

Padding is filled with anything — old remaining data in memory, zero values, or whatever. The C++ standard **does not specify** its contents.

## Danger of memcmp

Because padding contains indeterminate values, comparing the struct with `memcmp` can give **wrong** results:

```cpp
#include <cstring>

struct Campur { char a; int b; };

Campur x = {''A'', 100};
Campur y;
y.a = ''A'';
y.b = 100;

if (memcmp(&x, &y, sizeof(Campur)) == 0) {
    cout << "sama";
} else {
    cout << "beda";   // <- bisa tercetak walau datanya sama!
}
```

`memcmp` compares **all bytes**, including padding whose contents are indeterminate.

> [!DANGER]
> DO NOT compare structs with `memcmp`. Padding contains indeterminate values, so two structs with identical data can be considered different.
>
> Compare members one by one, or write your own `==` operator.

## The Correct Way to Compare

```cpp
struct Titik { int x; int y; };

bool sama(const Titik& a, const Titik& b) {
    return a.x == b.x && a.y == b.y;
}
```

Or in C++20, use the default `operator==`:

```cpp
struct Titik {
    int x;
    int y;

    bool operator==(const Titik&) const = default;
};
```

## Dangers of Writing Structs to Files

The same problem applies when writing structs directly to a file:

```cpp
Campur x = {''A'', 100};
berkas.write((char*)&x, sizeof(Campur));
```

What is written includes padding bytes whose content is uncertain. If the file is read on another platform with different alignment rules, the results can be messed up.

> [!INFO]
> For serialization, use a format that doesn''t depend on memory layout — for example JSON, Protocol Buffers, or write each member one by one in an agreed order.' where id='9eab48f2-56ea-49b2-ba5d-9f01239effb9'::uuid;
update public.bagian_modul set judul_en='Static Array Problems', konten_md_en='Regular arrays have one big limitation: **their size must be known at compile time**.

```cpp
int arr[5];   // ukuran ditentukan di kode
```

The problem is, we often don''t know how much data will be processed when writing code:

- How many rows of data will be imported from the file?
- How many words did the user type?
- How many nodes does the graph need?

## Poor Temporary Solution

```cpp
int arr[10000];   // "biar aman, kasih besar saja"
```

This has two problems:

| Problem | Consequences |
|---------|--------|
| Wastes memory | 10,000 int = 40 KB, even though it takes 5 |
| Still can be less | What if you need 20,000? |

##Correct Solution

Use a container that can **grow as the program runs**:

| Language | Container | Characteristics |
|--------|-------|--------------------|
| C++ | `std::vector` | Dynamic, data on the heap |
| C++ | `std::array` | Fixed, but safer than C | array
| Python | `list` | Dynamic, saving references |

> [!INFO]
> `std::vector` is the most frequently used container in modern C++. Understanding it is a mandatory basic skill.

## What to Learn

1. How `vector` grows
2. Difference between `size` and `capacity`
3. Danger of the pointer to the element when `vector` grows
4. `vector` equivalent in Python: `list`' where id='11b9ee1f-7838-47de-a5ae-bf7ea9d3372f'::uuid;
update public.bagian_modul set judul_en='Equivalent in Python', konten_md_en='Python doesn''t have pointers, but there are important differences to understand.

## Python Doesn''t Need Arrow Operators

```python
@dataclass
class Titik:
    x: int
    y: int

t = Titik(3, 7)
print(t.x)     # 3 - selalu pakai titik
```

There is no `t->x` because there is no pointer. All access uses points.

## Important Difference: Objects Copied or Shared?

This is the biggest source of confusion when moving from C++ to Python.

**In C++, structs are copied:**

```cpp
Titik a = {3, 7};
Titik b = a;      // SALINAN

b.x = 99;
cout << a.x;      // 3 - TIDAK berubah
```

**In Python, objects are divided:**

```python
a = Titik(3, 7)
b = a             # REFERENSI yang sama

b.x = 99
print(a.x)        # 99 - IKUT berubah!
```

## Why It''s Different

| Aspect | C++ structs | Python objects |
|-------|-----------|--------------|
| `b = a` | Copy **value** | Copying **reference** |
| Change `b` | Does not affect `a` | **Affect `a`** |
| Need pointers? | Yes, to share | No, it''s automatic |

In C++, to make two variables point to the same object, you **need a pointer**. In Python, it happens **automatically**.

## How to Make a Copy in Python

```python
import copy

a = Titik(3, 7)
b = copy.copy(a)      # salinan dangkal

b.x = 99
print(a.x)            # 3 - TIDAK berubah
```

For nested objects, use `copy.deepcopy()`.

## Comparison Summary

| Operation | C++ | Python |
|---------|-----|--------|
| Member access | `t.x` (value) or `pt->x` (pointer) | `t.x` always |
| `b = a` | Copying the value | Copying references |
| Sharing objects | Need pointers | Automatic |
| Copy | Automatically when `=` | Need `copy()` |
| Null check | Need (`if (p)`) | No null pointer |

> [!INFO]
> Python eliminates pointers by making all names references. This eliminates many bugs (dangling pointers, null dereference), but also eliminates the low-level control that is sometimes needed.' where id='a60e4954-be6d-4505-bd08-4a9cedb95d6b'::uuid;
update public.bagian_modul set judul_en='Nested Struct Trap', konten_md_en='Several errors that often occur when using nested structs.

## Trap 1: Switched Access Order

```cpp
struct Alamat { string kota; };
struct Mahasiswa { string nama; Alamat alamat; };

Mahasiswa m = {"Rani", {"Bandung"}};

cout << m.alamat.kota;   // BENAR
cout << m.kota.alamat;   // SALAH - m tidak punya anggota ''kota''
```

The compiler will give the error "no member named ''city'' in ''Student''". This message is self-explanatory, so the error is easy to spot.

## Trap 2: Forgetting Nested Curly Brackets

```cpp
// SALAH - compiler bingung
Mahasiswa m = {"Rani", "Bandung"};

// BENAR - alamat dibungkus kurung sendiri
Mahasiswa m = {"Rani", {"Bandung"}};
```

## Pitfall 3: Mistakenly Thinking Nested Structs Are Partially Copied

The nested struct is copied **entirely**, including the structs within it:

```cpp
Mahasiswa a = {"Rani", 20, {"Bandung", "40123"}};
Mahasiswa b = a;              // SALINAN lengkap

b.alamat.kota = "Jakarta";

cout << a.alamat.kota;        // Bandung - TIDAK berubah
cout << b.alamat.kota;        // Jakarta
```

This is **different** from Python, where nested objects may share references.

## Trap 4: Using `->` even though it is not a pointer

```cpp
Mahasiswa m = {"Rani", {"Bandung"}};

cout << m->nama;      // SALAH - m bukan pointer
cout << m.nama;       // BENAR

Mahasiswa* p = &m;
cout << p->nama;      // BENAR - p pointer
cout << p.nama;       // SALAH
```

Rules: **`.` for value/reference, `->` for pointer.**

## Pitfall 5: Incorrect Cascade Initialization

```cpp
// SALAH - urutan tertukar
Mahasiswa m = {"Rani", {"40123", "Bandung"}};
// kota berisi "40123", kodePos berisi "Bandung"
```

The compiler will not error because both are of type `string`. This error is only visible while the program is running.

> [!DANGER]
> Initialization sequence error as above **not detected by compiler** if the types are the same. This is an important reason to use name initialization (C++20) when a struct has many members of the same type:
>
> ```cpp
> Mahasiswa m = {.nama = "Rani", .alamat = {.kota = "Bandung"}};
> ```' where id='bf5c3450-c2eb-4f4c-a91a-70c874a81085'::uuid;
update public.bagian_modul set judul_en='Array Name as Pointer', konten_md_en='An array name, in most situations, **changes automatically to a pointer** to its first element. This is called **array-to-pointer decay**.

```cpp
int arr[5] = {10, 20, 30, 40, 50};

int* p = arr;      // arr berubah jadi pointer ke arr[0]
```

**Evidence:**

```cpp
cout << (arr == &arr[0]);   // 1 (true)
```

`arr` and `&arr[0]` produce the **same** address.

## When does Decay Occur

| Situation | Decay? |
|---------|--------|
| Sent to function | **Yes** |
| Assigned to the pointer | **Yes** |
| Arithmetic (`arr + 1`) | **Yes** |
| `sizeof(arr)` | **No** |
| `&arr` | **No** |

## When Decay DOES NOT Occur

This is important — there are two situations where an array remains an array:

```cpp
int arr[5];

sizeof(arr);   // 20 - ukuran ARRAY, bukan pointer
&arr;          // pointer ke ARRAY (int(*)[5]), bukan int*
```

## Difference between &arr and arr

Both produce the same address, but **different types**:

| Expression | Type | `+ 1` jump |
|----------|------|----------------|
| `arr` | `int*` | 4 bytes (one element) |
| `&arr` | `int(*)[5]` | **20 bytes** (entire array) |

**Measurable proof:**

```cpp
cout << (char*)(arr + 1) - (char*)arr;      // 4
cout << (char*)(&arr + 1) - (char*)&arr;    // 20
```

Note: `&arr + 1` jumps **the entire array** (20 bytes), not a single element.

> [!INFO]
> `arr` and `&arr` produce the same address, but the type and arithmetic behavior are different. This is a detail that is often asked in job interviews.

## Consequences of Decay

Because the array turns into a pointer when sent to the function, **its size information is lost**. This is discussed in the next section.' where id='f230004e-8c0c-474d-89f8-b8ce22fd1111'::uuid;
update public.bagian_modul set judul_en='std::vector: Basic', konten_md_en='`std::vector` is a dynamic array from the C++ standard library.

```cpp
#include <vector>
using namespace std;

vector<int> v;              // kosong
vector<int> a = {1, 2, 3};  // dengan nilai awal
vector<int> b(5);           // 5 elemen, semua 0
vector<int> c(5, 7);        // 5 elemen, semua 7
```

## Basic Operations

| Operation | Code | Description |
|---------|------|------------|
| Add at the end | `v.push_back(4)` | Fastest, O(1) average |
| Delete at the end | `v.pop_back()` | O(1) |
| Size | `v.size()` | Number of elements |
| Capacity | `v.capacity()` | Allocated space |
| Access | `v[i]` or `v.at(i)` | `at()` check limits |
| First element | `v.front()` | — |
| Last element | `v.back()` | — |
| Clear | `v.clear()` | Size becomes 0, capacity remains |

## Usage Example

```cpp
vector<int> v = {10, 20, 30};

v.push_back(40);
v.push_back(50);

cout << v.size();      // 5
cout << v[0];          // 10
cout << v.back();      // 50

for (size_t i = 0; i < v.size(); i++) {
    cout << v[i] << " ";
}
```

## Difference between `v[i]` and `v.at(i)`

This is important for code safety:

```cpp
vector<int> v = {10, 20, 30};

cout << v.at(1);    // 20 - aman
cout << v[99];      // undefined behavior - TIDAK diperiksa
cout << v.at(99);   // melempar std::out_of_range
```

`at()` checks boundaries and throws exceptions. `[ ]` doesn''t check anything — just like a regular C array.

> [!TIP]
> Use `.at()` when the index comes from user input or a calculation that could be wrong. Use `[ ]` when you are sure the index is valid, because it is faster.' where id='c318013a-1c66-43d1-b1f8-c7c757704c29'::uuid;
update public.bagian_modul set judul_en='2D Lists in Python', konten_md_en='Python doesn''t have built-in 2D arrays like C++. What exists is a **nested list** — a list whose elements are lists.

```python
m = [[1, 2, 3], [4, 5, 6]]

print(m[1][2])   # 6
```

Looks similar, but the mechanism is **totally different** from C++.

## Important Differences

| Aspect | C++ `int m[2][3]` | Python `[[1,2,3],[4,5,6]]` |
|-------|----------|--------------------|
| Storage | One sequential memory block | A reference to a separate list object |
| Size | Fixed when compiling | Subject to change |
| Element type | Must be uniform | Free |
| Line | Part of the same block | Separate objects |

## Proving the Difference

```python
a = [1, 2, 3]
b = [4, 5, 6]
nested = [a, b]

print(id(nested[0]) == id(a))   # True
```

`nested[0]` **is** the same `a` object, not a copy. Nested lists store **references**, not values.

As a result, two lines can be stored in memory locations that are far apart — there is no sequential guarantee like C++.

## How to Access

```python
m = [[1, 2, 3], [4, 5, 6]]

# Ukuran
print(len(m))       # 2  (jumlah baris)
print(len(m[0]))    # 3  (jumlah kolom)

# Iterasi
for baris in m:
    for nilai in baris:
        print(nilai, end=" ")
```

> [!INFO]
> In Python there is no concept of `sizeof` for lists. `sys.getsizeof()` returns the size of the **list object**, not the size of the stored data.' where id='c7968063-419c-4c0b-9601-7be56461450e'::uuid;
update public.bagian_modul set judul_en='Memory Management in Python', konten_md_en='Python manages memory **automatically**. No `new`, no `delete`, no pointers.

## There is no delete in Python

```python
data = [1, 2, 3, 4, 5]

# ... pakai data ...

# Tidak ada yang perlu dilakukan.
# Python membersihkan otomatis saat data tidak dipakai lagi.
```

## Reference Counting

Python counts how many names point to an object:

```python
import sys

a = [1, 2, 3]

print(sys.getrefcount(a))   # 2 (a + argumen getrefcount)

b = a
print(sys.getrefcount(a))   # 3 (a, b, + argumen)

del b
print(sys.getrefcount(a))   # 2 kembali
```

When the counter reaches **zero**, the object is freed automatically.

**This is similar to `shared_ptr` in C++**, but happens to all objects without you needing to write.

## Garbage Collection for Reference Cycle

Reference counting has one weakness: **reference cycle**.

```python
class Node:
    def __init__(self):
        self.teman = None

a = Node()
b = Node()

a.teman = b      # a menunjuk b
b.teman = a      # b menunjuk a - SIKLUS!
```

Once `a` and `b` are deprecated, their reference counters **do not reach zero** because they are pointing at each other.

**The solution:** Python has a separate *garbage collector* that detects cycles like this and cleans them up.

So Python has **two mechanisms**:

| Mechanism | Handle |
|-----------|-----------|
| Reference counting | General case, direct |
| Garbage collector | Reference cycle, periodic |

## Why Python Doesn''t Have Pointers

| Reason | Explanation |
|--------|------------|
| All names are references | No need for a separate pointer |
| Memory managed automatically | No need `new`/`delete` |
| No arithmetic | Cannot access raw memory |
| Safe | No dangling, double free, or leak |

## Comparison

| Aspect | C++ raw pointers | C++ unique_ptr | Python |
|-------|------------------------|----------------|--------|
| Allocation | `new` | `make_unique` | Automatic |
| Liberation | `delete` manual | Automatic | Automatic |
| Risk of leaks | **High** | None | None |
| Reference cycle | Can | Can (with shared_ptr) | Handled by GC |
| Memory control | **Full** | Limited | None |

> [!INFO]
> Python sacrifices **control** for **security**. For most applications, this is a favorable trade-off. But for systems that require precise memory control (game engines, embedded systems, databases), C++ is still needed.

## Things to Remember

Even though Python manages memory automatically, **leaks are still possible**:

1. **Reference cycles** that GC doesn''t handle
2. **Unrestricted cache** — objects are stored continuously and never released
3. **Global references** that hold large objects

So "automatic" doesn''t mean "free from memory problems".' where id='d64133d8-5a3e-4e0d-9c38-cef454e22277'::uuid;
update public.bagian_modul set judul_en='Defining Structs', konten_md_en='## Basic Syntax

```cpp
struct NamaStruct {
    tipe anggota1;
    tipe anggota2;
};   // <- JANGAN lupa titik koma!
```

Note the **semicolon after the closing curly brace**. This is the most common mistake for beginners.

## Complete Example

```cpp
struct Titik {
    int x;
    int y;
};

int main() {
    Titik t = {3, 7};

    cout << t.x;   // 3
    cout << t.y;   // 7
}
```

## Three Ways to Initialize

```cpp
// Cara 1: daftar nilai berurutan
Titik a = {3, 7};

// Cara 2: dengan nama anggota (C++20, lebih jelas)
Titik b = {.x = 3, .y = 7};

// Cara 3: satu per satu
Titik c;
c.x = 3;
c.y = 7;
```

## Accessing Members

Use the **point operator** (`.`):

```cpp
Titik t = {3, 7};

t.x = 10;              // ubah nilai
cout << t.x;           // 10

int jumlah = t.x + t.y;   // 17
```

## Partial Initialization

```cpp
Titik t = {5};   // hanya x yang diisi

cout << t.x;   // 5
cout << t.y;   // 0  <- sisanya OTOMATIS nol
```

Just like arrays, uninitialized members are **automatically zeroed**.

## Structs Can Contain Anything

```cpp
struct Mahasiswa {
    string nama;        // string
    int umur;           // bilangan bulat
    double ipk;         // bilangan desimal
    bool aktif;         // boolean
    char kelas;         // karakter
};
```

Member types **may vary** — this is what differentiates structs from arrays which must be of uniform type.

> [!ATTENTION]
> Forgetting the semicolon after `}` in a struct definition is a very common error. The error message can be confusing because it points to the next line, not where the error occurred.' where id='ea397a8c-08d4-4b71-a1a5-ec21b6df6f8e'::uuid;
update public.bagian_modul set judul_en='Array of Structs Via Pointers', konten_md_en='Pointers are also useful for accessing arrays of structs.

## Access with Pointer Arithmetic

```cpp
Mahasiswa daftar[3] = {
    {"Rani", 20, 3.75},
    {"Budi", 21, 3.20},
    {"Citra", 22, 3.90}
};

Mahasiswa* p = daftar;   // decay ke &daftar[0]

for (int i = 0; i < 3; i++) {
    cout << (p + i)->nama;
}
```

**Measured output:**

```
(p+0)->nama = Rani
(p+1)->nama = Budi
(p+2)->nama = Citra
```

## Equivalent Form

These four forms produce the same result:

```cpp
daftar[i].nama        // cara indeks biasa
p[i].nama             // pointer + indeks
(p + i)->nama         // aritmetika pointer + arrow
(*(p + i)).nama       // eksplisit
```

**Proof:** `p[1].nama` = `Budi`, the same as `(p+1)->nama`.

## When to Use Which One

| Shape | When to use |
|--------|--------------------|
| `daftar[i].nama` | **Most obvious** - use this for new code |
| `p[i].nama` | When `p` is already pointer |
| `(p + i)->nama` | When explaining pointer arithmetic |

> [!TIP]
> While `(p + i)->nama` is valid, `p[i].nama` is easier to read. Use the most obvious form unless there is a special reason.

## Changing Elements Via Pointers

```cpp
Mahasiswa* p = daftar;

p[1].ipk = 4.0;      // atau (p + 1)->ipk = 4.0

cout << daftar[1].ipk;   // 4.0 - array ASLI berubah
```

## Iterate with Pointers

```cpp
// Gaya pointer
for (Mahasiswa* p = daftar; p != daftar + 3; ++p) {
    cout << p->nama << "\n";
}
```

Note `daftar + 3` — this is **one-past-the-end**, and as explained in module 7, it is **LEGAL** (not UB). What UB does is just dereference it.

## Trap: nullptr

```cpp
Mahasiswa* kosong = nullptr;

if (kosong) {
    // tidak dijalankan
}

// kosong->nama;   // UB - tidak dijalankan
```

Always check pointers before accessing their members, especially if they come from function parameters.' where id='fe48b8cc-71a1-4a92-8cf9-a777f28e95d1'::uuid;
update public.bagian_modul set judul_en='2D Array Concept', konten_md_en='A 2D array is an array whose elements are arrays. Imagine a table with **rows** and **columns**.

```cpp
int m[3][4];   // 3 baris, 4 kolom
```

How to read the above declaration: "`m` is an array of 3 elements, where each element is an array of 4 `int`".

## Why 3x4 and not 4x3

The first number is **number of rows**, the second number is **number of columns**:

| Declaration | Line | Column | Total elements |
|-----------|-------|-------|--------------|
| `int m[3][4]` | 3 | 4 | 12 |
| `int m[2][5]` | 2 | 5 | 10 |

> [!TIP]
> Remember: rows first, columns later. Just like reading coordinates (row, column) in a spreadsheet.

## Initialize 2D Array

```cpp
// Cara 1: bersarang, lebih jelas
int m[2][3] = {
    {1, 2, 3},
    {4, 5, 6}
};

// Cara 2: rata, hasilnya sama
int n[2][3] = {1, 2, 3, 4, 5, 6};
```

Both ways produce **identical** arrays. The first method is easier to read because its shape resembles a table.

## Accessing Elements

```cpp
int m[2][3] = {{1,2,3},{4,5,6}};

cout << m[0][0];   // 1  (baris 0, kolom 0)
cout << m[1][2];   // 6  (baris 1, kolom 2)
```

Note: `m[1][2]` means row **1**, column **2** — not vice versa.' where id='1779c6c0-a0d5-4472-bb80-20baf0e64313'::uuid;
update public.bagian_modul set judul_en='Equivalent in Python', konten_md_en='Python doesn''t have an array of structs, but it does have a more flexible equivalent: **list of dataclass**.

## Nested Dataclasses

```python
from dataclasses import dataclass

@dataclass
class Alamat:
    kota: str
    kode_pos: str

@dataclass
class Mahasiswa:
    nama: str
    umur: int
    alamat: Alamat

m = Mahasiswa("Rani", 20, Alamat("Bandung", "40123"))

print(m.nama)             # Rani
print(m.alamat.kota)      # Bandung
```

Multilevel access uses dots, just like C++.

## List of Dataclasses

```python
daftar = [
    Mahasiswa("Rani", 20, Alamat("Bandung", "40123")),
    Mahasiswa("Budi", 21, Alamat("Jakarta", "10110")),
]

for m in daftar:
    print(f"{m.nama} dari {m.alamat.kota}")
```

## Sorting

Python has `sorted()` with parameter `key`:

```python
@dataclass
class Kelas:
    nama: str
    ipk: float

kelas = [
    Kelas("Rani", 3.75),
    Kelas("Budi", 3.20),
    Kelas("Citra", 3.90),
]

# Urut menurun berdasarkan ipk
terurut = sorted(kelas, key=lambda k: k.ipk, reverse=True)

for k in terurut:
    print(f"{k.nama} = {k.ipk}")
```

**Output:**
```
Citra = 3.9
Rani = 3.75
Budi = 3.2
```

## Comparison with C++

| Aspect | C++ | Python |
|-------|-----|--------|
| Nested structs | `struct` inside `struct` | `dataclass` inside `dataclass` |
| Multilevel access | `m.alamat.kota` | `m.alamat.kota` |
| Array of structs | `Barang daftar[3]` | `daftar = [...]` |
| Size | Fixed | Dynamic |
| Sorting | `std::sort` + lambda | `sorted()` + `key` |
| Number of elements | `sizeof/sizeof` | `len()` |

> [!INFO]
> In Python, lists can hold dataclasses of different types without errors. This is flexible but also risky: new types of errors are detected while the program is running, not while writing the code.' where id='ee612e6c-69f2-4b17-bc7f-6e1e1d38f3c4'::uuid;
update public.bagian_modul set judul_en='new and delete', konten_md_en='`new` allocates memory on the heap. `delete` freed him.

## Single Value Allocation

```cpp
int* p = new int(42);   // alokasi + inisialisasi

cout << *p;             // 42

delete p;               // bebaskan
```

## Array Allocation

```cpp
int* arr = new int[5];   // 5 elemen

for (int i = 0; i < 5; i++) arr[i] = i * 10;
cout << arr[4];          // 40

delete[] arr;            // PERHATIKAN: delete[]
```

## RULE: new[] MUST Be Paired with delete[]

These are the rules that **should not be broken**:

| Allocation | TRUE Liberation | The WRONG |
|---------|----------------------|------------|
| `new int` | `delete p` | `delete[] p` |
| `new int[5]` | `delete[] arr` | `delete arr` |

Mixing the two is **undefined behavior**.

```cpp
int* arr = new int[5];
delete arr;      // UB! seharusnya delete[]
```

> [!DANGER]
> `new[]` must be paired with `delete[]`, and `new` must be paired with `delete`. Mixing them up is undefined behavior that can cause crashes or memory corruption.

## delete DOES NOT Change the Pointer

Here''s a fact that surprises many people:

```cpp
int* p = new int(42);
cout << p;      // 0x557d611d7030

delete p;
cout << p;      // 0x557d611d7030  <- MASIH ALAMAT LAMA!
```

**`delete` frees memory, but does NOT change the pointer value.**

After `delete`, `p` still keeps the old address. That address is now invalid — using it is **undefined behavior**.

**Good practice:**

```cpp
delete p;
p = nullptr;    // set sendiri, tidak otomatis
```

## Pointer Size vs Data

```cpp
cout << sizeof(int*);   // 8 (pointer)
cout << sizeof(int);    // 4 (data)
```

Pointers are always 8 bytes in 64-bit systems, no matter the size of the data being pointed to.

> [!TIP]
> After `delete`, always set the pointer to `nullptr`. This prevents *dangling pointers* and makes the `if (p)` check meaningful.' where id='025d7d49-ef0a-4c05-839f-4fb7e04af63f'::uuid;
update public.bagian_modul set judul_en='Smart Pointers', konten_md_en='Modern C++ provides **smart pointers** that free memory automatically. This eliminates three classic bugs at once.

## unique_ptr: Sole Proprietorship

```cpp
#include <memory>

{
    auto p = make_unique<int>(99);

    cout << *p;    // 99

}   // <- memori OTOMATIS dibebaskan di sini
```

No `delete`. It''s impossible to forget. It''s impossible to double free.

## unique_ptr Cannot Be Copied

Due to sole ownership:

```cpp
auto p1 = make_unique<int>(7);

// auto p2 = p1;         // ERROR: tidak bisa disalin
auto p2 = move(p1);      // BOLEH: dipindahkan

cout << *p2;             // 7
cout << (p1 == nullptr); // 1 (true) - p1 sekarang kosong
```

**Once moved, `p1` becomes empty.** This prevents two `unique_ptr`s from having the same object.

## unique_ptr for Arrays

```cpp
auto arr = make_unique<int[]>(3);

arr[0] = 1;
arr[1] = 2;
arr[2] = 3;

// otomatis dibebaskan, tidak perlu delete[]
```

## shared_ptr: Shared Ownership

If several pieces of code need to have the same object:

```cpp
#include <memory>

auto s1 = make_shared<int>(55);

cout << s1.use_count();    // 1

{
    auto s2 = s1;          // salinan DIPERBOLEHKAN
    cout << s1.use_count(); // 2
}

cout << s1.use_count();    // 1 - s2 sudah hilang
```

**Measured output:** `1 → 2 → 1`

Memory is freed when **counter reaches zero** — meaning no one else owns that object.

## Comparison

| Aspect | Raw pointers | unique_ptr | shared_ptr |
|-------|-------|------------|------------|
| Need `delete` manual | **Yes** | No | No |
| Can be copied | Yes | **No** | Yes |
| Can be moved | Yes | **Yes** | Yes |
| Risk of leaks | **High** | None | None |
| Cost | Free | Very small | Slightly larger |

## When to Use Which One

| Situation | Choice |
|---------|---------|
| Sole proprietorship (most common) | **`unique_ptr`** |
| Shared ownership | `shared_ptr` |
| Just look, don''t have | Raw pointer or reference |
| Interact with C API | Raw pointers |

> [!TIP]
> **Modern C++ rules:** avoid manual `new`/`delete`. Use `make_unique` as default. Use `shared_ptr` only if you really need shared ownership — it''s a little more expensive due to reference counting.

## Why This Matters

With smart pointers, three classic bugs are **not likely to occur**:

| Bugs | With unique_ptr |
|-----|------------------|
| Memory leaks | Not possible — automatically released |
| Dangling | Not possible — pointer becomes empty |
| Double free | Not possible — only freed once |

It''s not just convenience. This eliminates a whole category of bugs.' where id='23b78b43-973a-4b02-8223-13d961d4cc16'::uuid;
update public.bagian_modul set judul_en='Pointer Arithmetic', konten_md_en='Pointer arithmetic is different from regular number arithmetic.

## Rule: Scale Follows Type

`p + 1` **doesn''t** add 1 byte. It adds **`sizeof(*p)` bytes**.

```cpp
int arr[5];
int* p = arr;

cout << (char*)(p + 1) - (char*)p;   // 4 (sizeof(int))
```

| Pointer type | `p + 1` adds |
|--------------|-----|
| `char*` | 1 byte |
| `int*` | 4 bytes |
| `double*` | 8 bytes |
| `Titik*` (struct) | `sizeof(Titik)` bytes |

**Measurable proof:**

```cpp
char c[4];   char* pc = c;
double d[3]; double* pd = d;

(char*)(pc + 1) - (char*)pc;   // 1
(char*)(pd + 1) - (char*)pd;   // 8
```

## Why Scale Follows Type

Because the purpose of `p + 1` is to point to the **next element**, not the next byte. If `int*` adds 1 byte, it will point to the middle of the int — useless.

## Permitted Operations

| Operation | Example | Description |
|---------|--------|------------|
| Add number | `p + 3` | Jump 3 elements |
| Less number | `p - 2` | Backward 2 elements |
| Difference of two pointers | `p2 - p1` | The number of elements between the two |
| Increments | `p++` | Go forward one element |
| Comparison | `p1 < p2` | Compare positions (same arrays) |

## Pointer Difference

```cpp
int arr[5] = {10, 20, 30, 40, 50};
int* awal = &arr[0];
int* akhir = &arr[4];

cout << (akhir - awal);   // 4 (elemen, BUKAN byte)
```

The result is **4 elements**, not 16 bytes. The `-` operator on the pointer returns the number of elements.

## Safe Boundaries

For an array of size `n`:

```
arr + i    LEGAL    jika  0 <= i <= n
*(arr + i) LEGAL    jika  0 <= i < n
```

Note the upper bound is **different**:

- Forming a pointer: can be up to `n` (one-past-the-end)
- Dereferencing: only up to `n-1`

> [!DANGER]
> Pointer arithmetic outside this limit is **undefined behavior**.
>
> ```cpp
> int arr[5];
> int* p = arr + 6;   // UB!
> int* q = arr - 1;   // UB!
> ```
>
> Surprisingly: **going further than one-past-the-end is also UB**, even if you don''t dereference it.' where id='26a6564a-634f-4a6c-b614-52f609b75878'::uuid;
update public.bagian_modul set judul_en='Size vs Capacity', konten_md_en='This is the concept that most often confuses newbies, and it often comes up in job interviews.

## The difference

| Terms | Meaning |
|---------|------|
| **size** | Number of elements that **actually exist** |
| **capacity** | The number of elements that **can fit** before needing to be reallocated |

The analogy is like a cupboard:

```
size = 3      -> 3 baju tergantung
capacity = 8  -> lemari muat 8 baju
```

The cupboard can hold 8, but only contains 3.

## Seeing the Growth

```cpp
vector<int> v;

cout << v.size() << " " << v.capacity() << "\n";   // 0 0

for (int i = 1; i <= 10; i++) {
    v.push_back(i);
    cout << v.size() << " " << v.capacity() << "\n";
}
```

**Real output (GCC 16.2.1):**

```
size  capacity
  1      1
  2      2
  3      4      <- kapasitas berlipat
  4      4
  5      8      <- berlipat lagi
  6      8
  7      8
  8      8
  9     16      <- berlipat lagi
 10     16
```

Note: the capacity doubles (1 → 2 → 4 → 8 → 16), while the size increases one by one.

## Why Capacity Has Doubled

Because adding capacity one by one will be very slow:

```
Tambah 1 per 1  : setiap push_back butuh alokasi ulang -> O(n) per operasi
Lipat ganda     : alokasi ulang jarang -> O(1) rata-rata
```

By multiplying, re-allocations become less frequent as the data increases.

> [!ATTENTION]
> The growth number **2x** is *implementation-defined* — not guaranteed by the C++ standard. GCC uses 2x, but other implementations may use 1.5x. **Don''t memorize the numbers**; understand **why** multiple growth is necessary.

## reserve: Prevents Re-Allocation

If the number of elements is known, use `reserve()`:

```cpp
vector<int> v;
v.reserve(10);      // alokasikan ruang untuk 10 elemen

cout << v.size();       // 0
cout << v.capacity();   // 10
```

Now `push_back` doesn''t need re-allocation until the 11th element.

> [!TIP]
> If you know it will hold 1000 elements, call `v.reserve(1000)` before the loop. This prevents dozens of re-allocations and speeds up the program significantly.' where id='2c4b7e23-7490-460a-b304-e0feed6e6055'::uuid;
update public.bagian_modul set judul_en='Large Structs & Pointers', konten_md_en='Why are pointers important for structs? Because **avoids copying**.

## Problem: Large Struct Copied

```cpp
struct Besar {
    int data[1000];
};

cout << sizeof(Besar);   // 4000 byte
```

If this struct is sent **as a value** to the function:

```cpp
void proses(Besar b) {    // menyalin 4000 byte!
    // ...
}
```

Each call copies **4000 bytes**. If it''s called 1000 times, that''s 4 million bytes of unnecessary copying.

**Measurable proof:** `sizeof(Besar)` = 4000 bytes, while `sizeof(Besar*)` is only 8 bytes.

## Solution: Send Pointer

```cpp
void proses(Besar* b) {   // menyalin 8 byte saja
    // ...
}

proses(&data);
```

Only **8 bytes** are copied (pointer size), not 4000 bytes.

## Three Ways to Send Structs

| How to | Copied? | Can it be changed? | When to use |
|------|----------|--------------|--------------------------|
| `void f(Titik t)` | **Yes** (entire struct) | No | Small struct + need copy |
| `void f(Titik* t)` | Only 8 bytes | **Yes** | Need to change the original data |
| `void f(const Titik* t)` | Only 8 bytes | No | **Most common** - read only |

## Proof: Values vs Pointers

**Send as value — DOES NOT change:**

```cpp
void ubahNilai(Mahasiswa m) {
    m.ipk = 4.0;
}

Mahasiswa m = {"Rani", 20, 3.5};
ubahNilai(m);
// m.ipk tetap 3.5
```

**Send as pointer — CHANGED:**

```cpp
void ubahPointer(Mahasiswa* m) {
    m->ipk = 4.0;
}

ubahPointer(&m);
// m.ipk jadi 4.0
```

**Measured output:**

```
Sebelum:               Rani ipk=3.5
Setelah ubahNilai:     Rani ipk=3.5   <- TIDAK berubah
Setelah ubahPointer:   Rani ipk=4     <- BERUBAH
```

## Most Common Pattern: const Pointer

```cpp
void cetak(const Mahasiswa* m) {
    cout << m->nama << " ipk=" << m->ipk;
    // m->ipk = 4.0;   // ERROR - tidak bisa diubah
}
```

`const` prevents functions from changing data, while pointers prevent copying. This is the most frequently used pattern in professional C++ code.

> [!TIP]
> Rule of thumb: send the struct as `const T*` if it''s just reading, and `T*` if it needs to change. Send as value (`T`) only for small structs (under ~16 bytes) that really need to be copied.' where id='f6a6d695-d230-4021-9305-6020da10f0bb'::uuid;
update public.bagian_modul set judul_en='Memory Address', konten_md_en='Each variable in the program occupies space in memory, and that space has an **address**.

```cpp
int nilai = 42;

cout << nilai;    // 42    <- NILAI
cout << &nilai;   // 0x7ffd...  <- ALAMAT
```

The `&` (address-of) operator takes the address of a variable.

## Analogy: House and Address

| Concept | Analogy |
|--------|---------|
| Variable | Home |
| Value | House contents |
| Address | Home address |
| Pointers | Paper containing home address |

The pointer doesn''t store the contents of the house — it stores the **address** of the house.

## Addresses are numbers

Memory addresses are actually just numbers — position numbers in memory. In 64-bit systems, addresses are written in hexadecimal:

```
0x7ffdd6755440
```

This address changes every time the program is run (due to *address space layout randomization*). What''s important is not the number, but that the address **points to a consistent location** as long as the program runs.

## View Address Size

```cpp
cout << sizeof(&nilai);   // 8 pada sistem 64-bit
```

Addresses are always the same size (8 bytes in 64-bit), no matter the data type. The `int` address and the `double` address are both 8 bytes long.

> [!INFO]
> Memory addresses are not values that need to be memorized. What you need to understand: **each variable has a unique address**, and pointers store that address.

## Why This Matters

With the address, you can:

1. **Change the value of another variable** from within the function
2. **Avoid copying** big data
3. **Create a dynamic data structure** whose size changes
4. **Access memory directly** for low level control

This is all the basis of linked lists, trees, graphs, and almost all advanced data structures.' where id='3374086a-2138-47a7-ad7e-08cf0ba20c81'::uuid;
update public.bagian_modul set judul_en='Dereference', konten_md_en='Dereference means **retrieving the value at the pointer''s stored address**. Carried out with the operator `*`.

```cpp
int nilai = 42;
int* p = &nilai;

cout << p;    // 0x7ffd...  <- alamat
cout << *p;   // 42         <- nilai di alamat itu
```

## Reading and Writing

```cpp
int nilai = 42;
int* p = &nilai;

cout << *p;    // 42  - membaca

*p = 100;      // menulis lewat pointer
cout << nilai; // 100 - nilai ASLI berubah!
```

This is the power of pointers: **change another variable** without touching its name directly.

## Two Meanings of Star Signs

This is what often confuses beginners:

| Context | Meaning |
|---------|------|
| In the declaration | Part of TYPE |
| In expression | Dereference operator |

```cpp
int* p = &nilai;   // * di sini bagian dari tipe
*p = 100;          // * di sini operator dereferensi
```

## Danger: Nullptr dereference

```cpp
int* p = nullptr;
cout << *p;    // UNDEFINED BEHAVIOR - crash!
```

Dereferencing `nullptr` is **undefined behavior**. Programs usually crash, but the standard doesn''t guarantee that — it may appear to be running normally.

**Always check before dereferencing:**

```cpp
if (p != nullptr) {
    cout << *p;   // aman
}
```

> [!TIP]
> Good habit: before dereferencing a pointer, ask "does this pointer definitely point to a valid object?" If in doubt, check with `if (p)`.

## Pointers and const

`const` on a pointer can mean two different things:

```cpp
// 1. Tidak bisa mengubah NILAI yang ditunjuk
const int* p1 = &nilai;
// *p1 = 10;   // ERROR
p1 = &lain;    // BOLEH

// 2. Tidak bisa mengubah ALAMAT yang disimpan
int* const p2 = &nilai;
*p2 = 10;      // BOLEH
// p2 = &lain; // ERROR

// 3. Keduanya tidak bisa diubah
const int* const p3 = &nilai;
```

How to read: read from right to left.

| Declaration | Meaning |
|-----------|------|
| `const int* p` | pointer to constant int |
| `int* const p` | constant pointer to int |
| `const int* const p` | constant pointer to constant int |' where id='fe68a9cb-fd58-4ecd-b68e-9e49ee172a5b'::uuid;
update public.bagian_modul set judul_en='Three Classic Memory Bugs', konten_md_en='Manual memory management is the most expensive source of bugs in C/C++. There are three that occur most often.

### Bug 1: Memory Leak

**Cause:** forgot `delete`.

```cpp
void bocor() {
    for (int i = 0; i < 10; i++) {
        int* p = new int(i);
        if (*p > 5) {
            return;      // <- LEAK: return tanpa delete
        }
        delete p;
    }
}
```

**Why it''s leaking:** `new` allocates on the heap. When `return`, the `p` pointer disappears from the scope, **but memory on the heap is not automatically freed**.

**Consequence:** memory is used until the program ends. In long programs, memory runs out and the program crashes.

**Important:** forgetting `delete` **isn''t** undefined behavior — just a memory leak. The differences are important:

| Problem | UB? | Consequences |
|---------|-----|--------|
| Forgot `delete` | **No** | Memory continues to be used, eventually runs out |
| Use after `delete` | **Yes** | It could be anything, including crashes |

**Fix:**

```cpp
int* p = new int(i);
if (*p > 5) {
    int hasil = *p;
    delete p;        // bebaskan SEBELUM return
    return hasil;
}
delete p;
```

### Bug 2: Dangling Pointers

**Cause:** using a pointer after its memory has been freed.

```cpp
int* p = new int(42);
delete p;

cout << *p;    // UNDEFINED BEHAVIOR!
```

**The danger:** this code **may appear to run normally**. The freed memory still contains the old value, so `*p` can print 42.

But as soon as that memory is used for something else, its value changes. This is what makes this bug so difficult to track down.

**Fix:**

```cpp
delete p;
p = nullptr;

if (p) {
    cout << *p;    // tidak dijalankan
}
```

### Bug 3: Double Free

**Cause:** calling `delete` twice on the same pointer.

```cpp
int* p = new int(42);

delete p;
delete p;      // UNDEFINED BEHAVIOR!
```

**Consequences:** could crash, could damage the heap, could be anything.

**Fix:**

```cpp
delete p;
p = nullptr;

delete p;      // AMAN - delete pada nullptr tidak melakukan apa-apa
```

This is one reason **always set the pointer to `nullptr` after `delete`** — it makes the second `delete` safe.

## Summary

| Bugs | Causes | UB? | Prevention |
|-----|----------|-----|------------|
| Memory leaks | Forgot `delete` | No | Always keep it free, or use the smart pointer |
| Dangling | Use after `delete` | **Yes** | Set `nullptr` after `delete` |
| Double free | `delete` twice | **Yes** | Set `nullptr` after `delete` |

> [!DANGER]
> These three bugs are the reason why modern C++ advocates **smart pointers**. With `unique_ptr`, all three are **impossible** — memory is freed automatically when the pointer goes out of scope.' where id='41ec14c6-0468-4745-92cb-d0cd3316671f'::uuid;
update public.bagian_modul set judul_en='When is Dynamic Allocation Required', konten_md_en='Not all data needs to be allocated dynamically. Here''s when it''s really necessary.

## Four Situations That Require Heap

### 1. Size is only known at runtime

```cpp
int n;
cin >> n;

int* data = new int[n];
```

Ordinary arrays need a constant size when compiling. If the size is from user input, you must use a heap.

**In modern C++:** use `std::vector` which takes care of this automatically.

### 2. Lifetime Exceeds Scope

```cpp
int* buat() {
    int* p = new int(42);
    return p;    // masih valid setelah fungsi selesai
}
```

The stack variable is lost when the function completes. Data in the heap remains alive until `delete`.

### 3. Recursive Data Structures

This is the most important for Data Structures:

```cpp
struct Node {
    int data;
    Node* next;      // menunjuk node lain di heap
};
```

**Linked lists, trees, and graphs** are impossible to create without dynamic allocation, because:
- The size changes as the program runs
- Nodes point to each other, and their number is unknown at the start

### 4. Large Objects

```cpp
// Stack kecil - ini bisa overflow
int besar[1000000];    // 4 MB

// Heap besar - aman
int* besar = new int[1000000];
```

## When NOT to Need to be Dynamic

| Situation | Better choice |
|---------|------------------------|
| Size known at compile time | `std::array` or regular array |
| Dynamic but simple size | `std::vector` |
| Small struct | Send as value |
| Only read big data | `const` pointer or reference |

## In Modern C++: Avoid Manual new/delete

```cpp
// GAYA LAMA - hindari
int* data = new int[n];
// ... 
delete[] data;

// GAYA MODERN - pakai ini
vector<int> data(n);
// otomatis dibebaskan
```

`std::vector` does the same thing but **impossible to leak**.

## For Data Structures: Smart Pointer

```cpp
struct Node {
    int data;
    unique_ptr<Node> next;   // kepemilikan jelas
};
```

With `unique_ptr`, the entire linked list is freed automatically when the head exits the scope. No need to browse and delete one by one.

> [!TIP]
> For the Data Structures module, you will often use `new`/`delete` because it is part of the material. But in production code, use `std::vector` and smart pointer. Understanding both is important: one for exams, one for work.' where id='44d64e12-3ac3-40ad-8661-b76a02b28616'::uuid;
update public.bagian_modul set judul_en='Notational Equivalence', konten_md_en='Because `arr` turns into a pointer and `p + i` points to the ith element, then:

```cpp
arr[i]  ==  *(arr + i)
```

This is no coincidence — `arr[i]` is **defined** as `*(arr + i)`.

## All Forms Are Equal

```cpp
int arr[5] = {10, 20, 30, 40, 50};

arr[3]        // 40
*(arr + 3)    // 40
*(3 + arr)    // 40  <- penjumlahan komutatif
3[arr]        // 40  <- valid, tapi JANGAN dipakai
```

**Measurable proof:** all four make 40.

## Why is i[arr] Valid

Since `arr[i]` translates to `*(arr + i)`, and addition is commutative (`arr + i == i + arr`), then `i[arr]` is also valid.

**But don''t use them.** Codes like `3[arr]` confuse readers and are useless. This is only interesting as a language fact.

## Pointer vs Index Notation

| Notation | When to use |
|--------|--------------------|
| `arr[i]` | **Most obvious** — use this |
| `*(arr + i)` | When explaining how array | works
| `*(p + i)` | When working with pointers |
| `i[arr]` | Don''t use it — just a language fact |

> [!TIP]
> Use `arr[i]` for readability. Understand `*(arr + i)` to understand **why** arrays can be accessed so quickly: element addresses are calculated directly, without searching.

## Important Consequences

Since `arr[i]` is equivalent to `*(arr + i)`, the **array does not store boundary information**. There is no way for `arr` to know how long it is.

This is why C++ cannot detect out-of-bounds accesses — the information simply isn''t in the array itself.

Compare with Python: Python lists **know** their length, so they can throw `IndexError`.' where id='531cbfa5-881c-43e5-bc8d-43f5065cd6d6'::uuid;
update public.bagian_modul set judul_en='Pointer to Struct', konten_md_en='Pointers can point to structs, just as they can to other types.

```cpp
struct Titik { int x; int y; };

Titik t = {3, 7};
Titik* pt = &t;      // pointer ke struct
```

## How to Access Members

There are **two ways**, and they are equivalent:

```cpp
(*pt).x      // BENAR - dereferensi dulu, lalu akses anggota
pt->x        // BENAR - cara singkat
```

**Measurable proof:** all three produce the same value.

```cpp
cout << t.x;        // 3
cout << pt->x;      // 3
cout << (*pt).x;    // 3
```

## Why There Are Operators ->

`(*pt).x` is correct but **a pain to write** and easy to get wrong. The brackets are required because the operator `.` has a higher priority than `*`.

Without brackets:

```cpp
*pt.x        // SALAH - dibaca sebagai *(pt.x)
```

This will error because `pt.x` is invalid (pt is a pointer, not a struct).

Therefore C++ provides `->` as an abbreviation:

```cpp
pt->x   ==   (*pt).x
```

> [!TIP]
> Use `->` for the pointer. Use `.` for value or reference. This simple rule prevents confusion.

## Changing Members Via Pointers

```cpp
Titik t = {3, 7};
Titik* pt = &t;

pt->x = 99;

cout << t.x;   // 99 - struct ASLI berubah
```

Since the pointer points to the original `t`, changing it via the pointer changes `t`.

## Summary Table

| Expression | Valid? | Description |
|----------|--------|------------|
| `t.x` | Yes | `t` is a struct |
| `pt->x` | Yes | `pt` is the pointer |
| `(*pt).x` | Yes | Dereference then access |
| `pt.x` | **No** | `pt` pointer, not struct |
| `*pt.x` | **No** | Wrong priority |
| `t->x` | **No** | `t` is not a pointer |' where id='790e3443-d7cd-485f-9656-7083ada23163'::uuid;
update public.bagian_modul set judul_en='Pointers in Python', konten_md_en='Python **doesn''t have pointers** like C++. But Python has something similar: **reference**.

## All Names in Python Are References

```python
x = [1, 2, 3]
y = x          # y menunjuk objek yang SAMA

y.append(4)
print(x)       # [1, 2, 3, 4] - x ikut berubah!
```

`y = x` does not copy the list. Both names designate **the same object**.

## View Object Identity

```python
x = [1, 2, 3]
y = x

print(id(x))            # 140323743028864
print(id(y))            # 140323743028864  <- SAMA
print(id(x) == id(y))   # True
```

`id()` returns the object''s identity — similar to a memory address.

## This is SIMILAR to Pointers, But DIFFERENT

| Aspect | C++ pointers | Python name |
|-------|-------------|-------------|
| Saving | Address | Reference to object |
| Arithmetic | Can (`p + 1`) | Can''t |
| Can be cast | Can | Can''t |
| Visible address | Yes (`cout << p`) | Indirect (`id()`) |
| Memory management | Manuals | Automatic |

**Most important difference:** in C++ you can do **pointer arithmetic** (`p + 1`), in Python you can''t. You cannot "add 1" to a Python name.

## Make the Actual Copy

```python
x = [1, 2, 3]
y = x.copy()      # salinan baru

y.append(4)
print(x)          # [1, 2, 3] - TIDAK berubah
print(y)          # [1, 2, 3, 4]
print(id(x) == id(y))   # False
```

## For Nested Objects: deepcopy

```python
import copy

x = [[1, 2], [3, 4]]
y = x.copy()          # salinan DANGKAL

y[0].append(99)
print(x)              # [[1, 2, 99], [3, 4]] - IKUT berubah!
```

`copy()` only copies the outer list. The list inside is still **divided**.

```python
z = copy.deepcopy(x)  # salinan MENDALAM

z[0].append(77)
print(x)              # tidak berubah
```

> [!DANGER]
> `copy()` only copies one level. For nested objects, use `copy.deepcopy()`. This is a very common source of bugs in Python.

## Why Python Doesn''t Need Pointers

Python manages memory automatically:

1. **No explicit address** — you don''t need to know where the object is stored
2. **No `delete`** — *garbage collector* cleans unused objects
3. **No dangling pointers** — the object remains alive as long as there is a reference

> [!INFO]
> Understanding C++ pointers makes you understand **why** Python was designed without pointers. Python sacrifices low-level control for security. For most applications, this is a favorable trade-off.' where id='8e37d8e4-1c8d-47f0-a7b3-720d1fa7d5f6'::uuid;
update public.bagian_modul set judul_en='Stack vs Heap', konten_md_en='C++ programs have two main memory areas: **stack** and **heap**. Understanding the difference is key to understanding dynamic allocation.

## Comparison

| Aspect | Stacks | Heap |
|-------|-------|------|
| Speed ​​| **Very fast** | Slower |
| Size | Small (usually 1-8 MB) | Large (limited memory available) |
| Lifespan | Automatic (when exiting scope) | **Manual** (until at-`delete`) |
| Management | Automatically by compiler | **Manual by programmer** |
| Fragmentation | None | Could happen |

## Normal Variables Are in the Stack

```cpp
void fungsi() {
    int x = 42;         // di stack
    Titik t = {3, 7};   // di stack

}   // <- x dan t OTOMATIS hilang di sini
```

When the function completes, all local variables are **automatically freed**. No need to do anything.

## Dynamic Allocation is on the Heap

```cpp
void fungsi() {
    int* p = new int(42);   // di HEAP

    // ... pakai p ...

    delete p;   // <- WAJIB dibebaskan manual
}
```

If you forget `delete`, the memory remains in use **until the program ends**.

## Why There Are Two

**Stack** is suitable for data that:
- The size is known at compile time
- Its lifetime is limited to one scope

**Heap** is required for data that:
- The size is only known when the program is running
- Its lifespan must exceed the manufacturer''s scope
- The size is too big for the stack

## Example: New Size Known at Runtime

```cpp
int n;
cout << "Berapa data? ";
cin >> n;

int* arr = new int[n];   // ukuran dari input pengguna

// ... pakai arr ...

delete[] arr;
```

This **cannot** be done with regular arrays because the size must be a constant at compile time.

## Danger: Stack Overflow

Small stack. Large allocations on the stack can cause **stack overflow**:

```cpp
void bahaya() {
    int besar[1000000];   // 4 MB di stack - bisa overflow!
}
```

The solution: allocate it on the heap.

```cpp
void aman() {
    int* besar = new int[1000000];   // di heap
    // ...
    delete[] besar;
}
```

> [!INFO]
> Rule of thumb: small, short-lived data -> stack. Large or long-lived data -> heap. But in modern C++, **avoid manual `new`/`delete`** — use `std::vector` or *smart pointer*.' where id='9f013cd8-0d87-4da1-a48e-af7b7f053e67'::uuid;
update public.bagian_modul set judul_en='Correction: One-Past-The-End Is LEGAL', konten_md_en='This section corrects **very common** misconceptions — including those that are often taught incorrectly.

## Common Misconceptions

Many say:

> "Performing `arr + 5` on an array of size 5 is undefined behavior."

**This is WRONG.**

## Correct

The C++ standard **allows** forming pointers one step past the last element. That pointer is called **one-past-the-end**.

```cpp
int arr[5] = {10, 20, 30, 40, 50};

int* akhir = arr + 5;    // LEGAL! Ini pointer one-past-the-end
```

This is not UB. The standard even names this category of values ​​as valid values.

## Proof: Valid Loop Idioms

Take a look at the following loop — it''s **legal** precisely because `arr + 5` is legal:

```cpp
for (int* p = arr; p != arr + 5; ++p) {
    cout << *p << " ";
}
// Output: 10 20 30 40 50
```

If `arr + 5` is UB, then this standard loop idiom is also UB — even though this is the usual and correct way to iterate over an array.

## Three Different Things

This must be clearly differentiated:

| Operation | Status |
|---------|--------|
| **Forming** `arr + 5` (one-past-end) | **LEGAL** |
| **Dereferencing** `*(arr + 5)` | **UNDEFINED BEHAVIOR** |
| **Going further** `arr + 6` or `arr - 1` | **UNDEFINED BEHAVIOR** |

```cpp
int arr[5];

int* a = arr + 5;    // LEGAL
// int x = *a;       // UB - tidak dijalankan
// int* b = arr + 6; // UB - tidak dijalankan
// int* c = arr - 1; // UB - tidak dijalankan
```

## Why This Rule Exists

This rule makes sense if you think about it: to write a loop `p != akhir`, you **need** to be able to construct a pointer `akhir` that points one step through the array. Otherwise, you have to use `<` indexes and comparisons, which are less common in C++.

## Summary of Pointer Arithmetic Rules

For an array with `n` elements:

```
arr + i  LEGAL    jika  0 <= i <= n
arr + i  UB       jika  i < 0 atau i > n

*(arr + i)  LEGAL jika  0 <= i < n
*(arr + i)  UB    jika  i == n atau di luar rentang
```

Note the limits: **`<= n`** to form the pointer, **`< n`** to dereference it.

> [!INFO]
> This is an important example that "often repeated rules" are not necessarily true. Always verify against standards or official documentation, not secondary sources.' where id='a9c9ae58-ccff-426c-8f46-1d78dbda2ad0'::uuid;
update public.bagian_modul set judul_en='vectors vs arrays', konten_md_en='Three containers are often confused: plain C array, `std::array`, and `std::vector`.

## Comparison

| Aspect | `int arr[5]` | `std::array<int,5>` | `std::vector<int>` |
|-------|--------|---------------------|---------------------|
| Size | Fixed (compile) | Fixed (compile) | **Dynamic** |
| Location data | Stacks | Stacks | **Heap** |
| `.size()` | None | **There** | **There** |
| Decay to pointer | **Yes** | No | No |
| Can be copied with `=` | No | **Yes** | **Yes** |
| Check limits | No | No | There is (`.at()`) |
| Can grow | No | No | **Yes** |

## Decay: Typical C Array Problems

```cpp
void cetak(int arr[]) {
    cout << sizeof(arr);   // 8 (ukuran POINTER, bukan array!)
}

int main() {
    int arr[5] = {1,2,3,4,5};
    cout << sizeof(arr);   // 20 (ukuran array asli)
    cetak(arr);
}
```

Inside the function, `sizeof(arr)` produces **8 bytes** — the size of the pointer — not the 20 bytes size of the array. Size information is **missing**.

`std::array` doesn''t have this problem:

```cpp
void cetak(const array<int,5>& a) {
    cout << a.size();   // 5 - informasi ukuran TIDAK hilang
}
```

## When to Use Which One

| Situation | Choice |
|---------|---------|
| Fixed size, requires maximum performance, C | interoperability `int arr[5]` |
| Fixed size, want to be safe and have `.size()` | `std::array<int,5>` |
| Size unknown at compile time | `std::vector<int>` |
| Need to be able to grow/decrease | `std::vector<int>` |

> [!TIP]
> Modern C++ rule of thumb: **defaults to `std::vector`**. Use `std::array` if the size is fixed and you want extra security. Use regular C arrays only if you interact with C-style APIs or need maximum performance.' where id='c5159968-c50b-4ac7-b954-46205aa5c3db'::uuid;
update public.bagian_modul set judul_en='Calculating Element Addresses', konten_md_en='Because 2D arrays are stored row by row, the address of each element can be calculated directly.

## Formula

```
alamat(i,j) = alamat(0,0) + (i x jumlahKolom + j) x sizeof(Tipe)
```

Note: what is multiplied is **number of columns**, not number of rows.

## Calculation Example

Arrays `int m[2][3]`, `sizeof(int) = 4`:

| Element | Calculation | Offset bytes |
|--------|-------------|-------------|
| `m[0][0]` | (0×3 + 0) × 4 | 0 |
| `m[0][2]` | (0×3 + 2) × 4 | 8 |
| `m[1][0]` | (1×3 + 0) × 4 | 12 |
| `m[1][2]` | (1×3 + 2) × 4 | 20 |

Note `m[1][0]`: line 1 starts at offset 12, which is after the **entire** line 0 (3 elements × 4 bytes).

## Proving with Code

```cpp
int m[2][3] = {{1,2,3},{4,5,6}};

long selisih = (char*)&m[1][2] - (char*)&m[0][0];

cout << selisih;   // 20
```

The result is **20 bytes**, matching the formula: (1×3 + 2) × 4 = 20.

## Alternative Notation

`m[i][j]` is actually syntax sugar. Original form:

```cpp
m[i][j]  ==  *(*(m + i) + j)
```

Why? `m + i` points to the ith row, `*(m + i)` is that row, then `+ j` points to the jth column, and the final `*` takes its value.

```cpp
int m[2][3] = {{1,2,3},{4,5,6}};

cout << m[1][2];          // 6
cout << *(*(m+1)+2);      // 6  <- sama persis
```

> [!TIP]
> The `alamat(i,j) = alamat(0,0) + (i x kolom + j) x sizeof` formula is the reason why 2D array access can be so fast — the address is calculated directly, without searching.' where id='cfd64099-2d88-4ef6-aed5-cb3306353e9c'::uuid;
update public.bagian_modul set judul_en='Row-Major Order', konten_md_en='This is the most important concept in multidimensional arrays: **how elements are stored in memory**.

C++ stores 2D arrays **row by row**, not column by column. This is called **row-major order**.

## Visualization

Array `int m[2][3]` with value `{{1,2,3},{4,5,6}}`:

```
Logis (yang kamu lihat):        Memori (yang sebenarnya):

    kol0  kol1  kol2              Alamat:  0    4    8   12   16   20
bar0  1     2     3               Nilai:   1    2    3    4    5    6
bar1  4     5     6                        └── baris 0 ──┘└── baris 1 ──┘
```

Row 0 is saved **in its entirety** first, then row 1.

## Proving with Code

```cpp
int m[2][3] = {{1,2,3},{4,5,6}};
int* flat = &m[0][0];   // alamat elemen pertama

cout << m[1][2];      // 6
cout << flat[5];      // 6  <- elemen ke-6 dari awal
```

`flat[5]` produces `6`, the same as `m[1][2]`. This proves the elements are stored sequentially: the 5th index is row 1, column 2.

## Why This Matters

Because it is stored row by row, **accessing adjacent elements in a row is much faster** than jumping between rows.

```cpp
// CEPAT: akses berurutan dalam satu baris
for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 4; j++) {
        proses(m[i][j]);
    }
}
```

> [!INFO]
> Python **does** guarantee that nested lists are stored sequentially in memory. What is stored sequentially is a *reference* to each row. This is an important difference from C++.' where id='dfededd4-de79-42a3-ba34-02d6b189222b'::uuid;
update public.video set judul_en='Learn C++ [Basic] - 57 - Nesting Structs', deskripsi_en='Nested structures, arrays of structs, and modeling of interconnected entities in a structured manner.' where id='3d2215f6-91be-432f-b714-15dfa9a97786'::uuid;
update public.video set judul_en='Learn C++ [Basic] - 43 - Arrays || Standard Library', deskripsi_en='An introduction to std::array and modern C++ container concepts, the size utility function (.size()), and the transition to dynamic arrays.' where id='4131b54f-1adb-425c-8ef2-7b9826893f25'::uuid;
update public.video set judul_en='Learn C++ [Basic] - 38 - Pointers', deskripsi_en='The concept of pointers in C++, the address operator (&), the dereference operator (*), and how to manipulate variable values via memory addresses.' where id='60713118-5d55-4ed7-a181-e6d462ba34eb'::uuid;
update public.video set judul_en='Learn C++ [Basic] - 46 - Multidimensional Arrays | Built-ins', deskripsi_en='Understanding 2-dimensional arrays (matrices), row and column representation, as well as row-column index mapping in memory.' where id='11799492-4ad8-4012-b665-f820fe33fe43'::uuid;
update public.video set judul_en='Learn C++ [OOP] - 20 - This & Cascading Function Calls', deskripsi_en='Accessing struct/object members via pointers uses the arrow operator (->) and the implicit pointer role this in C++.' where id='31ea4ef7-73dd-44e8-ad95-5526a2e8cd2b'::uuid;
update public.video set judul_en='Learn C++ [Basic] - 40 - Functions with Pointers', deskripsi_en='Sending pointers and arrays to function parameters, the concept of decaying arrays into pointers, and manipulating array data via pointers.' where id='74d56a14-6548-4f84-8316-e34065157415'::uuid;
update public.video set judul_en='Learn C++ [OOP] - 07 - Various ways to create Objects', deskripsi_en='Dynamic memory allocation on the heap using the new keyword, saving the address to a pointer, and freeing memory with delete.' where id='7de167f3-b3ff-4d7f-982e-2d8e511fda01'::uuid;
update public.video set judul_en='Learn C++ [OOP] - 08 - Memory and Addresses of Objects', deskripsi_en='Dissect the memory structure of objects/structs in C++, analyze the memory address of each member, the size of size, and the concepts of padding and alignment.' where id='d6f52d0d-3ac5-4977-ade4-70105e7c7867'::uuid;
update public.video set judul_en='Learn C++ [Basic] - 42 - Introduction to Arrays', deskripsi_en='Basic concepts of arrays, declarations, element indexing, and representation of array elements stored sequentially in memory.' where id='dcee140e-9ba8-4f78-aa1a-0421c79a1ec1'::uuid;
update public.video set judul_en='Learn C++ [Basic] - 56 - Structs', deskripsi_en='Create new data types with structs, group heterogeneous type variables, and access members with the dot operator.' where id='e5da63dc-6528-4cee-87f3-89cba2e382b2'::uuid;
update public.flashcard set depan_en='What are the two meanings of the asterisk on a pointer?', belakang_en='1. In DECLARATION = part of TYPE
   int* p;

2. In EXPRESSION = DEREFERENCE operator
   *p = 100;

This is what often confuses beginners.' where id='116409ea-b00a-41c2-96cd-b78427fa94b8'::uuid;
update public.flashcard set depan_en='int arr[5];
cout << (arr == &arr[0]);', belakang_en='Output: 1 (true)

The name of the array and the address of its first element
produces the SAME address.

This is proof of decay: arr turns into a pointer to arr[0].' where id='7d405e59-f7a8-470e-a0df-faa27f60b4c5'::uuid;
update public.flashcard set depan_en='Why does the vector capacity double (2x) and not increase by 1?', belakang_en='Because adding 1 by 1 would be very slow:
each push_back requires reallocation -> O(n) per operation

With multiples, re-allocations become less frequent
as data grows -> O(1) on average.

NOTE: the 2x number is implementation-defined.
GCC uses 2x, other implementations can use 1.5x.' where id='fbb0dc00-9d01-4353-83ce-f21e40d4598b'::uuid;
update public.flashcard set depan_en='How do I create an empty vector and a vector with 5 elements with a value of 7?', belakang_en='vector<int> empty;         // empty
vector<int> v(5, 7);      // 5 elements, all 7
vector<int> w = {1,2,3};  // with initial value' where id='80554832-97ae-4846-b8ea-4e6690531fec'::uuid;
update public.flashcard set depan_en='What happens if you access a local variable value that has gone out of scope via a pointer?', belakang_en='UNDEFINED BEHAVIOR.

int* f() {
    local int = 42;
    return &local;   // DANGER!
}

Once f() completes, the local no longer exists.
The pointer returned is a DANGLING POINTER.

Using it = UB.' where id='808009b4-74ea-4685-a59d-72f7608d5043'::uuid;
update public.flashcard set depan_en='What is the difference between C++ arrays and Python lists?', belakang_en='C++ arrays (int arr[5]):
- fixed size when compiling
- uniform element type
- one sequential block of memory

List Python ([0]*5):
- size can change
- free element type
- saves references to objects' where id='dba998ea-ecb0-4200-808f-33caee5896d9'::uuid;
update public.flashcard set depan_en='What''s wrong with this code?\nstruct Point { int x; int y; }\nint main() { ... }', belakang_en='LESS THE semicolon after the closing curly brace.

Correct:
struct Point { int x; int y; };   <- semicolon

The error message often points to the next line,
not where the error is.' where id='0782f7b8-60e0-438d-a6e2-2dc41c117562'::uuid;
update public.flashcard set depan_en='What is the formula for the address of the ith element in an array?', belakang_en='address(i) = address(0) + i x sizeof(Type)\n\nTherefore accessing the array is very fast: the addresses can be calculated directly.' where id='62b267df-4667-431d-9a55-e3c55e21f95c'::uuid;
update public.flashcard set depan_en='How to create a 5 element array in Python?', belakang_en='arr = [0] * 5

By direct value:
arr = [10, 20, 30, 40, 50]

Python uses LIST, not arrays like C++.' where id='6de4eaaf-e714-493c-a598-6b5b33760fe8'::uuid;
update public.flashcard set depan_en='What''s wrong with this code?\nint arr[5];\narr[5] = 100;', belakang_en='Index 5 is OUT of bounds.

An array of size 5 has indices 0 to 4.
Writing arr[5] is undefined behavior: it may appear to work, but it corrupts the surrounding memory.' where id='8694ffb1-7999-407f-9456-a0e7e033f6fe'::uuid;
update public.flashcard set depan_en='How to declare an array of 5 integers in C++?', belakang_en='int arr[5];

// With initial value:
int arr[5] = {10, 20, 30, 40, 50};' where id='94021799-480e-4d9f-816e-24c3cdaf49ea'::uuid;
update public.flashcard set depan_en='int m[2][3] = {{1,2,3},{4,5,6}};
int* flat = &m[0][0];
cout << flat[5];

What is the output?', belakang_en='Outputs: 6

flat[5] is the 6th element from the start = m[1][2] = 6.
This proves the 2D array is stored sequentially (row-major).' where id='f29249be-886f-4ccd-812a-a6d990167476'::uuid;
update public.flashcard set depan_en='Why does new[] have to be paired with delete[]?', belakang_en='Because they are DIFFERENT:

new int -> delete p
new int[5] -> delete[] arr

Mixing it up is UNDEFINED BEHAVIOR:

int* arr = new int[5];
delete arr;      // UB! should be delete[]' where id='0aaabfbc-5eaf-474f-a379-3b05ce4ac290'::uuid;
update public.flashcard set depan_en='vector<int> v;
for (int i = 1; i <= 10; i++) {
    v. push_back(i);
    cout << v.size() << " " << v.capacity() << "\n";
}

What is the output pattern (GCC)?', belakang_en='size increases by 1 each time:
1, 2, 3, 4, 5, 6, 7, 8, 9, 10

MULTIPLE capacity: 1, 2, 4, 8, 16

capacity increases only when size reaches its limit.' where id='63d7308d-439c-4b97-8b0e-b745dac3ced7'::uuid;
update public.flashcard set depan_en='When should you use vectors and when should you use arrays?', belakang_en='Use VECTOR if:
- unknown size at compile time
- need to add/subtract elements
- need .size() and security

Use ARRAY (C or std::array) when:
- fixed and known size
- need maximum performance
- interact with C style API

Modern C++ default: std::vector.' where id='f3764b1e-da7b-450f-aa67-4a23aaabf992'::uuid;
update public.flashcard set depan_en='What is the difference between v[i] and v.at(i)?', belakang_en='v[i] : DOES NOT check bounds (undefined behavior)
v.at(i) : CHECKS bounds, throws std::out_of_range

Use .at() if the index comes from user input.
Use [ ] if you are sure the index is valid (faster).' where id='703ca35c-1aaf-4dc7-b933-2cc94fd2a7a1'::uuid;
update public.flashcard set depan_en='What is the difference between size and capacity in vector?', belakang_en='size = number of elements that are ACTUALLY present
capacity = number of elements that CAN be accommodated
           before needing to be re-allocated

Cupboard analogy:
size = 3 clothes depending
capacity = cupboard fits 8 clothes' where id='dc631692-9764-4d0f-b3de-5826df0d123b'::uuid;
update public.flashcard set depan_en='What is sizeof(struct { char a; int b; }) if sizeof(int)=4?', belakang_en='8 bytes instead of 5.

1 (char) + 3 (padding) + 4 (int) = 8

3 bytes of padding appears for int b to start with
at an offset that is a multiple of 4.' where id='df32dd2a-e9d3-4cac-9621-c5452b5fda12'::uuid;
update public.flashcard set depan_en='Why is array accessing so fast?', belakang_en='Because element addresses can be CALCULATED DIRECTLY:
address(i) = address(0) + i x sizeof(Type)

No need to search or browse.
The complexity is O(1) - constant time,
does not depend on the position of the element.' where id='14081b65-846c-423f-b2d3-80fa793d5ce7'::uuid;
update public.flashcard set depan_en='How to initialize a nested struct?', belakang_en='Student m = {"Rani", 20, {"Bandung", "40123"}};

Note the NESTING curly braces:
{"Bandung", "40123"} is the value for the address.' where id='14cbcf34-2c95-488b-8778-93315022e03a'::uuid;
update public.flashcard set depan_en='What is the difference between const int* p and int* const p?', belakang_en='const int* p : value cannot be changed, address IS OK
int* const p : address cannot be changed, value CAN
const int* const p : both are immutable

How to remember: read from right to left.
The const closest to p locks p.' where id='186a400b-bb90-4b8f-a910-a9a4a729ebbb'::uuid;
update public.flashcard set depan_en='How to iterate over an array of structs?', belakang_en='for (int i = 0; i < 3; i++) {
    cout << list[i].name;
    cout << list[i].price;
}

Access the members of each element with the dot operator.' where id='e9276590-cfb9-4412-b07d-64843234c1b6'::uuid;
update public.flashcard set depan_en='Does ordering struct members ALWAYS reduce padding?', belakang_en='NO.

{char a; int b;} = 8 bytes
{int b; char a;} = 8 bytes

SAME! Sorting doesn''t help on 2 member structs.

Sorting only helps if there are SEVERAL small members
which can be packed side by side.' where id='6173c386-2384-49fa-9241-9fe9a198544c'::uuid;
update public.flashcard set depan_en='How to create an immutable dataclass?', belakang_en='Use frozen=True:

@dataclass(frozen=True)
class Point:
    x: int
    y: int

t = Point(3, 7)
t.x = 10 # ERROR: cannot assign to field

Without frozen, the dataclass is mutable by default.' where id='8a61d544-206a-46c5-acee-1511166e8821'::uuid;
update public.flashcard set depan_en='What happens if you dereference nullptr?', belakang_en='UNDEFINED BEHAVIOR - usually crashes,
but the standard doesn''t guarantee that.

int* p = nullptr;
cout << *p;   // UB!

Always check: if (p) { cout << *p; }' where id='f476781e-606c-4dbc-9084-73204063785d'::uuid;
update public.flashcard set depan_en='What is double free?', belakang_en='Calling delete TWICE on the same pointer.

int* p = new int(42);
delete p;
delete p;      // UB!

Improvements:
delete p;
p = nullptr;
delete p;      // SAFE - delete on nullptr is OK' where id='188da660-1ac8-4e86-96f4-8779cf68e590'::uuid;
update public.flashcard set depan_en='int m[2][3] = {{1,2,3},{4,5,6}};
cout << *(*(m+1)+2);

What is the output?', belakang_en='Outputs: 6

*(*(m+1)+2) is the same as m[1][2].

m+1 -> points to row 1
*(m+1) -> row 1 itself
+2 -> column 2
* -> value = 6' where id='2018ede9-897d-43e5-92b4-18aebb40e7b3'::uuid;
update public.flashcard set depan_en='Is arr[i] the same as *(arr + i)?', belakang_en='YES, both are IDENTICAL.

arr[i] is DEFINED as *(arr + i).

int arr[5] = {10,20,30,40,50};
arr[3] = 40
*(arr + 3) = 40

This is not a coincidence - it is the definition of the language.' where id='fc972eb6-276c-4798-a066-4712fd57639b'::uuid;
update public.flashcard set depan_en='Why do pointers always have to be initialized?', belakang_en='Uninitialized pointers contain RANDOM ADDRESS
(wild pointer).

int* p;        // DANGER - random address
cout << *p;    // UB!

If you don''t know where to point:
int* p = nullptr;' where id='5efe8f35-0f82-4fe4-8a07-a3b930157b0a'::uuid;
update public.flashcard set depan_en='What is the difference between arr and &arr?', belakang_en='Both are the SAME address, but different TYPE:

arr : int* -> +1 jumps 4 bytes (one element)
&arr : int(*)[5] -> +1 jumps 20 bytes (ENTIRE array)

Measurable evidence:
(char*)(arr+1)-(char*)arr = 4
(char*)(&arr+1)-(char*)&arr = 20' where id='68fb8b6b-c042-4b72-872c-78753321ee4e'::uuid;
update public.flashcard set depan_en='int arr[5] = {10, 20, 30, 40, 50};
initial int* = &arr[0];
final int* = &arr[4];
cout << (end - start);', belakang_en='Outputs: 4

The difference of two pointers yields the NUMBER OF ELEMENTS,
not bytes.

(end - start) = 4 elements, not 16 bytes.' where id='f29f6e79-e925-4f45-b9bb-c507e359125c'::uuid;
update public.flashcard set depan_en='What is a memory leak?', belakang_en='Heap memory that is NOT freed due to forgetting to delete.

void leak() {
    int* p = new int(42);
    // forgot to delete -> LEAK
}

Result: memory is used up until the program ends.
In long programs, memory runs out -> crashes.' where id='e1ddc798-c5c7-4a9f-970e-8b49e22d29b3'::uuid;
update public.flashcard set depan_en='What are the differences in terms of use? and ->?', belakang_en='. (dot) : for VALUE or REFERENCE
-> (arrow) : for POINTER

Point t = {3,7};
t.x // CORRECT
t->x // FALSE

Point* pt = &t;
pt->x // TRUE
pt.x // WRONG' where id='22d063c0-f2fc-4adf-b2a1-cfd3fd5972d2'::uuid;
update public.flashcard set depan_en='a = [1, 2, 3]
b = a
b.append(4)
print(a)

What is the output?', belakang_en='[1, 2, 3, 4]

b = a does NOT make a copy!
Both point to the SAME list object.

To copy: use a.copy(), a[:], or list(a).' where id='372f7a25-9c8a-44da-bd36-4a689c746dcf'::uuid;
update public.flashcard set depan_en='Why is it necessary to check the pointer before accessing its members?', belakang_en='Because accessing members via nullptr is UB.

Student* p = nullptr;
p->name;   // UB!

Always check:
if (p) { cout << p->name; }

This is especially important if the pointer comes from a function parameter.' where id='39920c96-9b5d-41cf-b251-f622a5d84c33'::uuid;
update public.flashcard set depan_en='How to retrieve the address of a variable?', belakang_en='Use the & (address-of) operator:

int value = 42;
cout << &value;   // 0x7ffd...

& is the opposite of * (dereference).' where id='39b00636-eed9-454a-bfea-f9cbfd951c4e'::uuid;
update public.flashcard set depan_en='How to declare a pointer to a struct?', belakang_en='struct Point { int x; int y; };

Point t = {3, 7};
Point* pt = &t;   // pointer to struct' where id='3b59075c-0844-4ac2-9f0a-7bf1f86bba59'::uuid;
update public.flashcard set depan_en='struct Student { double ipk; };

void changePointer(Student* m) { m->ipk = 4.0; }

Student m = {3.5};
changePointer(&m);
cout << m.ipk;', belakang_en='Outputs: 4

Send as POINTER = send address.
Changing m->ipk changes the ORIGINAL struct.

Compare with send value: the result is still 3.5.' where id='eece344c-6284-49a3-8318-ab16437a0f8e'::uuid;
update public.flashcard set depan_en='How to allocate a single value in the heap?', belakang_en='int* p = new int(42);   // allocation + initialization

cout << *p;             // 42

delete p;               // MUST be released' where id='737e1537-633e-44d4-a8d5-0e90375cef90'::uuid;
update public.flashcard set depan_en='How to access an array of structs via pointers?', belakang_en='Student list[3];
Student* p = list;

Four EQUIVALENT forms:
  list[i].name
  p[i].name
  (p + i)->name
  (*(p + i)).name

Most obvious: p[i].name' where id='776ac814-4af5-46cd-a1c9-547fe48ec339'::uuid;
update public.flashcard set depan_en='What is unique_ptr?', belakang_en='Smart pointer with SINGLE ownership.

#include <memory>

auto p = make_unique<int>(99);
cout << *p;   // 99

// exit scope -> AUTOMATICALLY freed

Cannot be COPYED (sole ownership),
but it can be MOVED with move().' where id='0437edcb-4078-4225-a1e6-cd1335716ca0'::uuid;
update public.flashcard set depan_en='What is a nested struct?', belakang_en='A struct whose members are of another struct type.

struct Address { string city; };
struct Student {
    name string;
    Address address;   <- struct as member
};' where id='04f7ed8f-8249-48f4-b7a9-80727402e335'::uuid;
update public.flashcard set depan_en='What is the difference between a 2D array in C++ and a 2D list in Python?', belakang_en='C++ int m[2][3]:
- one sequential block of memory
- fixed size
- uniform element type

Python [[1,2],[3,4]]:
- list of references to separate objects
- size can change
- free element type' where id='05209b5a-da28-4520-b70a-0213618cf69f'::uuid;
update public.flashcard set depan_en='What is the formula for calculating the address of m[i][j] elements in a 2D array?', belakang_en='address(i,j) = address(0,0) + (i x numberofColumns + j) x sizeof(Type)

What is multiplied is the number of COLUMNS, not the number of rows.' where id='073871d5-f170-4e23-947d-51f9138eb847'::uuid;
update public.flashcard set depan_en='Why is accessing elements in one row faster than jumping between rows?', belakang_en='Because arrays are stored row by row (row-major).

Sequential access utilizes CPU cache:
adjacent data is loaded at once.

Jumping between lines causes cache misses
so it''s slower.' where id='15197642-96e9-495b-a438-f5699aba49db'::uuid;
update public.flashcard set depan_en='Why are pointers important for large structs?', belakang_en='Because it AVOIDS copying.

struct Large { int data[1000]; };
sizeof(Large) = 4000 bytes

Send as value -> copy 4000 bytes each call
Send as pointer -> copy 8 bytes only

The difference is 500x more economical!' where id='15f9fb00-c89c-4323-a5d3-8682ae3ada42'::uuid;
update public.flashcard set depan_en='How does Python manage memory?', belakang_en='AUTOMATIC, with two mechanisms:

1. REFERENCE COUNTING (main)
   Counts how many names point to an object.
   When it reaches zero -> freed.

2. GARBAGE COLLECTOR (for cycles)
   Detect objects pointing at each other
   so the counter is never zero.

No new, no delete.' where id='16b56ac0-38f9-4bff-9d80-9f1b7c8ce296'::uuid;
update public.flashcard set depan_en='What is padding in a struct?', belakang_en='EMPTY bytes that the compiler inserts between struct members
so that each member starts at the address that matches its alignment.

Padding does NOT contain any data - it contains indeterminate values.' where id='257096a8-2535-4907-a782-1aae4ad6056e'::uuid;
update public.flashcard set depan_en='What''s wrong with int* a, b;?', belakang_en='ONLY a is a pointer. b is a REGULAR int.

Proof:
sizeof(a) = 8 (pointers)
sizeof(b) = 4 (int)

The * sign only applies to the FIRST variable.

True: int* a; int* b;' where id='2f271887-1a7d-4f81-85b9-73cafdefa1d9'::uuid;
update public.flashcard set depan_en='From what index do arrays start in C++ and Python?', belakang_en='From 0. The first element is arr[0], not arr[1].' where id='31557acb-795f-4633-8176-5d37c5e5cf75'::uuid;
update public.flashcard set depan_en='How to initialize a struct with values?', belakang_en='Three ways:

Point a = {3, 7};              // ordered list
Point b = {.x = 3, .y = 7};    // by name (C++20)

Point c;
c.x = 3; c.y = 7;              // one by one' where id='3161ccc4-d0c5-4254-820d-eaab05c80cb2'::uuid;
update public.flashcard set depan_en='What is the equivalent of a struct in Python?', belakang_en='DATACLASS:

from dataclasses import dataclass

@dataclass
class Point:
    x: int
    y: int

t = Point(3, 7)' where id='35d13a68-da72-4f5e-aea8-f9c5f3e11cdf'::uuid;
update public.flashcard set depan_en='What is the difference between array of structs and struct of arrays?', belakang_en='Array of Structs (AoS):
struct Mhs { string name; double GPA; };
Students register[100];
-> one intact object, adjacent data

Struct of Arrays (SoA):
struct List { string name[100]; double ipk[100]; };
-> one field for all objects

AoS is easier to read - recommended.' where id='3d3266da-1069-44f4-88da-4f70a146fa3b'::uuid;
update public.flashcard set depan_en='What happens when the vector needs to grow (push_back when full)?', belakang_en='1. Allocate a NEW larger memory block
2. COPY all old elements to the new block
3. FREE old blocks
4. Add new elements

Important consequence: ADDRESS of element changed!' where id='447732e9-970a-44a8-ba58-4fda12f66ad6'::uuid;
update public.flashcard set depan_en='How to properly compare two structs?', belakang_en='Compare members one by one:

bool equal(const Point& a, const Point& b) {
    return a.x == b.x && a.y == b.y;
}

Or in C++20, use the default operator==:

struct Point {
    int x, y;
    bool operator==(const Point&) const = default;
};' where id='453d788b-0a4e-4e38-8c63-32571af2c328'::uuid;
update public.flashcard set depan_en='What does "row-major order" mean?', belakang_en='Multidimensional array storage order
where elements are stored LINE BY LINE.

Complete row 0 first, then row 1,
and so on.

This is the opposite of column-major (used by Fortran, MATLAB, R).' where id='4c75da68-5f3e-44c4-9798-d87b6de2bd6f'::uuid;
update public.flashcard set depan_en='What happens to sizeof(arr) inside the function?', belakang_en='Returns POINTER size (8 bytes), not array size.

void f(int arr[]) {
    sizeof(arr);   // 8, not 20!
}

Cause: The parameter int arr[] is actually int* arr.
Size information MISSING.' where id='512d1dfd-01f7-4e13-a28c-abcc203d56f2'::uuid;
update public.flashcard set depan_en='What are two ways to access struct members via pointers?', belakang_en='1. (*pt).x - dereference first, then access members
2. pt->x - SHORT way (arrow operator)

Both are EQUIVALENT and produce the same value.' where id='5213fbc9-8e62-441c-b7ed-0ed60bddf37a'::uuid;
update public.flashcard set depan_en='Why always set pointer to nullptr after delete?', belakang_en='Two reasons:

1. Prevent DANGLING POINTERS
   Access via nullptr would be obviously wrong,
   not hidden UB

2. Make SECOND DELETE safe
   delete on nullptr does nothing

delete p;
p = nullptr;' where id='56590f6a-4275-411c-8852-a21634149f3e'::uuid;
update public.flashcard set depan_en='When is it better to use 2D arrays and when are Python nested lists?', belakang_en='C++ 2D Arrays:
- size is known at compile time
- requires one sequential block of memory
- critical access performance

Python nested lists:
- dynamic size
- free element type
- readability is more important than performance' where id='7152e43b-7bb1-47c3-b86d-0c82c7cf1606'::uuid;
update public.flashcard set depan_en='false = [[0] * 3] * 3
false[0][0] = 99
print(false)

What is the output?', belakang_en='[[99, 0, 0], [99, 0, 0], [99, 0, 0]]

ALL rows change, not just the first.

Cause: [x] * 3 doubles the REFERENCE, not the value. All three lines point to the same list object.' where id='74b3d3eb-7f29-4542-8aa0-cbd0a2085b46'::uuid;
update public.flashcard set depan_en='What are the advantages of std::span over int arr[] as a parameter?', belakang_en='std::span stores POINTER and SIZE at once.

void f(std::span<int> arr) {
    cout << arr.size();   // saved size!
    for (int x : arr) cout << x;
}

Decay issue resolved: size not lost,
and remains flexible for arrays of various sizes.' where id='5bfba0d1-adb1-4e97-9773-68863df7dc4c'::uuid;
update public.flashcard set depan_en='What is the difference between structs and classes in C++?', belakang_en='MAIN difference: default access.

struct : default member PUBLIC
class : default member PRIVATE

Convention:
- structs for simple data containers
- classes for objects with behavior' where id='5dd37480-7c77-4eac-95a0-85b0ccd1d05b'::uuid;
update public.flashcard set depan_en='What is the value of arr[0] if declared int arr[5] = {1, 2};?', belakang_en='1

The first element is filled with 1, the second element 2.
The remainder (arr[2], arr[3], arr[4]) are automatically filled with ZERO
in C++.

This differs from ordinary local variables in that they are uninitialized
(contains rubbish value).' where id='5e16dac2-ad6d-4906-ae73-4d81884a8f2b'::uuid;
update public.flashcard set depan_en='Why is i[arr] also valid?', belakang_en='Because arr[i] translates to *(arr + i),
and addition is COMMUTATIVE:

*(arr + i) == *(i + arr)

So 3[arr] is also valid and has the same value as arr[3].

BUT don''t use it - it confuses the reader.' where id='82443216-a64a-4b1e-b416-ebaaeabd0029'::uuid;
update public.flashcard set depan_en='How many bytes does p + 1 add if p is int*?', belakang_en='4 bytes (= sizeof(int)).

Pointer arithmetic follows a TYPE SCALE,
not 1 byte.

char* -> +1 byte
double* -> +8 bytes
int* -> +4 bytes' where id='86ffa71b-d2dd-43de-b86a-baea11353bed'::uuid;
update public.flashcard set depan_en='How to sort an array of structs based on one field?', belakang_en='Use std::sort with the comparison lambda:

sort(class, class + 3, [](const Class& a, const Class& b) {
    return a.ipk > b.ipk;   // decrease
});

Change > to < for ascending.' where id='8b013fd2-bc46-48a0-9316-6f973be1ec54'::uuid;
update public.flashcard set depan_en='Why should struct NOT be compared to memcmp?', belakang_en='Because padding contains INDETERMINATE values.

memcmp compares ALL bytes including padding.
Two structs with identical data can be considered DIFFERENT
if the padding is different.

Compare members one by one, or use
operator== default (C++20).' where id='8ddfa037-7cd4-4f20-9da1-e05ff8920cfe'::uuid;
update public.flashcard set depan_en='What are the risks of using #pragma pack(1)?', belakang_en='1. SLOWER - CPU has to read multiple blocks and combine them
2. NOT PORTABLE - behavior differs between compilers
3. DANGER IN ARM - unaligned access can cause a crash

Use only if absolutely necessary,
for example for a particular network protocol or binary format.' where id='9279be4f-33ef-466c-8e47-2aeddff8157a'::uuid;
update public.flashcard set depan_en='How to send a struct so that it is not copied and cannot be changed?', belakang_en='Use const pointers:

void print(const Student* m) {
    cout << m->name;
    // m->ipk = 4.0;   // ERROR
}

const prevents changes, pointers prevent copying.
This is the MOST COMMON pattern in professional C++ code.' where id='934a5417-96fd-43d3-a9d2-b5f64a4883bc'::uuid;
update public.flashcard set depan_en='When is it best to use structs?', belakang_en='Use a struct if these data ALWAYS appear together:

- 2D Point -> struct Point { int x; int y; }
- Student data -> name, age, GPA
- Items in the store -> name, price
- Date -> day, month, year

Structs are a step from "loose variables" to DATA MODELS.' where id='9599d339-5d60-462d-8584-42bae1ceebe8'::uuid;
update public.flashcard set depan_en='How to sort a list of dataclasses in Python?', belakang_en='Use sorted() with key:

sorted = sorted(class, key=lambda k: k.ipk, reverse=True)

reverse=True for descending order.
No reverse, ascending order (default).' where id='96dd1fec-7e98-43ed-aa8e-d0aceb1f4056'::uuid;
update public.flashcard set depan_en='What is the difference between Python slices and C++ pointers?', belakang_en='Python Slice COPYING:
  s = arr[1:4] -> new copy
  s[0] = 999 -> arr DOES NOT change

C++ pointers DO NOT copy:
  int* p = &arr[1];
  p[0] = 999;    -> arr[1] FOLLOWS the change

It''s a basic difference: value vs reference.' where id='9887ac50-5d9c-494d-a736-54123cd49f27'::uuid;
update public.flashcard set depan_en='How to access nested struct members?', belakang_en='Use TWO POINTS - one for each level:

m.address.city

How to read: m has an address, and address has a city.

IMPORTANT SEQUENCE: from outside to inside.' where id='99d13123-1c74-459d-b2f3-c5543b1c239b'::uuid;
update public.flashcard set depan_en='Why is the -> operator needed?', belakang_en='Because (*pt).x is a pain to write and easy to get wrong.

Brackets are MANDATORY because of the operator . higher
takes priority over *.

Without brackets:
*pt.x WRONG - reads as *(pt.x)

Therefore C++ provides -> as an abbreviation.' where id='9e55f189-ee00-494e-bdc8-3705e2addb5a'::uuid;
update public.flashcard set depan_en='What are pointers?', belakang_en='Variable that stores memory ADDRESS,
not direct value.

int value = 42;
int* p = &value;   // p stores the address of the value' where id='a131afc8-a06f-45b7-b48e-66161ab47a5e'::uuid;
update public.flashcard set depan_en='How to declare a 2D array of 3 rows 4 columns in C++?', belakang_en='int m[3][4];

First number = number of rows.
Second number = number of columns.' where id='a27efb60-108d-4920-b567-21ca013c3789'::uuid;
update public.flashcard set depan_en='What is the difference between stack and heap?', belakang_en='STACKS:
- very fast
- small (1-8 MB)
- automatic lifetime (out of scope)
- compiler managed

HEAP:
- slower
- big
- MANUAL lifetime (until delete)
- managed by programmers' where id='a88f6add-54e6-48a9-bdd0-74d66938a4aa'::uuid;
update public.flashcard set depan_en='What are the alignment rules for struct members?', belakang_en='Each member must start at an address that is
MULTIPLE alignments.

The alignment is usually the same as the type size:
char=1, short=2, int=4, long=8, pointer=8

Additionally, the total struct size is rounded to a multiple
BIGGEST alignment among its members.' where id='a8d12a48-0803-4f06-b8e4-0eb9b5664a68'::uuid;
update public.flashcard set depan_en='How to access struct members?', belakang_en='Use the POINT OPERATOR ( . ):

Point t = {3, 7};
cout << t.x;   // 3
t.x = 10;      // change value

int sum = t.x + t.y;   // 17' where id='a9b4a27e-7915-422f-9744-9392b73ce27f'::uuid;
update public.flashcard set depan_en='int value = 42;
int* p = &value;
*p = 100;
cout << value;', belakang_en='Outputs: 100

*p = 100 changes the value at the designated address p.
Because p points to a value, the value changes accordingly.

This is the power of pointers: changing other variables
without touching his name.' where id='aa36f048-908b-495b-af43-2c3fe05ef024'::uuid;
update public.flashcard set depan_en='int arr[5] = {10,20,30,40,50};\ncout << arr[2];\n\nWhat is the output?', belakang_en='30\n\narr[2] is the third element because the indices start at 0:\narr[0]=10, arr[1]=20, arr[2]=30' where id='af544cf1-bfa5-449c-981e-2841181b6f2d'::uuid;
update public.flashcard set depan_en='How is the behavior of b = a different on C++ structs and Python objects?', belakang_en='C++ : b = a copies VALUE. Change b NO
      influence a.

Python: b = a copy REFERENCE. Change b FOLLOW
        influence a.

Here are the BASIC differences:
- C++ struct = value type
- Python object = reference type' where id='b339b9e5-7903-4899-ae10-d5f8fbadc495'::uuid;
update public.flashcard set depan_en='How to check struct member offset?', belakang_en='Use offsetof from <cstddef>:

#include <cstddef>

struct Mix { char a; int b; };

cout << offsetof(Mix, a);   // 0
cout << offsetof(Mix, b);   // 4' where id='b4054dc2-9d09-4f0c-b413-36ba35be3869'::uuid;
update public.flashcard set depan_en='What is wrong with this initialization?\nStudent m = {"Rani", "Bandung"};', belakang_en='NESTED curly braces are not used for addresses.

WRONG: {"Rani", "Bandung"}
CORRECT: {"Rani", {"Bandung"}}

Since addresses are structs, their values must be wrapped in their own curly braces.' where id='b503acfd-dfef-4bd9-8987-a586e543e8be'::uuid;
update public.flashcard set depan_en='struct Point { int x; int y; };
void shear(Point t) { t.x = t.x + 10; }

int main() {
    Point a = {3, 7};
    shift(a);
    cout << a.x;
}

What is the output?', belakang_en='Outputs: 3

The struct is sent as a COPY.
Changing t in the function does NOT affect a.

In order to change the original, the parameter must be a reference:
shear void(Point&t)' where id='bb484054-57bc-4274-be19-5fe887b03538'::uuid;
update public.flashcard set depan_en='How does the syntax define a struct in C++?', belakang_en='struct StructureName {
    member type1;
    member type2;
};   <- DON''T forget the semicolon!

The semicolon after } is the most common mistake.' where id='bbdf3270-ca90-4cfc-bd51-3d7cb65793f0'::uuid;
update public.flashcard set depan_en='What is a struct?', belakang_en='How to group several related data
become ONE unit, even though the types are different.

struct Student {
    name string;
    int age;
};' where id='c0f68c05-b43e-4fd4-9926-27a5fd7e152b'::uuid;
update public.flashcard set depan_en='How to allocate an array in the heap?', belakang_en='int* arr = new int[5];   // 5 elements

for (int i = 0; i < 5; i++) arr[i] = i * 10;

delete[] arr;             // NOTE: delete[]' where id='c274fe22-b77b-468c-ae03-9af4689bbf56'::uuid;
update public.flashcard set depan_en='What is std::vector?', belakang_en='Dynamic arrays from the C++ standard library.

The size can increase as the program runs,
different from regular arrays which are fixed in size.' where id='c287ce98-a14c-4654-8637-3be7e2770c95'::uuid;
update public.flashcard set depan_en='Why is lst.insert(0, x) expensive?', belakang_en='Because it has to shift all elements one position to the right.
The complexity is O(n), not O(1).

Real measurements (5,000 iterations):
backward append: 0.8 ms
forward insert: 155.1 ms

198x slower!

Alternative: use collections.deque with appendleft().' where id='c45228d4-df99-4bd0-bae3-9332b71d6583'::uuid;
update public.flashcard set depan_en='What is array-to-pointer decay?', belakang_en='Automatic change of array names to pointers to elements
first in a particular expression.

int arr[5];
int* p = arr;   // arr decays to &arr[0]

As a result, size information can be lost.' where id='c4750c08-fde9-49b1-9908-20508dd4f2a9'::uuid;
update public.flashcard set depan_en='What is dangling pointer?', belakang_en='A pointer that points to memory that has ALREADY been freed.

int* p = new int(42);
delete p;
cout << *p;   // UB! p is a dangling pointer

THE DANGER: It may appear to be running normally because
the old values are still there. But that''s undefined behavior.

Fix: p = nullptr; after deleting.' where id='c8014e82-cf1f-41f7-9111-da4d383ac007'::uuid;
update public.flashcard set depan_en='What is an array?', belakang_en='A collection of elements of the same type that are stored sequentially in memory and accessed via an index.' where id='ce0eb92e-6591-40d6-98fd-a49b079e9027'::uuid;
update public.flashcard set depan_en='Is struct alignment the same on all platforms?', belakang_en='NO - alignment is IMPLEMENTATION-DEFINED.

Numbers like sizeof(int)=4, sizeof(long)=8 apply to
x86-64. On other platforms (ARM, embedded) it can be DIFFERENT.

Always verify with sizeof and offsetof
on the platform you use.' where id='d51ebfdd-9055-4f05-a0e7-31a261ff4ace'::uuid;
update public.flashcard set depan_en='What is sizeof(struct { char a; long b; char c; })?', belakang_en='24 bytes.

Offset: a=0, b=8 (requires multiple of 8), c=16
Total before rounding: 17
Biggest alignment: 8
Rounded to a multiple of 8 -> 24

Details: 1 + 7 pad + 8 + 1 + 7 pad end = 24' where id='d8ba2f3a-f22d-4a1d-88a6-0e1cdaf99d44'::uuid;
update public.flashcard set depan_en='How to declare a pointer to int?', belakang_en='int* p;

How to read: "p is a pointer to int".
Read from RIGHT to LEFT.' where id='dabdb783-c656-4395-b84c-f938daf61d46'::uuid;
update public.flashcard set depan_en='When is it best to use nested structs?', belakang_en='If there is data that ALWAYS appears together as one unit.

Example:
- Students have an address
- Items have dimensions
- Orders have Delivery

If the data can stand alone, make it a separate struct
and save them as two fields, not nested.' where id='f2225d48-0231-4d8a-9a0f-615524fd3d68'::uuid;
update public.flashcard set depan_en='How to declare an array of structs?', belakang_en='Listitem[3] = {
    {"Book", 25000},
    {"Pen", 3000},
    {"Bag", 150000}
};

Each element is a complete struct.' where id='f5e94166-8c45-47cf-aaa1-73bf613450dc'::uuid;
update public.flashcard set depan_en='How to CORRECTLY create a 2D list in Python?', belakang_en='true = [[0] * 3 for _ in range(3)]

Use a list comprehension for each row
is a separate NEW object.

DO NOT use [[0] * 3] * 3.' where id='fa983b61-bd7b-4238-8e1f-973508cb80cc'::uuid;
update public.soal set pertanyaan_en='struct A { char a; long b; char c; };
struct B { long b; char a; char c; };

cout << sizeof(A) << " " << sizeof(B);

What is the output?', penjelasan_en='Output: 24 16

A: a=0, b=8, c=16 -> total 17 rounded to 24
B: b=0, a=8, c=9 -> total 10 rounded to 16

B saves 8 bytes because the small members (a and c) are grouped side by side.

Here''s an example of sorting that SUCCESSFULLY saves.' where id='000dec22-1cca-48e2-bde9-5ef41d65de80'::uuid;
update public.soal set pertanyaan_en='The following code is slow for large data.
Why?', penjelasan_en='Cause: Access m[j][i] jumps between rows, not sequentially.

Because nested lists store references to separate objects, accessing m[0][0], m[1][0], m[2][0] means moving between list objects that are located far apart.

Fix: swap loop order to access m[i][j] - sequentially in one line.' where id='0c086090-a7af-4f42-94be-307e5528015d'::uuid;
update public.soal set pertanyaan_en='Is arr[i] the same as *(arr + i)?', penjelasan_en='Answer: Yes, both are identical.

arr[i] is DEFINED as *(arr + i). This isn''t a coincidence or a compiler optimization - it''s the language definition.

The consequence: arrays do not store boundary information, so C++ cannot detect out-of-bounds accesses.' where id='1e87cbee-8bdf-464e-85bc-678967aca884'::uuid;
update public.soal set pertanyaan_en='What is a more accurate rule about reducing padding?', penjelasan_en='Answer: Padding is reduced when small members are grouped side by side so they fit in one alignment block.

This is USUALLY achieved by ordering from largest to smallest, but is NOT a GUARANTEE.

On structs with only 2 members, sorting often doesn''t change anything because there are no small members to pack together.' where id='203b096e-aad6-4501-bc1f-b759b2bf3da3'::uuid;
update public.soal set pertanyaan_en='struct Item { string name; double price; };
Item list[3] = {{"Books",25000},{"Pens",3000},{"Bags",150000}};

int n = sizeof(list) / sizeof(list[0]);
cout << n;', penjelasan_en='Outputs: 3

sizeof(list) is the size of the ENTIRE array.
sizeof(list[0]) is the size of ONE element.
The division results in the number of elements = 3.

IMPORTANT: this only works if the array is still in the same scope. If sent to a function, the array decays into a pointer and size information is lost.' where id='20904f13-c442-452a-beb4-ba9bd2613f53'::uuid;
update public.soal set pertanyaan_en='What is the formula for calculating the address of the ith element in an array?', penjelasan_en='Answer: address(0) + i x sizeof(Type)

Because the array elements are stored sequentially with a fixed distance (the size of the type), the address of the ith element can be calculated directly.

This is the reason array accessing is O(1) - constant time.' where id='11128467-2cea-4970-8b13-56b33fd6b208'::uuid;
update public.soal set pertanyaan_en='Why is accessing array elements O(1) complexity?', penjelasan_en='Answer: Because element addresses can be calculated directly without searching.

The formula address(i) = address(0) + i x sizeof(Type) allows the computer to jump directly to any element.

Unlike a linked list which has to search one by one (O(n)).' where id='206e3d4e-9ccf-49e9-8197-12dc0d586bec'::uuid;
update public.soal set pertanyaan_en='What is wrong with Student m = {"Rani", "Bandung"};?', penjelasan_en='Answer: The value for the address must be wrapped in its own curly braces.

WRONG: {"Rani", "Bandung"}
CORRECT: {"Rani", {"Bandung"}}

Since addresses are structs, their values must be a separate list.

The compiler will give an error because it cannot convert "Bandung" into an Address struct.' where id='34046ea6-17ad-444d-bf5d-22c5a4526919'::uuid;
update public.soal set pertanyaan_en='How to declare an array of 3 items with initial value?', penjelasan_en='Answer: Item list[3] = {{"Books",25000},{"Pens",3000},{"Bags",150000}};

Each element is wrapped in its own curly braces.

Listitems[3] = {"Books", 25000, "Pens", 3000} false - the compiler doesn''t know where the boundaries of each element are.' where id='3478c4a9-6158-49fc-b55f-652a5d4acc18'::uuid;
update public.soal set pertanyaan_en='What is the difference between array of structs and struct of arrays?', penjelasan_en='Answer: An array of structs stores one complete object per element; The struct of array stores one field for all objects.

AoS: struct Mhs { string name; double GPA; }; Students register[100];
-> list[0] contains the name AND GPA of the first student

SoA: struct List { string name[100]; double ipk[100]; };
-> all names in one array, all ipk in another array

AoS is easier to read and is recommended for most cases.' where id='3cde2f41-6294-4c12-97e6-253ca0252482'::uuid;
update public.soal set pertanyaan_en='Which is the CORRECT way to create a 2D 3x3 list containing zeros in Python?', penjelasan_en='Answer: [[0] * 3 for _ in range(3)]

List comprehension creates a NEW list object for each row.

[[0]*3]*3 false: doubles references, all rows become the same object.
[0]*9 is wrong: it''s a 1D list containing 9 zeros, not 2D.
[[0]*3]*range(3) is wrong: not valid Python syntax.' where id='5adc9e5f-191f-4e67-acc0-c20c4967d261'::uuid;
update public.soal set pertanyaan_en='What is the use of v.reserve(n)?', penjelasan_en='Answer: Allocate space for n elements so that there is no need to re-allocate until the n+1st element.

After reserve(10), size remains 0 but capacity becomes 10.

The "fill vector with n elements" trick is wrong - that''s what vector<int> v(n) does.' where id='5ea0ccd7-d991-40c6-9bed-6324815fd01c'::uuid;
update public.soal set pertanyaan_en='int arr[5] = {1, 2};
cout << arr[4];

What is the output?', penjelasan_en='Output: 0

When an array is initialized with a value less than its size, the remainder is automatically filled to ZERO.

arr[0]=1, arr[1]=2, arr[2]=0, arr[3]=0, arr[4]=0.

This is DIFFERENT from uninitialized local variables containing garbage values.' where id='61ab709c-b0c1-4c86-ae3b-16c06baa4da4'::uuid;
update public.soal set pertanyaan_en='struct Address { string city; };
struct Student { string name; Address address; };

Student m = {"Rani", {"Bandung"}};
cout << m.address.city;', penjelasan_en='Output: Bandung

m.address.city accesses the city string inside the Address struct, which is a member of Student.

"Rani" is the name, "Bandung" is the city.' where id='5b82b9b8-1418-4898-9ee7-7181aed28d55'::uuid;
update public.soal set pertanyaan_en='What happens when the vector needs to grow?', penjelasan_en='Answer: Allocate new block, copy old element, free old block, add new element.

This process causes the ADDRESS of the element to change - that''s why the pointer to the element can become dangling after push_back.

The "old memory automatically expands" bug is wrong - memory that has already been allocated cannot be expanded in place.' where id='6261ad9b-3941-4661-8cba-a969e99003cf'::uuid;
update public.soal set pertanyaan_en='What are the two meanings of the asterisk on a pointer?', penjelasan_en='Answer: In the declaration it is part of TYPE; in the expression it is the DEREFERENCE operator.

int* p = &value;   // * part of the type
*p = 100;          // * dereference operator

This is what often confuses beginners because the symbols are the same but the meanings are different.' where id='e51cc450-02be-427a-83b3-59c3ace7d1ee'::uuid;
update public.soal set pertanyaan_en='vector<int> v = {1,2,3,4};
v. push_back(5);
cout << v. size();

What is the output?', penjelasan_en='Outputs: 5

Vector initially contains 4 elements.
After push_back(5), the number of elements becomes 5.

Distractor 4 = size before push_back.' where id='0e906cb5-51e4-4a00-809a-e90ebf81e00b'::uuid;
update public.soal set pertanyaan_en='Why are uninitialized pointers dangerous?', penjelasan_en='Answer: Because it contains a random address (wild pointer), and dereferencing it is undefined behavior.

int* p;        // contains random addresses
cout << *p;    // UB!

Always initialize: int* p = nullptr;' where id='129f5d23-564f-425c-aecc-be0d2c6b32cc'::uuid;
update public.soal set pertanyaan_en='What are the risks of using #pragma pack(1)?', penjelasan_en='Answer: Slower, not portable, and can crash on ARM.

1. SLOWER - CPU has to read multiple blocks and combine them
2. NOT PORTABLE - behavior differs between compilers
3. DANGER IN ARM - unaligned access can cause a crash

Use only when absolutely necessary (network protocols, certain binary formats).' where id='1dfa2948-66eb-4248-9064-e30a73d57c59'::uuid;
update public.soal set pertanyaan_en='What happens if you dereference nullptr?', penjelasan_en='Answer: Undefined behavior - usually crashes, but the standard doesn''t guarantee that.

int* p = nullptr;
cout << *p;   // UB!

The "always crashes" trick isn''t quite right - the standard just says UB, so it may appear to be running.
The "return 0" distractor is false - no value is returned.' where id='6dc72f08-9db1-4a76-8cbf-b7207be92c65'::uuid;
update public.soal set pertanyaan_en='Why is accessing members via nullptr dangerous?', penjelasan_en='Answer: Because it is undefined behavior.

Student* p = nullptr;
p->name;   // UB!

Always check: if (p) { cout << p->name; }

It''s especially important that the pointer comes from a function parameter, because the caller might send nullptr.' where id='e99ee03d-3101-4023-832b-f373d03c10ca'::uuid;
update public.soal set pertanyaan_en='What are the rules for using operators? and ->?', penjelasan_en='Answer: . for value/reference; -> for pointers.

Point t = {3,7};
t.x // TRUE (t is value)
t->x // FALSE

Point* pt = &t;
pt->x // TRUE (pt is a pointer)
pt.x // WRONG' where id='e13a3c55-363e-492d-8eb5-cc7383b09f05'::uuid;
update public.soal set pertanyaan_en='What is the main advantage of std::span over int arr[] as a parameter?', penjelasan_en='Answer: std::span stores both pointer AND size.

void f(std::span<int> arr) {
    cout << arr.size();   // saved size
}

Decay issue resolved: size doesn''t vanish, and remains flexible for arrays of any size.

int (&arr)[5] also stores size, but the size must be known at compile time.' where id='5475b10a-0a85-42ad-aa84-93d6e2166584'::uuid;
update public.soal set pertanyaan_en='How does Python manage memory?', penjelasan_en='Answer: Automatic with reference counting, plus garbage collector for reference cycles.

1. REFERENCE COUNTING: counts how many names refer to objects. When it reaches zero, it is released.
2. GARBAGE COLLECTOR: detects objects pointing to each other so the counter is never zero.

No new, no delete.' where id='6c6e8f7a-195a-43db-85ec-a4c17b6cbf0a'::uuid;
update public.soal set pertanyaan_en='What''s the difference between copying C++ nested structs and Python objects?', penjelasan_en='Answer: C++ copies the entire value; Python only copies references.

C++: Student b = a; -> complete copy, including the structs inside. Changing b does not affect a.

Python: b = a; -> only references to the same object. Changing b FOLLOWING changing a. For the actual copy need copy.deepcopy(a).

This is the basic difference between language by value and language by reference.' where id='eaf2c826-d676-44b8-8d19-41d11ca1f984'::uuid;
update public.soal set pertanyaan_en='What happens if you use delete (instead of delete[]) for the memory of new[]?', penjelasan_en='Answer: Undefined behavior.

int* arr = new int[5];
delete arr;      // UB! should be delete[]

new[] MUST be paired with delete[], and new must be paired with delete. Mixing them can cause crashes or heap corruption.

This rule must not be violated.' where id='5d22632d-e2ce-4c0a-bf96-006f4b12d400'::uuid;
update public.soal set pertanyaan_en='Student list[3] = {{"Rani"},{"Budi"},{"Citra"}};
Student* p = list;
cout << (p + 1)->name;', penjelasan_en='Output: Budi

p points to list[0]. p + 1 points to list[1]. (p + 1)->name = list[1].name = "Budi"

Equivalent to p[1].name.

Rani distractor = list[0]. Image = list[2].' where id='fb48ccd3-c0fc-4309-b9c8-394bf4ee6b32'::uuid;
update public.soal set pertanyaan_en='What is the difference between arr and &arr?', penjelasan_en='Answer: The types are different, so the arithmetic is different.

arr : int* -> +1 jumps 4 bytes (one element)
&arr : int(*)[5] -> +1 jumps 20 bytes (ENTIRE array)

Both produce the same ADDRESS, but the +1 type and behavior are different.

This is a detail that is often asked in job interviews.' where id='94411807-4f84-4d4e-8ad1-73f9d25c12a4'::uuid;
update public.soal set pertanyaan_en='How is the behavior of b = a different on C++ structs and Python objects?', penjelasan_en='Answer: C++ copies VALUES; Python copies REFERENCES.

C++: Point b = a; -> copy. Changing b does not affect a.

Python: b = a -> same reference. Changing b FOLLOWS affects a.

This is the basic difference between value types (C++ structs) and reference types (Python objects).' where id='25b363a6-4b0e-4380-a8b6-3eae53d8f793'::uuid;
update public.soal set pertanyaan_en='What is the main difference between structs and classes in C++?', penjelasan_en='Answer: The default struct is public, the default class is private.

Apart from that they are almost identical - they can have methods, constructors, and inheritance.

General conventions: structs for simple data containers, classes for objects with behavior and encapsulation.' where id='4d5a9f89-927b-44d4-87e4-dce480e99381'::uuid;
update public.soal set pertanyaan_en='How to allocate an array in the heap?', penjelasan_en='Answer: int* arr = new int[5];

Note the square brackets [5] for the array.

int* arr = new int; wrong - that''s allocation of ONE int, not an array.
int arr[5] = new int[5]; wrong - it''s a stack array, not a heap.
int* arr = new int(5); wrong - that''s one int worth 5.' where id='536b4732-f834-4bdf-8b89-1edffdf6b531'::uuid;
update public.soal set pertanyaan_en='What is unique_ptr?', penjelasan_en='Answer: Smart pointer with single ownership.

auto p = make_unique<int>(99);
// exit scope -> automatically freed

Cannot be COPYED because ownership is single, but can be MOVED with move().

The "shared ownership" distractor is wrong - it''s shared_ptr.' where id='35ed542c-4b7f-48f4-9ee7-71b5f37cf3ce'::uuid;
update public.soal set pertanyaan_en='What is double free?', penjelasan_en='Answer: Call delete twice on the same pointer.

delete p;
delete p;      // UB!

The fix:
delete p;
p = nullptr;
delete p;      // SAFE - delete on nullptr does nothing

This is one reason to always set nullptr after delete.' where id='371781d4-fbf9-4898-90e3-b99e1fe89497'::uuid;
update public.soal set pertanyaan_en='int arr[5] = {10, 20, 30, 40, 50};
cout << (&arr[4] - &arr[0]);', penjelasan_en='Outputs: 4

The difference between two pointers results in the NUMBER OF ELEMENTS, not bytes.

(&arr[4] - &arr[0]) = 4 elements, not 16 bytes.

Distractor 16 = counting bytes (4 elements x 4 bytes).' where id='39149ef8-b437-4ee7-b2f8-230311bbf972'::uuid;
update public.soal set pertanyaan_en='Why are pointers important for large structs?', penjelasan_en='Answer: Because it avoids copying the entire struct.

struct Large { int data[1000]; };
sizeof(Large) = 4000 bytes

Send as value -> copy 4000 bytes each call
Send as pointer -> copy 8 bytes only

The difference is 500x more economical. For functions that are called frequently, this is very significant.' where id='3ca84bbc-0e22-4ac1-96b3-d5ff711a3d2e'::uuid;
update public.soal set pertanyaan_en='What is the difference between size and capacity in vector?', penjelasan_en='Answer: size = number of elements present; capacity = the amount that can be accommodated before re-allocation.

The analogy is with a wardrobe: size is the number of clothes hanging, capacity is how many clothes will fit.

The "size is greater than capacity" distractor is wrong - capacity always >= size.' where id='4063907b-847d-4b40-b52e-e525125a07a3'::uuid;
update public.soal set pertanyaan_en='What happens if you write arr[3] = 100 to an array of size 3 in C++?', penjelasan_en='Undefined behavior.

An array of size 3 has valid indices 0, 1, 2.
arr[3] is OUT OF LIMITS.

C++ DOES NOT check index bounds - programs can appear to run normally, print garbage values, crash, or corrupt other data without being seen.

This is not a catchable error, but rather behavior that is not standardly defined.' where id='40b7ce57-63ef-402b-94f1-06f744f7d51b'::uuid;
update public.soal set pertanyaan_en='How to sort a list of dataclasses based on the descending GPA field?', penjelasan_en='Answer: sorted(class, key=lambda k: k.ipk, reverse=True)

key determines the field used for sorting.
reverse=True creates descending order.

class.sort(key=...) is also possible but changes the original list (in-place).

C++ uses std::sort with a comparison lambda - the concept is similar.' where id='463c1d04-d13a-4bf1-a7f8-7e4baf89bb6b'::uuid;
update public.soal set pertanyaan_en='How to calculate the address of the element m[i][j]?', penjelasan_en='Answer: address(0,0) + (i x numberofColumns + j) x sizeof(Type)

Multiplied by i is the number of COLUMNS, because we have to go through i full rows first.

The distractor using the number of rows is the most common mistake here.' where id='4e1b2030-d6d8-45e9-92cf-539f26ee9c6a'::uuid;
update public.soal set pertanyaan_en='What is array-to-pointer decay?', penjelasan_en='Answer: Automatic change of array name to a pointer to its first element.

int arr[5];
int* p = arr;   // arr decays to &arr[0]

Occurs when passed to a function, assigned to a pointer, or in arithmetic.
NOT happening with sizeof(arr) and &arr.' where id='4f32fe9e-fa05-465d-94a9-b9d38fe18258'::uuid;
update public.soal set pertanyaan_en='Why always set pointer to nullptr after delete?', penjelasan_en='Answer: To prevent dangling pointers and make the second delete safe.

1. Access via nullptr will be obviously wrong (not hidden UB)
2. delete on nullptr does nothing, so double free is avoided

delete p;
p = nullptr;   // always do' where id='51a56984-fc34-4fd5-965c-a33fa5ea7aa9'::uuid;
update public.soal set pertanyaan_en='What is sizeof(struct { char a; int b; }) if sizeof(int) = 4?', penjelasan_en='Answer: 8 bytes

1 (char) + 3 (padding) + 4 (int) = 8.

Distractor 5 = adding without considering padding.
Distractor 4 = int size only. Distractor 12 = miscalculated alignment.' where id='70a2677f-155e-4977-a14b-388064c07212'::uuid;
update public.soal set pertanyaan_en='int m[3][4] = {0};
cout << sizeof(m);

What is the output if sizeof(int) = 4?', penjelasan_en='Outputs: 48

sizeof(m) = number of elements x sizeof(int) = 12 x 4 = 48 bytes.

Distractor 12 = number of elements, not byte size.
Distractor 16 = size of one line (4 x 4).' where id='7191dfdf-d768-490a-aa38-1d7a9ed3e829'::uuid;
update public.soal set pertanyaan_en='How to declare a 2D array with 3 rows and 4 columns?', penjelasan_en='Answer: int m[3][4];

The FIRST number is the number of rows (3), the SECOND number is the number of columns (4).

int m[4][3] will result in 4 rows and 3 columns - swapped.
int m[3,4] is not valid C++ syntax.
int m[12] is just a 1D array with 12 elements.' where id='75666aff-fbe7-4424-a681-edce2a1dd7cc'::uuid;
update public.soal set pertanyaan_en='How to iterate over an array of structs and add up their price fields?', penjelasan_en='Answer: double total = 0; for (int i = 0; i < 3; i++) { total += list[i].price; }

Each element is accessed by index, then its fields by dot.

list.price is wrong because list is an array, not a single struct.

Result for example data: 25000 + 3000 + 150000 = 178000.' where id='782dc8de-7136-43ef-81c3-9c593600a155'::uuid;
update public.soal set pertanyaan_en='What happens if a default field is placed before a non-default field in the dataclass?', penjelasan_en='Answer: Python throws TypeError: non-default argument follows default argument

WRONG:
@dataclass
class M:
    age: int = 18
    name: str # ERROR

TRUE: fields without default must come first.

This is a Python rule for all functions, not just dataclasses.' where id='896878f4-d085-4766-8e6d-f26688d99e57'::uuid;
update public.soal set pertanyaan_en='What is the main difference between C++ pointers and Python references?', penjelasan_en='Answer: C++ can do pointer arithmetic and manual memory management; Python cannot have arithmetic and memory managed automatically.

C++: p + 1 (arithmetic), delete (manual), address visible
Python: can''t do arithmetic, automatic garbage collector, id() for identity

Both point to objects, but the level of control is very different.' where id='89a88523-14f4-43cf-bf60-decd3e654fe7'::uuid;
update public.soal set pertanyaan_en='Why is lst.insert(0, x) so much slower than lst.append(x)?', penjelasan_en='Answer: insert(0, x) should shift ALL elements one position, complexity is O(n). append just adds at the end, O(1).

Real measurements 5,000 iterations: append 0.8 ms, insert 155.1 ms - 198x slower.

Alternative: collections.deque with appendleft() which is O(1).' where id='8afabacc-c8eb-45ab-b1a2-198d985016e9'::uuid;
update public.soal set pertanyaan_en='What is the difference between const int* p and int* const p?', penjelasan_en='Answer: const int* p locks VALUE; int* const p locks ADDRESS.

const int* p : value cannot be changed, address is allowed
int* const p : address cannot be changed, value can

How to remember: read from right to left. The const closest to p locks p.' where id='a82a2d75-f634-4534-95df-5dabaf774b92'::uuid;
update public.soal set pertanyaan_en='What''s wrong with declaring int* a, b;?', penjelasan_en='Answer: Only a is a pointer; b is a regular int.

Proof: sizeof(a) = 8 (pointer), sizeof(b) = 4 (int).

The * only applies to the FIRST variable in the declaration.

Correct way: int* a; int* b; or int *a, *b;' where id='a84f225b-4e51-4e15-bcfc-cc6911e40868'::uuid;
update public.soal set pertanyaan_en='struct Point { int x; int y; };
Point t = {5};
cout << t.x << " " << t.y;

What is the output?', penjelasan_en='Output: 5 0

Partial initialization: only x is filled with 5.
Members that are not initialized are AUTOMATICALLY filled with ZERO.

Same as array: int arr[5] = {1} -> remainder 0.

The distractor "5 5" is false - the value is not repeated.' where id='ad032b05-3e47-4260-85bf-0a3cfe2a9097'::uuid;
update public.soal set pertanyaan_en='What does #pragma pack(1) do?', penjelasan_en='Answer: Forces the compiler to reduce or eliminate padding.

#pragma pack(push, 1)
struct Solid { char a; int b; };
#pragma pack(pop)

With pack(1), sizeof(Dense) becomes 5 bytes (instead of 8).

But there are serious consequences: it''s slower, not portable, and can crash on ARM.' where id='b494d048-fa52-4cb5-8562-b693b1599e18'::uuid;
update public.soal set pertanyaan_en='What happens if accessing an index is out of bounds in Python?', penjelasan_en='Answer: Python throws IndexError and the program stops with a clear message.

This is an important difference from C++ which produces undefined behavior (which can appear successful).

The "return 0" distractor is wrong - Python does not fill in the default value.' where id='b5ca9d61-5290-4ea9-a6d0-1bb55fbf8dad'::uuid;
update public.soal set pertanyaan_en='Why is returning a pointer to a local variable dangerous?', penjelasan_en='Answer: Because the local variable no longer exists after the function completes, so the pointer becomes dangling and using it is UB.

int* f() {
    local int = 42;
    return &local;   // DANGER!
}

Once f() completes, local memory is freed.' where id='bbb1dd8c-250d-4f5c-a4c5-92325ae1420b'::uuid;
update public.soal set pertanyaan_en='struct Point { int x; int y; };
Point a = {3, 7};
Point b = a;
b.x = 99;
cout << a.x;

What is the output?', penjelasan_en='Outputs: 3

b = a creates a COPY, not a reference.
Changing b.x does not affect a.x.

This is different from Python lists: b = a in Python lists creates a REFERENCE, so changing b also changes a.

C++ structs copy values; Python list copies references.' where id='cc655b20-c893-4260-9877-651b76ab9d6a'::uuid;
update public.soal set pertanyaan_en='false = [[0] * 3] * 3
false[0][0] = 99
print(false[1][0])

What is the output?', penjelasan_en='Output: 99

Because [[0]*3]*3 doubles REFERENCES, all three rows point to the SAME list object.
Changing false[0][0] also changes false[1][0] and false[2][0].

If you use a list comprehension, the result is 0.' where id='cdf9d1ff-a20e-49f0-a967-fc30330cb6c7'::uuid;
update public.soal set pertanyaan_en='What is the value of sizeof(arr) in the void function f(int arr[])?', penjelasan_en='Answer: 8 bytes - pointer size, not array size.

The int arr[] parameter is actually int* arr. The compiler decodes it, so the array size information is LOST.

The "20 bytes" distractor is wrong - that''s the size of the array in main, not in the function.' where id='d19e3b80-f3b8-4c2e-a088-8e5dedb184d0'::uuid;
update public.soal set pertanyaan_en='Why is the -> operator needed?', penjelasan_en='Answer: Because (*pt).x is a pain to write and is easy to get wrong.

The parentheses are mandatory because of the . higher priority than *. Without the brackets, *pt.x is read as *(pt.x) which is an error.

Therefore C++ provides -> as a clearer abbreviation.' where id='db1a85fc-1786-4a66-b2dd-d5b57deabd08'::uuid;
update public.soal set pertanyaan_en='What is the difference between v[i] and v.at(i)?', penjelasan_en='Answer: v[i] does not check bounds (undefined behavior); v.at(i) checks and throws std::out_of_range.

Both access the same element if the index is valid. The only difference is in the bounds checking.

v.at() is a bit slower because of the checks, but safer.' where id='f3e7dd4a-d169-47b6-ab9d-30486aaea1ff'::uuid;
update public.soal set pertanyaan_en='What is the value of sizeof(arr) if it is declared as int arr[5] with an int of 4 bytes?', penjelasan_en='5 elements x 4 bytes = 20 bytes.

Option 4 is wrong because it''s a size of one int. Option 5 is wrong because it is the number of elements. Option 40 is incorrect because it mistakenly assumes that int is 8 bytes in size.' where id='f8890c32-dc74-4da5-bf03-09dba3b6f4fe'::uuid;
update public.soal set pertanyaan_en='vector<int> v;
v.reserve(10);
cout << v.size() << " " << v.capacity();

What is the output?', penjelasan_en='Output: 0 10

reserve() prepares SPACE, not fills elements.
size remains 0 because there are no elements yet.
capacity becomes 10 because space has been allocated.

This differentiates reserve() from vector<int> v(10) which immediately fills 10 elements.' where id='db23a306-9741-4ed9-9bcb-54f71dfb07cd'::uuid;
update public.soal set pertanyaan_en='int m[2][3] = {{1,2,3},{4,5,6}};
int* flat = &m[0][0];
cout << flat[4];

What is the output?', penjelasan_en='Outputs: 5

flat[4] is the 5th element from the start (index 4).
Stored elements in order: m[0][0]=1, m[0][1]=2, m[0][2]=3, m[1][0]=4, m[1][1]=5.
So element index 4 = 5.

Distractor 4 = m[1][0] (index 3). Distractor 6 = m[1][2] (index 5).' where id='fd5ac703-49fc-4291-a162-60b358e76adc'::uuid;
update public.soal set pertanyaan_en='int arr[5] = {10, 20, 30, 40, 50};
cout << arr[4];

What is the output?', penjelasan_en='Outputs: 50

arr[4] is the FIFTH element (last index) because the index starts from 0.

Distractor 40 = arr[3]. Distractor 10 = arr[0].' where id='feb80d99-3364-4dda-9cac-2c89a3b35b8e'::uuid;
update public.soal set pertanyaan_en='int value = 42;
int* p = &value;
*p = 100;
cout << value;', penjelasan_en='Outputs: 100

*p = 100 changes the value at the designated ADDRESS p.
Because p points to a value, the value changes accordingly.

This is the power of pointers: changing another variable without touching its name.

Distractor 42 = value before change.' where id='1e55ae80-78e2-4438-b465-8b8036a851c1'::uuid;
update public.soal set pertanyaan_en='int m[2][3] = {{1,2,3},{4,5,6}};
cout << *(*(m+1)+1);

What is the output?', penjelasan_en='Outputs: 5

*(*(m+1)+1) is the same as m[1][1].

m+1 -> row 1
*(m+1) -> row 1 (array contains 4,5,6)
+1 -> second element of that row
* -> value = 5' where id='20afa50a-9375-4f49-ba6b-593d52c23b6a'::uuid;
update public.soal set pertanyaan_en='What is the main difference between stack and heap?', penjelasan_en='Answer: Stacks are managed automatically and quickly; the heap is managed manually and is slower.

STACK: very fast, small (1-8 MB), auto-lifetime when exiting scope.
HEAP: slower, larger, manual lifetime until delete.

The "bigger stack" distractor is wrong - it''s a big heap instead.' where id='2dd08efb-923c-4ae1-bc52-60e303a85f26'::uuid;
update public.soal set pertanyaan_en='arr = [10, 20, 30, 40, 50]
s = arr[1:4]
s[0] = 999
print(arr[1])', penjelasan_en='Outputs: 20

Slicing Python COPIES elements. Changing s[0] does not change arr[1].

Compare C++:
int* p = &arr[1];
p[0] = 999;   // arr[1] FOLLOW changes

The distractor 999 is wrong - it thinks slice points to a real element.' where id='3d2c17bd-3f12-4674-9e28-5b55b5850562'::uuid;
update public.soal set pertanyaan_en='How to create a dataclass that cannot be changed once created?', penjelasan_en='Answer: @dataclass(frozen=True)

@dataclass(frozen=True)
class Point:
    x: int
    y: int

t = Point(3, 7)
t.x = 10 # ERROR: cannot assign to field

Without frozen, the dataclass is mutable by default - fields can be changed at any time.' where id='3d3ebe7e-cd46-4289-93ee-30ed5b34b968'::uuid;
update public.soal set pertanyaan_en='What is the equivalent of a struct in Python?', penjelasan_en='Answer: dataclass with @dataclass decorator

from dataclasses import dataclass

@dataclass
class Point:
    x: int
    y: int

The namedtuple distractor can also store data, but it is immutable and less flexible for general cases.' where id='48cf8da7-8c07-4d3e-9046-f8c6fa7159f0'::uuid;
update public.soal set pertanyaan_en='How can a pointer change a variable from within a function?', penjelasan_en='Answer: By sending a variable address, then the function dereferences it.

void change(int* q) { *q = 777; }
int y = 1;
change(&y);   // y becomes 777

If a normal value is sent, the change does not affect the original:
void changeFalse(int q) { q = 888; } // y does not change' where id='490c2971-6ee2-4618-a66d-ad671fba1145'::uuid;
update public.soal set pertanyaan_en='How do I access the city of a Student struct that has an Address member?', penjelasan_en='Answer: m.address.city

Access follows a structure from OUTSIDE to INSIDE:
m (struct Student) -> .address (struct Address) -> .city (string).

m.city.address is incorrect because m does not have a direct city member.' where id='4a6875ed-5ff9-4ece-b797-4751813c26b6'::uuid;
update public.soal set pertanyaan_en='What is the CORRECT syntax to define a struct in C++?', penjelasan_en='Answer: struct Point { int x; int y; };

The semicolon after } is MANDATORY.

struct Point { int x; int y; } without a semicolon is the most common error - the error message points to the next line and is confusing.' where id='521ee5df-b2e7-422f-8b2e-48d97feb5f21'::uuid;
update public.soal set pertanyaan_en='struct Student { double ipk; };
void change(Student m) { m.ipk = 4.0; }

Student m = {3.5};
change(m);
cout << m.ipk;', penjelasan_en='Output: 3.5

Send as VALUE = COPY. Changing m.ipk inside the function does not affect the original struct.

Distractor 4 is incorrect - that''s the result if sent as a pointer.

To change the original: void change(Student* m) { m->ipk = 4.0; }' where id='52beb91d-95e2-424d-bcd7-e96a9eb7b1bf'::uuid;
update public.soal set pertanyaan_en='Why is i[arr] also valid?', penjelasan_en='Answer: Because arr[i] is translated as *(arr + i), and addition is commutative.

*(arr + i) == *(i + arr)

So 3[arr] is valid and has the same value as arr[3].

BUT don''t use it - it confuses the reader and is of no use. This is just an interesting language fact.' where id='6edad433-e2bb-42ba-8404-088f73a6fb9f'::uuid;
update public.soal set pertanyaan_en='What do pointers store?', penjelasan_en='Answer: Memory address, not direct value.

int value = 42;
int* p = &value;   // p stores the ADDRESS value

The "variable value" distractor is wrong - it''s the body, not the address.
The "variable copy" distractor is wrong - the pointer does not copy.' where id='6fadcb5e-319f-44cc-9b50-2957196b9630'::uuid;
update public.soal set pertanyaan_en='How to sort an array of structs based on descending ipk field?', penjelasan_en='Answer: sort(class, class + 3, [](const Class& a, const Class& b) { return a.ipk > b.ipk; });

The comparison lambda accepts two elements and returns true if a must come before b.

The > sign is for decreasing, < for increasing.

Need to #include <algorithm>.' where id='75a52bfe-4e0b-4676-b0ee-ad3cc54aeb61'::uuid;
update public.soal set pertanyaan_en='arr = [10, 20, 30, 40, 50]
print(arr[-1])

What is the output?', penjelasan_en='Outputs: 50

Python supports NEGATIVE indexes:
arr[-1] = last element
arr[-2] = penultimate

This feature does NOT exist in C++.' where id='75cc5b1c-1765-41bd-b069-283552e856a2'::uuid;
update public.soal set pertanyaan_en='Why does pointer arithmetic follow a type scale instead of 1 byte?', penjelasan_en='Answer: Because the purpose of p+1 is to point to the next element, not the next byte.

If int* adds 1 byte, it will point to the middle of the int - useless. With type scaling, p+1 is always right at the next element.

char* +1 = 1 byte, int* +1 = 4 bytes, double* +1 = 8 bytes.' where id='7907294a-1636-4a6a-a37d-00f4c5f43a6a'::uuid;
update public.soal set pertanyaan_en='What is dangling pointer?', penjelasan_en='Answer: A pointer that points to freed memory.

int* p = new int(42);
delete p;
cout << *p;   // UB! p is a dangling pointer

The danger: it may appear to run normally because the old values are still in memory. But that''s undefined behavior.

Fix: set p = nullptr after delete.' where id='7cb99828-7d60-47fe-ae89-3f03afaff6fe'::uuid;
update public.soal set pertanyaan_en='a = [1, 2, 3]
b = a
b.append(4)
print(len(a))

What is the output?', penjelasan_en='Outputs: 4

b = a does NOT make a copy - they both point to the SAME list object.

After b.append(4), the lists pointed to by a and b both contain [1,2,3,4].

To copy correctly: a.copy(), a[:], or list(a).' where id='84784049-f51b-479e-ba71-0561b08ed3c3'::uuid;
update public.soal set pertanyaan_en='struct Point { int x; int y; };
void shear(Point t) { t.x = t.x + 10; }

Point a = {3, 7};
shift(a);
cout << a.x;

What is the output?', penjelasan_en='Outputs: 3

The struct is sent as a COPY.
Changing t in the function does not affect a.

In order to change the original, the parameter must be a reference: void shear(Point& t)

This is an important concept: value vs reference.' where id='98d1a0c4-d6e6-4069-a64f-f6191390cc06'::uuid;
update public.soal set pertanyaan_en='From what index do arrays start in C++ and Python?', penjelasan_en='Answer: 0

Both C++ and Python start the index from 0.
The first element is arr[0], not arr[1].

Distractor 1 is the most common mistake for beginners.' where id='9afbd965-01cc-4e21-8be3-a5ea798db757'::uuid;
update public.soal set pertanyaan_en='How many elements does the int array m[4][5] have?', penjelasan_en='Answer: 20

4 rows x 5 columns = 20 elements.

Distractor 9 = 4+5 (adding, not multiplying).
Distractor 5 = column only. Distractor 4 = row only.' where id='a1e9a32a-e02b-4ba7-a209-ccc2695539da'::uuid;
update public.soal set pertanyaan_en='Why does the vector capacity double (2x) and not increase by 1 each time?', penjelasan_en='Answer: To make re-allocations less frequent, so that push_back remains O(1) on average.

If the capacity increases by 1 each time, each push_back will trigger a re-allocation + copy of all elements, so O(n) per operation. For n elements, the total is O(n squared) - very slow.

With multiples, the total time becomes O(n).' where id='a57e18ed-e514-4348-b332-3a00ecffd6bf'::uuid;
update public.soal set pertanyaan_en='Why is padding needed in structs?', penjelasan_en='Answer: So that each member starts at an aligned address, so that the CPU can read it in one operation.

The CPU reads memory in blocks (4 or 8 bytes), not byte by byte. If the int is placed at an unaligned offset, the CPU needs two read operations and merges them - much slower.

The "to save memory" scam is wrong - padding actually WASTES memory for the sake of speed.' where id='af7ef32d-1b9a-40fb-8844-c36090884239'::uuid;
update public.soal set pertanyaan_en='What does "row-major order" mean?', penjelasan_en='Answer: Multidimensional array elements are stored row by row.

Row 0 is saved completely first, then row 1, and so on.

The opposite is column-major (used by Fortran, MATLAB, R).
C++ and Python (for lists) use row-major.' where id='b07af669-eded-414f-9a14-698be03e0b1a'::uuid;
update public.soal set pertanyaan_en='How to declare an array of 3 integers with initial values in C++?', penjelasan_en='Answer: int arr[3] = {1, 2, 3};

int arr(3) is wrong: that''s the syntax for calling a function, not an array.
arr = [1,2,3] is Python syntax, not C++.
array arr[3] is not valid C++ syntax.' where id='edf4df47-31a0-4abf-ae79-687fc8c884da'::uuid;
update public.soal set pertanyaan_en='When is it better to use std::vector instead of array?', penjelasan_en='Answer: When size is unknown during compilation or need to add/subtract elements.

Excellent vector for:
- data whose amount is only known when the program is running
- data that needs to grow/decrease
- cases that need .size() and security

Arrays are more appropriate when the size is fixed and maximum performance is required.

Modern C++ default: std::vector.' where id='efed2877-6f2c-4b48-9b3d-69526c273ecf'::uuid;
update public.soal set pertanyaan_en='What is sizeof(struct { char a; long b; char c; })?', penjelasan_en='Answer: 24 bytes

Offset: a=0, b=8 (requires multiple of 8), c=16.
Total before rounding: 17.
Largest alignment = 8, rounded to 24.

Details: 1 + 7 padding + 8 + 1 + 7 final padding = 24.

Distractor 10 = 1+8+1 without padding. Distractor 16 = forgot padding after c.' where id='b1faa4af-45d9-46a4-8670-1be52ac2cbb7'::uuid;
update public.soal set pertanyaan_en='How to send a struct so that it is not copied and cannot be changed?', penjelasan_en='Answer: Use const pointers.

void print(const Student* m) {
    cout << m->name;
    // m->ipk = 4.0;   // ERROR
}

const prevents changes, pointers prevent copying. This is the most common pattern in professional C++ code.

The student m (value) also cannot be changed if it is const, but is still copied.' where id='c1561a63-4e32-4135-a036-9e95cd95e12e'::uuid;
update public.soal set pertanyaan_en='What is a memory leak?', penjelasan_en='Answer: Heap memory that is not freed because you forgot to delete it.

void leak() {
    int* p = new int(42);
    // forgot to delete
}

Result: memory is used up until the program ends. In long programs, memory runs out and the program crashes.

The "crash instantly" trick is wrong - the leak works slowly.' where id='c79a0d15-03b8-4160-a6ee-2960e786b415'::uuid;
update public.soal set pertanyaan_en='int arr[5];
cout << (arr == &arr[0]);', penjelasan_en='Outputs: 1

The name of the array and the address of its first element result in the SAME address.
This is proof of decay: arr turns into a pointer to arr[0].

Distractor 0 is false - they are indeed the same address.' where id='c7a45af0-6df7-406d-909b-e0c967ab679f'::uuid;
update public.soal set pertanyaan_en='Why should struct NOT be compared to memcmp?', penjelasan_en='Answer: Because padding contains indeterminate values, two structs with identical data can be considered different.

memcmp compares ALL bytes including padding. The C++ standard does not specify the contents of the padding - it can be a null value, the rest of old data, or whatever.

Compare members one by one, or use the default operator== (C++20).' where id='d5930a11-2f82-40d7-875a-2282c380e88f'::uuid;
update public.soal set pertanyaan_en='When should a struct be sent to a function with a const reference?', penjelasan_en='Answer: When the function is read only and the struct is large.

void print(const Point& t)

const prevents functions from changing data, & prevents copying.

This is the most common pattern and is recommended for large structs.

Send as value only if the struct is small AND needs to be changed without affecting the original.' where id='d7463005-3aaa-4868-ae9c-2055504dd1f6'::uuid;
update public.soal set pertanyaan_en='What are the dangers of writing structs directly to a file?', penjelasan_en='Answer: Padding bytes whose contents are not necessarily written, so the data can be confused when read on other platforms.

file.write((char*)&x, sizeof(Mix));

What is written includes padding. If you read it on a platform with different alignment rules, the layout doesn''t match.

Solution: use JSON, Protocol Buffers, or write each member individually.' where id='d83d45ec-21e8-4286-bb13-480dd5c0855a'::uuid;
update public.soal set pertanyaan_en='struct Mix { char a; int b; };
cout << offsetof(Mix, b);

What is the output if sizeof(int)=4?', penjelasan_en='Outputs: 4

b must start at an offset that is a multiple of 4 (int alignment).
After char a is offset 0, the next offset is 1.
Rounded to a multiple of 4 -> 4.

The three bytes at offset 1-3 are padding.' where id='dcbfe273-766b-4cda-b1af-f79a8c3f660f'::uuid;
update public.soal set pertanyaan_en='What are two ways to access struct members via pointers?', penjelasan_en='Answer: (*pt).x and pt->x

Both are equivalent and produce the same value.

pt->x is a shorthand for (*pt).x. The brackets in the long method MUST be there because of the operator . higher priority than *.

pt.x is wrong - pt is a pointer, not a struct.' where id='f5bbf4c4-9144-4553-bc3c-25f4367f2a20'::uuid;
update public.soal set pertanyaan_en='How to allocate a single value in the heap?', penjelasan_en='Answer: int* p = new int(42);

new allocates on the heap and returns a pointer. delete frees it.

int* p = &x; wrong - it points to a stack variable, not a heap allocation.
int p = new int; false - p is not a pointer.
malloc alone without free is C style, not C++.' where id='fb324a19-3482-46ef-ab48-3c11f2cfae25'::uuid;
update public.soal set pertanyaan_en='What does the @dataclass decorator AUTOMATICALLY create?', penjelasan_en='Answer: __init__, __repr__, and __eq__

@dataclass
class Point:
    x: int
    y: int

t = Point(3, 7) # __init__
print(t) # __repr__: Point(x=3, y=7)
t == Point(3, 7) # __eq__: True

Without @dataclass, all three must be written manually.' where id='fc0257b5-d448-4d4f-976f-e442888a190f'::uuid;
update public.soal set pertanyaan_en='struct Point { int x; int y; };
Point t = {3, 7};
Point* pt = &t;
pt->x = 99;
cout << t.x;', penjelasan_en='Output: 99

pt points to the ORIGINAL t.
Changing pt->x is the same as changing t.x.

Distractor 3 = initial value before change.' where id='fcaabef2-feb9-4af5-b114-5243cbfa2ff1'::uuid;
update public.opsi_soal set teks_en='Error' where id='44c30ed5-68a0-49c6-9efe-1b6d30c26135'::uuid;
update public.opsi_soal set teks_en='Returns the value 0' where id='4536a6f6-832e-446e-a1f9-893ad8608c32'::uuid;
update public.opsi_soal set teks_en='New elements are stored in a separate location' where id='45489340-2ee1-4531-aadb-5180f9ef2ac4'::uuid;
update public.opsi_soal set teks_en='Python has pointer arithmetic, C++ doesn''t' where id='469f1b49-c226-433d-bb71-429ddd4e0829'::uuid;
update public.opsi_soal set teks_en='So that each member starts at an aligned address so the CPU can read it in one operation' where id='48190e8c-a941-4eca-a77b-8a1d512530b3'::uuid;
update public.opsi_soal set teks_en='1' where id='49a1e10a-1ca5-45c2-b668-5ef402efaef5'::uuid;
update public.opsi_soal set teks_en='*pt.x and pt->x' where id='4a4ecd08-fbb8-4a86-bdbe-41e76f991036'::uuid;
update public.opsi_soal set teks_en='address(0) + sizeof(Type)' where id='4a8522b6-727f-4eca-96e0-e77ce12012ce'::uuid;
update public.opsi_soal set teks_en='By returning the value from the function' where id='4aa1a8dd-e62c-4549-b16d-a434a7d8a37a'::uuid;
update public.opsi_soal set teks_en='m->address->city' where id='4aa99b87-8fac-4fd0-84b4-7241af403ee2'::uuid;
update public.opsi_soal set teks_en='Convert array to list' where id='4ad860dd-0704-4edc-9421-0561cf3f7733'::uuid;
update public.opsi_soal set teks_en='Yes, but only in C++20 and above' where id='4b10bc51-163e-4d78-92d8-9254e8ddb5a0'::uuid;
update public.opsi_soal set teks_en='Listitems[] = {"Books"};' where id='4b855941-08a9-4745-8822-a7b2a8313e1a'::uuid;
update public.opsi_soal set teks_en='int* arr = new int[5];' where id='4d3dc2e4-d72a-47a2-8479-98ebf2f6a7d7'::uuid;
update public.opsi_soal set teks_en='10 10' where id='4df6973f-a97d-479a-a608-bd2eb35eed79'::uuid;
update public.opsi_soal set teks_en='address(0,0) + (i x j) x sizeof(Type)' where id='4e76d0b3-f6fa-4441-b49d-304aee073b2f'::uuid;
update public.opsi_soal set teks_en='3' where id='4f9d61be-0d85-4054-ba49-7f0943aab352'::uuid;
update public.opsi_soal set teks_en='When interacting with C style APIs' where id='4fb86408-4838-4492-aaf5-2585fb1e6fae'::uuid;
update public.opsi_soal set teks_en='TypeError: non-default argument follows default argument' where id='509e21d3-d225-4f6e-a0e2-55320675329b'::uuid;
update public.opsi_soal set teks_en='Padding always decreases by ordering from largest to smallest' where id='5190808c-8654-47d7-a220-19af902ed71a'::uuid;
update public.opsi_soal set teks_en='Because it is undefined behavior' where id='51faedc0-7666-4a14-be40-858c890a62c2'::uuid;
update public.opsi_soal set teks_en='sort(class, class+3);' where id='5215402f-dfc6-42cc-b4f6-51a6229a4d2e'::uuid;
update public.opsi_soal set teks_en='To make re-allocations less frequent so that push_back remains O(1) on average' where id='5238ac2c-e89f-4fe6-8c0b-e5d359f3fc8f'::uuid;
update public.opsi_soal set teks_en='8 bytes - the size of the pointer, since the actual parameter is int*' where id='5528e0cf-ee42-4b68-99ae-3b7f12b74856'::uuid;
update public.opsi_soal set teks_en='24' where id='57ef0822-ead2-4844-a58d-0d864a154c33'::uuid;
update public.opsi_soal set teks_en='Because pointers save memory when stored' where id='580d98f9-51b4-40ca-bc1b-f603ec640f13'::uuid;
update public.opsi_soal set teks_en='5' where id='597d2dab-aac2-4660-8ecb-523cc87b641e'::uuid;
update public.opsi_soal set teks_en='pt.x and (*pt)->x' where id='59acf49c-4ff8-4a74-935d-7c5f2a08702c'::uuid;
update public.opsi_soal set teks_en='. for value/reference; -> for pointers' where id='5a857625-4465-49a4-be4c-4a5832af6467'::uuid;
update public.opsi_soal set teks_en='capacity = number of elements; size = available space' where id='5ca07ddc-f9dd-4fd9-992d-4440a7053e3d'::uuid;
update public.opsi_soal set teks_en='arr is the value, &arr is the address' where id='5e04bcbc-16cd-4a2e-94cc-1892dd9fd41d'::uuid;
update public.opsi_soal set teks_en='1' where id='5fbd6ef5-cb13-4236-a8a0-f52c312f29ed'::uuid;
update public.opsi_soal set teks_en='IndexError' where id='600ca924-b604-4b1b-89c9-fe468156ab84'::uuid;
update public.opsi_soal set teks_en='memcmp can only compare primitive types' where id='60245672-2a31-4745-b7ca-ce2c4a6d1ffd'::uuid;
update public.opsi_soal set teks_en='3.5' where id='608b70be-7535-4b3d-8f69-af9793550a3a'::uuid;
update public.opsi_soal set teks_en='__init__, __repr__, and __eq__' where id='62849f69-dcd0-459a-a17c-1d0d3a9167a8'::uuid;
update public.opsi_soal set teks_en='memcmp is too slow for large structs' where id='62a5a42f-7f23-48f2-9faa-df5a2b261b48'::uuid;
update public.opsi_soal set teks_en='Because the compiler optimizes all arrays' where id='63559ae0-29f3-4bc7-bdb1-97e8a8a26650'::uuid;
update public.opsi_soal set teks_en='Both are not pointers' where id='6399599b-3680-4e2f-b9a1-ed2f598cbe67'::uuid;
update public.opsi_soal set teks_en='Because the compiler optimizes the arithmetic' where id='63e05b3f-8396-43d0-9827-402d962faea6'::uuid;
update public.opsi_soal set teks_en='5' where id='643d1c19-8344-4bdf-9fc2-29b7484f8d4d'::uuid;
update public.opsi_soal set teks_en='When the function is read only and the struct is large' where id='64e860df-50c4-4ed1-9595-13d6607063ab'::uuid;
update public.opsi_soal set teks_en='Compilation error' where id='65b609df-3b93-4738-8f82-ee35538106e0'::uuid;
update public.opsi_soal set teks_en='C++ copy reference; Python copies values' where id='65ca4874-19f8-4ba2-aae5-2cddb1e4f0cb'::uuid;
update public.opsi_soal set teks_en='int* arr = new int;' where id='66427f73-f8bd-418b-9b7f-790717197ff6'::uuid;
update public.opsi_soal set teks_en='Because the compiler rejects pointers without a value' where id='669f49cf-76a3-40c3-bcf6-9ca2e015356d'::uuid;
update public.opsi_soal set teks_en='10' where id='68589b7e-c28a-491d-95e3-8e8ee19098b7'::uuid;
update public.opsi_soal set teks_en='append is optimized by the Python compiler' where id='6978fa9e-d457-43bc-bde2-dc1c3916263e'::uuid;
update public.opsi_soal set teks_en='Yes, arr[i] is defined as *(arr + i)' where id='6986ffc5-72f4-48ea-9340-03b1604d39c9'::uuid;
update public.opsi_soal set teks_en='insert(0, x) should shift all elements (O(n)); append only adds at the end (O(1))' where id='6a654d4e-5700-4fc7-ae6b-e01b03df64f5'::uuid;
update public.opsi_soal set teks_en='The array is automatically enlarged to fit' where id='6ba01242-d90a-4ce5-a6f7-89db370038b2'::uuid;
update public.opsi_soal set teks_en='Only with garbage collector' where id='6d4a45ff-5c93-4033-a591-1e10ffade2d5'::uuid;
update public.opsi_soal set teks_en='Calling delete twice on the same pointer' where id='6d76178a-878a-46ca-be1f-f3ab24367356'::uuid;
update public.opsi_soal set teks_en='Because element addresses can be calculated directly without searching' where id='6dba34e1-7e53-4bdb-b3e5-3a2d83c8c601'::uuid;
update public.opsi_soal set teks_en='[[0] * 3] * range(3)' where id='6e38897b-3da4-40d3-989c-9790ba757bc5'::uuid;
update public.opsi_soal set teks_en='13' where id='6eb91466-33a0-46b5-9b52-a01c8be42a42'::uuid;
update public.opsi_soal set teks_en='AoS stores one intact object per element; SoA stores one field for all objects' where id='6ecf9a5b-c0aa-4d95-afbf-87fd710c82de'::uuid;
update public.opsi_soal set teks_en='Error' where id='709f399e-eb5a-44c0-a648-9eed77d69144'::uuid;
update public.opsi_soal set teks_en='sort(class.ipk);' where id='70d15a22-57af-4ce2-8ee0-afd925837831'::uuid;
update public.opsi_soal set teks_en='0 10' where id='711f57bd-acc7-4a11-a185-d110259145d9'::uuid;
update public.opsi_soal set teks_en='4' where id='0198aafa-5323-4884-8c8f-8f7d2101719f'::uuid;
update public.opsi_soal set teks_en='7' where id='022545fb-023c-4b2a-a068-f2cd8228f4dd'::uuid;
update public.opsi_soal set teks_en='address(0,0) + (i x numberofRows + j) x sizeof(Type)' where id='029e6b81-c2fe-4a67-a121-0c2565bf3766'::uuid;
update public.opsi_soal set teks_en='Budi' where id='0424a900-4e06-4579-9b0a-bcc2eee98d7a'::uuid;
update public.opsi_soal set teks_en='0 5' where id='0430a8cb-ec69-4550-8e2f-88d4de384f32'::uuid;
update public.opsi_soal set teks_en='Undefined behavior: may print garbage values, crash, or appear normal' where id='0489eae9-5665-4241-8e4d-fcdd979be539'::uuid;
update public.opsi_soal set teks_en='insert requires data type conversion' where id='05200236-e4cc-46f9-af3d-c596091ea032'::uuid;
update public.opsi_soal set teks_en='The size of one element in bytes' where id='058aa1bc-e57f-4c81-81b7-da97c7148791'::uuid;
update public.opsi_soal set teks_en='6' where id='05dbd6f9-3540-4585-a6f8-13c475d4116a'::uuid;
update public.opsi_soal set teks_en='40' where id='7431723d-7319-4bd2-a7bb-a0283d567d05'::uuid;
update public.opsi_soal set teks_en='5 5' where id='7469ef8c-228b-4495-8124-11e51e51b523'::uuid;
update public.opsi_soal set teks_en='Always means dereference' where id='74b32568-f9f6-4387-af72-bd0d11880253'::uuid;
update public.opsi_soal set teks_en='The program automatically stops with an error message' where id='75b5b4e6-442e-49b7-ae52-06d9532259c1'::uuid;
update public.opsi_soal set teks_en='20 bytes - the same as in main' where id='7615a19e-33a6-4ca4-b21f-f3d66d00d649'::uuid;
update public.opsi_soal set teks_en='v[i] for read, v.at(i) for write' where id='76f4e326-841e-42c4-a185-6e46db967a48'::uuid;
update public.opsi_soal set teks_en='[0] * 9' where id='7778347b-4897-492d-8874-eb3beb5e7113'::uuid;
update public.opsi_soal set teks_en='Stack is bigger than heap' where id='788ccae5-ce0e-482a-a895-46f93060f8fd'::uuid;
update public.opsi_soal set teks_en='Allocate new blocks, copy old elements, free old blocks' where id='78b0b567-ac3f-4d4b-b09a-bec0579da68f'::uuid;
update public.opsi_soal set teks_en='5 0' where id='79c5f4ea-f341-453a-87f6-62048116f3c9'::uuid;
update public.opsi_soal set teks_en='Enlarge the list automatically' where id='06786609-914d-493e-9155-519d7c40f78a'::uuid;
update public.opsi_soal set teks_en='99' where id='06de8ec0-621d-44e1-805d-3734f0bcdf86'::uuid;
update public.opsi_soal set teks_en='Error' where id='06e4b28c-8106-482f-bcbc-2c36d9411a5c'::uuid;
update public.opsi_soal set teks_en='10 0' where id='073ef422-32a0-4947-8514-7b83f11e02e4'::uuid;
update public.opsi_soal set teks_en='So that the vector cannot be accessed from outside' where id='07b77b39-2446-4580-a964-8aafc63f6567'::uuid;
update public.opsi_soal set teks_en='1' where id='08288f5c-3113-4709-b090-d6dc46826583'::uuid;
update public.opsi_soal set teks_en='dictionary' where id='082b0d5e-6abb-4db3-85c5-4c67451faf3c'::uuid;
update public.opsi_soal set teks_en='Invalid declaration and compilation failed' where id='08d9b514-5a71-4d9c-84ee-f6b9cad50737'::uuid;
update public.opsi_soal set teks_en='Variable copy' where id='095b325a-ce0c-4dd2-ae7e-0dcf834f594f'::uuid;
update public.opsi_soal set teks_en='sorted(class, key=lambda k: k.ipk, reverse=True)' where id='09b544db-5ee5-4528-b475-ee23e8b467f1'::uuid;
update public.opsi_soal set teks_en='int* p = new int(42);' where id='0a660546-5680-438a-98e7-2c81e4862f37'::uuid;
update public.opsi_soal set teks_en='Yes, but only for char arrays' where id='0a923074-8a24-4d9e-91a8-64454af1478c'::uuid;
update public.opsi_soal set teks_en='nested lists' where id='0be8e558-9383-4ee2-aa10-25dfcaba1ce7'::uuid;
update public.opsi_soal set teks_en='def struct Point { int x; int y; };' where id='0d2bfcb0-af7e-451e-8fc8-4215efb8a5f8'::uuid;
update public.opsi_soal set teks_en='5' where id='3a872227-f4e2-447a-b684-7511db432356'::uuid;
update public.opsi_soal set teks_en='address(0,0) + (i + j) x sizeof(Type)' where id='80f114c6-74be-4e7e-a173-311e45e29cbc'::uuid;
update public.opsi_soal set teks_en='4' where id='81251405-fa8f-4ce5-a238-2685350d0c76'::uuid;
update public.opsi_soal set teks_en='Always means multiplication' where id='8153eaeb-7609-4248-909b-1b3bf96f7c6d'::uuid;
update public.opsi_soal set teks_en='5' where id='81acb7eb-7d2b-4dcd-90c5-20034e739f8b'::uuid;
update public.opsi_soal set teks_en='sort(class, class+3, [](const Class& a, const Class& b) { return a.ipk > b.ipk; });' where id='8247f293-61d2-4b1c-a8af-a05375b93bbb'::uuid;
update public.opsi_soal set teks_en='__str__ and __len__' where id='825416ae-5665-4531-a0ee-b8a1a949a2d5'::uuid;
update public.opsi_soal set teks_en='There is no special meaning' where id='826fe58b-7ff5-40f2-9297-def787adc78b'::uuid;
update public.opsi_soal set teks_en='Padding contains indeterminate values, so structs with the same data can be considered different' where id='83079a3b-4e7c-4f20-ad18-ebc53ee0abad'::uuid;
update public.opsi_soal set teks_en='42' where id='83a5edda-e161-448a-8f4e-a42a8aeda645'::uuid;
update public.opsi_soal set teks_en='24' where id='83dac4da-c61e-456f-b4ec-39a36e85753b'::uuid;
update public.opsi_soal set teks_en='With smart pointer' where id='842c0856-1d2e-446d-a25e-46f3662836db'::uuid;
update public.opsi_soal set teks_en='Depends on data type' where id='84448f28-2f72-474a-b701-eae9167dc082'::uuid;
update public.opsi_soal set teks_en='Depends on the compiler' where id='85be71a3-55a3-4ef7-89de-ed9fe9235b35'::uuid;
update public.opsi_soal set teks_en='Error' where id='865f44eb-741c-4421-a90b-273118219ae0'::uuid;
update public.opsi_soal set teks_en='50' where id='8794e0de-23a5-421e-928b-aadeb4ac9b2b'::uuid;
update public.opsi_soal set teks_en='Because the operator . cannot be used on structs' where id='87da533f-1e0d-4bb0-8af3-954c4a8a8821'::uuid;
update public.opsi_soal set teks_en='Python will sort automatically' where id='895e45c4-3d80-4962-be74-d9c6f31c7827'::uuid;
update public.opsi_soal set teks_en='16' where id='89ded8d7-1d59-48c0-b7a3-ba7c0a22b9f6'::uuid;
update public.opsi_soal set teks_en='Both cannot point to objects' where id='8ab4adef-65ba-4341-99f3-6b2a79b30338'::uuid;
update public.opsi_soal set teks_en='The value for the address must be wrapped in its own curly braces: {"Rani", {"Bandung"}}' where id='8b3e2605-4f5e-419e-9190-ee89b8a3fb80'::uuid;
update public.opsi_soal set teks_en='0' where id='8ca45fca-021b-44c1-92cc-4e04ad99a57c'::uuid;
update public.opsi_soal set teks_en='48' where id='8d5fc19c-89fc-4ec7-aaea-fb9df4c24bf4'::uuid;
update public.opsi_soal set teks_en='Use regular references: void print(Student&m)' where id='8db1bf38-8a2a-4882-9855-fd36693e7ddd'::uuid;
update public.opsi_soal set teks_en='0' where id='8edf655d-7d50-40c3-91af-215172c38e2c'::uuid;
update public.opsi_soal set teks_en='Adding padding for better alignment' where id='8efe3fe5-6456-469e-aaf8-3ff6eecdd09d'::uuid;
update public.opsi_soal set teks_en='12' where id='8f4f03a7-fe55-45b0-8a1d-f3c79eba6277'::uuid;
update public.opsi_soal set teks_en='Both are the same type and behave the same' where id='90487569-5513-4a88-9537-9fd0770f3e53'::uuid;
update public.opsi_soal set teks_en='A pointer that points to an array' where id='91cf0d12-e4ff-4740-93a2-b07532b0ceb0'::uuid;
update public.opsi_soal set teks_en='int m[3][4];' where id='921df9ea-acc6-4c70-9538-6c89f8a91894'::uuid;
update public.opsi_soal set teks_en='0' where id='92f151e8-340a-4cef-a34d-417537633965'::uuid;
update public.opsi_soal set teks_en='Multidimensional array elements are stored column by column' where id='930cd5b0-9dd2-4a21-b695-94bdb1711b06'::uuid;
update public.opsi_soal set teks_en='Because arrays are always small' where id='9362b239-f6c3-4e79-bd35-1203d73c6d8c'::uuid;
update public.opsi_soal set teks_en='Automatic heap, manual stack' where id='93da37f4-1ca0-4dff-8ede-208fa32e7e8c'::uuid;
update public.opsi_soal set teks_en='The student''s name must be placed after the address' where id='940dc36f-84ca-4b98-9bb4-4867430a744d'::uuid;
update public.opsi_soal set teks_en='Returns None' where id='957cc746-f468-43ef-95c0-f478003c8c6f'::uuid;
update public.opsi_soal set teks_en='@dataclass(frozen=True)' where id='9583451c-7956-4281-8c27-4929776ad8f3'::uuid;
update public.opsi_soal set teks_en='Because computer memory is block based' where id='97383a64-952b-4871-b354-3f25f85e8e4e'::uuid;
update public.opsi_soal set teks_en='24 24' where id='979ebb3d-52e4-4f6a-93b7-5111358b9112'::uuid;
update public.opsi_soal set teks_en='m.address.city' where id='0141dbf0-2b7c-4807-9bd9-f62745f76659'::uuid;
update public.opsi_soal set teks_en='structs cannot have methods' where id='0d41022b-b2fd-4580-8093-ec55f7b3d486'::uuid;
update public.opsi_soal set teks_en='int arr(3);' where id='0dae5ba7-28a2-47d3-b0f0-85f9f6453cb8'::uuid;
update public.opsi_soal set teks_en='16 24' where id='0ddf9382-7cea-4b96-bfec-551dd01a5dfe'::uuid;
update public.opsi_soal set teks_en='When a struct has only one member' where id='0f17c251-e0f7-45f5-85e2-8889b2b3ac87'::uuid;
update public.opsi_soal set teks_en='Struct members cannot be accessed' where id='0f48ca2f-6e5c-400c-9aa2-ead84f144d61'::uuid;
update public.opsi_soal set teks_en='Because the purpose of p+1 is to point to the next element, not the next byte' where id='112a78ad-cd0c-4e94-8cb4-96cb3707f335'::uuid;
update public.opsi_soal set teks_en='3' where id='1169385c-39e1-4f28-8522-f88b75ace06c'::uuid;
update public.opsi_soal set teks_en='Because pointers cannot be compared' where id='14f0c13a-fd5e-452e-8fab-beffb5ae96d0'::uuid;
update public.opsi_soal set teks_en='The pointer pointing to memory is invalid' where id='15c257d0-8115-4c69-b805-77d07ac0a104'::uuid;
update public.opsi_soal set teks_en='When you need maximum performance and fixed size' where id='1709fcfd-c5f9-41a9-ab68-466bb2565afe'::uuid;
update public.opsi_soal set teks_en='Both lock the value and address' where id='184c9da0-107c-4d85-8115-973b4d8ad5fc'::uuid;
update public.opsi_soal set teks_en='Both copy references' where id='98b975ac-03d7-4b3e-b9ca-9fe3b68fe30a'::uuid;
update public.opsi_soal set teks_en='C++ copy VALUE; Python copies REFERENCES' where id='98c5b424-c0cb-457d-bb8f-7d47e07422d2'::uuid;
update public.opsi_soal set teks_en='@dataclass(immutable=True)' where id='997a6b0b-0bcb-417f-acd5-d35d8aa6a1b9'::uuid;
update public.opsi_soal set teks_en='Undefined behavior - usually crashes, but the standard doesn''t guarantee that' where id='9baef7f7-dec1-4827-8e15-57549031a253'::uuid;
update public.opsi_soal set teks_en='tuple' where id='9c3488d2-5de9-4d32-add4-513b995f332b'::uuid;
update public.opsi_soal set teks_en='Because (*pt).x is invalid' where id='9d430cd1-6aad-4049-bd3c-ba6ccbf25763'::uuid;
update public.opsi_soal set teks_en='address(0) + i x sizeof(Type)' where id='9de5c751-dbdb-4b1c-b085-fa3adcff4a47'::uuid;
update public.opsi_soal set teks_en='Because structs don''t have members' where id='9e411554-e5c3-4304-9566-6ebdc0e844bd'::uuid;
update public.opsi_soal set teks_en='The compiler refuses to return the pointer' where id='a0b132ee-4c0b-49bc-8819-a48f16dea6ad'::uuid;
update public.opsi_soal set teks_en='Smart pointer with single ownership' where id='a11cf056-d2c2-426b-9f3a-6bef2c23380c'::uuid;
update public.opsi_soal set teks_en='10 10' where id='a1ffd95f-4af5-4ac0-94c6-2b5114c328cb'::uuid;
update public.opsi_soal set teks_en='9' where id='a211f405-e996-47e8-8ae2-445ae24ad392'::uuid;
update public.opsi_soal set teks_en='std::span copies the array' where id='a24d12bf-1ebe-4089-a0a8-96180530dfb5'::uuid;
update public.opsi_soal set teks_en='32' where id='a34532f4-6f8f-4c06-bccd-62902fe17eda'::uuid;
update public.opsi_soal set teks_en='0' where id='a4bed959-a705-43b6-a33b-26756580d5bf'::uuid;
update public.opsi_soal set teks_en='None' where id='a5141501-2208-48c8-a714-37dd007965fa'::uuid;
update public.opsi_soal set teks_en='The pointer automatically becomes nullptr' where id='a52bab23-f253-4e46-aece-5a81f7ff001f'::uuid;
update public.opsi_soal set teks_en='Because i[arr] is a special syntax' where id='a53d9de3-636f-4f57-ac6f-4501e18e61bb'::uuid;
update public.opsi_soal set teks_en='[[0] * 3] * 3' where id='a580f850-11da-4dc2-a33b-9bf81546f812'::uuid;
update public.opsi_soal set teks_en='Because pointers take up more memory' where id='a66103c5-1759-44e3-91b0-312ebb08ecdd'::uuid;
update public.opsi_soal set teks_en='Removes all elements then adds n new elements' where id='a70e652a-8ffd-455b-a717-b71ca9ce51fe'::uuid;
update public.opsi_soal set teks_en='In the declaration section of the type; in the dereference operator expression' where id='a7c1ad9a-f348-4cfe-acaa-6b0039ce4c91'::uuid;
update public.opsi_soal set teks_en='memcmp doesn''t support structs' where id='a7f5acb6-47d9-4ab4-97e3-a4c3371dca9b'::uuid;
update public.opsi_soal set teks_en='4' where id='a80e4398-3103-4c3d-bd0e-c906bfe38b2a'::uuid;
update public.opsi_soal set teks_en='Error' where id='aa9f6f38-6fa5-41e4-8eb5-e33dff0d435f'::uuid;
update public.opsi_soal set teks_en='Use const pointer: void print(const Student* m)' where id='aac9998c-bffc-4d83-b46f-8dfb6b5ab424'::uuid;
update public.opsi_soal set teks_en='5' where id='abb48dbc-e2e7-4e38-880a-3370c02b876c'::uuid;
update public.opsi_soal set teks_en='Throws IndexError and the program stops' where id='ac5f5336-d012-4573-a0e0-a71ef1d7cdf7'::uuid;
update public.opsi_soal set teks_en='array arr[3];' where id='ad0502a9-3837-406a-8a1e-ea4625bb633a'::uuid;
update public.opsi_soal set teks_en='2' where id='ada4ae0e-5369-4dc1-969c-83d3bae47d1e'::uuid;
update public.opsi_soal set teks_en='Because the C++ standard requires 2x capacity' where id='adb3a859-0063-4175-a583-7c8abaadd7c9'::uuid;
update public.opsi_soal set teks_en='Throwing an exception' where id='ae3dd6d2-8787-4061-8d47-445073084e1b'::uuid;
update public.opsi_soal set teks_en='std::span is faster to access' where id='ae436739-8b92-46cc-92c1-1d303a943aa8'::uuid;
update public.opsi_soal set teks_en='[[0] * 3 for _ in range(3)]' where id='ae7c8161-c4e3-4e01-84dd-bbcf87af4cea'::uuid;
update public.opsi_soal set teks_en='By sending a variable address, then the function dereferences it' where id='aeef46eb-6be9-4d6d-b3f7-af9abfede969'::uuid;
update public.opsi_soal set teks_en='double total = list[0].price + list.price;' where id='af840d71-6c5d-4040-92e9-832bd46d6363'::uuid;
update public.opsi_soal set teks_en='Error' where id='b036d3e3-8cde-470d-9210-6a28f27143f7'::uuid;
update public.opsi_soal set teks_en='99' where id='b05f749c-f164-4b42-a1c1-ad54b8b75c44'::uuid;
update public.opsi_soal set teks_en='struct Point ( int x; int y; );' where id='b0a8cb4d-b5e8-49d2-91cb-c07360a706a2'::uuid;
update public.opsi_soal set teks_en='The compiler refuses and the build fails' where id='19907e95-2895-463f-ab7b-51fba28d3497'::uuid;
update public.opsi_soal set teks_en='The value of the local variable is also returned' where id='19a2ea3b-75fb-4f28-8917-8dbf27566b13'::uuid;
update public.opsi_soal set teks_en='C++ and Python both have pointer arithmetic' where id='1a14efca-bc48-4e7f-8dac-2e044aeeb867'::uuid;
update public.opsi_soal set teks_en='v.at(i) is faster because it is compiler optimized' where id='1a6cf27a-9add-4d3e-a029-57f4e79b60ac'::uuid;
update public.opsi_soal set teks_en='const int* p lock VALUE; int* const p locks ADDRESS' where id='1af39339-4922-43e3-bf3d-7ab6311d126e'::uuid;
update public.opsi_soal set teks_en='@dataclass(const=True)' where id='1b19acb9-e866-4fc3-9a0b-094a7aea84bc'::uuid;
update public.opsi_soal set teks_en='Padding is reduced by adding members' where id='1b8aa765-1519-44f3-b72a-335296750bd9'::uuid;
update public.opsi_soal set teks_en='Both are the same' where id='1de3ac4d-e8ca-4dcf-80da-8484c5221edb'::uuid;
update public.opsi_soal set teks_en='Multidimensional array elements are stored row by row' where id='1e0dede6-56e5-4ca9-89b0-3b3b2506a319'::uuid;
update public.opsi_soal set teks_en='4' where id='1f48d3af-d662-4618-90f2-c3df075f1773'::uuid;
update public.opsi_soal set teks_en='10' where id='1f90cc07-d73f-4286-b915-3801c18d3dc6'::uuid;
update public.opsi_soal set teks_en='Depends on language' where id='2001bb1a-8e90-4561-9ee0-7ba3bc05b2a3'::uuid;
update public.opsi_soal set teks_en='3' where id='20eb411b-a656-44ae-8ea5-363672a1633c'::uuid;
update public.opsi_soal set teks_en='20' where id='23eadad4-55d8-4fce-a41c-a66699469643'::uuid;
update public.opsi_soal set teks_en='3' where id='248dee65-c386-4f67-a395-cd800db709f4'::uuid;
update public.opsi_soal set teks_en='address(i) = i x address(0)' where id='261c11a3-d86e-49c6-af02-66042cfa5c72'::uuid;
update public.opsi_soal set teks_en='When the function needs to change the original data' where id='b0b0af7a-5cb4-4eb7-8cad-6e52bf86170a'::uuid;
update public.opsi_soal set teks_en='arr is of type int* (+1 = 4 bytes); &arr is of type int(*)[5] (+1 = 20 bytes)' where id='b17df18e-af22-48b0-b4da-0f5eee338701'::uuid;
update public.opsi_soal set teks_en='m.city.address' where id='b23ae65b-cbff-4b67-85c8-d223978a8d7e'::uuid;
update public.opsi_soal set teks_en='const int* p lock address; int* const p locks the value' where id='b44c2833-a3ec-4302-a6a7-c2245affabf1'::uuid;
update public.opsi_soal set teks_en='12' where id='b4cd1b67-2c42-45ae-a8c2-962147f6be14'::uuid;
update public.opsi_soal set teks_en='struct Point { int x; int y; }' where id='b4cfe571-a309-471f-bdfb-65236ebda05e'::uuid;
update public.opsi_soal set teks_en='size = number of elements present; capacity = the amount that can be accommodated before re-allocation' where id='b6d94a4c-57dc-4e84-9acf-0ec4410dbfcd'::uuid;
update public.opsi_soal set teks_en='5' where id='b6da6046-48f3-45cb-8b81-c53519165e4b'::uuid;
update public.opsi_soal set teks_en='To prevent unauthorized access' where id='b79d12ed-2de3-4f6f-9b16-da1df41763da'::uuid;
update public.opsi_soal set teks_en='7' where id='b85cceac-587d-4ec8-bf3b-f65833334cd6'::uuid;
update public.opsi_soal set teks_en='Automatic change of array name to a pointer to its first element' where id='b88e359d-720b-4e97-b4ad-3ee6782cb476'::uuid;
update public.opsi_soal set teks_en='arr = [1, 2, 3];' where id='b99f17bf-5943-4829-930e-64adf07dcf1a'::uuid;
update public.opsi_soal set teks_en='Variable value' where id='ba1fcd05-a5ff-4887-a1d0-ef488d3fc62b'::uuid;
update public.opsi_soal set teks_en='40' where id='ba7c0646-8c15-4dbe-9fc0-18aeae67e8ab'::uuid;
update public.opsi_soal set teks_en='class.sort("ipk")' where id='26cca8c8-4bee-4fec-8e36-25d7b84bf8f5'::uuid;
update public.opsi_soal set teks_en='0' where id='278d96f2-216b-4b2d-a07a-c00c51c1467e'::uuid;
update public.opsi_soal set teks_en='Because the array is stored in the CPU cache' where id='27af63c2-7cc9-46e5-a338-ce2c07cd5916'::uuid;
update public.opsi_soal set teks_en='By sending variables as values' where id='28290246-8138-4446-92ea-3f0ef0680f3d'::uuid;
update public.opsi_soal set teks_en='struct Point { int x; int y; };' where id='2844160c-5b18-4a57-aaf1-66e97aea688e'::uuid;
update public.opsi_soal set teks_en='By declaring the variable as global' where id='29c09d10-f41b-4d12-afc8-170e4a7afe19'::uuid;
update public.opsi_soal set teks_en='a and b are both pointers' where id='29ecc2df-3b10-4f07-a2b1-1effc60a790d'::uuid;
update public.opsi_soal set teks_en='40' where id='2a559885-be02-4a11-ace6-0f99024d35cf'::uuid;
update public.opsi_soal set teks_en='3' where id='2b19f1eb-58ff-44ff-a55c-6410c9eff928'::uuid;
update public.opsi_soal set teks_en='sort(class, GPA, descending)' where id='2b43e7fe-b6d3-472b-a260-d87549e94483'::uuid;
update public.opsi_soal set teks_en='Undefined behavior' where id='2c939f4e-4b1e-43df-9265-b6323657f3a5'::uuid;
update public.opsi_soal set teks_en='4' where id='2d37eb53-047d-47d3-85f1-a54fd6324a83'::uuid;
update public.opsi_soal set teks_en='C++ can do pointer arithmetic and manual memory management; Python cannot do automatic arithmetic and memory' where id='2d451b70-1c0d-47d3-a424-7359a1be62b3'::uuid;
update public.opsi_soal set teks_en='4' where id='2d4e3507-9950-4438-8f6c-8f8d607b48df'::uuid;
update public.opsi_soal set teks_en='double total = sum(list);' where id='2f0dac71-803f-4323-b18d-e86d5a87811b'::uuid;
update public.opsi_soal set teks_en='Returns 0' where id='2f541dce-856e-4f1d-a76e-f275763f2af8'::uuid;
update public.opsi_soal set teks_en='Item list[3] = {"Books",25000,"Pens",3000,"Bags",150000};' where id='2f5b2f57-18c2-4c43-a32b-e4c12639f407'::uuid;
update public.opsi_soal set teks_en='Safe, because delete is the same as delete[]' where id='30ce4be1-d166-4a6a-b5cd-e91fe91c1ef8'::uuid;
update public.opsi_soal set teks_en='Because -> it runs faster' where id='332c6a3f-3b9b-4ec2-a00f-2aae82e2457f'::uuid;
update public.opsi_soal set teks_en='0 0' where id='c71d8b9a-6c69-4b46-809c-5087892bc2f4'::uuid;
update public.opsi_soal set teks_en='Both copy values' where id='c8a85407-295d-49fd-aec7-b4545c23fbad'::uuid;
update public.opsi_soal set teks_en='A pointer that points to freed memory' where id='c8e62b45-474b-40fb-9bec-f6dfb71be281'::uuid;
update public.opsi_soal set teks_en='Default fields will be overwritten' where id='c903094b-ee07-4ec0-b066-c46f973df2b6'::uuid;
update public.opsi_soal set teks_en='Nothing is automatic' where id='c9c1f923-15fc-44a1-be5e-3e1bf7988f0f'::uuid;
update public.opsi_soal set teks_en='Rani' where id='c9d3fdd3-ef92-49dc-8847-3239c7c8bcd7'::uuid;
update public.opsi_soal set teks_en='int m[4][3];' where id='c9e74420-db26-4dc6-8a25-1f12671aac75'::uuid;
update public.opsi_soal set teks_en='Python is slow for all loop operations' where id='cafa8298-8e82-4ee9-978d-583a24210dab'::uuid;
update public.opsi_soal set teks_en='Nothing happened' where id='cb27393f-f94b-43dd-b9a5-4a06080cc3d4'::uuid;
update public.opsi_soal set teks_en='Array elements are stored based on their values' where id='cb39c1f0-ea39-4a93-abcf-67c225d4ec19'::uuid;
update public.opsi_soal set teks_en='Variable name' where id='cba826a8-6e6b-40de-8161-6b8805af9fc4'::uuid;
update public.opsi_soal set teks_en='Error' where id='cbede891-8192-4c3c-a054-4f06398d1c02'::uuid;
update public.opsi_soal set teks_en='4' where id='ce1f1c35-21e1-4c46-a08d-fcb80989f563'::uuid;
update public.opsi_soal set teks_en='20' where id='ce843c03-49b9-4736-834a-dabb774fc405'::uuid;
update public.opsi_soal set teks_en='When you need an array with indices starting from 1' where id='cf5dac66-bb3b-4b3e-a4d4-272e81f40787'::uuid;
update public.opsi_soal set teks_en='16' where id='cf5efd97-f69d-4188-bf50-624757370412'::uuid;
update public.opsi_soal set teks_en='int* arr = new int(5);' where id='d07b7a2a-2a9a-4657-8fde-cc88966f88a0'::uuid;
update public.opsi_soal set teks_en='99' where id='d0906e7e-148e-4d37-9f8a-761e351b4d46'::uuid;
update public.opsi_soal set teks_en='Because the compiler refuses' where id='d1504fce-1ac0-4bf7-850d-f49459be615e'::uuid;
update public.opsi_soal set teks_en='Memory freed twice' where id='d1719ff9-78fe-47a8-a52d-3e4a6e3dc534'::uuid;
update public.opsi_soal set teks_en='Prevents dangling pointers and makes the second delete safe' where id='d18d696f-80fb-4de8-ae5f-7c12c31dabfa'::uuid;
update public.opsi_soal set teks_en='100' where id='d2020d24-b7e6-48be-ac41-634f133bd98e'::uuid;
update public.opsi_soal set teks_en='Only a is a pointer; b is a regular int' where id='d236b9a4-9452-49c0-827f-01468b5f4201'::uuid;
update public.opsi_soal set teks_en='Can''t do it in C++' where id='d23c2b32-47da-4e2e-9669-47633bd431f5'::uuid;
update public.opsi_soal set teks_en='20' where id='d266dfdd-8ad7-40b0-aa5f-08e0f9e03fa9'::uuid;
update public.opsi_soal set teks_en='Delete two elements at once' where id='d33d5fcb-a563-4455-afd5-d22f4e537338'::uuid;
update public.opsi_soal set teks_en='999' where id='d340bc8d-e47e-40a3-aa37-6bcecdeb36dc'::uuid;
update public.opsi_soal set teks_en='Delete an array with regular delete' where id='028f129e-6b6e-48e1-a2ca-e5147e929004'::uuid;
update public.opsi_soal set teks_en='Automatic with reference counting, plus garbage collector for reference cycles' where id='149d009e-6c53-418d-9d57-18c0b6673e4a'::uuid;
update public.opsi_soal set teks_en='The pointer is nullptr' where id='1a4804c0-b3cb-4658-a430-a2bdb67142d9'::uuid;
update public.opsi_soal set teks_en='Deletes unallocated pointers' where id='1c2a16cf-4e35-4be1-9bfc-012dc372344f'::uuid;
update public.opsi_soal set teks_en='Because delete requires a nullptr value' where id='2731bd37-fb94-4dc6-8904-0747693c7c26'::uuid;
update public.opsi_soal set teks_en='Immovable pointer' where id='2cb95be8-2d04-4372-8442-625bf8b97348'::uuid;
update public.opsi_soal set teks_en='Use regular value: void print(Student m)' where id='d417c8ac-9e18-4930-a572-12e8145bb02f'::uuid;
update public.opsi_soal set teks_en='1' where id='d48bd39c-d17f-4b49-8c01-a7ab8228d390'::uuid;
update public.opsi_soal set teks_en='3' where id='d51adb9b-c05d-4101-99e3-7b904ecef1e4'::uuid;
update public.opsi_soal set teks_en='std::span stores the pointer AND the size at the same time' where id='d5b1e6b8-eb91-48d3-b7bb-2a00546666bd'::uuid;
update public.opsi_soal set teks_en='-> only for arrays' where id='d6285e18-f0ef-4698-ba1a-e8406c833484'::uuid;
update public.opsi_soal set teks_en='Padding is reduced when small members are grouped side by side, usually achieved by sorting' where id='d6e29eaf-10e0-4380-aecb-afdfea12d38c'::uuid;
update public.opsi_soal set teks_en='Because nullptr cannot be accessed' where id='d6f77b7a-1b07-4b65-89af-42e82cd9736d'::uuid;
update public.opsi_soal set teks_en='Compilation error' where id='d72b1750-f9f1-4b29-bb01-083bc8820c49'::uuid;
update public.opsi_soal set teks_en='0' where id='d8103892-0b58-4e12-ac19-0827f287e7b1'::uuid;
update public.opsi_soal set teks_en='Because it contains a random address (wild pointer), and dereferencing it is UB' where id='da0bba28-d0b2-4411-8847-3c3181dfa413'::uuid;
update public.opsi_soal set teks_en='(*pt).x and pt->x' where id='dacdb7f8-f472-4c98-adc2-364e1a72d896'::uuid;
update public.opsi_soal set teks_en='8' where id='dc404a2f-2dfd-416b-8c29-2876299f5941'::uuid;
update public.opsi_soal set teks_en='int arr[3] = {1, 2, 3};' where id='de1c4633-46a4-4d9f-b89a-59de9089d932'::uuid;
update public.opsi_soal set teks_en='When the struct contains an array' where id='de753dbc-3555-4323-aeb9-c2de4c324609'::uuid;
update public.opsi_soal set teks_en='Because structs can''t be copied' where id='df27f532-8353-47b7-bc26-67a973bc87d8'::uuid;
update public.opsi_soal set teks_en='m. city' where id='df4e1b32-27c6-450b-aefe-d3834bd9bcae'::uuid;
update public.opsi_soal set teks_en='The m[j][i] access jumps between rows, not sequentially' where id='df669495-d779-45ed-b808-0871f5794406'::uuid;
update public.opsi_soal set teks_en='A struct cannot have members of type struct' where id='e0860403-cc78-453a-8127-07868f293514'::uuid;
update public.opsi_soal set teks_en='Always crashes' where id='e12bb909-ef71-42e8-a949-c418dd60ddcd'::uuid;
update public.opsi_soal set teks_en='size is always bigger than capacity' where id='e13d2a5b-a7c2-4ad5-80f0-378a55307766'::uuid;
update public.opsi_soal set teks_en='C++ and Python both copy references' where id='e17c702d-c761-4689-b1e2-f2ab085ccd78'::uuid;
update public.opsi_soal set teks_en='6' where id='e1937a13-3fe8-498c-94ae-4e2de4f4aadf'::uuid;
update public.opsi_soal set teks_en='IndexError' where id='e1ce70c0-2af8-452f-a60e-6f15ef99a950'::uuid;
update public.opsi_soal set teks_en='Python copies values; C++ copies references' where id='e2688d1b-754b-450e-a8c5-673950548e16'::uuid;
update public.opsi_soal set teks_en='To save memory usage' where id='e2914486-1dce-41d3-9e0e-d64634791d6f'::uuid;
update public.opsi_soal set teks_en='1' where id='e335d2f0-209f-4ab5-acb0-aa2396db7e3a'::uuid;
update public.opsi_soal set teks_en='int* p = malloc(4);' where id='e340c6da-45fe-481c-9897-68c7c59932fb'::uuid;
update public.opsi_soal set teks_en='Pointers for arrays only' where id='e3af9b73-0b1c-4081-ba31-a3737aaabcab'::uuid;
update public.opsi_soal set teks_en='class.sort(ipk);' where id='e41d7286-f677-4a5c-bd3a-752fa5d84da1'::uuid;
update public.opsi_soal set teks_en='Image' where id='e41fb20c-def2-49ff-812b-b123859d294d'::uuid;
update public.opsi_soal set teks_en='Automatic array zoom' where id='e42107df-ddf5-4c2a-813d-a23efc7f73a9'::uuid;
update public.opsi_soal set teks_en='Allocate space for n elements so no re-allocation is needed' where id='e48cca91-7b4a-4034-8913-651fd37458e4'::uuid;
update public.opsi_soal set teks_en='The local variable no longer exists after the function completes, the pointer becomes dangling, and uses UB' where id='e4b41504-15c9-44ce-b5bc-00300da374de'::uuid;
update public.opsi_soal set teks_en='Compilation error' where id='e4bc0b94-793d-437d-b6dd-bf1265222db8'::uuid;
update public.opsi_soal set teks_en='The default struct is public, the default class is private' where id='e5b9ec46-c79a-494b-bb4e-fd48470abcc7'::uuid;
update public.opsi_soal set teks_en='double total = 0; for (int i = 0; i < 3; i++) { total += list[i].price; }' where id='e5c72763-b937-41ac-a05f-d18284a2375e'::uuid;
update public.opsi_soal set teks_en='4' where id='e60641fd-295b-4763-82ef-be71665493e9'::uuid;
update public.opsi_soal set teks_en='i[arr] is actually invalid' where id='e6d1f1fe-0063-4e48-bca7-7a006815fbfa'::uuid;
update public.opsi_soal set teks_en='C++ copies the entire value; Python only copies references' where id='e6f71dc5-26a6-46c5-a89a-d2f71f0f6dc1'::uuid;
update public.opsi_soal set teks_en='AoS can only store primitive types' where id='348aae4b-b76c-4f8c-912f-cf5dbf3dc9fb'::uuid;
update public.opsi_soal set teks_en='address(0) + i' where id='353464d2-3b1f-4337-9410-cee4eef01b1b'::uuid;
update public.opsi_soal set teks_en='double total = list.price;' where id='357ed5bf-bccf-442e-87d7-824747f9b281'::uuid;
update public.opsi_soal set teks_en='Program crashes instantly' where id='37bdb177-3ccf-4f02-9e50-54a252482eb4'::uuid;
update public.opsi_soal set teks_en='Because arr[i] becomes *(arr + i) and addition is commutative' where id='38e24e80-5de3-48e0-95b6-2239d11e88b9'::uuid;
update public.opsi_soal set teks_en='int m[3,4];' where id='391fa0ac-11bb-4f09-8384-ea7a1d9be72c'::uuid;
update public.opsi_soal set teks_en='Bandung' where id='394b483d-69a8-472e-8a9f-c1f115633cd9'::uuid;
update public.opsi_soal set teks_en='Changed member types to be uniform' where id='39f5e8c5-c455-455e-905a-5909e6a08cc4'::uuid;
update public.opsi_soal set teks_en='Error' where id='3ad0286c-ce60-4c41-b877-196a4c1799ff'::uuid;
update public.opsi_soal set teks_en='24 16' where id='3b65b373-389b-4c66-928c-0a218b032be1'::uuid;
update public.opsi_soal set teks_en='address(0,0) + (i x numberofColumns + j) x sizeof(Type)' where id='3c53530a-6927-422c-8493-8f1383649dc7'::uuid;
update public.opsi_soal set teks_en='int p = new int;' where id='3d8ea488-84b8-4bf8-a4f3-aa7774fff8fe'::uuid;
update public.opsi_soal set teks_en='Variables i and j have changed names' where id='3dd1ca7e-db82-4640-bb75-3b1dae477958'::uuid;
update public.opsi_soal set teks_en='int* p = &x;' where id='3ee7133e-0dcd-4553-a662-83f2d8d51aaf'::uuid;
update public.opsi_soal set teks_en='m.address.city' where id='3fd3a51a-62a2-4ab7-81a0-4ae43facc9e8'::uuid;
update public.opsi_soal set teks_en='Smart pointer with shared ownership' where id='406c10f7-dc03-44dc-afb4-4a81df2c6c23'::uuid;
update public.opsi_soal set teks_en='When size is unknown during compilation or need to add/subtract elements' where id='40ad8715-3b30-46a2-b6de-c9d3cbdcd943'::uuid;
update public.opsi_soal set teks_en='Manual with new and delete' where id='40bca610-dd38-46f5-bf00-78c256bad5a6'::uuid;
update public.opsi_soal set teks_en='Padding cannot be reduced in any way' where id='414c841a-0dd1-45a8-971e-99c5e8755dfa'::uuid;
update public.opsi_soal set teks_en='Because pointers store data types' where id='427bd391-71d7-4876-a988-ecbb23822231'::uuid;
update public.opsi_soal set teks_en='Both cannot copy nested structs' where id='43a3cb0d-e59f-463f-aec6-a1c6f563d349'::uuid;
update public.opsi_soal set teks_en='Error' where id='440201ec-9fe6-4152-b926-3f678dc5065b'::uuid;
update public.opsi_soal set teks_en='4' where id='44a17ab8-e751-4f5f-bd6f-c5bbd52adf15'::uuid;
update public.opsi_soal set teks_en='Need to add a semicolon at the end' where id='f5c18c96-b77d-45ad-925e-a4c6975d1d05'::uuid;
update public.opsi_soal set teks_en='Byte padding whose contents are not necessarily written, the data can be confused on other platforms' where id='f69b2c41-c619-4fbc-86b4-e9d5a0678c6f'::uuid;
update public.opsi_soal set teks_en='AoS is more memory efficient than SoA' where id='f90bf831-598b-4492-9027-ab4f1d373b88'::uuid;
update public.opsi_soal set teks_en='The struct does not compile' where id='f9a7e0ec-6a4e-4f7b-a7b6-c909308490a2'::uuid;
update public.opsi_soal set teks_en='Because computer memory always doubles' where id='fa585413-1d25-4451-91ff-084d73a32aaf'::uuid;
update public.opsi_soal set teks_en='v[i] does not check bounds; v.at(i) checks and throws an exception' where id='fc4c22a3-5677-4a04-a217-4cd186e31d16'::uuid;
update public.opsi_soal set teks_en='1' where id='fc517905-bc8f-40ad-b1e9-70f5be8bb54c'::uuid;
update public.opsi_soal set teks_en='Item list(3) = {{"Books",25000}};' where id='fc7d56c5-b144-40db-bf1c-90a796533d47'::uuid;
update public.opsi_soal set teks_en='Error' where id='fd284107-65ae-43e5-a48c-0650b36c68ff'::uuid;
update public.opsi_soal set teks_en='50' where id='fd67f903-c26a-4151-997f-3f8a540828f2'::uuid;
update public.opsi_soal set teks_en='The compiler rejects the code and the build fails' where id='fdbc2b05-3433-4d0d-9e43-cd6e611026f4'::uuid;
update public.opsi_soal set teks_en='SoA cannot be sorted' where id='fe2fc6e3-6bda-4150-b711-faa43cbfcff9'::uuid;
update public.opsi_soal set teks_en='10' where id='feae1fba-964b-4633-8009-69c72cee461a'::uuid;
update public.opsi_soal set teks_en='Memory address, not direct value' where id='ffe5adf9-1f4d-41d4-8454-0527bc21cc79'::uuid;
update public.opsi_soal set teks_en='Old memories are automatically enlarged in place' where id='7a4a0eee-f165-44d6-a8f0-af840995c00d'::uuid;
update public.opsi_soal set teks_en='pt.x and pt->x' where id='7a62214e-909a-4ccb-a52d-343c3e25c691'::uuid;
update public.opsi_soal set teks_en='4 bytes - size of one int' where id='7aeaa1f5-3947-4162-8e0f-d24429bfd702'::uuid;
update public.opsi_soal set teks_en='structs can only store primitive types' where id='7b079e7d-cc6f-4ae4-a0e3-d24e667d4617'::uuid;
update public.opsi_soal set teks_en='insert uses more memory' where id='7d28eb42-61c1-44bb-8bc1-6e95403f090e'::uuid;
update public.opsi_soal set teks_en='Both are managed automatically' where id='7e05abcd-5707-4c7a-b00e-2f2d36d831bf'::uuid;
update public.opsi_soal set teks_en='To make it easier for the compiler to read the code' where id='7ff1a5a4-8041-4bb3-baf8-dbbff4113ad0'::uuid;
update public.opsi_soal set teks_en='Error' where id='809b93a0-c845-434d-aff1-bed95d489c2b'::uuid;
update public.opsi_soal set teks_en='std::span is only for char arrays' where id='80d317eb-9709-472c-81b3-bb64ec13f6f8'::uuid;
update public.opsi_soal set teks_en='Array elements are stored based on input order' where id='ba8a44fa-cc38-4235-bbd9-b3063310f0c1'::uuid;
update public.opsi_soal set teks_en='16' where id='bac60a2d-f11b-4bec-8ee2-77e56071e32c'::uuid;
update public.opsi_soal set teks_en='Because the compiler repairs the sequence automatically' where id='baf68390-4567-4aa7-ad2e-5a1e05a618c6'::uuid;
update public.opsi_soal set teks_en='size and capacity are always the same' where id='bb785e32-7eef-433a-ab13-38b9bc630dea'::uuid;
update public.opsi_soal set teks_en='Error' where id='bc8e71a9-78b4-4ecf-885e-e79560625a8e'::uuid;
update public.opsi_soal set teks_en='8' where id='bd075185-a3c3-423a-b392-5817354d8c25'::uuid;
update public.opsi_soal set teks_en='4' where id='bd88a2bf-7619-4550-a1b4-ef470572f0a4'::uuid;
update public.opsi_soal set teks_en='There is no difference at all' where id='be3c7c45-2cc6-429f-a8b1-0829136f1d85'::uuid;
update public.opsi_soal set teks_en='Because (*pt).x is a pain to write and the brackets are easy to forget' where id='be4de011-c9a8-4f27-90c3-2c87593c9261'::uuid;
update public.opsi_soal set teks_en='10' where id='beb04f8a-4312-4ffe-9398-a3035baae333'::uuid;
update public.opsi_soal set teks_en='Uninitialized pointer' where id='bfafb3e6-89fd-4292-9b36-84151482f570'::uuid;
update public.opsi_soal set teks_en='range() is inefficient' where id='c14a733a-a17f-4212-8ff0-7be92bc26a26'::uuid;
update public.opsi_soal set teks_en='Stacks are managed automatically and quickly; the heap is managed manually and is slower' where id='c42505ef-f17d-4858-a80c-687a2ce4e468'::uuid;
update public.opsi_soal set teks_en='Structs cannot be copied' where id='c439b981-1e56-4139-be6b-751444adeed3'::uuid;
update public.opsi_soal set teks_en='So that memory is freed up more quickly' where id='c4756fc8-2486-44d8-8786-1e3f23fed2f7'::uuid;
update public.opsi_soal set teks_en='Because pointers are easier to read' where id='c55a2240-920f-4b64-a945-c58918fc1f07'::uuid;
update public.opsi_soal set teks_en='The file becomes too large' where id='c63f26a9-a39e-495c-8b6b-59849cacf364'::uuid;
update public.opsi_soal set teks_en='Trash value' where id='c6651938-8619-4627-8d79-b49e27d5b08e'::uuid;
update public.opsi_soal set teks_en='. for pointers; -> for value' where id='e73cb7e7-8378-4d42-8b1d-c9221f4e68dd'::uuid;
update public.opsi_soal set teks_en='2' where id='e747edfa-5e84-412b-ad19-04fe8210933d'::uuid;
update public.opsi_soal set teks_en='dataclass with @dataclass decorator' where id='e7bc967b-7f1c-4af8-828b-92ddb621dd4a'::uuid;
update public.opsi_soal set teks_en='Only frees the first element' where id='e7c29358-e871-49f5-bfcc-9ff8ab518560'::uuid;
update public.opsi_soal set teks_en='So that the compiler does not give warnings' where id='e9b05eaf-5aa0-4834-8dfe-2b9afe258fe7'::uuid;
update public.opsi_soal set teks_en='30' where id='e9f97bb6-2671-466d-94c3-316c5f1b0f78'::uuid;
update public.opsi_soal set teks_en='Both can be used interchangeably' where id='ea4f930a-4419-473c-91fe-58fce41de21f'::uuid;
update public.opsi_soal set teks_en='Item list[3] = {{"Books",25000},{"Pens",3000},{"Bags",150000}};' where id='ea8c76a8-a2f0-4fa8-aa9f-248c4c14bd65'::uuid;
update public.opsi_soal set teks_en='It''s slower, not as portable, and can crash on ARM' where id='eabb4f29-f421-4758-96a0-c3f43d3f44a5'::uuid;
update public.opsi_soal set teks_en='1' where id='eac83034-d95d-43b6-a85c-1608842474ff'::uuid;
update public.opsi_soal set teks_en='Because it avoids copying the entire struct' where id='ebccae87-d2b2-4072-a462-cc5b434080b1'::uuid;
update public.opsi_soal set teks_en='8' where id='ecb65fc1-45b2-4b17-9eb4-6021ca7c9eaa'::uuid;
update public.opsi_soal set teks_en='&arr is not valid for arrays' where id='ecc3e997-ad4c-41ea-ae88-aa0e760fd789'::uuid;
update public.opsi_soal set teks_en='The program will crash while writing' where id='ed66d537-7627-4143-ad65-8e31ea612229'::uuid;
update public.opsi_soal set teks_en='Sort members automatically' where id='eddca42c-8711-4cd7-ba9c-e22e90009cc1'::uuid;
update public.opsi_soal set teks_en='Limiting vectors to a maximum of n elements' where id='ee974789-3975-4c04-9453-d3dcaed6b816'::uuid;
update public.opsi_soal set teks_en='Cannot be made irreversible' where id='eed17237-5487-4c4f-b60b-51826aaf5d3f'::uuid;
update public.opsi_soal set teks_en='int m[12];' where id='eeec7f13-bc6a-46a4-a540-b8dec692d56b'::uuid;
update public.opsi_soal set teks_en='classes cannot have constructors' where id='ef754769-8c77-46a5-a37e-35658501d42c'::uuid;
update public.opsi_soal set teks_en='Error' where id='effa38d1-7d17-4b41-977b-8a1aaf2cc197'::uuid;
update public.opsi_soal set teks_en='Rani' where id='f00aad2d-ba34-4cb9-ba78-a98214718ad7'::uuid;
update public.opsi_soal set teks_en='Removal of unused arrays' where id='f0632a91-c3bf-48b5-bd52-a4423ad91894'::uuid;
update public.opsi_soal set teks_en='Vector creates a new vector and deletes the old one' where id='f069a03a-b43b-40d4-a2cd-5c124ffa4a41'::uuid;
update public.opsi_soal set teks_en='Forces the compiler to reduce or eliminate padding' where id='f070e70c-480b-4e84-a614-de755952acaa'::uuid;
update public.opsi_soal set teks_en='sorted(class, GPA, True)' where id='f0baa314-7a4a-439f-83e2-702df2ffb69f'::uuid;
update public.opsi_soal set teks_en='int arr[5] = new int[5];' where id='f134946a-7e9c-4c4b-abe9-a02c75731529'::uuid;
update public.opsi_soal set teks_en='Fills a vector with n zero-valued elements' where id='f1471a34-051e-4778-aece-42288e007278'::uuid;
update public.opsi_soal set teks_en='Just __init__' where id='f16e42c3-c3f9-4b1f-be0c-246e45b6d1c5'::uuid;
update public.opsi_soal set teks_en='Structs cannot be written to files' where id='f2ae4f69-ee06-4048-b57a-f36a3e5cd7f1'::uuid;
update public.opsi_soal set teks_en='No, they are both different' where id='f2c161dc-def7-4288-a3e7-ac169cee5de2'::uuid;
update public.opsi_soal set teks_en='Heap memory that is not freed because you forgot to delete it' where id='f578ffad-2505-4865-b4c3-726994fd20b5'::uuid;
update public.opsi_soal set teks_en='5' where id='f89aede8-96b8-4742-8c05-e59deef20e59'::uuid;
commit;

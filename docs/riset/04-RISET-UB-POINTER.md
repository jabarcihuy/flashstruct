# RISET 04 — Verifikasi Klaim Undefined Behavior (UB) pada Pointer C++

**Tanggal riset:** 2025
**Tujuan:** Verifikasi setiap klaim UB pointer terhadap **sumber primer** sebelum dipakai sebagai materi edukasi Struktur Data.
**Sumber primer yang dipakai:**
- C++ Working Draft (eel.is/c++draft) — teks normatif standar C++ terkini
- Versi standar terbit: N3337 (C++11), N4659 (C++17), N4950 (C++23) — via timsong-cpp.github.io/cppwp
- cppreference.com (snapshot arsip Wayback Machine, karena situs memblokir akses langsung)
- C standard: N1570 (C11) dan N3096 (C23 working draft) — untuk klaim perbandingan C vs C++
- Dokumentasi Clang (UBSan) dan GCC

> **Catatan metodologi:** kutipan diambil persis (verbatim) dari halaman yang ditautkan. Untuk cppreference, tautan mengarah ke halaman asli; snapshot arsip dicantumkan karena akses langsung diblokir Cloudflare saat riset dilakukan.

---

## Ringkasan Status 12 Klaim

| # | Klaim | Status | Ringkas |
|---|-------|--------|---------|
| 1 | Dereferensi `nullptr` adalah UB | **BENAR** | UB eksplisit. Ada pengecualian khusus `typeid(*p)`. "Bisa jalan" ≠ terdefinisi |
| 2 | `p + 1` melewati satu elemen terakhir array adalah UB | **SALAH** | Membentuk pointer one-past-the-end **legal**. Yang UB adalah melewati *lebih dari* satu langkah |
| 3 | Dereferensi pointer one-past-the-end adalah UB | **BENAR** | UB karena pointer tidak menunjuk objek |
| 4 | Membandingkan pointer array berbeda dengan `<`/`>` adalah UB | **BENAR DENGAN CATATAN** | Di C++ hasilnya **unspecified**, bukan UB. Di C baru UB. `==` punya aturan berbeda |
| 5 | Mengakses memori lewat pointer setelah `delete` adalah UB | **BENAR** | UB untuk indirection/deallocation. Nilai pointer sendiri masih boleh dibaca (implementation-defined) |
| 6 | `delete` dua kali pada pointer yang sama adalah UB | **BENAR** | UB eksplisit (contoh resmi Annex F.2.17) |
| 7 | Campur `new`/`delete` dengan `new[]`/`delete[]` adalah UB | **BENAR** | UB eksplisit, ada dua entri Annex F terpisah (F.3.22, F.3.23) |
| 8 | Lupa `delete` **bukan** UB, hanya memory leak | **BENAR** | Tidak ada aturan UB untuk leak. Perlu catatan untuk kasus khusus |
| 9 | Membaca variabel lokal belum diinisialisasi adalah UB | **BENAR DENGAN CATATAN** | UB di C++ (kecuali `unsigned char`/`std::byte`). C++26 mengubahnya jadi *erroneous behavior*. C lebih sempit lagi |
| 10 | Memakai pointer ke variabel lokal yang sudah keluar scope adalah UB | **BENAR** | UB saat *diakses*, bukan saat pointer disimpan/disalin |
| 11 | `memcmp` pada struct dengan padding bisa memberi hasil salah | **BENAR DENGAN CATATAN** | Bukan UB — hanya hasil tak dapat diandalkan. Padding = *unspecified value*, bukan "indeterminate" |
| 12 | Setelah `delete`, pointer tidak otomatis `nullptr`; mengaksesnya UB | **BENAR** | Standar tidak mengubah nilai pointer. Tapi "mengaksesnya UB" terlalu umum — harus dipilah |

**Rekap:** 8 BENAR (klaim 1, 3, 5, 6, 7, 8, 10, 12), 3 BENAR DENGAN CATATAN (klaim 4, 9, 11), 1 SALAH (klaim 2). Total 12 klaim.

---

## 1. Dereferensi `nullptr`

**Status: BENAR**

### Kutipan sumber primer

Standar C++ draft, [\[expr.unary.op\]/1](https://eel.is/c++draft/expr.unary.op):

> "The unary `*` operator performs *indirection*. Its operand shall be a prvalue of type "pointer to T", where T is an object or function type. The operator yields an lvalue of type T. **If the operand points to an object or function, the result denotes that object or function; otherwise, the behavior is undefined** except as specified in [\[expr.typeid\]]"

Annex F (Core undefined behavior), [\[ub:expr.unary.dereference\]](https://eel.is/c++draft/ub:expr.unary.dereference):

> "Dereferencing a pointer that does not point to an object or function has undefined behavior."

Contoh normatif dari standar itu sendiri:

> ```cpp
> int f() {
>   int *p = nullptr;
>   return *p;            // undefined behavior
> }
> ```

cppreference — [Pointer declaration § Null pointers](https://en.cppreference.com/w/cpp/language/pointer):

> "A pointer whose value is null does not point to an object or a function (the behavior of dereferencing a null pointer is undefined), and compares equal to all pointers of the same type whose value is also null."

cppreference — [Undefined behavior § Null pointer dereference](https://en.cppreference.com/w/cpp/language/ub):

> "The examples demonstrate reading from the result of dereferencing a null pointer."
> ```cpp
> int foo(int* p) {
>   int x = *p;
>   if (!p) return x;   // Either UB above or this branch is never taken
>   else return 0;
> }
> ```

### Nuansa yang perlu ditambahkan

1. **Satu pengecualian eksplisit:** `typeid(*p)` di mana `p` bernilai null **bukan** UB — ia melempar `std::bad_typeid`. Lihat [\[expr.typeid\]/3](https://eel.is/c++draft/expr.typeid): *"If an expression operand of typeid is a possibly-parenthesized unary-expression whose unary-operator is `*` and whose operand evaluates to a null pointer value, the typeid expression throws an exception ... of type std::bad_typeid."* Ini kasus yang sangat jarang muncul di materi kuliah dan aman untuk diabaikan, tetapi bagus disebut sebagai catatan kaki kejujuran.

2. **"Program tidak crash" tidak berarti terdefinisi.** UB berarti standar tidak memberi persyaratan apa pun. [\[defns.undefined\]](https://eel.is/c++draft/defns.undefined) menyatakan rentangnya: *"Permissible undefined behavior ranges from ignoring the situation completely with unpredictable results, to behaving during translation or program execution in a documented manner characteristic of the environment ..., to terminating a translation or execution."* Jadi program "kelihatan jalan" sepenuhnya konsisten dengan UB.

3. **Bahaya optimisasi nyata.** GCC mendokumentasikan asumsinya secara terbuka di [Optimize Options § `-fdelete-null-pointer-checks`](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html):
   > "Assume that programs cannot safely dereference null pointers, and that no code or data element resides at address zero. ... other optimization passes in GCC use this flag to control global dataflow analyses that eliminate useless checks for null pointers; **these assume that a memory access to address zero always results in a trap, so that if a pointer is checked after it has already been dereferenced, it cannot be null.**"
   Ini persis alasan mengapa contoh `int foo(int* p)` di atas bisa dioptimisasi menjadi tidak memeriksa `p` sama sekali. Sangat baik untuk didemokan ke mahasiswa.

4. **Kaitan dengan member access.** `p->member` secara semantik adalah `(*(p)).member` ([\[expr.ref\]](https://eel.is/c++draft/expr.ref): *"The expression `E1->E2` is converted to the equivalent form `(*(E1)).E2`"*), sehingga dereferensi null lewat `->` juga UB.

---

## 2. Aritmetika pointer di luar batas

**Status: SALAH** (sebagaimana dirumuskan di klaim)

Klaim menyatakan *"Melakukan aritmetika pointer (mis. `p + 1`) sampai melewati satu elemen terakhir array adalah undefined behavior."* Ini **salah**: membentuk pointer **one-past-the-end adalah legal**. Yang UB adalah melangkah **lebih jauh** dari itu.

### Kutipan sumber primer

Standar C++ draft, [\[expr.add\]/4](https://eel.is/c++draft/expr.add):

> "When an expression J that has integral type is added to or subtracted from an expression P of pointer type, the result has the type of P.
> - If P evaluates to a null pointer value and J evaluates to 0, the result is a null pointer value.
> - Otherwise, if P points to a (possibly-hypothetical) array element *i* of an array object *x* with *n* elements, the expressions `P + J` and `J + P` (where J has the value *j*) point to the (possibly-hypothetical) array element *i+j* of x **if 0 ≤ i+j ≤ n** and the expression `P - J` points to the (possibly-hypothetical) array element *i−j* of x **if 0 ≤ i−j ≤ n**.
> - **Otherwise, the behavior is undefined.**"

Perhatikan batas atasnya: **`i+j ≤ n`**, bukan `i+j < n`. Nilai `i+j == n` berarti pointer sah ke satu elemen setelah elemen terakhir.

Standar C++ draft, [\[basic.compound\]/3](https://eel.is/c++draft/basic.compound):

> "Every value of pointer type is one of the following:
> - a *pointer to* an object or function (the pointer is said to *point* to the object or function), or
> - **a *pointer past the end of* an object**, or
> - the *null pointer value* for that type, or
> - an *invalid pointer value*.
>
> A value of a pointer type that is a pointer to or past the end of an object *represents the address* of the first byte in memory occupied by the object or **the first byte in memory after the end of the storage occupied by the object**, respectively."

Jadi "pointer past the end" adalah kategori nilai pointer yang **sah dan bernama**, bukan bentuk UB.

cppreference — [Arithmetic operators § Pointer arithmetic](https://en.cppreference.com/w/cpp/language/operator_arithmetic):

> "The expressions `P + J` and `J + P`
> - point to the *i+j*th element of x if *i + j* is in `[​0​, n)`, and
> - **are pointers past the end of the last element of x if *i + j* is n.**
>
> **Other j values result in undefined behavior.**"

### Contoh normatif dari standar

Standar C++ draft, [\[expr.unary.op\]/3](https://eel.is/c++draft/expr.unary.op) memberi contoh yang secara eksplisit menyebut *defined behavior*:

> ```cpp
> int a;
> int* p1 = &a;
> int* p2 = p1 + 1;   // defined behavior
> bool b = p2 > p1;   // defined behavior, with value true
> ```

Catatan: di sini `a` adalah objek non-array, tetapi [\[basic.compound\]/3](https://eel.is/c++draft/basic.compound) mengaturnya: *"an object of type T that is not an array element is considered to belong to an array with one element of type T"*. Jadi objek tunggal pun punya "satu-past-the-end" yang sah.

### Nuansa yang perlu ditambahkan

1. **Bedakan tiga hal berbeda:**
   - **Membentuk** pointer one-past-the-end (`p + n`) → **legal, well-defined**
   - **Menyimpan/menyalin/membandingkan** pointer one-past-the-end → **legal** (untuk perbandingan, lihat klaim 4)
   - **Mendereferensi** pointer one-past-the-end → **UB** (lihat klaim 3)

2. **Batas satu langkah, bukan "sampai n".** Untuk pointer yang sudah berada di posisi one-past-the-end, `p + 1` **lagi** adalah UB. cppreference menyatakannya: *"Otherwise, if P is a pointer past the end of an object z ... Other j values result in undefined behavior."*

3. **Catatan penting untuk non-array:** [\[expr.add\]/4 Note 1](https://eel.is/c++draft/expr.add) — *"Adding a value other than 0 or 1 to a pointer to a base class subobject, a member subobject, or a complete object results in undefined behavior."* Untuk objek tunggal (bukan elemen array), hanya `+0` dan `+1` yang sah.

4. **Riwayat:** cppreference mencatat CWG 2853 — *"a pointer past the end of an object could not be added or subtracted with an integer → it can"*. Wording lama memang lebih membingungkan, jadi klaim yang salah ini historis bisa dimengerti.

5. **Kaitkan dengan idiom loop.** `for (p = arr; p != arr + n; ++p)` sah justru karena `arr + n` legal dibentuk dan dibandingkan. Ini alasan teknis mengapa idiom tersebut standar, dan mengapa mengubahnya menjadi `p < arr + n + 1` justru **memperkenalkan** UB.

---

## 3. Dereferensi pointer one-past-the-end

**Status: BENAR**

### Kutipan sumber primer

Standar C++ draft, [\[expr.unary.op\]/1](https://eel.is/c++draft/expr.unary.op):

> "The operator yields an lvalue of type T. **If the operand points to an object or function, the result denotes that object or function; otherwise, the behavior is undefined** ..."

Pointer one-past-the-end **tidak menunjuk ke objek mana pun** — [\[basic.compound\]/3 Note 2](https://eel.is/c++draft/basic.compound):

> "A pointer past the end of an object is **not considered to point to an unrelated object of the object's type, even if the unrelated object is located at that address**."

Karena operand tidak "points to an object or function", syarat di [\[expr.unary.op\]/1](https://eel.is/c++draft/expr.unary.op) tidak terpenuhi → UB.

cppreference — [Pointer declaration § Pointers](https://en.cppreference.com/w/cpp/language/pointer) menegaskan kategori nilai:

> "Every value of pointer type is one of the following:
> - a pointer to an object or function ..., or
> - **a pointer past the end of an object**, or
> - the null pointer value for that type, or
> - an invalid pointer value."

Hanya kategori pertama yang boleh didereferensi.

### Nuansa yang perlu ditambahkan

1. **Perbedaan `*(p+n)` vs `p[n]`.** Menurut definisi, `p[n]` ≡ `*(p+n)` (subscript operator), jadi `arr[n]` pada array berukuran `n` adalah UB yang identik. Ini sangat relevan untuk materi Struktur Data (off-by-one pada traversal).

2. **Perbedaan halus: pointer ke alamat yang sama belum tentu dereferensi-legal.** Perhatikan contoh dari [\[basic.compound\]/3 Note 2](https://eel.is/c++draft/basic.compound) dan cppreference [Pointer declaration](https://en.cppreference.com/w/cpp/language/pointer):

   > ```cpp
   > struct C { int x, y; } c;
   > int* px = &c.x;                 // value of px is "pointer to c.x"
   > int* pxe = px + 1;              // value of pxe is "pointer past the end of c.x"
   > int* py = &c.y;                 // value of py is "pointer to c.y"
   > assert(pxe == py);              // == tests if two pointers represent the same address
   >                                  // may or may not fire
   > *pxe = 1;                       // undefined behavior even if the assertion does not fire
   > ```

   Ini contoh emas untuk mengajarkan bahwa **"alamatnya sama" ≠ "boleh didereferensi"**. Pointer membawa *provenance* (asal objek), bukan sekadar angka alamat.

3. **Jangan sampai tertukar dengan klaim 2.** Materi harus secara eksplisit memisahkan "membentuk" dan "mendereferensi", karena keduanya sering digabung dalam satu kalimat yang membuat mahasiswa menyimpulkan `p + n` itu sendiri ilegal.

---

## 4. Membandingkan pointer dari array berbeda

**Status: BENAR DENGAN CATATAN**

Klaim menyatakan UB. **Di C++, hasilnya adalah *unspecified*, bukan undefined behavior.** Perbedaan ini bukan sekadar semantik — unspecified berarti program tetap well-defined dan implementasi wajib menghasilkan salah satu nilai yang diizinkan. Di **C**, baru benar-benar UB.

### Kutipan sumber primer — C++ (relasional `<`, `>`, `<=`, `>=`)

Standar C++ draft, [\[expr.rel\]/4-5](https://eel.is/c++draft/expr.rel):

> "The result of comparing unequal pointers to objects is defined in terms of a partial order consistent with the following rules:
> - If two pointers point to different elements of the same array, or to subobjects thereof, the pointer to the element with the higher subscript is required to compare greater.
> - If two pointers point to different non-static data members of the same object, ..., the pointer to the later declared member is required to compare greater ...
> - **Otherwise, neither pointer is required to compare greater than the other.**
>
> If two operands p and q compare equal ([\[expr.eq\]](https://eel.is/c++draft/expr.eq)), p<=q and p>=q both yield true and p<q and p>q both yield false. Otherwise, if a pointer to object p compares greater than a pointer q, ... **Otherwise, the result of each of the operators is unspecified.**"

cppreference — [Comparison operators § Built-in pointer relational comparison](https://en.cppreference.com/w/cpp/language/operator_comparison):

> "Built-in pointer relational comparison on unequal pointers p and q has three possible results: p is greater, q is greater and **unspecified**."
>
> "Otherwise, the result is **unspecified**."

### Kutipan sumber primer — C++ (kesetaraan `==`, `!=`)

Standar C++ draft, [\[expr.eq\]/4](https://eel.is/c++draft/expr.eq):

> "Comparing pointers is defined as follows:
> - **If one pointer represents the address of a complete object, and another pointer represents the address one past the last element of a different complete object, the result of the comparison is unspecified.**
> - Otherwise, if the pointers are both null, both point to the same function, or both represent the same address, they compare equal.
> - **Otherwise, the pointers compare unequal.**"

cppreference — [Comparison operators § Built-in pointer equality comparison](https://en.cppreference.com/w/cpp/language/operator_comparison):

> "The two pointers of the composite pointer type are compared as follows:
> - If one pointer represents the address of a complete object, and another pointer represents the address past the end of a different complete non-array object, or represents the address one past the last element of a different complete array object, the result of the comparison is **unspecified**.
> - Otherwise, if the pointers are both null, both point to the same function, or both represent the same address ..., they compare equal.
> - Otherwise, the pointers compare unequal."

**Kunci untuk `==`:** dua pointer ke array berbeda yang **bukan** kasus one-past-the-end → hasilnya **`false` secara well-defined** ("Otherwise, the pointers compare unequal"). Yang *unspecified* hanyalah kasus khusus pointer one-past-the-end dari satu array dibandingkan dengan pointer ke objek array lain — karena secara kebetulan alamatnya bisa bersebelahan.

### Kutipan sumber primer — C (untuk kontras)

C11 (N1570), 6.5.8/5:

> "When two pointers are compared, the result depends on the relative locations in the address space of the objects pointed to. ... **In all other cases, the behavior is undefined.**"

C23 (N3096), 6.5.8/6 — masih sama:

> "... **In all other cases, the behavior is undefined.**"

Jadi **klaim ini benar untuk C, tapi tidak akurat untuk C++.**

### Definisi istilah

- [\[defns.unspecified\]](https://eel.is/c++draft/defns.unspecified): *"unspecified behavior — behavior, for a well-formed program construct and correct data, that depends on the implementation. The implementation is not required to document which behavior occurs."*
- [\[defns.undefined\]](https://eel.is/c++draft/defns.undefined): *"undefined behavior — behavior for which this document imposes no requirements."*

### Nuansa yang perlu ditambahkan

1. **Status di standar lama.** Di C++11 (N3337) pun sudah *unspecified*: *"Other pointer comparisons are unspecified."* Jadi ini bukan perubahan C++20 — klaim UB memang tidak pernah benar untuk C++.

2. **Solusi praktis: `std::less`.** cppreference — [Pointer declaration](https://en.cppreference.com/w/cpp/language/pointer) dan [Comparison operators § Pointer total order](https://en.cppreference.com/w/cpp/language/operator_comparison):
   > "There exists an implementation-defined strict total order over pointers in each program. The strict total order is consistent with the partial order described above: unspecified results become implementation-defined, while other results stay the same."
   > "Pointer comparison with the strict total order is applied in the following cases: Calling the `operator()` of the pointer type specializations of `std::less`, `std::greater`, `std::less_equal`, and `std::greater_equal`. ..."
   
   Artinya `std::less<int*>()(p, q)` **dijamin** memberi urutan total, sedangkan `p < q` tidak. Ini poin praktis yang sangat berguna untuk materi Struktur Data (misalnya saat membahas pointer sebagai key di BST/`std::map`).

3. **Bahaya praktis tetap ada.** Hasil unspecified + optimisasi berarti `p < q` dan `q < p` bisa sama-sama `false`, atau bisa memberi hasil tak konsisten antar-pemanggilan. Menyebutnya "UB" dari sudut pandang *pedagogis* adalah penyederhanaan yang berbahaya karena mengajarkan istilah teknis yang salah. Sebaiknya materi memakai istilah yang tepat: **"hasilnya tidak dijamin (unspecified) — jangan dipakai untuk mengurutkan"**.

---

## 5. Menggunakan pointer setelah `delete` (dangling pointer)

**Status: BENAR** (dengan pembedaan penting)

### Kutipan sumber primer

Standar C++ draft, [\[basic.compound\]/6](https://eel.is/c++draft/basic.compound):

> "A pointer value P is *valid in the context of* an evaluation E if P is a pointer to function or a null pointer value, or if it is a pointer to or past the end of an object O and E happens after the beginning and happens before the end of the duration of the region of storage for O.
>
> If a pointer value P is used in an evaluation E and P is not valid in the context of E:
> - **If E is an indirection ([\[expr.unary.op\]]), the behavior is undefined.**
> - If E either is a boolean conversion ([\[conv.bool\]]) or is performed by a unary +, additive, three-way comparison, relational, or equality operator, **the behavior is implementation-defined.**"

Annex F, [\[ub:basic.compound.invalid.pointer\]](https://eel.is/c++draft/ub:basic.compound.invalid.pointer):

> "Indirection or the invocation of a deallocation function with a pointer value referencing storage that has been freed has undefined behavior. **(Most other uses of such a pointer have implementation-defined behavior.)**"

Contoh normatif dari standar itu sendiri:

> ```cpp
> void f() {
>   int *x = new int{5};
>   delete x;
>   int y = *x;   // undefined behavior
>   delete x;     // undefined behavior
> }
> ```

cppreference — [Pointer declaration § Invalid pointers](https://en.cppreference.com/w/cpp/language/pointer):

> "A pointer value p is valid in the context of an evaluation e if one of the following condition is satisfied:
> - p is a null pointer value.
> - p is a pointer to function.
> - p it is a pointer to or past the end of an object o, and e is in the duration of the region of storage for o.
>
> If a pointer value p is used in an evaluation e, and p is not valid in the context of e, then:
> - **If e is an indirection or an invocation of a deallocation function, the behavior is undefined.**
> - **Otherwise, the behavior is implementation-defined.**"

### Apakah nilai pointernya sendiri masih valid untuk dibaca/dibandingkan?

**Jawaban singkat: bukan UB, tetapi tidak dijamin — "implementation-defined".**

Standar C++ draft, [\[basic.stc.general\]](https://eel.is/c++draft/basic.stc):

> "After the duration of a region of storage has ended, the use of pointers to that region of storage is limited ([\[basic.compound\]](https://eel.is/c++draft/basic.compound))."

Cppreference memberi contoh persisnya:

> ```cpp
> int* ptr = f();    // the storage duration of "obj" is expired,
>                    // therefore "ptr" is an invalid pointer in the following contexts
> int* copy = ptr;   // implementation-defined behavior
> *ptr = 2;          // undefined behavior: indirection of an invalid pointer
> delete ptr;        // undefined behavior: deallocating storage from an invalid pointer
> ```

### Nuansa yang perlu ditambahkan

1. **Bukan sekadar "dibaca = UB".** Membaca **nilai** variabel pointer (mis. `int* q = p;`) adalah *implementation-defined*, bukan UB. Yang UB adalah **indirection** (`*p`, `p->x`) dan **deallocation** (`delete p`). Ini perbedaan yang harus disampaikan dengan hati-hati — jika materi menulis "mengakses pointer dangling adalah UB" tanpa kualifikasi, itu secara teknis terlalu luas.

2. **Peringatan nyata soal salinan.** Standar (dan cppreference) mencatat: *"Some implementations might define that copying an invalid pointer value causes a system-generated runtime fault."* Jadi "implementation-defined" di sini bukan berarti aman — ada implementasi yang memilih membuat penyalinan pointer invalid langsung fault.

3. **Pointer menjadi invalid saat storage duration berakhir**, bukan saat `delete` secara khusus. [\[basic.stc\]](https://eel.is/c++draft/basic.stc) versi C++17 (N4659) merumuskannya lebih eksplisit: *"When the end of the duration of a region of storage is reached, the values of all pointers representing the address of any part of that region of storage become invalid pointer values."* Jadi kasus ini mencakup juga variabel lokal yang keluar scope (klaim 10).

4. **Relevansi untuk Struktur Data.** Materi linked list / tree harus menekankan: setelah `delete node`, semua pointer lain yang menunjuk node tersebut (mis. `prev->next`, pointer di stack traversal) menjadi invalid — bukan hanya variabel yang di-`delete`. Ini sumber bug klasik *use-after-free*.

---

## 6. Double free

**Status: BENAR**

### Kutipan sumber primer

Annex F, [\[ub:basic.compound.invalid.pointer\]](https://eel.is/c++draft/ub:basic.compound.invalid.pointer):

> "Indirection or **the invocation of a deallocation function with a pointer value referencing storage that has been freed has undefined behavior.**"

Contoh normatif dari standar itu sendiri secara eksplisit menunjukkan `delete` kedua:

> ```cpp
> void f() {
>   int *x = new int{5};
>   delete x;
>   int y = *x;   // undefined behavior
>   delete x;     // undefined behavior
> }
> ```

Aturan precondition di library, [\[new.delete.single\]/10](https://eel.is/c++draft/new.delete.single):

> "*Preconditions*: ptr is a null pointer or its value represents the address of a block of memory allocated by an earlier call to a (possibly replaced) `operator new(std::size_t)` or `operator new(std::size_t, std::align_val_t)` **which has not been invalidated by an intervening call to `operator delete`**."

Dan definisi pelanggaran precondition, [\[structure.specifications\]/3.4](https://eel.is/c++draft/structure.specifications):

> "*Preconditions*: conditions that the function assumes to hold whenever it is called; **violation of any preconditions results in undefined behavior.**"

Juga, [\[basic.stc.dynamic.deallocation\]/5](https://eel.is/c++draft/basic.stc.dynamic.deallocation):

> "If the argument given to a deallocation function in the standard library is a pointer that is not the null pointer value, the deallocation function shall deallocate the storage referenced by the pointer, ending the duration of the region of storage."

### Nuansa yang perlu ditambahkan

1. **Kenapa UB dan bukan sekadar error?** Karena setelah `delete` pertama, storage sudah tidak lagi dialokasikan. `delete` kedua memanggil `operator delete` dengan pointer yang bukan (lagi) hasil alokasi aktif → melanggar precondition → UB.

2. **Tidak semua "double free" adalah UB.** Yang UB adalah memanggil `delete` dua kali pada **pointer yang sama**. Jika pointer di-`delete`, lalu variabel di-set `nullptr`, lalu `delete` lagi → **well-defined**, karena [\[basic.stc.dynamic.deallocation\]/4](https://eel.is/c++draft/basic.stc.dynamic.deallocation) menyatakan: *"The value of the first argument supplied to a deallocation function may be a null pointer value; if so, and if the deallocation function is one supplied in the standard library, the call has no effect."* Ini jembatan langsung ke klaim 12.

3. **Manifestasi di dunia nyata.** Double free sering muncul sebagai crash di allocator (`free(): double free detected in tcache 2` pada glibc) atau, lebih berbahaya, sebagai kerentanan keamanan (heap corruption). Untuk materi Struktur Data, ini alasan mengapa operasi `delete` pada linked list harus disertai pemutusan tautan dan/atau penugasan `nullptr`.

4. **Catatan versi.** Aturan precondition di [\[new.delete.single\]] adalah wording library (C++20+). Wording Annex F [\[ub:basic.compound.invalid.pointer\]] menutup kasus ini secara langsung untuk versi manapun sejak C++11.

---

## 7. Mencampur `new`/`delete` dengan `new[]`/`delete[]`

**Status: BENAR**

### Kutipan sumber primer

Standar C++ draft, [\[expr.delete\]/2](https://eel.is/c++draft/expr.delete):

> "In a single-object delete expression, the value of the operand of delete may be a null pointer value, a pointer value that resulted from a previous non-array *new-expression*, or a pointer to a base class subobject of an object created by such a *new-expression*. **If not, the behavior is undefined.**
>
> In an array delete expression, the value of the operand of delete may be a null pointer value or a pointer value that resulted from a previous array *new-expression* whose allocation function was not a non-allocating form. **If not, the behavior is undefined.**"

Standar menambahkan catatan penjelas yang sangat relevan:

> "*Note*: This means that **the syntax of the delete-expression must match the type of the object allocated by new**, not the syntax of the new-expression."

Annex F, dua entri terpisah:
- [\[ub:expr.delete.mismatch\]](https://eel.is/c++draft/ub:expr.delete.mismatch): *"Using array delete on the result of a single object new expression has undefined behavior."* Contoh: `int* x = new int; delete[] x; // undefined behavior`
- [\[ub:expr.delete.array.mismatch\]](https://eel.is/c++draft/ub:expr.delete.array.mismatch): *"Using single object delete on the result of an array new expression has undefined behavior."* Contoh: `int* x = new int[10]; delete x; // undefined behavior`

cppreference — [delete-expression](https://en.cppreference.com/w/cpp/language/delete):

> "1) ptr must be one of
> - a null pointer,
> - a pointer to a non-array object created by a new-expression, or
> - a pointer to a base subobject of a non-array object created by a new-expression.
> The pointed-to type of ptr must be similar to the type of the object (or of a base subobject). **If ptr is anything else, including if it is a pointer obtained by the array form of new-expression, the behavior is undefined.**
>
> 2) ptr must be a null pointer or a pointer whose value is previously obtained by an array form of new-expression whose allocation function was not a non-allocating form. ... **If ptr is anything else, including if it is a pointer obtained by the non-array form of new-expression, the behavior is undefined.**"

### Nuansa yang perlu ditambahkan

1. **Mekanisme teknis (mengapa UB).** Pada banyak implementasi, `new T[n]` menyimpan *array allocation overhead* (biasanya jumlah elemen) di area sebelum pointer yang dikembalikan. `delete[]` membaca overhead ini untuk memanggil destruktor setiap elemen; `delete` tidak. Jadi `delete` pada hasil `new[]` melewatkan destruktor elemen dan meneruskan pointer yang salah ke `operator delete`. Standar mengizinkan overhead ini secara eksplisit di [\[expr.new\]/21](https://eel.is/c++draft/expr.new): *"each instance of x is a non-negative unspecified value representing array allocation overhead; the result of the new-expression will be offset by this amount from the value returned by operator new[]."*

2. **Perhatikan bahwa keduanya bertipe sama di mata tipe!** `new int` dan `new int[10]` sama-sama bertipe `int*` ([\[expr.new\]/11 Note 7](https://eel.is/c++draft/expr.new): *"Both `new int` and `new int[10]` have type `int*`"*). Inilah sebabnya compiler **tidak bisa** menangkap kesalahan ini dalam banyak kasus — dan mengapa UB-nya benar-benar berbahaya. Ini poin pengajaran yang sangat kuat.

3. **Kecuali tipe ber-destruktor trivial, MSVC/ABI bisa membuatnya "kebetulan jalan".** cppreference mencatat di [new-expression § Notes](https://en.cppreference.com/w/cpp/language/new): *"Itanium C++ ABI requires that the array allocation overhead is zero if the element type of the created array is trivially destructible. So does MSVC."* Artinya untuk `int[]`, kesalahan ini bisa lolos tanpa gejala di implementasi tersebut — dan baru meledak ketika tipe elemen berubah menjadi class dengan destruktor. Ini contoh bagus dari "UB yang kadang tampak benar".

4. **Versi lama/DR.** cppreference mencatat CWG 2624: *"pointers obtained from non-allocating `operator new[]` could be passed to `delete[]` → prohibited."* Jadi aturannya makin diperketat seiring waktu.

---

## 8. Lupa `delete` (memory leak)

**Status: BENAR**

Klaim ini **benar**: lupa memanggil `delete` **bukan** UB menurut standar C++.

### Kutipan sumber primer

cppreference — [new-expression § Memory leaks](https://en.cppreference.com/w/cpp/language/new):

> "The objects created by new expressions (objects with dynamic storage duration) persist until the pointer returned by the new expression is used in a matching delete-expression. **If the original value of pointer is lost, the object becomes unreachable and cannot be deallocated: a memory leak occurs.**"

Perhatikan bahwa cppreference mendeskripsikan ini murni sebagai *"memory leak occurs"* — **tanpa menyebut undefined behavior sama sekali**.

Standar C++ draft tidak memiliki entri Annex F untuk "lupa delete". Annex F ([\[ub\]](https://eel.is/c++draft/ub)) mendokumentasikan UB eksplisit, dan tidak ada entri untuk memory leak. Definisi UB di [\[defns.undefined\]](https://eel.is/c++draft/defns.undefined) adalah *"behavior for which this document imposes no requirements"* — untuk memory leak, standar justru **memberi** persyaratan yang jelas (objek berdurasi sampai di-`delete`), sehingga tidak masuk definisi UB.

Standar C++ draft, [\[basic.stc.dynamic.allocation\]/2](https://eel.is/c++draft/basic.stc.dynamic.allocation) mengonfirmasi bahwa storage hasil alokasi tetap hidup sampai di-deallocate:

> "If it is successful, it returns the address of the start of a block of storage whose length in bytes is at least as large as the requested size."

dan [\[basic.stc.dynamic.deallocation\]/5](https://eel.is/c++draft/basic.stc.dynamic.deallocation):

> "If the argument given to a deallocation function in the standard library is a pointer that is not the null pointer value, the deallocation function shall deallocate the storage referenced by the pointer, **ending the duration of the region of storage**."

### Mengapa ini penting secara pedagogis

Ini adalah **satu-satunya klaim di daftar ini yang benar-benar bukan UB**. Perbedaan ini penting karena:
- UB bisa membuat program apa pun terjadi (termasuk crash, data corruption, atau "kelihatan benar").
- Memory leak hanya membuat program memakai memori bertambah; perilaku program **terdefinisi dengan baik** (well-defined).

### Nuansa yang perlu ditambahkan

1. **Leak bisa berujung pada UB lewat jalur lain.** Jika leak menyebabkan alokasi gagal (`std::bad_alloc`) atau membuat program di-OOM-kill oleh OS, itu masalah *runtime/environment*, bukan UB menurut standar. Tetapi jika kode menangani `bad_alloc` dengan asumsi salah, barulah bisa masuk UB.

2. **Kasus khusus yang **memang** UB (bukan leak biasa).** Ada situasi terkait yang berbeda dan benar-benar UB, layak disebut agar materi tidak over-simplifikasi:
   - **Membuang pointer tanpa melepas storage lalu storage dipakai ulang dengan tipe berbeda** → masuk [\[basic.life\]](https://eel.is/c++draft/basic.life).
   - **`delete` pada pointer yang bukan hasil `new`** → UB (klaim 6/7).
   - **Pengecualian dalam destruktor saat `delete[]`** → [\[expr.new\]/27](https://eel.is/c++draft/expr.new) Note 13: *"This is appropriate when the called allocation function does not allocate memory; otherwise, it is likely to result in a memory leak."*
   - **`new` yang melempar exception di tengah inisialisasi array class** → bisa leak sebagian, dan standar menyebut kemungkinan deallocation function dipanggil atau tidak ([\[expr.new\]/27](https://eel.is/c++draft/expr.new)).

3. **Dalam `constexpr`, leak adalah ill-formed.** Standar [\[expr.new\]/15](https://eel.is/c++draft/expr.new): *"During an evaluation of a constant expression, a call to a replaceable allocation function is always omitted."* Karena alokasi tidak terjadi, "leak" tidak relevan di konteks constant expression — topik lanjutan yang mungkin di luar cakupan materi.

4. **Cara mengajar yang disarankan:** sajikan klaim 8 sebagai kontras langsung dengan klaim 6 dan 7. Tabel "ini UB / ini bukan UB" akan sangat efektif:
   | Operasi | Status |
   |---|---|
   | `delete` dua kali pada pointer sama | **UB** |
   | `delete` pada hasil `new[]` | **UB** |
   | Lupa `delete` (leak) | **Bukan UB** — perilaku well-defined |

---

## 9. Membaca memori yang belum diinisialisasi

**Status: BENAR DENGAN CATATAN** (dengan perbedaan C vs C++ yang signifikan)

### Kutipan sumber primer — C++

Standar C++ draft, [\[basic.indet\]/2](https://eel.is/c++draft/basic.indet):

> "**Except in the following cases, if an indeterminate value is produced by an evaluation, the behavior is undefined** ...:
> - If an indeterminate or erroneous value of **unsigned ordinary character type** or **`std::byte`** type is produced by the evaluation of:
>   - the second or third operand of a conditional expression,
>   - the right operand of a comma expression,
>   - the operand of a cast or conversion ... to an unsigned ordinary character type or std::byte type, or
>   - a discarded-value expression,
>   then the result of the operation is an indeterminate value or that erroneous value, respectively.
> - If an indeterminate or erroneous value of unsigned ordinary character type or std::byte type is produced by the evaluation of the right operand of a simple assignment operator ...
> - If an indeterminate or erroneous value of unsigned ordinary character type is produced by the evaluation of the initialization expression when initializing an object of unsigned ordinary character type ...
> - If an indeterminate value of unsigned ordinary character type or std::byte type is produced by the evaluation of the initialization expression when initializing an object of std::byte type ..."

Contoh normatif dari standar itu sendiri (menggabungkan storage duration otomatis dan dinamis):

> ```cpp
> int f(bool b) {
>   unsigned char *c = new unsigned char;
>   unsigned char d = *c;   // OK, d has an indeterminate value
>   int e = d;              // undefined behavior
>   return b ? d : 0;       // undefined behavior if b is true
> }
>
> int g(bool b) {
>   unsigned char c;
>   unsigned char d = c;    // no erroneous behavior, but d has an erroneous value
>   assert(c == d);         // holds, both integral promotions have erroneous behavior
>   int e = d;              // erroneous behavior
>   return b ? d : 0;       // erroneous behavior if b is true
> }
>
> void h() {
>   int d1, d2;
>   int e1 = d1;            // erroneous behavior
>   int e2 = d1;            // erroneous behavior
>   assert(e1 == e2);       // holds
>   ...
> }
> ```

Annex F, [\[ub:basic.indet.value\]](https://eel.is/c++draft/ub:basic.indet.value):

> "When the result of an evaluation is an indeterminate value (but not just an erroneous value) the behavior is undefined."

cppreference — [Default initialization § Indeterminate and erroneous values](https://en.cppreference.com/w/cpp/language/default_initialization):

> "When storage for an object with automatic or dynamic storage duration is obtained, the bytes comprising the storage for the object have the following initial value:
> - If the object has dynamic storage duration, or is the object associated with a variable or function parameter whose first declaration is marked with `[[indeterminate]]`, the bytes have **indeterminate values**;
> - Otherwise, the bytes have **erroneous values**, where each value is determined by the implementation independently of the state of the program.
>
> **If an evaluation produces an indeterminate value, the behavior is undefined.**
> If an evaluation produces an erroneous value, the behavior is erroneous." *(since C++26)*

cppreference juga memberi contoh klasik:

> ```cpp
> int main() {
>   bool p;   // uninitialized local variable
>   if (p)    // UB access to uninitialized scalar
>     std::puts("p is true");
>   if (!p)   // UB access to uninitialized scalar
>     std::puts("p is false");
> }
> ```

### Perbedaan C vs C++ (ini yang paling sering salah diajarkan)

**Di C, aturannya jauh lebih sempit.** C11 (N1570), 6.3.2.1/2:

> "If the lvalue designates an object of automatic storage duration that **could have been declared with the register storage class (never had its address taken)**, and that object is uninitialized (not declared with an initializer and no assignment to it has been performed prior to use), the behavior is undefined."

Artinya di C: jika **alamatnya pernah diambil** (`&x` dipakai), maka membaca `x` yang belum diinisialisasi **tidak otomatis UB** — melainkan menghasilkan *indeterminate value* yang bisa menjadi *trap representation*. C11 3.19.2:

> "**indeterminate value** — either an unspecified value or a trap representation"

dan 6.2.6.1/5:

> "Certain object representations need not represent a value of the object type. **If the stored value of an object has such a representation and is read by an lvalue expression that does not have character type, the behavior is undefined.** ... Such a representation is called a trap representation."

C23 (N3096) memperluas UB-nya: 6.2.4/6 menyebut *"the representation of the object becomes indeterminate each time the declaration is reached"*, dan aturan UB untuk penggunaan nilai indeterminate masih ada.

**Di C++, aturan umumnya berlaku untuk semua objek ber-storage otomatis/dinamis tanpa syarat "never had its address taken".** Jadi klaim umum "membaca variabel lokal belum diinisialisasi adalah UB" **lebih benar di C++ daripada di C**.

### Nuansa yang perlu ditambahkan

1. **Pengecualian `unsigned char` / `std::byte`.** Ini penting: membaca `unsigned char` yang belum diinisialisasi **tidak** UB di C++ — hanya menghasilkan indeterminate value. cppreference [Default initialization § Special cases](https://en.cppreference.com/w/cpp/language/default_initialization) menyebutkan *"the following types are uninitialized-friendly: `std::byte`, `unsigned char`, `char` if its underlying type is `unsigned char`."* Inilah alasan teknis mengapa membaca memori mentah lewat `unsigned char*` (seperti di `memcpy`, sanitizer, atau serialisasi) adalah praktik yang sah.

2. **Perubahan besar di C++26.** cppreference dan draft terkini memperkenalkan **erroneous behavior** untuk objek ber-storage otomatis. [\[defns.erroneous\]](https://eel.is/c++draft/defns.erroneous): *"erroneous behavior — well-defined behavior that the implementation is recommended to diagnose."* Jadi di C++26, `int d1; int e1 = d1;` adalah *erroneous behavior*, bukan UB — tetapi objek ber-storage **dinamis** (`new int`) tetap menghasilkan *indeterminate value* → tetap **UB**. Materi harus menyebutkan versi standar yang diasumsikan (umumnya C++17/20 di kelas).

3. **Praktik optimisasi.** cppreference [Undefined behavior § UB and optimization](https://en.cppreference.com/w/cpp/language/ub) mendemonstrasikan bahwa membaca uninitialized scalar bisa membuat compiler menyimpulkan cabang tidak pernah diambil:

   > ```cpp
   > std::size_t f(int x) {
   >   std::size_t a;
   >   if (x)      // either x nonzero or UB
   >     a = 42;
   >   return a;
   > }
   > ```
   > "May be compiled as: `mov eax, 42; ret`"

4. **`memcmp` dan uninitialized.** Perhatikan bahwa `std::memcpy` dari objek uninitialized **tidak** dengan sendirinya UB (lihat contoh `h()` di atas: *"`std::memcpy(&d2, &d1, sizeof(int));` // no erroneous behavior, but d2 has an erroneous value"*). Ini nuansa penting yang mengaitkan klaim 9 dengan klaim 11.

---

## 10. Pointer ke variabel lokal yang sudah keluar scope

**Status: BENAR**

### Kutipan sumber primer

Standar C++ draft, [\[basic.life\]/7](https://eel.is/c++draft/basic.life):

> "Before the lifetime of an object has started but after the storage which the object will occupy has been allocated or after the lifetime of an object has ended and before the storage which the object occupied is reused or released, any pointer that represents the address of the storage location where the object will be or was located **may be used but only in limited ways**. ...
>
> The program has undefined behavior if:
> - the pointer is used as the operand of a *delete-expression*,
> - **the pointer is used to access a non-static data member or call a non-static member function of the object**,
> - the pointer is converted to a pointer to a virtual base class or to a base class thereof, or
> - the pointer is used as the operand of a `dynamic_cast`."

Standar C++ draft, [\[basic.life\]/8](https://eel.is/c++draft/basic.life):

> "Similarly, before the lifetime of an object has started ... or after the lifetime of an object has ended ..., any glvalue that refers to the original object may be used but only in limited ways. ... **The program has undefined behavior if:**
> - **the glvalue is used to access the object, or**
> - the glvalue is used to call a non-static member function of the object, or
> - ..."

Annex F, [\[ub:basic.compound.invalid.pointer\]](https://eel.is/c++draft/ub:basic.compound.invalid.pointer):

> "Indirection or the invocation of a deallocation function with a pointer value referencing storage that has been freed has undefined behavior."

Contoh dari cppreference — [Pointer declaration § Invalid pointers](https://en.cppreference.com/w/cpp/language/pointer):

> ```cpp
> int* f() {
>   int obj;
>   int* local_ptr = new (&obj) int;
>   *local_ptr = 1;    // OK, the evaluation "*local_ptr" is
>                      // in the storage duration of "obj"
>   return local_ptr;
> }
>
> int* ptr = f();      // the storage duration of "obj" is expired,
>                      // therefore "ptr" is an invalid pointer in the following contexts
> int* copy = ptr;     // implementation-defined behavior
> *ptr = 2;            // undefined behavior: indirection of an invalid pointer
> delete ptr;          // undefined behavior: deallocating storage from an invalid pointer
> ```

Standar C++ draft, [\[basic.stc.auto\]/1](https://eel.is/c++draft/basic.stc.auto) menjelaskan kapan storage berakhir:

> "Variables that belong to a block scope and are not explicitly declared static, thread_local, or extern have *automatic storage duration*. **The storage for such variables lasts until the block in which they are created exits.**"

### Nuansa yang perlu ditambahkan

1. **UB terjadi saat pointer *dipakai untuk mengakses objek*, bukan saat pointer dikembalikan.** `return &local;` sendiri tidak UB. Bahkan `int* p = f();` (menyimpan hasilnya) dan `int* q = p;` (menyalin) tidak UB — hanya *implementation-defined*. Yang UB adalah `*p`, `p->x`, `p[0]`, atau `delete p`.

2. **Kasus `char`/`unsigned char` dan array.** Storage yang sudah tidak valid **bisa** dibaca secara terbatas dalam konteks tertentu (misalnya lewat `unsigned char*` untuk keperluan tertentu), tetapi ini topik lanjutan dan bergantung konteks. Untuk materi dasar, aman untuk menyatakan: mengakses objek setelah lifetime-nya berakhir adalah UB.

3. **Kaitkan dengan `std::string_view`/`std::span`.** Ini manifestasi modern dari bug yang sama: `std::string_view` yang menunjuk ke string temporer yang sudah mati. Materi Struktur Data sering memakai ini (mis. `string_view` sebagai key), jadi contoh ini sangat relevan.

4. **Perbedaan dengan C.** Di C, aturan serupa ada di 6.2.4/2 (N1570): *"If an object is referred to outside of its lifetime, the behavior is undefined."* Tetapi C juga menambahkan: *"The value of a pointer becomes indeterminate when the object it points to (or just past) reaches the end of its lifetime."* — sehingga di C, **nilai pointernya sendiri** menjadi indeterminate (yang bisa berujung UB saat dibaca), berbeda dari C++ yang memakai kategori *invalid pointer value* dengan aturan lebih terperinci. C23 (N3096) 6.2.4/2 bahkan lebih tegas: *"If a pointer value is used in an evaluation after the object the pointer points to (or just past) reaches the end of its lifetime, the behavior is undefined."*

5. **Sumber bug paling umum di praktik.** cppreference [Lifetime § Dangling references](https://en.cppreference.com/w/cpp/language/lifetime) mencatat: *"the lifetime of the referred object may end before the end of the lifetime of the reference, which makes dangling references possible."* Untuk pointer, kasus serupa muncul pada fungsi yang mengembalikan pointer ke member dari objek temporer, misalnya `const char* p = std::string("abc").c_str();` — string temporer mati di akhir full-expression.

---

## 11. `memcmp` pada struct dengan padding

**Status: BENAR DENGAN CATATAN**

Klaim menyatakan hasilnya bisa salah. Itu benar. **Tetapi ini bukan UB** — hanya hasil yang tidak dapat diandalkan (*unspecified*). Selain itu, istilah "padding berisi nilai tak tentu" perlu diperbaiki: standar C++ memakai **unspecified value**, bukan *indeterminate*.

### Kutipan sumber primer — C++ (istilah yang tepat)

Standar C++ draft, [\[basic.types.general\]/2](https://eel.is/c++draft/basic.types.general):

> "The *object representation* of a complete object type T is the sequence of N unsigned char objects taken up by a non-bit-field complete object of type T, where N equals `sizeof(T)`. The *value representation* of a type T is the set of bits in the object representation of T that participate in representing a value of type T. ... **Bits in the object representation of a type or object that are not part of the value representation are *padding bits*.**"

**Ini poin kunci.** Cari frasa "unspecified value" di [\[basic.fundamental\]](https://eel.is/c++draft/basic.fundamental). Teks draft (source `basic.tex`) menyatakan:

> "Each set of values for any padding bits in the object representation are alternative representations of the value specified by the value representation.
> *Note*: **Padding bits have unspecified value, but cannot cause traps.** In contrast, see ISO C 6.2.6.2."

Jadi menurut C++: padding bits punya **unspecified value** — kategori yang berbeda dari *indeterminate value*.

Perbedaan definisi:
- [\[defns.unspecified\]](https://eel.is/c++draft/defns.unspecified): *"unspecified behavior — behavior, for a well-formed program construct and correct data, that depends on the implementation."*
- [\[basic.indet\]](https://eel.is/c++draft/basic.indet): *"If an evaluation produces an indeterminate value, the behavior is undefined."*

Karena padding bits = **unspecified value** (bukan indeterminate), membacanya lewat `memcmp` **tidak** masuk aturan UB di [\[basic.indet\]/2](https://eel.is/c++draft/basic.indet).

### Kutipan sumber primer — C (untuk kontras, dan untuk asal-usul istilah "indeterminate")

C11 (N1570), 6.2.6.1/6:

> "When a value is stored in an object of structure or union type, including in a member object, **the bytes of the object representation that correspond to any padding bytes take unspecified values.**"

Footnote 310 pada deskripsi `memcmp` (C11 7.24.4.1) memakai istilah *indeterminate*:

> "The contents of ''holes'' used as padding for purposes of alignment within structure objects are **indeterminate**. Strings shorter than their allocated space and unions may also cause problems in comparison."

C23 (N3096), 6.2.6.1/6 dan footnote 379 pada `memcmp`:

> "When a value is stored in an object of structure or union type, including in a member object, **the bytes of the object representation that correspond to any padding bytes take unspecified values.**"
> *(footnote 379)* "The unused bytes used as padding for purposes of alignment within structure objects **take on unspecified values when a value is stored in the object**."

Jadi dalam **C**, istilah yang dipakai sekarang juga **unspecified**, bukan *indeterminate*. (Wording lama memakai "indeterminate"; C23 memakai "unspecified".) Di **C++** jelas **unspecified**.

### Kutipan sumber primer — `memcmp` (C++)

C++ draft, [\[cstring.syn\]/1](https://eel.is/c++draft/cstring.syn):

> "The contents and meaning of the header `<cstring>` are the same as the C standard library header `<string.h>`."

C11 7.24.4.1 / C23 7.26.4.1: *"The `memcmp` function compares the first n characters of the object pointed to by s1 to the first n characters of the object pointed to by s2."*

cppreference — [std::memcmp § Notes](https://en.cppreference.com/w/cpp/string/byte/memcmp):

> "This function reads object representations, not the object values, and is typically meaningful for only trivially-copyable objects that have no padding. For example, `memcmp()` between two objects of type `std::string` or `std::vector` will not compare their contents, **`memcmp()` between two objects of type `struct { char c; int n; }` will compare the padding bytes whose values may differ when the values of c and n are the same**, and even if there were no padding bytes, the int would be compared without taking into account endianness."

cppreference — [Objects and alignment](https://en.cppreference.com/w/cpp/language/object) memberi contoh mengapa padding tidak memengaruhi *value*:

> ```cpp
> struct S {
>   char c;              // 1 byte value
>                       // 3 bytes of padding bits (assuming alignof(float) == 4)
>   float f;            // 4 bytes value (assuming sizeof(float) == 4)
>   bool operator==(const S& arg) const { return c == arg.c && f == arg.f; }
> };
>
> void f() {
>   assert(sizeof(S) == 8);
>   S s1 = {'a', 3.14};
>   S s2 = s1;
>   reinterpret_cast<unsigned char*>(&s1)[2] = 'b';   // modify some padding bits
>   assert(s1 == s2);   // value did not change
> }
> ```

### Bedanya "tak tentu" (indeterminate) vs "unspecified"

| Istilah | Definisi | Konsekuensi |
|---|---|---|
| **indeterminate value** | [\[basic.indet\]]: nilai byte storage yang belum diinisialisasi (storage otomatis/dinamis) | *"If an evaluation produces an indeterminate value, the behavior is undefined."* → **UB** |
| **unspecified value** | [\[defns.unspecified\]]: perilaku yang bergantung implementasi, untuk program well-formed | Program tetap **well-defined**; implementasi bebas memilih nilai, tidak wajib didokumentasikan |
| **erroneous value** (C++26) | [\[defns.erroneous\]]: *"well-defined behavior that the implementation is recommended to diagnose"* | **Bukan UB**, hanya direkomendasikan didiagnosis |

**Padding = unspecified value**, jadi: **bukan UB, tetapi hasilnya tidak bisa diandalkan.**

### Nuansa yang perlu ditambahkan

1. **Padding di C++ "cannot cause traps".** Ini perbedaan penting dari C. Draft C++ (source `basic.tex`) menyatakan eksplisit: *"Padding bits have unspecified value, but cannot cause traps."* Di C, 6.2.6.1 footnote 53/54 menyatakan *"Some combinations of padding bits might generate trap representations"* — sehingga C lebih berbahaya. Di C++, membaca padding lewat `unsigned char`/`memcmp` tidak akan memicu trap.

2. **`memcmp` bukan UB, tapi jangan dipakai untuk kesetaraan struct.** Yang benar:
   - Bandingkan **member per member** (`operator==`), atau
   - Gunakan tipe tanpa padding (mis. `std::array<char, N>` untuk data mentah), atau
   - Pastikan padding ter-zero-kan dulu (mis. `memset(&s, 0, sizeof s)` sebelum mengisi member — dengan syarat tipe trivially copyable dan tidak ada member yang punya representasi nonzero untuk nilai nol).

3. **Kasus `bool` dan valid value representation.** Ada UB terkait `memcmp`/`memcpy` yang **berbeda** dari isu padding: menyalin byte yang bukan representasi valid untuk tipe. Lihat [\[ub:conv.lval.valid.representation\]](https://eel.is/c++draft/ub:conv.lval.valid.representation): *"Performing an lvalue-to-rvalue conversion on an object whose value representation is not valid for its type has undefined behavior."* Contoh: `bool b; char c = 42; memcpy(&b, &c, 1); return b;` → UB jika 42 bukan representasi valid untuk `bool`. Ini kasus yang **memang UB**, berbeda dari padding.

4. **Endianness.** Bahkan tanpa padding, `memcmp` membandingkan representasi byte, bukan nilai numerik. cppreference menyinggung ini: *"even if there were no padding bytes, the int would be compared without taking into account endianness."* Dua struct dengan nilai sama bisa memberi hasil `memcmp` berbeda pada mesin big-endian vs little-endian — tetapi tetap **bukan UB**.

5. **`std::has_unique_object_representations` (C++17).** Untuk tipe yang dijamin tanpa padding dan tanpa bit tak terpakai, trait ini bernilai `true` — berguna untuk memutuskan apakah `memcmp` aman. Ini topik lanjutan yang bisa disebut sebagai "cara resmi mengecek".

---

## 12. Null pointer check setelah `delete`

**Status: BENAR** (dengan kualifikasi pada kata "mengaksesnya")

Klaim: *"Setelah `delete`, pointer TIDAK otomatis menjadi `nullptr`; mengaksesnya masih UB. Setelah `delete` harus set `p = nullptr`."*

- **"Tidak otomatis menjadi `nullptr`"** → **BENAR**
- **"Mengaksesnya masih UB"** → **BENAR DENGAN CATATAN** (hanya untuk indirection/deallocation; bentuk akses lain *implementation-defined*)
- **"Harus set `p = nullptr`"** → **praktik defensif yang baik**, tetapi **bukan keharusan standar**

### Kutipan sumber primer

Standar C++ draft, [\[expr.delete\]/5-6](https://eel.is/c++draft/expr.delete) mendeskripsikan apa yang dilakukan `delete` — **tidak ada satu pun yang menyebut mengubah nilai pointer**:

> "If the value of the operand of the *delete-expression* is not a null pointer value and the selected deallocation function is not a destroying operator delete, evaluating the *delete-expression* invokes the destructor (if any) for the object or the elements of the array being deleted. ..."

Yang diubah adalah **storage**, bukan variabel pointer. [\[basic.stc.dynamic.deallocation\]/5](https://eel.is/c++draft/basic.stc.dynamic.deallocation):

> "If the argument given to a deallocation function in the standard library is a pointer that is not the null pointer value, the deallocation function shall deallocate the storage referenced by the pointer, **ending the duration of the region of storage**."

Karena storage-nya berakhir, pointer yang menunjuk ke sana menjadi **invalid pointer value**. Standar C++ draft, [\[basic.compound\]/3](https://eel.is/c++draft/basic.compound):

> "Every value of pointer type is one of the following: ... or **an invalid pointer value**."

Dan [\[basic.compound\]/6](https://eel.is/c++draft/basic.compound):

> "If a pointer value P is used in an evaluation E and P is not valid in the context of E:
> - **If E is an indirection, the behavior is undefined.**
> - If E either is a boolean conversion or is performed by a unary +, additive, three-way comparison, relational, or equality operator, **the behavior is implementation-defined.**"

Annex F, [\[ub:basic.compound.invalid.pointer\]](https://eel.is/c++draft/ub:basic.compound.invalid.pointer):

> "Indirection or the invocation of a deallocation function with a pointer value referencing storage that has been freed has undefined behavior. **(Most other uses of such a pointer have implementation-defined behavior.)**"

cppreference — [Pointer declaration § Invalid pointers](https://en.cppreference.com/w/cpp/language/pointer):

> "If a pointer value p is used in an evaluation e, and p is not valid in the context of e, then:
> - If e is an indirection or an invocation of a deallocation function, **the behavior is undefined**.
> - Otherwise, the behavior is **implementation-defined**."

### Perilaku `delete` terhadap nilai pointer

| Pertanyaan | Jawaban menurut standar |
|---|---|
| Apakah `delete p` mengubah `p` menjadi `nullptr`? | **Tidak.** Standar tidak mensyaratkan ini. Nilai `p` tidak berubah |
| Apakah `p` menjadi *invalid pointer value*? | **Ya** — karena storage-nya sudah tidak ada |
| Apakah `*p` setelah `delete` UB? | **Ya** |
| Apakah `p->member` setelah `delete` UB? | **Ya** (≡ `(*(p)).member`) |
| Apakah `delete p` lagi UB? | **Ya** (klaim 6) |
| Apakah `p == q` / `bool(p)` setelah `delete` UB? | **Tidak UB** — *implementation-defined* |
| Apakah menyalin `p` (`int* q = p;`) UB? | **Tidak UB** — *implementation-defined* |

### Apakah "harus set `p = nullptr`" wajib?

**Tidak.** Standar tidak mewajibkan. Tetapi praktik ini **sangat dianjurkan** karena mengubah perilaku setelahnya dari *implementation-defined* menjadi **well-defined**:

Standar C++ draft, [\[basic.stc.dynamic.deallocation\]/4](https://eel.is/c++draft/basic.stc.dynamic.deallocation):

> "The value of the first argument supplied to a deallocation function may be a null pointer value; **if so, and if the deallocation function is one supplied in the standard library, the call has no effect.**"

cppreference — [delete-expression](https://en.cppreference.com/w/cpp/language/delete):

> "If ptr is a null pointer value, no destructors are called, and the deallocation function may or may not be called (it's unspecified), but **the default deallocation functions are guaranteed to do nothing when passed a null pointer.**"

Jadi:
- Setelah `p = nullptr;`, `delete p;` lagi → **well-defined, tidak melakukan apa-apa** (mencegah klaim 6)
- Setelah `p = nullptr;`, `p == nullptr` → **well-defined** (bukan implementation-defined)
- Setelah `p = nullptr;`, `*p` → **tetap UB** (ini batas dari praktik defensif ini!)

### Nuansa yang perlu ditambahkan

1. **`p = nullptr` bukan solusi lengkap.** Ada masalah yang tidak diselesaikan:
   - **Alias:** jika ada pointer lain yang menunjuk objek yang sama (`q = p`), men-set `p = nullptr` tidak membantu `q` — `q` tetap dangling. Ini masalah utama di struktur data berpointer (linked list, tree), di mana satu node bisa ditunjuk dari beberapa tempat.
   - **`*p` setelah `p = nullptr` tetap UB.** Praktik ini hanya membuat `delete` dan perbandingan menjadi aman.

2. **Cara yang lebih baik: `std::unique_ptr` / `std::shared_ptr`.** cppreference [new-expression § Memory leaks](https://en.cppreference.com/w/cpp/language/new) mencatat: *"To simplify management of dynamically-allocated objects, the result of a new expression is often stored in a smart pointer: ... `std::unique_ptr`, or `std::shared_ptr`. These pointers guarantee that the delete expression is executed in the situations shown above."* `std::unique_ptr::reset()` secara eksplisit men-set pointer ke `nullptr` setelah delete. Ini praktik yang sebaiknya diajarkan bersamaan.

3. **Klarifikasi istilah untuk materi.** Klaim 12 sebaiknya dipecah menjadi dua pernyataan yang dipisah:
   - **Fakta standar:** "`delete` tidak mengubah nilai variabel pointer; pointer menjadi *invalid pointer value*; dereferensi/dealokasi ulang lewat pointer itu UB."
   - **Praktik baik (bukan aturan standar):** "Set `p = nullptr` setelah delete untuk mencegah double-delete dan membuat perbandingan aman."

   Membedakan keduanya penting agar mahasiswa tahu mana aturan bahasa dan mana konvensi rekayasa.

4. **Peringatan implementasi.** cppreference mencatat: *"Some implementations might define that copying an invalid pointer value causes a system-generated runtime fault."* Jadi, mengandalkan "membaca pointer dangling hanya implementation-defined" bisa tetap berbahaya di platform tertentu.

---

## Koreksi yang Perlu Dilakukan

Daftar perubahan konkret untuk materi Struktur Data:

### KOREKSI WAJIB

| # | Klaim lama | Masalah | Kalimat pengganti yang disarankan |
|---|---|---|---|
| **2** | "Melakukan aritmetika pointer sampai melewati satu elemen terakhir array adalah UB" | **SALAH.** Membentuk pointer one-past-the-end itu **legal** | "Membentuk pointer **satu langkah setelah** elemen terakhir array (`arr + n`) **legal dan terdefinisi**. Yang UB adalah melangkah **lebih jauh** (`arr + n + 1`) atau **mendereferensi** `arr + n`." |
| **4** | "Membandingkan pointer dari array berbeda dengan `<`/`>` adalah UB" | **Kurang tepat.** Di C++ hasilnya *unspecified*, bukan UB. Di C baru UB | "Di C++, membandingkan pointer dari array berbeda dengan `<`/`>` memberi hasil yang **tidak dijamin (unspecified)** — bukan UB, tetapi tidak boleh diandalkan untuk pengurutan. Gunakan `std::less` untuk urutan total. Di C, ini memang UB. Bandingkan dengan `==`: dua pointer ke array berbeda yang bukan kasus one-past-the-end dijamin `false`." |
| **11** | "Padding berisi nilai **tak tentu**" | **Istilah salah.** Standar C++ memakai **unspecified value**, bukan indeterminate | "Padding bits memiliki **unspecified value** — bukan *indeterminate value*. Karena itu `memcmp` pada struct dengan padding **bukan UB**, tetapi hasilnya tidak dapat diandalkan. (Di C11 lama istilahnya *indeterminate*, dan C23 juga sudah beralih ke *unspecified*.)" |
| **12** | "Mengaksesnya masih UB" | **Terlalu luas.** Hanya indirection & deallocation yang UB | "Setelah `delete`, pointer menjadi *invalid pointer value* dan tidak berubah menjadi `nullptr`. **Dereferensi (`*p`, `p->x`) dan `delete` ulang adalah UB**; sedangkan menyalin atau membandingkannya bersifat *implementation-defined*. Set `p = nullptr` adalah praktik baik (bukan keharusan standar) yang membuat `delete` ulang dan perbandingan menjadi well-defined." |
| **9** | "Membaca variabel lokal belum diinisialisasi adalah UB" | **Perlu kualifikasi** (pengecualian `unsigned char`; perbedaan C/C++; C++26) | "Di C++ (sampai C++23), membaca objek ber-storage otomatis/dinamis yang belum diinisialisasi adalah UB — **kecuali** tipe `unsigned char` dan `std::byte`, yang menghasilkan *indeterminate value* tanpa UB. Di C, aturannya lebih sempit: UB hanya jika objeknya *bisa* dideklarasikan `register` (alamatnya tidak pernah diambil). Mulai C++26, objek lokal menjadi *erroneous behavior*, bukan lagi UB." |

### KOREKSI RINGAN (perbaikan penyajian)

| # | Klaim | Perbaikan |
|---|---|---|
| **1** | Dereferensi `nullptr` adalah UB | Sudah benar. Tambahkan: ada pengecualian `typeid(*p)` yang melempar `std::bad_typeid`. Tambahkan demo optimisasi GCC `-fdelete-null-pointer-checks` |
| **5** | "Mengakses memori lewat pointer setelah `delete` adalah UB" | Sudah benar. Tambahkan pembedaan: indirection/deallocation = UB; menyalin/membaca nilai pointer = *implementation-defined*. Sebutkan peringatan implementasi bisa membuat penyalinan pointer invalid fault |
| **8** | Lupa `delete` bukan UB | Sudah benar. Perkuat dengan tabel kontras "UB vs bukan UB" terhadap klaim 6 & 7 |
| **10** | Memakai pointer ke variabel lokal setelah keluar scope adalah UB | Sudah benar. Tambahkan: UB terjadi saat **dereferensi**, bukan saat pointer dikembalikan/disalin. Sebutkan perbedaan dengan C (nilai pointer menjadi indeterminate di C) |

### Ringkasan status akhir

- **BENAR (tidak perlu koreksi substantif):** 1, 3, 6, 7, 8, 10
- **BENAR DENGAN CATATAN (perlu kualifikasi):** 4, 5, 9, 11, 12
- **SALAH (harus diperbaiki):** 2

**Total: 1 klaim salah, 5 klaim perlu kualifikasi, 6 klaim sudah benar.**

---

## Catatan Ketidakpastian

1. **Versi standar yang dirujuk.** Sumber utama yang dipakai adalah **C++ Working Draft terkini** di eel.is/c++draft (mendekati C++26). Beberapa wording berubah antar versi:
   - Klaim 9: C++26 memperkenalkan *erroneous behavior* untuk objek ber-storage otomatis, mengubah status dari UB menjadi erroneous behavior. Jika materi mengasumsikan C++17/C++20 (umum di perkuliahan), maka "UB" tetap akurat untuk versi tersebut. **Verifikasi ulang wording sesuai versi standar yang diajarkan.**
   - Klaim 5 & 12: Kategori *invalid pointer value* di [\[basic.compound\]] dan [\[basic.stc\]] sudah ada sejak C++11 (terverifikasi via N3337/N4659), tetapi struktur subclause-nya berubah (di N4659 aturannya ada di [\[basic.stc\]/4, di draft terkini di [\[basic.compound\]/6]). Rujukan silang harus disesuaikan.
   - Klaim 4: sudah *unspecified* sejak C++11 (terverifikasi via N3337), jadi tidak ada perubahan status — tetapi wordingnya dirapikan di C++20.

2. **cppreference diakses via arsip.** Situs en.cppreference.com memblokir akses langsung (Cloudflare 403) saat riset ini dilakukan. Kutipan cppreference diambil dari snapshot Wayback Machine dan **isi halaman telah diverifikasi konsisten** dengan teks standar. Namun, halaman cppreference dapat berubah; tautan yang dicantumkan mengarah ke halaman live untuk verifikasi ulang. Snapshot `wb_pointer.html` mencatat `oldid=183327`.

3. **Wording "padding bits have unspecified value" di C++.** Kalimat ini ditemukan di **source LaTeX draft** (`basic.tex` baris 5524, di dalam [\[basic.fundamental\]]) dan bukan di halaman HTML `eel.is/c++draft/basic.types.general` yang saya kutip untuk definisi padding bits. Kutipan definitif padding bits ([\[basic.types.general\]/2](https://eel.is/c++draft/basic.types.general)) terverifikasi dari HTML; kalimat "unspecified value, but cannot cause traps" terverifikasi dari source resmi di repositori `cplusplus/draft`. Untuk keperluan materi, keduanya konsisten dan dapat dikutip.

4. **Klaim 11 — nuansa C.** Wording C berubah antara C11 dan C23:
   - C11 7.24.4.1 footnote 310 memakai kata **"indeterminate"** untuk padding.
   - C23 (N3096) footnote 379 memakai **"unspecified values"**.
   Jadi jika materi mengutip "padding itu indeterminate", kutipan itu benar untuk C11 tetapi **tidak benar untuk C23 maupun untuk C++**. Disarankan memakai istilah C++ (**unspecified**) karena materi adalah materi C++.

5. **Klaim 9 — `register` di C23.** C23 menghapus makna storage-class `register` (lihat N3096 6.7.2.1 yang menyatakan `register` hanya sebagai *hint*). Karena itu, kondisi "could have been declared with the register storage class" di C23 secara praktis selalu terpenuhi, sehingga aturan UB di C23 menjadi **lebih luas** dari C11 dan mendekati aturan C++. Verifikasi ulang jika materi membahas C23 secara spesifik.

6. **Klaim 8 — "memory leak" dan standar.** Tidak ada entri Annex F untuk memory leak. Ini adalah **ketiadaan bukti** dalam dokumen standar: saya tidak menemukan aturan yang menjadikan leak sebagai UB, dan baik standar maupun cppreference mendeskripsikannya sebagai konsekuensi resource (bukan pelanggaran bahasa). Secara metodologis, ini adalah klaim "bukan UB" yang sulit dibuktikan secara positif dari teks standar (standar tidak mendaftar semua hal yang *bukan* UB). Bukti terkuat adalah: (a) [\[defns.undefined\]] mensyaratkan "no requirements", sedangkan standar **memberi** persyaratan tentang masa hidup objek dinamis; (b) cppreference mendeskripsikannya tanpa menyebut UB; (c) Annex F tidak memuatnya.

7. **Klaim 4 — kasus `void*`.** Standar [\[expr.rel\]/3](https://eel.is/c++draft/expr.rel) mengizinkan perbandingan pointer `void*`, dan cppreference [Comparison operators](https://en.cppreference.com/w/cpp/language/operator_comparison) menyatakan: *"Otherwise (the pointers compare unequal), if any of the pointers is not a pointer to object, the result is unspecified."* Jadi untuk `void*`, hasilnya *unspecified* lebih sering. Detail ini tidak saya masukkan ke klaim utama karena di luar cakupan pertanyaan, tetapi perlu diketahui jika materi membahas `void*`.

8. **Klaim 10 — storage reuse.** Ada kasus lanjutan di mana pointer ke objek yang sudah mati **boleh** dipakai kembali: *transparent replacement* ([\[basic.life\]/9-10](https://eel.is/c++draft/basic.life)) — jika objek baru bertipe sama dibuat di storage yang sama, pointer lama otomatis menunjuk objek baru. Ini kasus lanjutan (mis. untuk `std::vector`/allocator) dan tidak mengubah klaim untuk kasus variabel lokal biasa, tetapi bisa disebut sebagai catatan kaki.

9. **Klaim 1 — "kadang bekerja".** Saya tidak menemukan pernyataan normatif yang menjamin "dereferensi null tidak crash" pada platform mana pun. Yang dapat dikatakan: UB berarti program **boleh** tampak bekerja, dan GCC secara eksplisit mengasumsikan dereferensi null selalu trap (lihat `-fdelete-null-pointer-checks`). Namun pada platform embedded tertentu (mis. AVR/MSP430) GCC **mematikan** opsi ini — yang menunjukkan bahwa "bekerja" adalah kemungkinan nyata di sebagian lingkungan. Ini bukan jaminan, hanya catatan bahwa perilaku bergantung implementasi.

10. **Akses `eel.is/c++draft` vs versi terbit.** Situs eel.is menampilkan *working draft* terbaru, yang bisa memuat perubahan pasca-C++23. Untuk klaim yang sensitif versi (terutama klaim 9), saya sudah memverifikasi terpisah ke N4950 (C++23), N4659 (C++17), dan N3337 (C++11). Untuk klaim lain, wording intinya stabil sejak C++11 dan telah diverifikasi silang.

11. **Tidak diverifikasi langsung:** Saya tidak menjalankan kode apa pun untuk membuktikan perilaku runtime (sesuai instruksi untuk tidak menginstal/menjalankan apa pun). Semua kesimpulan murni dari teks normatif standar dan dokumentasi resmi. Klaim tentang "apa yang compiler lakukan" (mis. optimisasi GCC) bersumber dari dokumentasi resmi GCC, bukan dari eksperimen.

---

## Tautan Sumber Primer (Ringkasan)

### Standar C++ (working draft)
- [\[expr.unary.op\] — Unary operators (dereferensi)](https://eel.is/c++draft/expr.unary.op)
- [\[expr.add\] — Additive operators (aritmetika pointer)](https://eel.is/c++draft/expr.add)
- [\[expr.rel\] — Relational operators](https://eel.is/c++draft/expr.rel)
- [\[expr.eq\] — Equality operators](https://eel.is/c++draft/expr.eq)
- [\[basic.compound\] — Compound types (kategori nilai pointer, invalid pointer)](https://eel.is/c++draft/basic.compound)
- [\[basic.stc\] — Storage duration](https://eel.is/c++draft/basic.stc)
- [\[basic.stc.dynamic.deallocation\] — Deallocation functions](https://eel.is/c++draft/basic.stc.dynamic.deallocation)
- [\[basic.stc.dynamic.allocation\] — Allocation functions](https://eel.is/c++draft/basic.stc.dynamic.allocation)
- [\[expr.delete\] — Delete](https://eel.is/c++draft/expr.delete)
- [\[expr.new\] — New](https://eel.is/c++draft/expr.new)
- [\[new.delete.single\] — Single-object forms](https://eel.is/c++draft/new.delete.single)
- [\[basic.life\] — Lifetime](https://eel.is/c++draft/basic.life)
- [\[basic.indet\] — Indeterminate and erroneous values](https://eel.is/c++draft/basic.indet)
- [\[basic.types.general\] — Type representation, padding bits](https://eel.is/c++draft/basic.types.general)
- [\[basic.fundamental\] — Fundamental types (padding: unspecified value)](https://eel.is/c++draft/basic.fundamental)
- [\[conv.lval\] — Lvalue-to-rvalue conversion](https://eel.is/c++draft/conv.lval)
- [\[expr.typeid\] — Type identification (pengecualian nullptr)](https://eel.is/c++draft/expr.typeid)
- [\[structure.specifications\] — Arti "Preconditions"](https://eel.is/c++draft/structure.specifications)
- [\[defns.undefined\] — Definisi undefined behavior](https://eel.is/c++draft/defns.undefined)
- [\[defns.unspecified\] — Definisi unspecified behavior](https://eel.is/c++draft/defns.unspecified)
- [\[defns.erroneous\] — Definisi erroneous behavior](https://eel.is/c++draft/defns.erroneous)
- [Annex F \[ub\] — Core undefined behavior](https://eel.is/c++draft/ub)
  - [F.2.14 indeterminate value](https://eel.is/c++draft/ub:basic.indet.value)
  - [F.2.17 invalid pointer](https://eel.is/c++draft/ub:basic.compound.invalid.pointer)
  - [F.3.5 invalid value representation](https://eel.is/c++draft/ub:conv.lval.valid.representation)
  - [F.3.20 dereference](https://eel.is/c++draft/ub:expr.unary.dereference)
  - [F.3.22 delete mismatch](https://eel.is/c++draft/ub:expr.delete.mismatch)
  - [F.3.23 delete[] mismatch](https://eel.is/c++draft/ub:expr.delete.array.mismatch)

### Standar C++
- [N3337 (C++11) — expr.rel](https://timsong-cpp.github.io/cppwp/n3337/expr.rel)
- [N4659 (C++17) — basic.stc](https://timsong-cpp.github.io/cppwp/n4659/basic.stc)
- [N4950 (C++23) — basic.indet](https://timsong-cpp.github.io/cppwp/n4950/basic.indet)

### Standar C
- [N1570 (C11) — full text](http://port70.net/~nsz/c/c11/n1570.html) — 6.3.2.1, 6.2.6.1, 6.5.8, 6.5.9, 7.24.4.1
- [N3096 (C23 working draft, PDF)](https://www.open-std.org/jtc1/sc22/wg14/www/docs/n3096.pdf) — 6.2.4, 6.2.6.1, 6.5.8, 6.5.9, 7.26.4.1

### cppreference.com
- [Pointer declaration](https://en.cppreference.com/w/cpp/language/pointer) — null pointers, invalid pointers
- [Arithmetic operators](https://en.cppreference.com/w/cpp/language/operator_arithmetic) — pointer arithmetic
- [Comparison operators](https://en.cppreference.com/w/cpp/language/operator_comparison) — pointer comparison, total order
- [delete-expression](https://en.cppreference.com/w/cpp/language/delete)
- [new-expression](https://en.cppreference.com/w/cpp/language/new) — memory leaks
- [Default initialization](https://en.cppreference.com/w/cpp/language/default_initialization) — indeterminate/erroneous values
- [Undefined behavior](https://en.cppreference.com/w/cpp/language/ub) — UB and optimization
- [Objects and alignment](https://en.cppreference.com/w/cpp/language/object) — padding bits
- [std::memcmp](https://en.cppreference.com/w/cpp/string/byte/memcmp)
- [Lifetime](https://en.cppreference.com/w/cpp/language/lifetime)

### Dokumentasi compiler
- [GCC — Optimize Options § `-fdelete-null-pointer-checks`](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html)
- [Clang — UndefinedBehaviorSanitizer § `-fsanitize=null`](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html)

---

*Riset ini murni berbasis sumber primer. Tidak ada kode yang dijalankan dan tidak ada paket yang diinstal. Semua kutipan diverifikasi terhadap halaman yang ditautkan pada saat riset.*

/* automatically generated by rust-bindgen 0.69.4 */

#[repr(C)]
#[derive(Debug, Copy, Clone)]
pub struct FStar_Bytes_bytes {
    pub length: u32,
    pub data: *const ::std::os::raw::c_char,
}
#[test]
fn bindgen_test_layout_FStar_Bytes_bytes() {
    const UNINIT: ::std::mem::MaybeUninit<FStar_Bytes_bytes> = ::std::mem::MaybeUninit::uninit();
    let ptr = UNINIT.as_ptr();
    assert_eq!(
        ::std::mem::size_of::<FStar_Bytes_bytes>(),
        16usize,
        concat!("Size of: ", stringify!(FStar_Bytes_bytes))
    );
    assert_eq!(
        ::std::mem::align_of::<FStar_Bytes_bytes>(),
        8usize,
        concat!("Alignment of ", stringify!(FStar_Bytes_bytes))
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).length) as usize - ptr as usize },
        0usize,
        concat!(
            "Offset of field: ",
            stringify!(FStar_Bytes_bytes),
            "::",
            stringify!(length)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).data) as usize - ptr as usize },
        8usize,
        concat!(
            "Offset of field: ",
            stringify!(FStar_Bytes_bytes),
            "::",
            stringify!(data)
        )
    );
}
#[repr(C)]
#[derive(Debug, Copy, Clone)]
pub struct character_string_t_s {
    pub fst: u32,
    pub snd: FStar_Bytes_bytes,
}
#[test]
fn bindgen_test_layout_character_string_t_s() {
    const UNINIT: ::std::mem::MaybeUninit<character_string_t_s> = ::std::mem::MaybeUninit::uninit();
    let ptr = UNINIT.as_ptr();
    assert_eq!(
        ::std::mem::size_of::<character_string_t_s>(),
        24usize,
        concat!("Size of: ", stringify!(character_string_t_s))
    );
    assert_eq!(
        ::std::mem::align_of::<character_string_t_s>(),
        8usize,
        concat!("Alignment of ", stringify!(character_string_t_s))
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).fst) as usize - ptr as usize },
        0usize,
        concat!(
            "Offset of field: ",
            stringify!(character_string_t_s),
            "::",
            stringify!(fst)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).snd) as usize - ptr as usize },
        8usize,
        concat!(
            "Offset of field: ",
            stringify!(character_string_t_s),
            "::",
            stringify!(snd)
        )
    );
}
pub type character_string_t = character_string_t_s;
#[repr(C)]
#[derive(Debug, Copy, Clone)]
pub struct octet_string_t_s {
    pub len: u32,
    pub s: FStar_Bytes_bytes,
}
#[test]
fn bindgen_test_layout_octet_string_t_s() {
    const UNINIT: ::std::mem::MaybeUninit<octet_string_t_s> = ::std::mem::MaybeUninit::uninit();
    let ptr = UNINIT.as_ptr();
    assert_eq!(
        ::std::mem::size_of::<octet_string_t_s>(),
        24usize,
        concat!("Size of: ", stringify!(octet_string_t_s))
    );
    assert_eq!(
        ::std::mem::align_of::<octet_string_t_s>(),
        8usize,
        concat!("Alignment of ", stringify!(octet_string_t_s))
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).len) as usize - ptr as usize },
        0usize,
        concat!(
            "Offset of field: ",
            stringify!(octet_string_t_s),
            "::",
            stringify!(len)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).s) as usize - ptr as usize },
        8usize,
        concat!(
            "Offset of field: ",
            stringify!(octet_string_t_s),
            "::",
            stringify!(s)
        )
    );
}
pub type octet_string_t = octet_string_t_s;
#[repr(C)]
#[derive(Debug, Copy, Clone)]
pub struct deviceIDCSR_ingredients_t_s {
    pub ku: i32,
    pub version: i32,
    pub s_common: character_string_t,
    pub s_org: character_string_t,
    pub s_country: character_string_t,
}
#[test]
fn bindgen_test_layout_deviceIDCSR_ingredients_t_s() {
    const UNINIT: ::std::mem::MaybeUninit<deviceIDCSR_ingredients_t_s> =
        ::std::mem::MaybeUninit::uninit();
    let ptr = UNINIT.as_ptr();
    assert_eq!(
        ::std::mem::size_of::<deviceIDCSR_ingredients_t_s>(),
        80usize,
        concat!("Size of: ", stringify!(deviceIDCSR_ingredients_t_s))
    );
    assert_eq!(
        ::std::mem::align_of::<deviceIDCSR_ingredients_t_s>(),
        8usize,
        concat!("Alignment of ", stringify!(deviceIDCSR_ingredients_t_s))
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).ku) as usize - ptr as usize },
        0usize,
        concat!(
            "Offset of field: ",
            stringify!(deviceIDCSR_ingredients_t_s),
            "::",
            stringify!(ku)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).version) as usize - ptr as usize },
        4usize,
        concat!(
            "Offset of field: ",
            stringify!(deviceIDCSR_ingredients_t_s),
            "::",
            stringify!(version)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).s_common) as usize - ptr as usize },
        8usize,
        concat!(
            "Offset of field: ",
            stringify!(deviceIDCSR_ingredients_t_s),
            "::",
            stringify!(s_common)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).s_org) as usize - ptr as usize },
        32usize,
        concat!(
            "Offset of field: ",
            stringify!(deviceIDCSR_ingredients_t_s),
            "::",
            stringify!(s_org)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).s_country) as usize - ptr as usize },
        56usize,
        concat!(
            "Offset of field: ",
            stringify!(deviceIDCSR_ingredients_t_s),
            "::",
            stringify!(s_country)
        )
    );
}
pub type deviceIDCSR_ingredients_t = deviceIDCSR_ingredients_t_s;
#[repr(C)]
#[derive(Debug, Copy, Clone)]
pub struct aliasKeyCRT_ingredients_t_s {
    pub version1: i32,
    pub serialNumber: octet_string_t,
    pub i_common: character_string_t,
    pub i_org: character_string_t,
    pub i_country: character_string_t,
    pub notBefore: FStar_Bytes_bytes,
    pub notAfter: FStar_Bytes_bytes,
    pub s_common1: character_string_t,
    pub s_org1: character_string_t,
    pub s_country1: character_string_t,
    pub ku1: i32,
    pub l0_version: i32,
}
#[test]
fn bindgen_test_layout_aliasKeyCRT_ingredients_t_s() {
    const UNINIT: ::std::mem::MaybeUninit<aliasKeyCRT_ingredients_t_s> =
        ::std::mem::MaybeUninit::uninit();
    let ptr = UNINIT.as_ptr();
    assert_eq!(
        ::std::mem::size_of::<aliasKeyCRT_ingredients_t_s>(),
        216usize,
        concat!("Size of: ", stringify!(aliasKeyCRT_ingredients_t_s))
    );
    assert_eq!(
        ::std::mem::align_of::<aliasKeyCRT_ingredients_t_s>(),
        8usize,
        concat!("Alignment of ", stringify!(aliasKeyCRT_ingredients_t_s))
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).version1) as usize - ptr as usize },
        0usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(version1)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).serialNumber) as usize - ptr as usize },
        8usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(serialNumber)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).i_common) as usize - ptr as usize },
        32usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(i_common)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).i_org) as usize - ptr as usize },
        56usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(i_org)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).i_country) as usize - ptr as usize },
        80usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(i_country)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).notBefore) as usize - ptr as usize },
        104usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(notBefore)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).notAfter) as usize - ptr as usize },
        120usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(notAfter)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).s_common1) as usize - ptr as usize },
        136usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(s_common1)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).s_org1) as usize - ptr as usize },
        160usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(s_org1)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).s_country1) as usize - ptr as usize },
        184usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(s_country1)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).ku1) as usize - ptr as usize },
        208usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(ku1)
        )
    );
    assert_eq!(
        unsafe { ::std::ptr::addr_of!((*ptr).l0_version) as usize - ptr as usize },
        212usize,
        concat!(
            "Offset of field: ",
            stringify!(aliasKeyCRT_ingredients_t_s),
            "::",
            stringify!(l0_version)
        )
    );
}
pub type aliasKeyCRT_ingredients_t = aliasKeyCRT_ingredients_t_s;
extern crate libloading;
pub struct l0 {
    __library: ::libloading::Library,
    pub l0: unsafe extern "C" fn(
        cdi: *mut u8,
        fwid: *mut u8,
        deviceID_label_len: u32,
        deviceID_label: *mut u8,
        aliasKey_label_len: u32,
        aliasKey_label: *mut u8,
        deviceIDCSR_ingredients: deviceIDCSR_ingredients_t,
        aliasKeyCRT_ingredients: aliasKeyCRT_ingredients_t,
        deviceID_pub: *mut u8,
        aliasKey_pub: *mut u8,
        aliasKey_priv: *mut u8,
        deviceIDCSR_len: u32,
        deviceIDCSR_buf: *mut u8,
        aliasKeyCRT_len: u32,
        aliasKeyCRT_buf: *mut u8,
    ),
}
impl l0 {
    pub unsafe fn new<P>(path: P) -> Result<Self, ::libloading::Error>
    where
        P: AsRef<::std::ffi::OsStr>,
    {
        let library = ::libloading::Library::new(path)?;
        Self::from_library(library)
    }
    pub unsafe fn from_library<L>(library: L) -> Result<Self, ::libloading::Error>
    where
        L: Into<::libloading::Library>,
    {
        let __library = library.into();
        let l0 = __library.get(b"l0\0").map(|sym| *sym)?;
        Ok(l0 { __library, l0 })
    }
    pub unsafe fn l0(
        &self,
        cdi: *mut u8,
        fwid: *mut u8,
        deviceID_label_len: u32,
        deviceID_label: *mut u8,
        aliasKey_label_len: u32,
        aliasKey_label: *mut u8,
        deviceIDCSR_ingredients: deviceIDCSR_ingredients_t,
        aliasKeyCRT_ingredients: aliasKeyCRT_ingredients_t,
        deviceID_pub: *mut u8,
        aliasKey_pub: *mut u8,
        aliasKey_priv: *mut u8,
        deviceIDCSR_len: u32,
        deviceIDCSR_buf: *mut u8,
        aliasKeyCRT_len: u32,
        aliasKeyCRT_buf: *mut u8,
    ) {
        (self.l0)(
            cdi,
            fwid,
            deviceID_label_len,
            deviceID_label,
            aliasKey_label_len,
            aliasKey_label,
            deviceIDCSR_ingredients,
            aliasKeyCRT_ingredients,
            deviceID_pub,
            aliasKey_pub,
            aliasKey_priv,
            deviceIDCSR_len,
            deviceIDCSR_buf,
            aliasKeyCRT_len,
            aliasKeyCRT_buf,
        )
    }
}

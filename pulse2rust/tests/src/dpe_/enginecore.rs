////
////
//// This file is generated by the Pulse2Rust tool
////
////

pub fn authenticate_l0_image(
    mut record: super::enginetypes::engine_record_t,
    repr: (),
    p: (),
) -> (super::enginetypes::engine_record_t, bool) {
    let valid_header_sig = super::hacl::ed25519_verify(
        &mut record.l0_image_auth_pubkey,
        &mut record.l0_image_header,
        record.l0_image_header_size,
        &mut record.l0_image_header_sig,
        (),
        (),
        (),
        (),
        (),
        (),
    );
    let mut b = false;
    let b1 = if valid_header_sig {
        let hash_buf = &mut [0; 32];
        super::hacl::hacl_hash(
            super::hacl::dice_hash_alg0(()),
            record.l0_binary_size,
            &mut record.l0_binary,
            hash_buf,
            (),
            (),
            (),
        );
        let res = super::pulse_lib_array::compare(
            32,
            hash_buf,
            &mut record.l0_binary_hash,
            (),
            (),
            (),
            (),
        );
        let res1 = (record, res);
        let hash_buf1 = res1;
        hash_buf1
    } else {
        let res = (record, false);
        res
    };
    b1
}
pub fn compute_cdi(
    cdi: &mut [u8],
    uds: &mut [u8],
    mut record: super::enginetypes::engine_record_t,
    uds_perm: (),
    p: (),
    uds_bytes: (),
    __c0: (),
    __repr: (),
) -> super::enginetypes::engine_record_t {
    let uds_digest = &mut [0; 32];
    let l0_digest = &mut [0; 32];
    super::hacl::hacl_hash(
        super::hacl::dice_hash_alg0(()),
        super::enginetypes::uds_len,
        uds,
        uds_digest,
        (),
        (),
        (),
    );
    super::hacl::hacl_hash(
        super::hacl::dice_hash_alg0(()),
        record.l0_binary_size,
        &mut record.l0_binary,
        l0_digest,
        (),
        (),
        (),
    );
    super::hacl::hacl_hmac(
        super::hacl::dice_hash_alg0(()),
        cdi,
        uds_digest,
        32,
        l0_digest,
        32,
        (),
        (),
        (),
        (),
        (),
    );
    let l0_digest1 = record;
    let uds_digest1 = l0_digest1;
    uds_digest1
}
pub fn engine_main(
    cdi: &mut [u8],
    uds: &mut [u8],
    record: super::enginetypes::engine_record_t,
    c0: (),
    repr: (),
    uds_perm: (),
    p: (),
    uds_bytes: (),
) -> (super::enginetypes::engine_record_t, super::enginetypes::dice_return_code) {
    let b = super::enginecore::authenticate_l0_image(record, (), ());
    if b.1 {
        let record1 = super::enginecore::compute_cdi(cdi, uds, b.0, (), (), (), (), ());
        let res = (record1, super::enginetypes::dice_return_code::DICE_SUCCESS);
        res
    } else {
        let res = (b.0, super::enginetypes::dice_return_code::DICE_ERROR);
        res
    }
}


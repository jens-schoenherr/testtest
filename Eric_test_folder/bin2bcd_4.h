//--------------------------------------------------------------------------------
// Author: Eric Haertel, Jens Schoenherr
//         HTW Dresden
//
// Declarations for bin2bcd_4.cpp
//--------------------------------------------------------------------------------

const unsigned int bin_bits_c = 13;
const unsigned int bcd_bits_c = 16;
extern void bin2bcd_4(ap_uint<bin_bits_c> bin, ap_uint<bcd_bits_c> &bcd);

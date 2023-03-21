//--------------------------------------------------------------------------------
// Author: Eric Haertel, Jens Schoenherr
//         HTW Dresden
//
// example for synthesis of bin2bcd with HLS
//--------------------------------------------------------------------------------
#include <iostream>
#include <ap_int.h>
#include "bin2bcd.h"
#include "bin2bcd_4.h"

void bin2bcd_4(ap_uint<bin_bits_c> bin, ap_uint<bcd_bits_c> &bcd)
{
  
  bin2bcd(bin, bcd);

}
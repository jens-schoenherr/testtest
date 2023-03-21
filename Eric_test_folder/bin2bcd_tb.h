//--------------------------------------------------------------------------------
// Author: Eric Haertel, Jens Schoenherr
//         HTW Dresden
//
// Library with helper functions for testbenches, not to be used in HLS
//--------------------------------------------------------------------------------


// return the number of bits needed to represent "input" as unsigned binary number
constexpr inline unsigned unsigned_num_bits(unsigned input)
{
    unsigned nbits = 1;
    unsigned n = input;
    while (n > 1) {
        nbits++;
        n = n / 2;
    }
    return nbits;

}

// return the number of bits needed to represent "input" as BCD (unsignend)
constexpr inline unsigned unsigned_bin_num_bits_bcd_v2(unsigned input)
{
    unsigned bits = 1;
    unsigned factor = 10;
    while((input / factor) != 0)
    {
        bits++;
        factor *= 10;
    }
    return  bits * 4;
}

//--------------------------------------------------------------------------------
// Author: Eric Haertel, Jens Schoenherr
//         HTW Dresden
//
// Library with generic functions to convert ap_uint between binary and bcd
//--------------------------------------------------------------------------------
#include <iostream>
#include <ap_int.h>
#define max(a, b) ( ((a) > (b)) ? (a) : (b) )
#define min(a, b) ( ((a) > (b)) ? (b) : (a) )

#define unsigned_bin_num_dets(input)     ( ((input)*10000+33219-1) / 33219 )
#define unsigned_bin_num_bits_bcd(input) ( unsigned_bin_num_dets(input)*4  )
#define next_4(input)                    ( input + ((4 - (input % 4)) % 4) )

template<int T>
ap_uint<5> add_bcd_digit(ap_uint<T> a, ap_uint<T> b, bool c, unsigned int version = 1)
{
    ap_uint<5> res;
    ap_uint<5> res_a;
    ap_uint<5> res_b;
    ap_uint<1> ci = c;
#ifndef __SYNTHESIS__
    if (a.length() != 4)
        {
        std::cout << std::endl << "Error: Vector A is not a 4-bit vector" << std::endl;
        return 0;
        }
    if (b.length() != 4)
    {
        std::cout << std::endl << "Error: Vector B is not a 4-bit vector" << std::endl;
        return 0;
    }
    if (a > 9)
    {
        std::cout << std::endl << "Error: Vector A is (> 9)" << std::endl;
        return 0;
    }
    if (b > 9)
    {
        std::cout << std::endl << "Error: Vector B is (> 9)" << std::endl;
        return 0;
    }
#endif
    res_a = a+b+ci;
    res_b = a+b+ci+6;
    switch (version) {
      case 1: 
        if (res_b[4] == 0)
        {
          res = res_a;
        } else {
          res = res_b;
        }
        break;
      case 2: 
        if (res_b[4] == 0)
        {
          res = res_b - 6;
        } else {
          res = res_b;
        }
        break;
      case 3: 
        if (res_a(4, 1) >= 5)
        {
          res = res_b;
        } else {
          res = res_a;
        }
        break;
      case 4: 
        if (res_a(4, 1) >= 5)
        {
          res = res_a + 6;
        } else {
          res = res_a;
        }
        break;
      case 5: 
        if (res_a(4, 1) >= 5)
        {
          res = res_a - 10;
          res[4] = 1;
        } else {
          res = res_a;
        }
        break;
    }
    return res;
}

// add two bcd numbers a and b
// requires same size for a and b
template<int T>
ap_uint<T+4> add_bcd_v0(ap_uint<T> a, ap_uint<T> b)
{
    const unsigned res_width = max(next_4(a.length()),next_4(b.length()))+1;
    //ap_uint<res_width> res = 0; nicht nutzbar da res_width nicht const
    ap_uint<T+4> res = 0; //notloesung
    const unsigned iter = (res_width-1) / 4;
    ap_uint<5> bcd_sum = 0;

    ap_uint<4> a_temp;
    ap_uint<4> b_temp;


    for(int i = 0; i<iter; ++i)
    {
        a_temp(3, 0) = a(4*i+3, 4*i);
        b_temp(3, 0) = b(4*i+3, 4*i);
        bcd_sum = add_bcd_digit(a_temp, b_temp, bcd_sum[4]);
        res(4*i+3, 4*i) = bcd_sum(3, 0);
    }
    return res;
}

// add two bcd numbers a and b
template<
        int T1,
        int T2,
        int T3 = max(T1, T2)+4
>
ap_uint<T3> add_bcd(ap_uint<T1> a, ap_uint<T2> b)
{
    ap_uint<T3> res = 0;
    const unsigned iter = T3 / 4;
    ap_uint<5> bcd_sum = 0;
    ap_uint<T3> a_scaled_up = a;
    ap_uint<T3> b_scaled_up = b;
    ap_uint<4> a_temp;
    ap_uint<4> b_temp;
    //std::cout << std::endl << "size a: " << T1 << "  size b: " << T2 << "  size res: " << T3 << std::endl ;

    for(int i = 0; i<iter; i++)
    {
        a_temp(3, 0) = a_scaled_up(4*i+3, 4*i);
        b_temp(3, 0) = b_scaled_up(4*i+3, 4*i);
        bcd_sum = add_bcd_digit(a_temp, b_temp, bcd_sum[4]);
        res(4*i+3, 4*i) = bcd_sum(3, 0);
    }
    return res;
}

template<int T1, int T2>
void bin2bcd(ap_uint<T1> bin, ap_uint<T2> &bcd)
{
    // const unsigned n_dets_c = unsigned_bin_num_dets(bin.length()); //entfaellt =^= T2 / 4
    // const unsigned r_width_c = 4 * n_dets_c; //entfaellt =^= T2
    // a_v enfaellt =^= bin
    ap_uint<T2> res = 0;
    ap_uint<T2> dec = 1;

    for(int i = 0; i < T1; i++)
    {
        if(bin[i] == 1)
        {
          res = add_bcd(res, dec);
        }
        dec = add_bcd(dec, dec);
    }
    bcd = res;
}

template<int T1, int T2>
void bcd2bin(ap_uint<T1> bcd, ap_uint<T2> &bin)
{
  ap_uint<4> temp;
  
  bin = 0;
  for(int i = (T1 / 4)-1; i >= 0; --i)
  {
    temp = bcd(4*i+3, 4*i);
    bin = (bin * 10) + temp;
  }
}

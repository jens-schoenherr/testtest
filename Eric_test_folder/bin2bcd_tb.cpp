//--------------------------------------------------------------------------------
// Author: Eric Haertel, Jens Schoenherr
//         HTW Dresden
//
// testbench for bin2bcd.h
//--------------------------------------------------------------------------------
#include <iostream>
#include <ap_int.h>
#include "bin2bcd.h"
#include "bin2bcd_tb.h"
#include "bin2bcd_4.h"

template<int T>
void ap_print(ap_uint<T> input)
{
    std::cout << "Dezimal (dumb): [" << input << "]" << std::endl << "Binaer (dumb):  [";
    for(int i = input.length()-1; i >= 0; i--)
    {
        std::cout << input[i];
    }
    std::cout << "]" << std::endl;
    if((input.length() % 4) == 0)
    {
        std::cout << "BCD (dumb): [  ";
        int iter = input.length() / 4;
        int idx;
        for(int i = 0 ; i < iter; i++)
        {
            idx = (iter - 1 - i);
            ap_uint<4> temp = 0;
            for (int i2 = 0; i2 < 4; i2++)
            {
                temp[i2] = input[idx*4 + i2];
                std::cout << input[idx*4 + 3 - i2];
            }
            std::cout << "(" << temp << ")  ";
        }
        std::cout << "]" << std::endl;
    }

}

template<int T>
void bcd_print(ap_uint<T> input) {
    std::cout << "BCD (dumb): [  ";
    int iter = input.length() / 4;
    int idx;
    for (int i = 0; i < iter; i++) {
        idx = (iter - 1 - i);
        ap_uint<4> temp = 0;
        for (int i2 = 0; i2 < 4; i2++) {
            temp[i2] = input[idx * 4 + i2];
            std::cout << input[idx*4 + 3 - i2];
        }
        std::cout << "(" << temp << ")  ";
    }
    std::cout << "]" << std::endl;
}

int next_4_tb()
{
    std::cout << "Test next_4():                           ";
    std::cout.flush();

    unsigned max = 20;
    int passes = 0;
    for(int i = 0; i < max; i++)
    {
        unsigned res = next_4(i);
        if(((res - i) < 4) && ((res % 4) == 0))
        {
            passes++;
        }
    }
    if(passes == max)
    {
        std::cout << "Pass" << std::endl;
        return 0;
    }
    else
    {
        std::cout << "Fail" << std::endl;
        return 1;
    }
}

int unsigned_num_bits_tb()
{
    std::cout << "Test unsigned_num_bits():                ";
    std::cout.flush();

    int passes = 0;
    int max = 508874;
    for (unsigned i = 1; i <= max ; i++)
    {
        unsigned res = unsigned_num_bits(i);
        unsigned bin_fact = 1;
        for (int i2 = 1; i2 < res; i2++) {
            bin_fact *= 2;
        }
        int bin_fact_p1 = bin_fact * 2;
        int bin_fact_m1 = bin_fact / 2;
        if ((i < bin_fact_p1) && (i > bin_fact_m1)) { passes++; }
    }
    if(passes == max)
    {
      std::cout << "Pass" << std::endl;
    } else {
    	std::cout << "Fail" << std::endl;
    }
    return max - passes;
}

int unsigned_bin_num_bits_bcd_v2_tb()
{
    std::cout << "Test unsigned_bin_num_bits_bcd_v2():     ";
    std::cout.flush();

    int passes = 0;
    int max = 11111;
    for (unsigned i = 1; i <= max ; i++)
    {
        unsigned res = unsigned_bin_num_bits_bcd_v2(i) / 4;
        unsigned bin_fact = 1;
        for (int i2 = 1; i2 < res; i2++) {
            bin_fact *= 10;
        }
        int bin_fact_p1 = bin_fact * 10;
        int bin_fact_m1 = bin_fact / 10;
        if ((i < bin_fact_p1) && (i > bin_fact_m1))
        { passes++; }
    }
    if(passes == max)
    {
      std::cout << "Pass" << std::endl;
    } else {
    	std::cout << "Fail" << std::endl;
    }
    return max - passes;
}

int add_bcd_digit_tb()
{
    std::cout << "Test add_bcd_digit():                    ";
    std::cout.flush();

    int passes= 0;
    const int num_versions = 5;
    const int num_passes = num_versions*10*10*2;
    for (unsigned int version=1; version<=num_versions; ++version)
    {
      for(int i1 = 0; i1 < 10; i1++)
      {
          ap_uint<4> v1 = i1;
          for(int i2 = 0; i2 < 10; i2++)
          {
              ap_uint<4> v2 = i2;
              for (int i3 = 0; i3 < 2; i3++)
              {
                ap_uint<5> res = add_bcd_digit(v1, v2, i3);
                /*std::cout << "input A: " << i1 << "  ";
                bcd_print(v1);
                std::cout << "input B: " << i2 << "  ";
                bcd_print(v2);
                std::cout << "input C: " << i3 << "  ";
                std::cout  << "Result: " << res << "  " << std::endl;
                ap_print(res);
                std::cout  << std::endl;*/
                ap_uint<4> res0 = res(3, 0);
                ap_uint<1> res1 = res[4];
                if (10*res1 + res0 == i1 + i2 + i3) {
                    passes++;
                }
                /*if ( res == i + i2)
                {std::cout << "pass";} */
              }
          }
      }
    }
    //std::cout << passes;
    if(passes == num_passes)
    {
      std::cout << "Pass" << std::endl;
    } else {
    	std::cout << "Fail" << std::endl;
    }
    return num_passes - passes;
}

int add_bcd_tb()
{
    std::cout << "Test add_bcd():                          ";
    std::cout.flush();

    int passes = 0;
    ap_uint<12> A = 1384; //entspr. "010101101000" = "568"
    ap_uint<16> B = 28981; //entspr. "‭0111000100110101‬" = "‭7135‬"

    ap_uint<20> Res = add_bcd(A,B);

    if(Res == 30467) //entspr. "‭0111011100000011‬" = "7703"
    {passes++;}
    else
    {std::cout << "Wrong Result, adding [5 6 8] and [7 1 3 5]" << std::endl;}

    ap_uint<8> A2 = 36; //entspr. "‭00100100‬" = "24"
    ap_uint<12> B2 = 256; //entspr. "‭000100000000‬‬" = "100‬"

    ap_uint<16> Res2 = add_bcd(A2,B2);
    if(Res2 == 292) //entspr. "‭000100100100‬‬" = "124"
    {passes++;}
    else
    {std::cout << "Wrong Result, adding [2 4] and [1 0 0]" << std::endl;}

    ap_uint<16> A3 = 39321; //entspr. "‭1001100110011001‬‬" = "9999"
    ap_uint<12> B3 = 1352; //entspr. "‭010101001000‬‬‬" = "548‬"

    ap_uint<20> Res3 = add_bcd(A3,B3);
    if(Res3 == 66887) //entspr. "‭00010000010101000111‬‬‬" = "10547"
    {passes++;}
    else
    {std::cout << "Wrong Result, adding [9 9 9 9] and [5 4 8]" << std::endl;}

    ap_uint<32> A4 = 2576980377; //entspr. "‭10011001100110011001100110011001‬‬‬" = "99999999"
    ap_uint<12> B4 = 2; //entspr. "‭0010‬‬‬" = "2‬"

    ap_uint<36> Res4 = add_bcd(A4,B4);
    if(Res4 == 4294967297) //entspr. "‭000100000000000000000000000000000001‬‬‬‬" = "100000001"
    {passes++;}
    else
    {std::cout << "Wrong Result, adding [9 9 9 9 9 9 9 9] and [2]" << std::endl;}

    ap_uint<32> A5 = 2576980377; //entspr. "‭10011001100110011001100110011001‬‬‬" = "99999999"
    ap_uint<12> B5 = 2; //entspr. "‭0010‬‬‬" = "2‬"

    ap_uint<36> Res5 = add_bcd(B5,A5);
    if(Res5 == 4294967297) //entspr. "‭000100000000000000000000000000000001‬‬‬‬" = "100000001"
    {passes++;}
    else
    {std::cout << "Wrong Result, adding [2] and [9 9 9 9 9 9 9 9]" << std::endl;}

    ap_uint<4> A6 = 9; //entspr. "1001‬‬‬" = "9"
    ap_uint<4> B6 = 4; //entspr. "‭0100‬‬‬" = "4‬"

    ap_uint<8> Res6 = add_bcd(B6,A6);
    if(Res6 == 19) //entspr. "00010011‬‬‬‬" = "13"
    {passes++;}
    else
    {std::cout << "Wrong Result, adding [2] and [9 9 9 9 9 9 9 9]" << std::endl;}

    const unsigned int i1_num = 1000;
    const unsigned int i2_num = i1_num;
    for (unsigned int i1 = 0; i1 < i1_num; ++i1) {
      for (unsigned int i2 = 0; i2 < i2_num; ++i2) {
        ap_uint<12> i1_bcd;
        ap_uint<12> i2_bcd;
        unsigned int i1_tmp = i1;
        unsigned int i2_tmp = i2;
        for (unsigned int i = 0; i < 3; ++i) {
          i1_bcd(i*4+3, i*4) = i1_tmp % 10;
          i2_bcd(i*4+3, i*4) = i2_tmp % 10;
          i1_tmp = i1_tmp / 10;
          i2_tmp = i2_tmp / 10;
        }
        ap_uint<16> res;
        res = add_bcd(i1_bcd, i2_bcd);
        unsigned int r = 0;
        for (int i = 3; i >= 0; --i) {
          r = (10*r) + res(i*4+3, i*4);
        }
        if (r == (i1 + i2)) {
          passes++;
        } else {
          std::cout << "Wrong result, adding " << i1 << " and " << i2 << " leads to " << r /*<< "  " << std::hex << res << std::dec*/ << std::endl;
        }
      }
    }

    if(passes == 6 + (i1_num * i2_num))
    {
        std::cout << "Pass" << std::endl;
        return 0;
    }
    else
    {
        std::cout << "Fail" << std::endl;
        return 1;
    }
}

int bin2bcd_tb()
{
    std::cout << "Test bin2bcd():                          ";
    std::cout.flush();

    const int max = 100;
    const int bin_c =  unsigned_num_bits(max);
    const int bcd_c =  unsigned_bin_num_bits_bcd_v2(max);
    ap_uint<bin_c> Bin_Input;
    ap_uint<bcd_c> BCD_Output;
    ap_uint<4> Temp;
    int Factor;
    int Result;
    int passes=0;
    for(int i = 0;i <= max; i++)
    {
        Bin_Input = i;
        bin2bcd(Bin_Input, BCD_Output);
        Factor = 1;
        Result = 0;
        for(int i2 = 0; i2 < bcd_c/4 ; i2++)
        {
            for(int i3 = 0; i3<4; i3++)
            {
                Temp[i3] = BCD_Output[i2*4+i3];
            }
            Result += (Temp * Factor);
            Factor *= 10;
        }
        if(Result == i){passes++;}
    }

    if(passes == max + 1)
    {
      std::cout << "Pass" << std::endl;
    } else {
    	std::cout << "Fail" << std::endl;
    }
    return max - passes + 1;
}

int bcd2bin_tb()
{
  std::cout << "Test bcd2bin():                          ";
  std::cout.flush();

  int passes=0;
  const unsigned int a_num = 10000;
  for (unsigned int a = 0; a < a_num; ++a) {
    ap_uint<16> a_bcd = 0;
    unsigned a_tmp = a;
    for (int i=0; i<4; ++i) {
      a_bcd(4*i+3, 4*i) = a_tmp % 10;
      a_tmp = a_tmp / 10;
    }
    ap_uint<14> a_us14;
    bcd2bin(a_bcd, a_us14);
    if (a_us14 == a) {
      passes++;      
      //std::cout << "Right result, converting bcd " << a << "  " << std::hex << a_bcd << std::dec << " to binary leads to " << a_us14  << std::endl;
    } else {
      std::cout << "Wrong result, converting bcd " << a << "  " << std::hex << a_bcd << std::dec << " to binary leads to " << a_us14  << std::endl;
    }
  }

  if(passes == a_num)
  {
    std::cout << "Pass" << std::endl;
  } else {
    std::cout << "Fail" << std::endl;
  }
  return a_num - passes;
}

int bin2bcd_4_tb()
{
  std::cout << "Test bin2bcd_4():                        ";
  std::cout.flush();

  int res = 0;

  ap_uint<bin_bits_c> bin;
  ap_uint<bcd_bits_c> bcd;
    
  if ((bin_bits_c == 13) && (bcd_bits_c == 16)) {
    bin = 3000;
    bin2bcd_4(bin, bcd);
    if (bcd != 0x3000) {
      res = 1;
    }
  } else if ((bin_bits_c == 6) && (bcd_bits_c == 8)) {
    bin = 45;
    bin2bcd_4(bin, bcd);
    if (bcd != 0x45) {
      res = 1;
    }
  }
  
  if (res == 0)
  {
    std::cout << "Pass" << std::endl;
  } else {
	  std::cout << "Fail" << std::endl;
  }

  return res;
}


int main() {
  
  int res = 0;
  
  std::cout << std::endl;

  res |= next_4_tb();
  res |= unsigned_num_bits_tb();
  res |= unsigned_bin_num_bits_bcd_v2_tb();
  res |= add_bcd_digit_tb();
  res |= add_bcd_tb();
  res |= bin2bcd_tb();
  res |= bcd2bin_tb();
  res |= bin2bcd_4_tb();
  
  std::cout << std::endl;
  if (res == 0) {
    std::cout << "   All tests passed." << std::endl;
  } else {
    std::cout << "   Some tests failed." << std::endl;
  }
  std::cout << std::endl;
    
  return res;
}


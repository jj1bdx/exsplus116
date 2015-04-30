/* Xorshift116+ */
/*  Modified code from the one
    written in 2014 by Sebastiano Vigna (vigna@acm.org)
    by Kenji Rikitake (kenji.rikitake@acm.org)

To the extent possible under law, the authors have dedicated all copyright
and related and neighboring rights to this software to the public domain
worldwide. This software is distributed without any warranty.

See <http://creativecommons.org/publicdomain/zero/1.0/>. */

#include <stdint.h>

#define UINT58MASK (uint64_t)((1ULL << 58) - 1)

/* The state must be seeded so that it is not everywhere zero. If you have
   a 58-bit seed, we suggest to pass it twice through MurmurHash3's
   avalanching function. */

uint64_t s[ 2 ];

uint64_t next(void) { 
	uint64_t s1 = s[ 0 ];
	const uint64_t s0 = s[ 1 ];
	s[ 0 ] = s0;
	s1 ^= (s1 << 24) & UINT58MASK ; // a
	return ((( s[ 1 ] = ( s1 ^ s0 ^ ( s1 >> 11 ) ^ ( s0 >> 41 ) ) ) + s0) & UINT58MASK) ; // b, c
}

#ifndef _STDINT_H_
#define _STDINT_H_

typedef char int8_t;
typedef short int16_t;
typedef int int32_t;

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

typedef int32_t intptr_t;
typedef uint32_t uintptr_t;
//typedef int32_t ptrdiff_t;
//typedef uint32_t size_t;
typedef int32_t ssize_t;

typedef long intmax_t;

#define NULL (void *)(0ul)

#endif

// math.d
/*
 *  Copyright (C) 2001-2005 by Digital Mars, www.digitalmars.com
 *  Written by Walter Bright
 *
 *  This software is provided 'as-is', without any express or implied
 *  warranty. In no event will the authors be held liable for any damages
 *  arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute it
 *  freely, subject to the following restrictions:
 *
 *  o  The origin of this software must not be misrepresented; you must not
 *     claim that you wrote the original software. If you use this software
 *     in a product, an acknowledgment in the product documentation would be
 *     appreciated but is not required.
 *  o  Altered source versions must be plainly marked as such, and must not
 *     be misrepresented as being the original software.
 *  o  This notice may not be removed or altered from any source
 *     distribution.
 */

module std.math;

//debug=math;		// uncomment to turn on debugging printf's

private import std.c.stdio;
private import std.c.math;

/* Intrinsics */

real cos(real);
real sin(real);
real fabs(real);
real rint(real);
long rndtol(real);
real ldexp(real, int);

float sqrt(float);
double sqrt(double);
real sqrt(real);
//creal sqrt(creal);

real acos(real x)		{ return std.c.math.acosl(x); }
real asin(real x)		{ return std.c.math.asinl(x); }
real atan(real x)		{ return std.c.math.atanl(x); }
real atan2(real x, real y)	{ return std.c.math.atan2l(x,y); }
real cosh(real x)		{ return std.c.math.coshl(x); }
real sinh(real x)		{ return std.c.math.sinhl(x); }
real tanh(real x)		{ return std.c.math.tanhl(x); }

//real acosh(real x)		{ return std.c.math.acoshl(x); }
//real asinh(real x)		{ return std.c.math.asinhl(x); }
//real atanh(real x)		{ return std.c.math.atanhl(x); }

real exp(real x)		{ return std.c.math.expl(x); }
real exp2(real x)		{ return std.c.math.exp2l(x); }
real expm1(real x)		{ return std.c.math.expm1l(x); }
int  ilogb(real x)		{ return std.c.math.ilogbl(x); }
real log(real x)		{ return std.c.math.logl(x); }
real log10(real x)		{ return std.c.math.log10l(x); }
real log1p(real x)		{ return std.c.math.log1pl(x); }
real log2(real x)		{ return std.c.math.log2l(x); }
real logb(real x)		{ return std.c.math.logbl(x); }
real modf(real x, inout real y)	{ return std.c.math.modfl(x,&y); }
real cbrt(real x)		{ return std.c.math.cbrtl(x); }
real erf(real x)		{ return std.c.math.erfl(x); }
real erfc(real x)		{ return std.c.math.erfcl(x); }
real ceil(real x)		{ return std.c.math.ceill(x); }
real floor(real x)		{ return std.c.math.floorl(x); }

const real PI =		0x1.921fb54442d1846ap+1;	// 3.14159 fldpi
const real LOG2T =	0x1.a934f0979a3715fcp+1;	// 3.32193 fldl2t
const real LOG2E =	0x1.71547652b82fe178p+0;	// 1.4427 fldl2e
const real LOG2 =	0x1.34413509f79fef32p-2;	// 0.30103 fldlg2
const real LN2 =	0x1.62e42fefa39ef358p-1;	// 0.693147 fldln2
const real E =		2.7182818284590452354L;
const real LOG10E =	0.43429448190325182765;
const real LN10 =	2.30258509299404568402;
const real PI_2 =	1.57079632679489661923;
const real PI_4 =	0.78539816339744830962;
const real M_1_PI =	0.31830988618379067154;
const real M_2_PI =	0.63661977236758134308;
const real M_2_SQRTPI =	1.12837916709551257390;
const real SQRT2 =	1.41421356237309504880;
const real SQRT1_2 =	0.70710678118654752440;

/*
	Octal versions:
	PI/64800	0.00001 45530 36176 77347 02143 15351 61441 26767
	PI/180		0.01073 72152 11224 72344 25603 54276 63351 22056
	PI/8		0.31103 75524 21026 43021 51423 06305 05600 67016
	SQRT(1/PI)	0.44067 27240 41233 33210 65616 51051 77327 77303
	2/PI		0.50574 60333 44710 40522 47741 16537 21752 32335
	PI/4		0.62207 73250 42055 06043 23046 14612 13401 56034
	SQRT(2/PI)	0.63041 05147 52066 24106 41762 63612 00272 56161

	PI		3.11037 55242 10264 30215 14230 63050 56006 70163
	LOG2		0.23210 11520 47674 77674 61076 11263 26013 37111
 */


/*********************************
 * Is number a nan?
 */

int isnan(real e)
{
    ushort* pe = cast(ushort *)&e;
    ulong*  ps = cast(ulong *)&e;

    return (pe[4] & 0x7FFF) == 0x7FFF &&
	    *ps & 0x7FFFFFFFFFFFFFFF;
}

unittest
{
    assert(isnan(float.nan));
    assert(isnan(-double.nan));
    assert(isnan(real.nan));

    assert(!isnan(53.6));
    assert(!isnan(float.infinity));
}

/*********************************
 * Is number finite?
 */

int isfinite(real e)
{
    ushort* pe = cast(ushort *)&e;

    return (pe[4] & 0x7FFF) != 0x7FFF;
}

unittest
{
    assert(isfinite(1.23));
    assert(!isfinite(double.infinity));
    assert(!isfinite(float.nan));
}


/*********************************
 * Is number normalized?
 * Need one for each format because subnormal floats might
 * be converted to normal reals.
 */

int isnormal(float f)
{
    uint *p = cast(uint *)&f;
    uint e;

    e = *p & 0x7F800000;
    //printf("e = x%x, *p = x%x\n", e, *p);
    return e && e != 0x7F800000;
}

int isnormal(double d)
{
    uint *p = cast(uint *)&d;
    uint e;

    e = p[1] & 0x7FF00000;
    return e && e != 0x7FF00000;
}

int isnormal(real e)
{
    ushort* pe = cast(ushort *)&e;
    long*   ps = cast(long *)&e;

    return (pe[4] & 0x7FFF) != 0x7FFF && *ps < 0;
}

unittest
{
    float f = 3;
    double d = 500;
    real e = 10e+48;

    assert(isnormal(f));
    assert(isnormal(d));
    assert(isnormal(e));
}

/*********************************
 * Is number subnormal? (Also called "denormal".)
 * Subnormals have a 0 exponent and a 0 most significant mantissa bit.
 * Need one for each format because subnormal floats might
 * be converted to normal reals.
 */

int issubnormal(float f)
{
    uint *p = cast(uint *)&f;

    //printf("*p = x%x\n", *p);
    return (*p & 0x7F800000) == 0 && *p & 0x007FFFFF;
}

unittest
{
    float f = 3.0;

    for (f = 1.0; !issubnormal(f); f /= 2)
	assert(f != 0);
}

int issubnormal(double d)
{
    uint *p = cast(uint *)&d;

    return (p[1] & 0x7FF00000) == 0 && (p[0] || p[1] & 0x000FFFFF);
}

unittest
{
    double f;

    for (f = 1; !issubnormal(f); f /= 2)
	assert(f != 0);
}

int issubnormal(real e)
{
    ushort* pe = cast(ushort *)&e;
    long*   ps = cast(long *)&e;

    return (pe[4] & 0x7FFF) == 0 && *ps > 0;
}

unittest
{
    real f;

    for (f = 1; !issubnormal(f); f /= 2)
	assert(f != 0);
}

/*********************************
 * Is number infinity?
 */

int isinf(real e)
{
    ushort* pe = cast(ushort *)&e;
    ulong*  ps = cast(ulong *)&e;

    return (pe[4] & 0x7FFF) == 0x7FFF &&
	    *ps == 0x8000000000000000;
}

unittest
{
    assert(isinf(float.infinity));
    assert(!isinf(float.nan));
    assert(isinf(double.infinity));
    assert(isinf(-real.infinity));

    assert(isinf(-1.0 / 0.0));
}

/*********************************
 * Get sign bit.
 */

int signbit(real e)
{
    ubyte* pe = cast(ubyte *)&e;

//printf("e = %Lg\n", e);
    return (pe[9] & 0x80) != 0;
}

unittest
{
    debug (math) printf("math.signbit.unittest\n");
    assert(!signbit(float.nan));
    assert(signbit(-float.nan));
    assert(!signbit(168.1234));
    assert(signbit(-168.1234));
    assert(!signbit(0.0));
    assert(signbit(-0.0));
}

/*********************************
 * Copy sign.
 */

real copysign(real to, real from)
{
    ubyte* pto   = cast(ubyte *)&to;
    ubyte* pfrom = cast(ubyte *)&from;

    pto[9] &= 0x7F;
    pto[9] |= pfrom[9] & 0x80;

    return to;
}

unittest
{
    real e;

    e = copysign(21, 23.8);
    assert(e == 21);

    e = copysign(-21, 23.8);
    assert(e == 21);

    e = copysign(21, -23.8);
    assert(e == -21);

    e = copysign(-21, -23.8);
    assert(e == -21);

    e = copysign(real.nan, -23.8);
    assert(isnan(e) && signbit(e));
}

/****************************************************************************
 * Tangent.
 */

real tan(real x)
{
    asm
    {
	fld	x[EBP]			; // load theta
	fxam				; // test for oddball values
	fstsw	AX			;
	sahf				;
	jc	trigerr			; // x is NAN, infinity, or empty
					  // 387's can handle denormals
SC18:	fptan				;
	fstp	ST(0)			; // dump X, which is always 1
	fstsw	AX			;
	sahf				;
	jnp	Lret			; // C2 = 1 (x is out of range)

	// Do argument reduction to bring x into range
	fldpi				;
	fxch				;
SC17:	fprem1				;
	fstsw	AX			;
	sahf				;
	jp	SC17			;
	fstp	ST(1)			; // remove pi from stack
	jmp	SC18			;

trigerr:
	fstp	ST(0)			; // dump theta
    }
    return real.nan;

Lret:
    ;
}

unittest
{
    static real vals[][2] =	// angle,tan
    [
	    [   0,   0],
	    [   .5,  .5463024898],
	    [   1,   1.557407725],
	    [   1.5, 14.10141995],
	    [   2,  -2.185039863],
	    [   2.5,-.7470222972],
	    [   3,  -.1425465431],
	    [   3.5, .3745856402],
	    [   4,   1.157821282],
	    [   4.5, 4.637332055],
	    [   5,  -3.380515006],
	    [   5.5,-.9955840522],
	    [   6,  -.2910061914],
	    [   6.5, .2202772003],
	    [   10,  .6483608275],

	    // special angles
	    [   PI_4,	1],
	    //[	PI_2,	real.infinity],
	    [   3*PI_4,	-1],
	    [   PI,	0],
	    [   5*PI_4,	1],
	    //[	3*PI_2,	-real.infinity],
	    [   7*PI_4,	-1],
	    [   2*PI,	0],

	    // overflow
	    [   real.infinity,	real.nan],
	    [   real.nan,	real.nan],
	    [   1e+100,		real.nan],
    ];
    int i;

    for (i = 0; i < vals.length; i++)
    {
	real x = vals[i][0];
	real r = vals[i][1];
	real t = tan(x);

	//printf("tan(%Lg) = %Lg, should be %Lg\n", x, t, r);
	assert(mfeq(r, t, .0000001));

	x = -x;
	r = -r;
	t = tan(x);
	//printf("tan(%Lg) = %Lg, should be %Lg\n", x, t, r);
	assert(mfeq(r, t, .0000001));
    }
}


/****************************************************************************
 * hypotenuese.
 * This is based on code from:
 * Cephes Math Library Release 2.1:  January, 1989
 * Copyright 1984, 1987, 1989 by Stephen L. Moshier
 * Direct inquiries to 30 Frost Street, Cambridge, MA 02140
 */

real hypot(real zre, real zim)
{

    const int PRECL = 32;
    const int MAXEXPL = real.max_exp; //16384;
    const int MINEXPL = real.min_exp; //-16384;

    real x, y, b, re, im;
    int ex, ey, e;

    // Note, hypot(INFINITY,NAN) = INFINITY.
    if (isinf(zre) || isinf(zim))
	return real.infinity;

    if (isnan(zre))
	return zre;
    if (isnan(zim))
	return zim;

    re = fabs(zre);
    im = fabs(zim);

    if (re == 0.0)
	return im;
    if (im == 0.0)
	return re;

    // Get the exponents of the numbers
    x = frexp(re, ex);
    y = frexp(im, ey);

    // Check if one number is tiny compared to the other
    e = ex - ey;
    if (e > PRECL)
	return re;
    if (e < -PRECL)
	return im;

    // Find approximate exponent e of the geometric mean.
    e = (ex + ey) >> 1;

    // Rescale so mean is about 1
    x = ldexp(re, -e);
    y = ldexp(im, -e);

    // Hypotenuse of the right triangle
    b = sqrt(x * x  +  y * y);

    // Compute the exponent of the answer.
    y = frexp(b, ey);
    ey = e + ey;

    // Check it for overflow and underflow.
    if (ey > MAXEXPL + 2)
    {
	//return __matherr(_OVERFLOW, INFINITY, x, y, "hypotl");
	return real.infinity;
    }
    if (ey < MINEXPL - 2)
	return 0.0;

    // Undo the scaling
    b = ldexp(b, e);
    return b;
}

unittest
{
    static real vals[][3] =	// x,y,hypot
    [
	[	0,	0,	0],
	[	0,	-0,	0],
	[	3,	4,	5],
	[	-300,	-400,	500],
	[	real.min, real.min, 4.75473e-4932L],
	[	real.max/2, real.max/2, 0x1.6a09e667f3bcc908p+16383L /*8.41267e+4931L*/],
	[	real.infinity, real.nan, real.infinity],
	[	real.nan, real.nan, real.nan],
    ];
    int i;

    for (i = 0; i < vals.length; i++)
    {
	real x = vals[i][0];
	real y = vals[i][1];
	real z = vals[i][2];
	real h = hypot(x, y);

	//printf("hypot(%Lg, %Lg) = %Lg, should be %Lg\n", x, y, h, z);
	//if (!mfeq(z, h, .0000001))
	    //printf("%La\n", h);
	assert(mfeq(z, h, .0000001));
    }
}

/*********************************************************************
 * Returns:
 *	x such that value=x*2**n, .5 <= |x| < 1.0
 *	x has same sign as value.
 *	*eptr = n
 *
 *	Special cases:
 *		value	  x	*eptr
 *		+-0.0	+-0.0	  0
 *		+-inf	+-inf	  int.max/int.min
 *		+-NaN	+-NaN	  int.min
 *		+-NaNs	+-NaN	  int.min
 */


real frexp(real value, out int eptr)
{
    ushort* vu = cast(ushort*)&value;
    long* vl = cast(long*)&value;
    uint exp;

    // If exponent is non-zero
    exp = vu[4] & 0x7FFF;
    if (exp)
    {
	if (exp == 0x7FFF)
	{   // infinity or NaN
	    if (*vl &  0x7FFFFFFFFFFFFFFF)	// if NaN
	    {	*vl |= 0xC000000000000000;	// convert NANS to NANQ
		eptr = int.min;
	    }
	    else if (vu[4] & 0x8000)
	    {	// negative infinity
		eptr = int.min;
	    }
	    else
	    {	// positive infinity
		eptr = int.max;
	    }
	}
	else
	{
	    eptr = exp - 0x3FFE;
	    vu[4] = (0x8000 & vu[4]) | 0x3FFE;
	}
    }
    else if (!*vl)
    {
	// value is +-0.0
	eptr = 0;
    }
    else
    {	// denormal
	int i = -0x3FFD;

	do
	{
	    i--;
	    *vl <<= 1;
	} while (*vl > 0);
	eptr = i;
        vu[4] = (0x8000 & vu[4]) | 0x3FFE;
    }
    return value;
}


unittest
{
    static real vals[][3] =	// x,frexp,eptr
    [
	[0.0,	0.0,	0],
	[-0.0,	-0.0,	0],
	[1.0,	.5,	1],
	[-1.0,	-.5,	1],
	[2.0,	.5,	2],
	[155.67e20,	0x1.A5F1C2EB3FE4Fp-1,	74],	// normal
	[1.0e-320,	0.98829225,		-1063],
	[real.min,	.5,		-16381],
	[real.min/2.0L,	.5,		-16382],	// denormal

	[real.infinity,real.infinity,int.max],
	[-real.infinity,-real.infinity,int.min],
	[real.nan,real.nan,int.min],
	[-real.nan,-real.nan,int.min],

	// Don't really support signalling nan's in D
	//[real.nans,real.nan,int.min],
	//[-real.nans,-real.nan,int.min],
    ];
    int i;

    for (i = 0; i < vals.length; i++)
    {
	real x = vals[i][0];
	real e = vals[i][1];
	int exp = cast(int)vals[i][2];
	int eptr;
	real v = frexp(x, eptr);

	//printf("frexp(%Lg) = %.8Lg, should be %.8Lg, eptr = %d, should be %d\n", x, v, e, eptr, exp);
	assert(mfeq(e, v, .0000001));
	assert(exp == eptr);
    }
}

/*******************************************************************
 * Fast integral powers.
 */

real pow(real x, uint n)
{
    real p;

    switch (n)
    {
	case 0:
	    p = 1.0;
	    break;

	case 1:
	    p = x;
	    break;

	case 2:
	    p = x * x;
	    break;

	default:
	    p = 1.0;
	    while (1)
	    {
		if (n & 1)
		    p *= x;
		n >>= 1;
		if (!n)
		    break;
		x *= x;
	    }
	    break;
    }
    return p;
}

real pow(real x, int n)
{
    if (n < 0)
	return pow(x, cast(real)n);
    else
	return pow(x, cast(uint)n);
}

real pow(real x, real y)
{
    version (linux) // C pow() often does not handle special values correctly
    {
	if (isnan(y))
	    return real.nan;

	if (y == 0)
	    return 1;		// even if x is NAN
	if (isnan(x) && y != 0)
	    return real.nan;
	if (isinf(y))
	{
	    if (fabs(x) > 1)
	    {
		if (signbit(y))
		    return +0.0;
		else
		    return real.infinity;
	    }
	    else if (fabs(x) == 1)
	    {
		return real.nan;
	    }
	    else // < 1
	    {
		if (signbit(y))
		    return real.infinity;
		else
		    return +0.0;
	    }
	}
	if (isinf(x))
	{
	    if (signbit(x))
	    {   long i;

		i = cast(long)y;
		if (y > 0)
		{
		    if (i == y && i & 1)
			return -real.infinity;
		    else
			return real.infinity;
		}
		else if (y < 0)
		{
		    if (i == y && i & 1)
			return -0.0;
		    else
			return +0.0;
		}
	    }
	    else
	    {
		if (y > 0)
		    return real.infinity;
		else if (y < 0)
		    return +0.0;
	    }
	}

	if (x == 0.0)
	{
	    if (signbit(x))
	    {   long i;

		i = cast(long)y;
		if (y > 0)
		{
		    if (i == y && i & 1)
			return -0.0;
		    else
			return +0.0;
		}
		else if (y < 0)
		{
		    if (i == y && i & 1)
			return -real.infinity;
		    else
			return real.infinity;
		}
	    }
	    else
	    {
		if (y > 0)
		    return +0.0;
		else if (y < 0)
		    return real.infinity;
	    }
	}
    }
    return std.c.math.powl(x, y);
}

unittest
{
    real x = 46;

    assert(pow(x,0) == 1.0);
    assert(pow(x,1) == x);
    assert(pow(x,2) == x * x);
    assert(pow(x,3) == x * x * x);
    assert(pow(x,8) == (x * x) * (x * x) * (x * x) * (x * x));
}

/*****************************************
 */

creal sqrt(creal z)
{
    creal c;
    real x,y,w,r;

    if (z == 0)
    {
	c = 0;
    }
    else
    {	real z_re = z.re;
	real z_im = z.im;

	x = fabs(z_re);
	y = fabs(z_im);
	if (x >= y)
	{
	    r = y / x;
	    w = sqrt(x) * sqrt(0.5 * (1 + sqrt(1 + r * r)));
	}
	else
	{
	    r = x / y;
	    w = sqrt(y) * sqrt(0.5 * (r + sqrt(1 + r * r)));
	}

	if (z_re >= 0)
	{
	    c = w + (z_im / (w + w)) * 1.0i;
	}
	else
	{
	    if (z_im < 0)
		w = -w;
	    c = z_im / (w + w) + w * 1.0i;
	}
    }
    return c;
}

/****************************************
 * Simple function to compare two floating point values
 * to a specified precision.
 * Returns:
 *	1	match
 *	0	nomatch
 */

private int mfeq(real x, real y, real precision)
{
    if (x == y)
	return 1;
    if (isnan(x))
	return isnan(y);
    if (isnan(y))
	return 0;
    return fabs(x - y) <= precision;
}

/*******************************************
 * Submitted by Don Clugston
 * http://www.digitalmars.com/drn-bin/wwwnews?digitalmars.D/27735
 *
 *  "How equal" are two reals x and y?
 *  Returns the number of mantissa bits which are equal in x and y;
 *  this is similar to the concept of "significant figures".
 *  For example, 0x1.F8p+60 and 0x1.F1p+60 are equal to 5 bits of precision.
 *  If x==y, then precisionEquality(a,b) == real.mant_dig.
 *
 *  If x and y differ by a factor of two or more, then they have no
 *  bits in common, so this function returns a value which is <=0.
 *  Returns 0 if they differ by a factor of >=2 but < 4,
 *  returns 1 for factors >=4 but <8, etc.
 *
 *  If the numbers have opposite sign, the difference in orders
 *  of magnitude is based on the IEEE binary encoding.
 *  For example, -1 and +1 differ by half the number line.
 *
 *  Pretend the numbers were fixed point. In the IEEE extended format,
 *  there are about 32768 digits in front of the decimal point, and
 *  the same number behind. But only the first 64 bits after the first '1'
 *  bit are recorded.
 *
 *  If the exponents are different, then the return value
 *  is negative, and gives the number of (binary) orders of
 *  magnitude of difference between a and b.
 */

private int iabs(int i)
{
    return i >= 0 ? i : -i;
}
 
int precisionEquality(real a, real b)
{
    real diff = a-b;
    ushort *pa = cast(ushort *)(&a);
    ushort *pb = cast(ushort *)(&b);
    ushort *pd = cast(ushort *)(&diff);

    // The difference in exponent between 'a' and 'a-b'
    // is equal to the number of mantissa bits of a which are
    // equal to b. If the difference is negative, then a and b
    // have different exponents. If it is positive, then a and b
    // are equal to that number of decimal places. 
    // AND with 0x7FFF to form the absolute value.
    // Subtract 1 so that we round downwards.
    int bitsdiff = ( ((pa[4]&0x7FFF) + (pb[4]&0x7FFF)-1)>>1) - (pd[4]&0x7FFF);

    if ((pd[4]&0x7FFF) == 0)	// Difference is zero or denormal
    {
	if (a==b)
	    return real.mant_dig;
	// 'diff' is denormal, so the number of equal bits is higher;
	// we need to add the number of zeros that lie at the start of
	// its mantissa. We do this by multiplying by 2^real.mant_dig
	diff*=0x1p+63;
	return bitsdiff + real.mant_dig-(pd[4]&0x7FFF);
    }

    if (bitsdiff > 0)
	return bitsdiff + 1;

    // Check for NAN or Infinity.     
    if (pd[4]&0x7FFF==0x7FFF)	// Result is NAN or INF
    {
	if (a==b)	// both were +INF or both were -INF.
	{
	    return real.mant_dig;
	}
	if (isnan(diff))
	{
	    return -65535;  // at least one was a NAN.
	}
	// fall through for comparisons of INF with large reals.
    }
    // Return the negative of the absolute value of
    // the difference in exponents.

    if ((pa[4]^pb[4])&0x8000)	// do they have opposite signs?
    {	// Convert the 'offset' exponent format to twos-complement,
	// then do a normal subtraction.
	return 1-iabs(pa[4]-(0x8000-pb[4]));
    }
    return 1-iabs(pa[4]-pb[4]);
}

unittest
{
    // Exact equality
    assert(precisionEquality(real.max,real.max)==real.mant_dig);
    assert(precisionEquality(0,0)==real.mant_dig);
    assert(precisionEquality(7.1824,7.1824)==real.mant_dig);
    assert(precisionEquality(real.infinity,real.infinity)==real.mant_dig);

    // one bit off exact equality
    assert(precisionEquality(1+real.epsilon,1)==real.mant_dig-1);
    assert(precisionEquality(1,1+real.epsilon)==real.mant_dig-1);
    // one bit below. Must round off correctly when exponents are different.
    assert(precisionEquality(1,1-real.epsilon)==real.mant_dig-1); 
    assert(precisionEquality(1-real.epsilon,1)==real.mant_dig-1);
    assert(precisionEquality(-1-real.epsilon,-1)==real.mant_dig-1);
    assert(precisionEquality(-1+real.epsilon,-1)==real.mant_dig-1);

    // Numbers that are close
    assert(precisionEquality(0x1.Bp+5, 0x1.B8p+5)==5); 
    assert(precisionEquality(0x1.8p+10, 0x1.Cp+10)==2);
    assert(precisionEquality(1, 1.1249)==4);
    assert(precisionEquality(1.5, 1)==1); 

    // Extreme inequality
    assert(precisionEquality(real.nan,0)==-65535);
    assert(precisionEquality(0,-real.nan)==-65535);
    assert(precisionEquality(real.nan,real.infinity)==-65535); 
    assert(precisionEquality(real.infinity,-real.infinity)==-65533);
    assert(precisionEquality(-real.max,real.infinity)==-65532);
    assert(precisionEquality(-real.max,real.max)==-65531);

    // Numbers that are half the number line apart
    // Note that (real.max_exp-real.min_exp) = 32765
    assert(precisionEquality(-real.max,0)==-32765);
    assert(precisionEquality(-1,1)==-32765);
    assert(precisionEquality(real.min,1)==-16381);

    // Numbers that differ by one order of magnitude
    assert(precisionEquality(real.max,real.infinity)==0);
    assert(precisionEquality(1, 2)==0);
    assert(precisionEquality(2, 1)==0);
    assert(precisionEquality(1.5*(1-real.epsilon), 1)==2);
    assert(precisionEquality(4*(1-real.epsilon), 1)==0);
    assert(precisionEquality(4, 1)==-1);
}


/**************************************
   int feqrel(real x, real y)
   To what precision is x equal to y?
   Public Domain. Author: Don Clugston, 18 Aug 2005.

   Returns the number of mantissa bits which are equal in x and y.
   eg, 0x1.F8p+60 and 0x1.F1p+60 are equal to 5 bits of precision.
   If x == y, then feqrel(x, y) == real.mant_dig.

   If x and y differ by a factor of two or more, or if one or both
   is a nan, the return value is 0.
*/

int feqrel(real a, real b)
{
    if (a == b)
	return real.mant_dig; // ensure diff!=0, cope with INF.

    real diff = fabs(a-b);

    ushort *pa = cast(ushort *)(&a);
    ushort *pb = cast(ushort *)(&b);
    ushort *pd = cast(ushort *)(&diff);

    // The difference in abs(exponent) between a or b and abs(a-b)
    // is equal to the number of mantissa bits of a which are
    // equal to b. If negative, a and b have different exponents.
    // If positive, a and b are equal to 'bitsdiff' bits.
    // AND with 0x7FFF to form the absolute value.
    // To avoid out-by-1 errors, we subtract 1 so it rounds down
    // if the exponents were different. This means 'bitsdiff' is
    // always 1 lower than we want, except that if bitsdiff==0,
    // they could have 0 or 1 bits in common.
    int bitsdiff = ( ((pa[4]&0x7FFF) + (pb[4]&0x7FFF)-1)>>1) - pd[4];

    if (pd[4] == 0)
    {	// Difference is denormal
	// For denormals, we need to add the number of zeros that
	// lie at the start of diff's mantissa.
	// We do this by multiplying by 2^real.mant_dig
	diff *= 0x1p+63;
	return bitsdiff + real.mant_dig - pd[4];
    }

    if (bitsdiff > 0)
	return bitsdiff + 1; // add the 1 we subtracted before

    // Avoid out-by-1 errors when factor is almost 2.
    return (bitsdiff == 0) ? (pa[4] == pb[4]) : 0;
}

unittest
{
   // Exact equality
   assert(feqrel(real.max,real.max)==real.mant_dig);
   assert(feqrel(0,0)==real.mant_dig);
   assert(feqrel(7.1824,7.1824)==real.mant_dig);
   assert(feqrel(real.infinity,real.infinity)==real.mant_dig);

   // a few bits away from exact equality
   real w=1;
   for (int i=1; i<real.mant_dig-1; ++i) {
      assert(feqrel(1+w*real.epsilon,1)==real.mant_dig-i);
      assert(feqrel(1-w*real.epsilon,1)==real.mant_dig-i);
      assert(feqrel(1,1+(w-1)*real.epsilon)==real.mant_dig-i+1);
      w*=2;
   }
   assert(feqrel(1.5+real.epsilon,1.5)==real.mant_dig-1);
   assert(feqrel(1.5-real.epsilon,1.5)==real.mant_dig-1);
   assert(feqrel(1.5-real.epsilon,1.5+real.epsilon)==real.mant_dig-2);

   // Numbers that are close
   assert(feqrel(0x1.Bp+84, 0x1.B8p+84)==5);
   assert(feqrel(0x1.8p+10, 0x1.Cp+10)==2);
   assert(feqrel(1.5*(1-real.epsilon), 1)==2);
   assert(feqrel(1.5, 1)==1);
   assert(feqrel(2*(1-real.epsilon), 1)==1);

   // Factors of 2
   assert(feqrel(real.max,real.infinity)==0);
   assert(feqrel(2*(1-real.epsilon), 1)==1);
   assert(feqrel(1, 2)==0);
   assert(feqrel(4, 1)==0);

   // Extreme inequality
   assert(feqrel(real.nan,real.nan)==0);
   assert(feqrel(0,-real.nan)==0);
   assert(feqrel(real.nan,real.infinity)==0);
   assert(feqrel(real.infinity,-real.infinity)==0);
   assert(feqrel(-real.max,real.infinity)==0);
   assert(feqrel(real.max,-real.max)==0);
}

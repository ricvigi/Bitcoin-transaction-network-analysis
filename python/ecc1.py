from field import FieldElement
from unittest import TestCase
from random import SystemRandom
from helper1 import (hash160,
                     hash256,
                     encode_base58_checksum,
                     encode_base58)

class FieldElement:

    def __init__(self, num, prime):
        if num >= prime or num < 0:
            # We first check that num is between 0 and prime - 1 inclusive. If not, we get an invalid FieldElement and we raise a ValueError, which is what we should raise when we get an inappropriate value.
            error = f"Num {num} not in field range 0 to {prime - 1}"
            raise ValueError(error)
        self.num = num
        self.prime = prime

    def __repr__(self):
        return f"FieldElement_{self.prime}({self.num})"

    def __eq__(self, other=None):
        # this method checks if two objects of class FieldElement are equal. This is only true when the num and prime properties are equal. NOTE: Python allows us to override the "==" operator on FieldElement with the __eq__ method.
        if other is None:
            return False
        return self.num == other.num and self.prime ==other.prime

    def __ne__(self, other):
        # here the "==" operator should be the one declared in the "__eq__" method
        return not (self == other)

    def __add__(self, other):
        # In Python we can define what addition (or the + operator) means for our class with the __add__ method.
        # Ensure that elements are from the same finite field
        if self.prime != other.prime:
            raise TypeError("Cannot add two numbers in different Fields")
        num = (self.num + other.num) % self.prime
        return self.__class__(num, self.prime) # We have to return an instance of the class, which we can conveniently access with self.__class__. We pass the two initializing arguments, num and self.prime, for the __init__ method. NOTE: We could also use FieldElement instead of self.__class__, but this would not make the method easily inheritable.

    def __sub__(self, other):
        # You can also define what subtraction (the - operator) means for our class by implementing the __sub__ method.
        if self.prime != other.prime:
            raise TypeError("Cannot add two numbers in different Fields")
        num = (self.num - other.num) % self.prime
        return self.__class__(num, self.prime)

    def __mul__(self, other):
        # Define the multiplication * operator for this class.
        if self.prime != other.prime:
            raise TypeError("Cannot add two numbers in different Fields")
        num = (self.num * other.num) % self.prime
        return self.__class__(num, self.prime)

    def __pow__(self, exponent):
        # Define the exponentiation for FieldElement, which overrides the ** operator. NOTE: because the exponent is an integer, instead of another instance of FieldElement, the method receives the variable exponent as an integer! The exponent does not need to be a member of the finite field for the math to work
        # The following is needed to handle negative exponents
        n = exponent % (self.prime - 1)
        num = pow(self.num, n, self.prime)
        return self.__class__(num, self.prime)

    def __truediv__(self, other):
        # This method overrides normal division / operator.
        if self.prime != other.prime:
            raise TypeError("Cannot divide two numbers in different Fields")
        num = (self.num * pow(other.num, (self.prime - 2), self.prime)) % self.prime
        return self.__class__(num, self.prime)

    def __rmul__(self, coefficient):
        num = (self.num * coefficient) % self.prime
        return self.__class__(num=num, prime=self.prime)


class Point():

    def __init__(self, x, y, a ,b) -> None:
        self.a=a
        self.b=b
        self.x=x
        self.y=y
        if (self.x is None and self.y is None):
            # NOTE: The x coordinate and the y coordinate being None is how we signify the point at infinity. Note that the next if statement will fail if here we don't return'
            return
        if self.y**2 != (self.x**3 + a*x + b):
            # check that the point is actually on the curve
            raise ValueError(f"({x}, {y}) is not on the curve")
        return

    def __eq__(self, other) -> bool:
        # points are equal IFF the are on the same curve and have the same coordinates
        return ((self.x == other.x) and (self.y == other.y) and (self.a == other.a) and (self.b == other.b))


    def __ne__(self, other) -> bool:
        return not (self == other)

    def __add__(self, other):
        if self.a != other.a or self.b != other.b:
            raise TypeError('Points {}, {} are not on the same curve'.format(self, other))
        if self.x is None:
            # self.x being None means that self is the point at infinity, or the additive identity. Thus, we return other
            return other
        if other.x is None:
            # other.x being None means that other is the point at infinity, or the additive identity.
            return self

        if self.x == other.x and self.y != other.y:
            # Point addition for when x_1 == x_2, result is point at infinity
            return self.__class__(None, None, self.a, self.b)

        # Point addition for when x_1 != x_2
        # Formula (x3,y3)==(x1,y1)+(x2,y2)
        # s=(y2-y1)/(x2-x1)
        # x3=s**2-x1-x2
        # y3=s*(x1-x3)-y1
        if self.x != other.x:
            s = (other.y - self.y) / (other.x - self.x)
            x = s**2 - self.x - other.x
            y = s * (self.x - x) - self.y
            return self.__class__(x, y, self.a, self.b)


        if self == other and self.y == 0 * self.x:
            # If the two points are equal and the y coordinate is 0, we return the point at infinity
            # we return the point at infinity
            # note instead of figuring out what 0 is for each type
            # we just use 0 * self.x
            return self.__class__(None, None, self.a, self.b)

        if self == other:
            # point addition if P_1 == P_2
            # Formula (x3,y3)=(x1,y1)+(x1,y1)
            # s=(3*x1**2+a)/(2*y1)
            # x3=s**2-2*x1
            # y3=s*(x1-x3)-y1
            s = (3 * self.x**2 + self.a) / (2 * self.y)
            x = s**2 - 2 * self.x
            y = s * (self.x - x) - self.y
            return self.__class__(x, y, self.a, self.b)

    def __rmul__(self, coefficient):
        # Implement multiplication using binary expansion. It allows you to perform multiplication in log_2(n) loops, which dramatically reduces the calculation time for large numbers. For example, 1 trillion is 40 bits in binary, so we only have to loop 40 times for a number that's generally considered very large.
        coef = coefficient
        current = self # current represents the point that's at the current bit. The first time through the loop it represents 1 x self; the second time it will be 2 x self, the third time 4 x self, then 8 x self, and so on. We double the point each time. In binary the coefficients are 1, 10, 100, 1000, 10000, etc.
        res = self.__class__(None, None, self.a, self.b) # We start the result at 0, or the point at infinity
        while coef:
            if coef & 1: # We are looking at whether the rightmost bit is a 1. If it is, then we add the value of the current bit
                res += current
            current += current # We need to double the point until we're past how big the coefficient can be
            coef >>= 1 # We bit shift the coefficient to the right
        return res

    def __repr__(self):
        if self.x is None:
            return 'Point(infinity)'
        elif isinstance(self.x, FieldElement):
            return 'Point({},{})_{}_{} FieldElement({})'.format(
                self.x.num, self.y.num, self.a.num, self.b.num, self.x.prime)
        else:
            return 'Point({},{})_{}_{}'.format(self.x, self.y, self.a, self.b)

P = 2**256 - 2**32 - 977

class S256Field(FieldElement):
    def __init__(self, num, prime=None):
        super().__init__(num=num, prime=P)

    def __repr__(self):
        return "{:x}".format(self.num).zfill(64)

    def sqrt(self):
        return self**((P + 1) // 4)

A = 0
B = 7

N = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141

class S256Point(Point):

    def __init__(self, x, y, a=None, b=None):
        a, b = S256Field(A), S256Field(B)
        if type(x) == int:
            super().__init__(x=S256Field(x), y=S256Field(y), a=a, b=b)
        else:
            super().__init__(x=x, y=y, a=a, b=b) # In case we initialize with the point at infinity, we need to let x and y through directly instead of using the S256Field class


    def __rmul__(self, coefficient):
        coef = coefficient % N # We can mod by n because nG = 0. That is, every n times we cycle back to zero or the point at infinity
        return super().__rmul__(coef)

    def verify(self, z, sig):
        # Given a public key that is a point on the secp256k1 curve and a signature hash, z, we can verify whether a signature is valid or not
        s_inv = pow(sig.s, N - 2, N) # s_inv (1/s) is calculated using Fermat's little theorem on the order of the group n, which is prime
        u = z * s_inv % N # u = z/s. NOTE: we can mod by n as that's the order of the group
        v = sig.r * s_inv % N # v = r/s. NOTE: we can mod by n as that's the order of the group
        total = u * G + v * self # uG + vP should be R
        return total.x.num == sig.r # We check that the x coordinate is r

    def sec(self, compressed=True):
        '''returns the binary version of the SEC format'''
        if compressed:
            if self.y.num % 2 == 0:
                return b'\x02' + self.x.num.to_bytes(32, 'big')
            else:
                return b'\x03' + self.x.num.to_bytes(32, 'big')
        else:
            return b'\x04' + self.x.num.to_bytes(32, 'big') + self.y.num.to_bytes(32, 'big') # In Python 3, you can convert a number to bytes using the to_bytes method. The first argument is how many bytes it should take up and the second argument is the endianness

    @classmethod
    def parse(self, sec_bin):
        '''return a Point object from a SEC binary (not hex)'''
        if sec_bin[0] == 4: # Uncompressed SEC format is pretty straighforward
            x = int.from_bytes(sec_bin[1:33], 'big')
            y = int.from_bytes(sec_bin[33:65], 'big')
            return S256Point(x=x, y=y)
        is_even = sec_bin[0] == 2 # The evenness of the y coordinate is given in the first bytes
        x = S256Field(int.from_bytes(sec_bin[1:], 'big'))
        # right side of the equation y^2 = x^3 + 7
        alpha = x**3 + S256Field(B)
        # solve for left side
        beta = alpha.sqrt() # We take the square root of the right side of the elliptic curve equation to get y
        if beta.num % 2 == 0: # We determine the evenness and return the correct point
            even_beta = beta
            odd_beta = S256Field(P - beta.num)
        else:
            even_beta = S256Field(P - beta.num)
            odd_beta = beta
        if is_even:
            return S256Point(x, even_beta)
        else:
            return S256Point(x, odd_beta)

    def hash160(self, compressed=True):
        return hash160(self.sec(compressed))

    def address(self, compressed=True, testnet=False):
        '''Returns the address string'''
        h160 = self.hash160(compressed)
        if testnet:
            prefix = b'\x6f'
        else:
            prefix = b'\x00'
        return encode_base58_checksum(prefix + h160)

# Define G directly now
G = S256Point(
    0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798,
    0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)

class Signature:

    def __init__(self, r, s):
        self.r = r
        self.s = s

    def __repr__(self):
        return "Signature({:x}, {:x})".format(self.r, self.s)

    def der(self):
        rbin = self.r.to_bytes(32, byteorder='big')
        # remove all null bytes at the beginning
        rbin = rbin.lstrip(b'\x00')
        # if rbin has a high bit, add a \x00
        if rbin[0] & 0x80:
            rbin = b'\x00' + rbin
        result = bytes([2, len(rbin)]) + rbin # In python 3, you can convert a list of numbers to the byte equivalents using bytes([some_integer1, some_integer2])
        sbin = self.s.to_bytes(32, byteorder='big')
        # remove all null bytes at the beginning
        sbin = sbin.lstrip(b'\x00')
        # if sbin has a high bit, add a \x00
        if sbin[0] & 0x80:
            sbin = b'\x00' + sbin
        result += bytes([2, len(sbin)]) + sbin
        return bytes([0x30, len(result)]) + result

class PrivateKey:

    def __init__(self, secret):
        self.secret = secret
        self.point = secret * G # Keep around the public key (self.point) for convenience

    def hex(self):
        return '{:x}'.format(self.secret).zfill(64)

    def sign(self, z):
        cryptogen = SystemRandom()
        k = cgen.randint(0, N) # randint chooses a random integer from [0, n). DO NOT USE random.randint(). Always use SystemRandom.randint().
        k = self.deterministic_k(z)
        r = (k*G).x.num # r is the x coordinate of kG
        k_inv = pow(k, N-2, N) # Fermat's little theorem because n is prime
        s = (z + r*self.secret) * k_inv % N
        if s > N/2: # it turns out that using the low-s value will get nodes to relay our transactions. This is for malleability reasons.
            s = N - s
        return Signature(r, s) # We return a signature objects

    def deterministic_k(self, z):
        k = b'\x00' * 32
        v = b'\x01' * 32
        if z > N:
            z -= N
        z_bytes = z.to_bytes(32, 'big')
        secret_bytes = self.secret.to_bytes(32, 'big')
        s256 = hashlib.sha256
        k = hmac.new(k, v + b'\x00' + secret_bytes + z_bytes, s256).digest()
        v = hmac.new(k, v, s256).digest()
        k = hmac.new(k, v + b'\x00' + secret_bytes + z_bytes, s256).digest()
        v = hmac.new(k, v, s256).digest()
        while True:
            v = hmac.new(k, v, s256).digest()
            candidate = int.from_bytes(v, 'big')
            if candidate >= 1 and candidate < N:
                return candidate # The algorithm returns a candidate that is suitable
            k = hmac.new(k, v + b'\x00', s256).digest()
            v = hmac.new(k, v, s256).digest()

    def wif(self, compressed=True, testnet=False):
        secret_bytes = self.secret.to_bytes(32, 'big')
        if testnet:
            prefix = b'\xef'
        else:
            prefix = b'\x80'
        if compressed:
            suffix = b'\x01'
        else:
            suffix = b''
        return encode_base58_checksum(prefix + secret_bytes + suffix)

class ECCTest(TestCase):
    def test_on_curve(self):
        prime = 223
        a = FieldElement(0, prime)
        b = FieldElement(7, prime)
        valid_points = ((192, 105), (17, 56), (1, 193))
        invalid_points = ((200, 119), (42, 99))

        for x_raw, y_raw in valid_points:
            x = FieldElement(x_raw, prime)
            y = FieldElement(y_raw, prime)
            Point(x, y, a, b) # We pass in FieldElement objects the the Point class for initialization. This will, in turn, use all the overloaded math operations in FieldElement.

        for x_raw, y_raw in invalid_points:
            x = FieldElement(x_raw, prime)
            y = FieldElement(y_raw, prime)
            with self.assertRaises(ValueError):
                Point(x, y, a, b) # We pass in FieldElement objects the the Point class for initialization. This will, in turn, use all the overloaded math operations in FieldElement.
        return

    def test_add(self):
        prime = 223
        a = FieldElement(0, prime)
        b = FieldElement(7, prime)
        valid_points = (((170,142), (60,139)), ((47,71), (17,56)), ((143, 98), (76,66)))

        for couple in valid_points:
            x1 = FieldElement(couple[0][0], prime)
            y1 = FieldElement(couple[0][1], prime)
            x2 = FieldElement(couple[1][0], prime)
            y2 = FieldElement(couple[1][1], prime)
            p1 = Point(x1, y1, a, b)
            p2 = Point(x2, y2, a, b)
            p3 = p1 + p2
            with self.assertRaises(ValueError):
                self.assertEqual(p1 + p2, p3)
        return

    def test_ex_4(self):
        prime = 223
        a = FieldElement(0, prime)
        b = FieldElement(7, prime)
        points = ((192, 105), (143,98), (47,71))

        for point in points:
            x1 = FieldElement(point[0], prime)
            y1 = FieldElement(point[1], prime)
            p1 = Point(x1, y1, a, b)
            for k in (2,4,8,21):
                pass





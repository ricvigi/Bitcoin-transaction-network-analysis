
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

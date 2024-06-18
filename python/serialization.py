class S256Point(Point):
    '''...'''

    def sec(self):
        '''returns the binary version of the SEC format'''
    return b'\x04' + self.x.num.to_bytes(32, 'big') + \
        self.y.num.to_bytes(32, 'big')

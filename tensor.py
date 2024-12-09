import numpy as np

class Tensor:
    def __init__(self, data):
        self._data = np.array(data)

    def add(self, other):
        return Tensor(self._data + other._data)

    def multiply(self, other):
        return Tensor(self._data * other._data)

    def reshape(self, shape):
        return Tensor(self._data.reshape(shape))

    def transpose(self, axes=None):
        return Tensor(np.transpose(self._data, axes=axes))

    def svd(self):
        if self._data.ndim != 2:
            raise ValueError("SVD is only defined for 2D tensors.")
        u, s, vh = np.linalg.svd(self._data)
        return Tensor(u), Tensor(s), Tensor(vh)

    def __str__(self):
        return str(self._data)

    def __add__(self, other):
        return self.add(other)

    def __mul__(self, other):
        return self.multiply(other)

# Example Usage
if __name__ == "__main__":
    tensor1 = Tensor(np.random.rand(3, 3))
    tensor2 = Tensor(np.random.rand(3, 3))

    print("Tensor 1:")
    print(tensor1)
    print("Tensor 2:")
    print(tensor2)

    print("Sum:")
    print(tensor1 + tensor2)

    print("SVD of Tensor 1:")
    u, s, vh = tensor1.svd()
    print("U:", u)
    print("S:", s)
    print("Vh:", vh)

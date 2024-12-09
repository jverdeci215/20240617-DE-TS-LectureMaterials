import unittest
import numpy as np

# Assuming the module to test is named 'my_module.py'
from tensor import Tensor  # Replace with your actual class or functions

class TestTensorOperations(unittest.TestCase):
    """Unit tests for the Tensor class."""

    def setUp(self):
        """Set up test fixtures, if any."""
        self.tensor1 = Tensor([[1, 2], [3, 4]])
        self.tensor2 = Tensor([[5, 6], [7, 8]])

    def tearDown(self):
        """Tear down test fixtures, if any."""
        # Clear any resources if needed (e.g., delete files, close DB connections, etc.)
        pass

    def test_addition(self):
        """Test tensor addition."""
        result = self.tensor1 + self.tensor2
        expected = np.array([[6, 8], [10, 12]])
        np.testing.assert_array_equal(result._data, expected)

    def test_multiplication(self):
        """Test element-wise tensor multiplication."""
        result = self.tensor1 * self.tensor2
        expected = np.array([[5, 12], [21, 32]])
        np.testing.assert_array_equal(result._data, expected)

    def test_reshape(self):
        """Test tensor reshaping."""
        reshaped = self.tensor1.reshape((4,))
        expected = np.array([1, 2, 3, 4])
        np.testing.assert_array_equal(reshaped._data, expected)

    def test_transpose(self):
        """Test tensor transposition."""
        transposed = self.tensor1.transpose()
        expected = np.array([[1, 3], [2, 4]])
        np.testing.assert_array_equal(transposed._data, expected)

    def test_svd(self):
        """Test singular value decomposition."""
        u, s, vh = self.tensor1.svd()
        reconstructed = np.dot(u._data, np.dot(np.diag(s._data), vh._data))
        np.testing.assert_almost_equal(reconstructed, self.tensor1._data)

    def test_exceptions(self):
        """Test error handling for invalid operations."""
        with self.assertRaises(ValueError):
            # Trying to perform an operation with incompatible dimensions
            self.tensor1.multiply(Tensor([[1, 2]]))  # Incorrect dimensions

    def test_equality(self):
        """Test tensor equality."""
        identical_tensor = Tensor([[1, 2], [3, 4]])
        self.assertEqual(self.tensor1, identical_tensor)

# Entry point for running the tests
if __name__ == "__main__":
    unittest.main()

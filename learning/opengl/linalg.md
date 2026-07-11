# Linear Algebra

## Vectors
### Length of the vector
length == sqrt(x^2 + y^2 + z^2)
unit vector is a vector with length 1.
To make a unit vector out of a vector you divide each component of the vector by its length.
The math checks out:
```shell
sqrt(x^2/length^2 + y^2/length^2 + z^2/length^2) = sqrt(x^2 + y^2 + z^2)/sqrt(length^2) = length/length = 1
```

### Dot product
dot(u, v) == u.x * v.x + u.y + v.y + u.z + v.z
For unit vectors geometric meaning of dot product is cos of angle between two vectors.

## Matrices
### Matrix multiplication

Matrices we multiply need to match dimension, e.g. we can multiply MxN matrix only by NxT matrix.
Resulting matrix will be MxT. 
Resulting matrix element at i,j is calculated as a dot product of row i from the first matrix and column j from
the second matrix.

Vectors are actually a special case of matrices, e.g. vector with 4 elements can be considered as
4x1 matrix (4 rows, 1 column).
So if we multiply matrix 4x4 by vector 4x1 we'll get a vector 4x1. So matrix multiplication is useful for
vector transformations (vector is input and transformed vector of the the is )

### Identity matrix
Identity matrix is a matrix NxN where diagonal elements are 1 and other elements are zero.

Identity matrix looks like this:
1 0 0 0 
0 1 0 0
0 0 1 0
0 0 0 1

It's easy to see that if we multiply this matrix by any 4x1 vector we'll get the same vector in the output.

### Scaling
If we multiply identity matrix by k, then we can scale vectors with the new scaling matrix.

### Translation
To move (translate) vector it's useful to work with the vectors of the form (x, y, z, 1) where 4th element is 
always 1.

Then the matrix 

1 0 0 dx
0 1 0 dy
0 0 1 dz
0 0 0 1

can be used to move vector by dx, dy, dz. We can combine scaling + translation in a single matrix.
We just need to scale first three ones on a diagonal.
Actually if we multiply scaling matrix by transform matrix, then we'll get scale + transform.

See [vertex_shader.glsl](./src/vertex_shader.glsl) for an example of using transform in GLSL.

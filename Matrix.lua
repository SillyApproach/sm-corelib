--- Represents a matrix and implements basic matrix operations
--- @class Matrix
--- @field private m number Number of rows
--- @field private n number Number of columns
--- @field private data table<number> Table containing the matrix' data
Matrix = class()

--- Creates table with fitting the required amount of elements
--- @param m number Number of rows
--- @param n number Number of columns
--- @param v number Initial value of the matrix' elements
--- @return table<number>
local function newDataTable(m, n, v)
    local data = {}
    v = v or 0

    for i = 1, m, 1 do
        table.insert(data, i, {})

        for j = 1, n, 1 do
            table.insert(data[i], j, v)
        end
    end

    return data
end

--- Lineary combines `a` and `b` by the given `sign`
--- @param a number First matrix
--- @param b number Second matrix
--- @param sign number Sign determining addition or subtraction
--- @return Matrix @Lineary combined matrix
local function matrixEntrywiseSum(a, b, sign)
    assert((a.m == b.m) and (a.n == b.n), "Mismatching dimensions")

    local data = newDataTable(a.m, a.n)

    for i = 1, a.m, 1 do
        for j = 1, a.n, 1 do
            local sum = a.data[i][j] + (sign * b.data[i][j])
            data[i][j] = sum
        end
    end

    return Matrix(data)
end

--- Initialises the matrix with the given data
--- @param self Matrix Matrix instance
--- @param data table<number> Initial matrix values
local function __init1(self, data)
    self.m = #data
    self.n = #data[1]
    self.data = data
end

--- Initialises the matrix with the given initial value
--- @param self Matrix Matrix instance
--- @param m number Number of rows
--- @param n number Number of columns
--- @param v number Initial value of the matrix' elements
local function __init2(self, m, n, v)
    self.m = m
    self.n = n
    self.data = newDataTable(m, n, v)
end

--- Constructor
--- @vararg any Overloaded constructor parameters
--- @overload fun(self: Matrix, initialData: table<number>)
--- @overload fun(self: Matrix, m: number, n: number, initialValue: number)
function Matrix:__init(...)
    local args = {...}
    assert(#args > 0, "No arguments passed. Either pass a table with matrix values or dimensions m and n and a default entry value v")

    if type(#args[1]) == "table" then
        __init1(self, #args[1])
    elseif #args >= 2 and type(args[1]) == "number" and type(args[2]) == "number" then
        __init2(self, args[1], args[2], args[3])
    else
        error("Arguments must be either a m*n array or two dimensions m and n and a default entry value v")
    end
end

--- Returns the product of a matrix multiplication
--- @param a Matrix First matrix
--- @param b Matrix Second matrix
--- @return Matrix @Product of matrix multiplication
function Matrix.__mul(a, b)
    assert(a.n == b.m, "Mismatching dimensions")

    local m, n, p = a.m, a.n, b.n
    local data = newDataTable(m, p)

    for i = 1, m, 1 do
        for j = 1, p, 1 do
            local sum = 0

            for k = 1, n, 1 do
                sum = sum + a.data[i][k] * b.data[k][j]
            end

            data[i][j] = sum
        end
    end

    return Matrix(data)
end

--- Lineary combines two matrices by addition
--- @param a Matrix First matrix
--- @param b Matrix Second matrix
--- @return Matrix @Lineary combined matrix
function Matrix.__add(a, b)
    return matrixEntrywiseSum(a, b, 1)
end

--- Lineary combines two matrices by subtraction
--- @param a Matrix First matrix
--- @param b Matrix Second matrix
--- @return Matrix @Lineary combined matrix
function Matrix.__sub(a, b)
    return matrixEntrywiseSum(a, b, -1)
end

--- Transposes the matrix
function Matrix:transpose()
    local data = newDataTable(self.n, self.m)

    for i = 1, self.m, 1 do
        for j = 1, self.n, 1 do
            data[j][i] = self.data[i][j]
        end
    end

    self.data = data
end

Matrix = class()
Matrix.m = nil
Matrix.n = nil
Matrix.data = nil

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

local function __init1(self, data)
    self.m = #data
    self.n = #data[1]
    self.data = data
end

local function __init2(self, m, n, v)
    self.m = m
    self.n = n
    self.data = newDataTable(m, n, v)
end

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

function Matrix.__add(a, b)
    return matrixEntrywiseSum(a, b, 1)
end

function Matrix.__sub(a, b)
    return matrixEntrywiseSum(a, b, -1)
end

function Matrix:transpose()
    local data = newDataTable(self.n, self.m)

    for i = 1, self.m, 1 do
        for j = 1, self.n, 1 do
            data[j][i] = self.data[i][j]
        end
    end

    self.data = data
end

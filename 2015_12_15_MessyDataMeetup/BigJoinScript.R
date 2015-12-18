
R
require(h2o)
h2o.init()
# or ...
# java -jar ./build/h2o.jar -name MyCloud &
# h2o.init(ip="mr-0xd6", port=55666)

N = 1e7

X = h2o.createFrame(rows=N,cols=5,integer_range=N,categorical_fraction = 0,integer_fraction=1,binary_fraction=0,missing_fraction = 0)
X
X$C1 = abs(X$C1)
colnames(X) = paste0("X.",colnames(X))
colnames(X)[1] = "KEY"
X
Y = h2o.createFrame(rows=N,cols=5,integer_range=N,categorical_fraction = 0,integer_fraction=1,binary_fraction=0,missing_fraction = 0)
Y$C1 = abs(Y$C1)
colnames(Y) = paste0("Y.",colnames(Y))
colnames(Y)[1] = "KEY"
Y

ans1 = h2o.merge(X, Y, method="radix")
system.time(print(dim(ans1)))
ans1
tail(ans1)



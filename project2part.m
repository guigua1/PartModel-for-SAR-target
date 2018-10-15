function p_point = project2part(part, point)

p_point = part.d * part.d' * point' + [part.d(2); -part.d(1)] * part.bias;
p_point = p_point';
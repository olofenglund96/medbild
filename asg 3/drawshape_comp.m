function drawshape_comp(shape, conList, col)
%Modified function drawshape where shape is complex.

if size(shape, 1) == 1
  shape = shape.';
end

if isreal(shape)
    shape = complex(shape(:,1), shape(:,2));
end

washold = 1;
if ~ishold
  washold = 0;
end

for subShapeId = 1:size(conList, 1)
  if ~washold && subShapeId > 1
    hold on
  end
  if conList(subShapeId, 3) == 0,
    plot(shape, char(col));
  else
    closedShape = [shape; shape(1)];
    plot(closedShape, char(col));
  end
end

if ~washold
  hold off
end

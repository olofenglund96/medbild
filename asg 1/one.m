sm1 = 0.5;
sm2 = 5;

m1 = 0;
m2 = 1;

% classes with s = 0.5
y11 = @(x) normpdf(x, m1, sm1);
y12 = @(x) normpdf(x, m2, sm1);

% classes with s = 5
y21 = @(x) normpdf(x, m1, sm2);
y22 = @(x) normpdf(x, m2, sm2);

p = @(x, mu, sig) [(mu + sig.*x), normpdf((mu + sig.*x), mu, sig)];
%rng(1); % predictable random numbers

r = randn(10,1);
XTrain11 = p(r, m1, sm1);
r = randn(10,1);
XTrain12 = p(r, m2, sm1);

r = randn(1000,1);
XTest11 = p(r, m1, sm1);
r = randn(1000,1);
XTest12 = p(r, m2, sm1);

r = randn(10,1);
XTrain21 = p(r, m1, sm2);
r = randn(10,1);
XTrain22 = p(r, m2, sm2);

r = randn(1000,1);
XTest21 = p(r, m1, sm2);
r = randn(1000,1);
XTest22 = p(r, m2, sm2);

XTrain = zeros(10, 2, 4);
XTrain(:,:,1) = XTrain11;
XTrain(:,:,2) = XTrain12;
XTrain(:,:,3) = XTrain21;
XTrain(:,:,4) = XTrain22;

XTest = zeros(1000, 2, 4);
XTest(:,:,1) = XTest11;
XTest(:,:,2) = XTest12;
XTest(:,:,3) = XTest21;
XTest(:,:,4) = XTest22;

%%
%scatter(XTest(:,1,1), XTest(:,2,1))

for i = 1:2
    scatter(XTrain(:,1,i), XTrain(:,2,i))
    hold on
    if i == 1
        x = linspace(-2, 2, 1000);
        plot(x, y11(x));
    elseif i == 2
        x = linspace(-1, 3, 1000);
        plot(x, y12(x));
    end
end

%%
sp1 = 0.01;
sp2 = 1;
k1 = @(x, xi) 1/(2*pi*sp1^2)^(1/2)*exp(-1/(2*sp1^2)*abs(x-xi).^2);
k2 = @(x, xi) 1/(2*pi*sp2^2)^(1/2)*exp(-1/(2*sp2^2)*abs(x-xi).^2);

p1 = @(x, xi) sum(k1(xi, x))/size(xi,1);
p2 = @(x, xi) sum(k2(xi, x))/size(xi,1);

%p11 = @(x)

xp = linspace(-3, 3, 10000);

figure
plot(xp, p1(xp, XTrain(:,1,1)));
hold on;
plot(xp, p1(xp, XTrain(:,1,2)));
plot(xp, 0.5*p1(xp, XTrain(:,1,1)) + 0.5*p1(xp, XTrain(:,1,2)))
title(['\sigma = 0.5 s_{parzen} = 0.01'])
legend('p(x|y=1)', 'p(x|y=2)', 'p(x)')
figure
plot(xp, 0.5*(p1(xp, XTrain(:,1,1)))./(0.5*p1(xp, XTrain(:,1,1)) + 0.5*p1(xp, XTrain(:,1,2))))
title(['\sigma = 0.5 s_{parzen} = 0.01'])
legend('p(y=1|x)')
%%
xp = linspace(-15, 15, 10000);
figure
plot(xp, p1(xp, XTrain(:,1,3)));
hold on;
plot(xp, p1(xp, XTrain(:,1,4)));
plot(xp, 0.5*p1(xp, XTrain(:,1,3)) + 0.5*p1(xp, XTrain(:,1,4)))
title(['\sigma = 5 s_{parzen} = 0.01'])
legend('p(x|y=1)', 'p(x|y=2)', 'p(x)')
figure
plot(xp, 0.5*(p1(xp, XTrain(:,1,3)))./(0.5*p1(xp, XTrain(:,1,3)) + 0.5*p1(xp, XTrain(:,1,4))))
title(['\sigma = 5 s_{parzen} = 0.01'])
legend('p(y=1|x)')
%%
xp = linspace(-10, 10, 10000);
figure
plot(xp, p2(xp, XTrain(:,1,1)));
hold on;
plot(xp, p2(xp, XTrain(:,1,2)));
plot(xp, 0.5*p2(xp, XTrain(:,1,1)) + 0.5*p2(xp, XTrain(:,1,2)))
title(['\sigma = 0.5 s_{parzen} = 1'])
legend('p(x|y=1)', 'p(x|y=2)', 'p(x)')
figure
plot(xp, 0.5*(p2(xp, XTrain(:,1,1)))./(0.5*p2(xp, XTrain(:,1,1)) + 0.5*p2(xp, XTrain(:,1,2))))
title(['\sigma = 0.5 s_{parzen} = 1'])
legend('p(y=1|x)')
%%
xp = linspace(-20, 20, 10000);
figure
plot(xp, p2(xp, XTrain(:,1,3)));
hold on;
plot(xp, p2(xp, XTrain(:,1,4)));
plot(xp, 0.5*p2(xp, XTrain(:,1,3)) + 0.5*p2(xp, XTrain(:,1,4)))
title(['\sigma = 5 s_{parzen} = 1'])
legend('p(x|y=1)', 'p(x|y=2)', 'p(x)')
figure
plot(xp, 0.5*(p2(xp, XTrain(:,1,3)))./(0.5*p2(xp, XTrain(:,1,3)) + 0.5*p2(xp, XTrain(:,1,4))))
title(['\sigma = 5 s_{parzen} = 1'])
legend('p(y=1|x)')
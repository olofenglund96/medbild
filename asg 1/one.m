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

for i = 3:4
    scatter(XTrain(:,1,i), XTrain(:,2,i))
    hold on
    if i == 3
        x = linspace(-20, 20, 1000);
        plot(x, y21(x));
    elseif i == 4
        x = linspace(-20, 20, 1000);
        plot(x, y22(x));
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
%%
xp = linspace(-3, 3, 10000);

figure
plot(xp, p1(xp, XTrain(:,1,1)));
hold on;
plot(xp, p1(xp, XTrain(:,1,2)));
plot(xp, 0.5*p1(xp, XTrain(:,1,1)) + 0.5*p1(xp, XTrain(:,1,2)))
title(['Estimated p(x|y=1), p(x|y=2) and p(x) with \sigma = 0.5 s_{parzen} = 0.01'])
legend('p(x|y=1)', 'p(x|y=2)', 'p(x)')
saveas(gcf,'plots/yxs05s001', 'epsc')
figure
plot(xp, 0.5*(p1(xp, XTrain(:,1,1)))./(0.5*p1(xp, XTrain(:,1,1)) + 0.5*p1(xp, XTrain(:,1,2))))
title(['Estimated p(y=1|x) with \sigma = 0.5 s_{parzen} = 0.01'])
ylim([0 1.3])
saveas(gcf,'plots/y1s05s001', 'epsc')
%%
xp = linspace(-15, 15, 10000);
figure
plot(xp, p1(xp, XTrain(:,1,3)));
hold on;
plot(xp, p1(xp, XTrain(:,1,4)));
plot(xp, 0.5*p1(xp, XTrain(:,1,3)) + 0.5*p1(xp, XTrain(:,1,4)))
title(['Estimated p(x|y=1), p(x|y=2) and p(x) with \sigma = 5 s_{parzen} = 0.01'])
legend('p(x|y=1)', 'p(x|y=2)', 'p(x)')
saveas(gcf,'plots/yxs5s001', 'epsc')
figure
plot(xp, 0.5*(p1(xp, XTrain(:,1,3)))./(0.5*p1(xp, XTrain(:,1,3)) + 0.5*p1(xp, XTrain(:,1,4))))
title(['Estimated p(y=1|x) with \sigma = 5 s_{parzen} = 0.01'])
ylim([0 1.3])
saveas(gcf,'plots/y1s5s001', 'epsc')
%%
xp = linspace(-10, 10, 10000);
figure
plot(xp, p2(xp, XTrain(:,1,1)));
hold on;
plot(xp, p2(xp, XTrain(:,1,2)));
plot(xp, 0.5*p2(xp, XTrain(:,1,1)) + 0.5*p2(xp, XTrain(:,1,2)))
title(['Estimated p(x|y=1), p(x|y=2) and p(x) with \sigma = 0.5 s_{parzen} = 1'])
legend('p(x|y=1)', 'p(x|y=2)', 'p(x)')
saveas(gcf,'plots/yxs05s1', 'epsc')
figure
plot(xp, 0.5*(p2(xp, XTrain(:,1,1)))./(0.5*p2(xp, XTrain(:,1,1)) + 0.5*p2(xp, XTrain(:,1,2))))
title(['Estimated p(y=1|x) with \sigma = 0.5 s_{parzen} = 1'])
ylim([0 1.3])
saveas(gcf,'plots/y1s05s1', 'epsc')
%%
xp = linspace(-20, 20, 10000);
figure
plot(xp, p2(xp, XTrain(:,1,3)));
hold on;
plot(xp, p2(xp, XTrain(:,1,4)));
plot(xp, 0.5*p2(xp, XTrain(:,1,3)) + 0.5*p2(xp, XTrain(:,1,4)))
title(['Estimated p(x|y=1), p(x|y=2) and p(x) with \sigma = 5 s_{parzen} = 1'])
legend('p(x|y=1)', 'p(x|y=2)', 'p(x)')
saveas(gcf,'plots/y1s5s1', 'epsc')
figure
plot(xp, 0.5*(p2(xp, XTrain(:,1,3)))./(0.5*p2(xp, XTrain(:,1,3)) + 0.5*p2(xp, XTrain(:,1,4))))
title(['Estimated p(y=1|x) with \sigma = 5 s_{parzen} = 1'])
ylim([0 1.3])
saveas(gcf,'plots/yxs5s1', 'epsc')
%%
t = 0.5;
px1 = 0.5*(p1(XTest(:,1,1)', XTrain(:,1,1)))./(0.5*p1(XTest(:,1,1)', XTrain(:,1,1)) + 0.5*p1(XTest(:,1,1)', XTrain(:,1,2))) >= t;
px2 = 0.5*(p1(XTest(:,1,2)', XTrain(:,1,1)))./(0.5*p1(XTest(:,1,2)', XTrain(:,1,1)) + 0.5*p1(XTest(:,1,2)', XTrain(:,1,2))) < t;

correct = length(find(px1 == 1)) + length(find(px2 == 1));
perf = correct/(length(px1) + length(px2))
err = 1-perf
%%
px1 = 0.5*(p2(XTest(:,1,1)', XTrain(:,1,1)))./(0.5*p2(XTest(:,1,1)', XTrain(:,1,1)) + 0.5*p2(XTest(:,1,1)', XTrain(:,1,2))) >= t;
px2 = 0.5*(p2(XTest(:,1,2)', XTrain(:,1,1)))./(0.5*p2(XTest(:,1,2)', XTrain(:,1,1)) + 0.5*p2(XTest(:,1,2)', XTrain(:,1,2))) < t;

correct = length(find(px1 == 1)) + length(find(px2 == 1));
perf = correct/(length(px1) + length(px2))
err = 1-perf

%%
px1 = 0.5*(p1(XTest(:,1,3)', XTrain(:,1,3)))./(0.5*p1(XTest(:,1,3)', XTrain(:,1,3)) + 0.5*p1(XTest(:,1,3)', XTrain(:,1,4))) >= t;
px2 = 0.5*(p1(XTest(:,1,4)', XTrain(:,1,3)))./(0.5*p1(XTest(:,1,4)', XTrain(:,1,3)) + 0.5*p1(XTest(:,1,4)', XTrain(:,1,4))) < t;

correct = length(find(px1 == 1)) + length(find(px2 == 1));
perf = correct/(length(px1) + length(px2))
err = 1-perf
%%
px1 = 0.5*(p2(XTest(:,1,3)', XTrain(:,1,3)))./(0.5*p2(XTest(:,1,3)', XTrain(:,1,3)) + 0.5*p2(XTest(:,1,3)', XTrain(:,1,4))) >= t;
px2 = 0.5*(p2(XTest(:,1,4)', XTrain(:,1,3)))./(0.5*p2(XTest(:,1,4)', XTrain(:,1,3)) + 0.5*p2(XTest(:,1,4)', XTrain(:,1,4))) < t;

correct = length(find(px1 == 1)) + length(find(px2 == 1));
perf = correct/(length(px1) + length(px2))
err = 1-perf
%% true models
t = 0.5;
px1 = 0.5*(y11(XTest(:,1,1))./(0.5*y11(XTest(:,1,1)) + 0.5*y12(XTest(:,1,1)))) >= t;
px2 = 0.5*(y11(XTest(:,1,2))./(0.5*y11(XTest(:,1,2)) + 0.5*y12(XTest(:,1,2)))) < t;

correct = length(find(px1 == 1)) + length(find(px2 == 1));
perf = correct/(length(px1) + length(px2))
err = 1-perf
%%
px1 = 0.5*(y21(XTest(:,1,3))./(0.5*y21(XTest(:,1,3)) + 0.5*y22(XTest(:,1,3)))) >= t;
px2 = 0.5*(y21(XTest(:,1,4))./(0.5*y21(XTest(:,1,4)) + 0.5*y22(XTest(:,1,4)))) < t;

correct = length(find(px1 == 1)) + length(find(px2 == 1));
perf = correct/(length(px1) + length(px2))
err = 1-perf

%% cross-validation
ni = 1;
data = XTrain(:,1,4);
datlen = length(data);
n = datlen;
k = @(x, xi, width) 1/(2*pi*width^2)^(1/2)*exp(-1/(2*width^2)*abs(x-xi).^2);
p = @(x, xi, width) sum(k(xi, x, width))/size(xi,1);

max_LL = -1000;
max_r = -1;
for r = 0.1:0.001:2
    LL = 0;
    for i = 1:n
        % remove 1 data point
        X = data;
        X(i) = [];
        xi = data(i);
        LL = LL + log(p(xi, X, r));
    end
    
    LL = LL/n;
    
    if LL > max_LL
        max_LL = LL;
        max_r = r;
    end
end

max_r
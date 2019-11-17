%% Load data (training data X1 - labels Y1)
% test data X2 - labels Y2

clear all
load(fullfile('databases','hep_proper_mask'));
X1_masks = Y1;
X2_masks = Y2;
load(fullfile('databases','hep_proper'));

%% Use hand made features

nr_of_training_images = size(X1,4)
for i = 1:nr_of_training_images,
   [fv,str]=get_features(X1(:,:,1,i),X1_masks(:,:,1,i));
   X1f(i,:)=fv;
end

nr_of_test_images = size(X2,4)
for i = 1:nr_of_test_images,
   [fv,str]=get_features(X2(:,:,1,i),X2_masks(:,:,1,i));
   X2f(i,:)=fv;
end

%% Visualize the data
figure(1);
gscatter(X1f(:,3), X1f(:,5), Y1 ,'rgbrgb','ooo+++');
xlabel(str{3});
ylabel(str{5});
figure(2)

colors = ['r','b','g','y', 'm', 'k'];

for i = 1:size(X1f, 1)
    scatter3(X1f(i,1), X1f(i,3), X1f(i,5), Y1(i), colors(Y1(i)));
    hold on;
end

xlabel(str{1});
ylabel(str{3});
zlabel(str{5});

%% Visualize cell images
indices = randi(size(X1,4), 4)
%indices = [426 427; 338 339]
hold off;
montage(X1(:,:,1, indices), 'DisplayRange', [0 100])


%% Visualize features on images
indices = randi(size(X1,4), 10);
Xf = X1(:,:,1, indices);

m = montage(X1(:,:,1, indices), 'DisplayRange', [0 100])
imshow(m)
%% Train machine learning models to data

%% Fit a decision tree model
disp(' ');
disp('Decision tree');
model1 = fitctree(X1f(:,1:6),Y1,'PredictorNames',str);
% Test the classifier on the training set
[Y_result1,node_1] = predict(model1,X1f);
accuracy1 = sum(Y_result1 == Y1)/numel(Y_result1);
disp(['The accuracy on the training set: ' num2str(accuracy1)]);
% Test the classifier on the test set
[Y_result2,node_2] = predict(model1,X2f);
accuracy2 = sum(Y_result2 == Y2)/numel(Y_result2);
disp(['The accuracy on the test set: ' num2str(accuracy2)]);

%% Fit a random forest model
disp(' ');
disp('Random forest');
model2 = TreeBagger(50,X1f,Y1,'OOBPrediction','On',...
    'Method','classification')
% Test the classifier on the training set
[Y_result1,node_1] = predict(model2,X1f);
accuracy1 = sum(Y_result1 == Y1)/numel(Y_result1);
disp(['The accuracy on the training set: ' num2str(accuracy1)]);
% Test the classifier on the test set
[Y_result2,node_2] = predict(model2,X2f);
accuracy2 = sum(Y_result2 == Y2)/numel(Y_result2);
disp(['The accuracy on the test set: ' num2str(accuracy2)]);

%% Fit a support vector machine model
disp(' ');
disp('Suppport vector machine');
model3 = fitcecoc(X1f,Y1);
% Test the classifier on the training set
[Y_result1,node_1] = predict(model3,X1f);
accuracy1 = sum(Y_result1 == Y1)/numel(Y_result1);
disp(['The accuracy on the training set: ' num2str(accuracy1)]);
% Test the classifier on the test set
[Y_result2,node_2] = predict(model3,X2f);
accuracy2 = sum(Y_result2 == Y2)/numel(Y_result2);
disp(['The accuracy on the test set: ' num2str(accuracy2)]);

%% Fit a k-nearest neighbour model
disp(' ');
disp('k-nearest neighbour');
model4 = fitcknn(X1f,Y1);
% Test the classifier on the training set
[Y_result1,node_1] = predict(model4,X1f);
accuracy1 = sum(Y_result1 == Y1)/numel(Y_result1);
disp(['The accuracy on the training set: ' num2str(accuracy1)]);
% Test the classifier on the test set
[Y_result2,node_2] = predict(model4,X2f);
accuracy2 = sum(Y_result2 == Y2)/numel(Y_result2);
disp(['The accuracy on the test set: ' num2str(accuracy2)]);







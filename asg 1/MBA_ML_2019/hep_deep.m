%% Load data (training data X1 - labels Y1)
% test data X2 - labels Y2

clear all
load(fullfile('databases','hep_proper_mask'));
X1_masks = Y1;
X2_masks = Y2;
load(fullfile('databases','hep_proper'));

idx = randperm(size(X1,4),round(size(X1,4)*0.2));
XValidation = X1(:,:,:,idx);
X1(:,:,:,idx) = [];
YValidation = Y1(idx);
Y1(idx) = [];

imageAugmenter = imageDataAugmenter( ...
    'RandRotation',[-45,45], ...
    'RandXTranslation',[-10 10], ...
    'RandYTranslation',[-10 10], ...
    'RandXReflection', true, ...
    'RandYReflection', true, ...
    'RandXScale', [0.9 1.1], ...
    'RandYScale', [0.9 1.1]);

augimds = augmentedImageDatastore([64 64 1],X1,Y1,'DataAugmentation',imageAugmenter)

%% 2. Select deep learning architecture
layers = [
    imageInputLayer([64 64 1],'Name','input') % Specify input sizes
    convolution2dLayer(3,16,'Padding',1,'Name','conv_3x3x16')
    batchNormalizationLayer('Name','batch_norm_1')
    reluLayer('Name','relu_1')
    
    maxPooling2dLayer(2,'Stride',2,'Name','max_pool_2x2_1')
    
    convolution2dLayer(3,32,'Padding',1,'Name','conv_3x3x32')
    batchNormalizationLayer('Name','batch_norm_2')
    reluLayer('Name','relu_2')
    
    maxPooling2dLayer(2,'Stride',2,'Name','max_pool_2x2_2')
    
    convolution2dLayer(3,64,'Padding',1, 'Name','conv_3x3x64')
    batchNormalizationLayer('Name','batch_norm_3')
    reluLayer('Name','relu_3')
    
    maxPooling2dLayer(4,'Stride',2,'Name','max_pool_4x4')
    
    convolution2dLayer(3,128,'Padding',1, 'Name','conv_3x3x128')
    batchNormalizationLayer('Name','batch_norm_4')
    reluLayer('Name','relu_4')
    
    convolution2dLayer(3,256,'Padding',1, 'Name','conv_3x3x256')
    batchNormalizationLayer('Name','batch_norm_41')
    reluLayer('Name','relu_41')
    
    transposedConv2dLayer(3,128, 'Name','tconv_3x3x128')
    batchNormalizationLayer('Name','batch_norm_42')
    reluLayer('Name','relu_42')
    
    transposedConv2dLayer(3,64, 'Name','64')
    batchNormalizationLayer('Name','batch_norm_43')
    reluLayer('Name','relu_43')
    
    fullyConnectedLayer(64, 'Name','fully_connected_64')
    fullyConnectedLayer(32, 'Name','fully_connected_32')
    fullyConnectedLayer(6, 'Name','fully_connected_6')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','output')];      % Specify output layer

lgraph = layerGraph(layers);
plot(lgraph)
%% 3. Train deep learning network
miniBatchSize = 64;       
max_epochs = 500;           % Specify how long we should optimize
learning_rate = 0.001;     % Try different learning rates 
options = trainingOptions( 'sgdm',...
    'MaxEpochs',max_epochs,...
    'InitialLearnRate',learning_rate, ...
    'Shuffle','every-epoch', ...
    'MiniBatchSize', miniBatchSize,...
    'Plots', 'training-progress', ...
    'verbose', false, ...
    'ValidationData',{XValidation,YValidation});
net = trainNetwork(augimds, layers, options);

%% 4. Test the classifier on the test set
[Y_result2,scores2] = classify(net,X2);
accuracy2 = sum(Y_result2 == Y2)/numel(Y_result2);
disp(['The accuracy on the test set: ' num2str(accuracy2)]);
%% Test the classifier on the training set
[Y_result1,scores1] = classify(net,X1);
accuracy1 = sum(Y_result1 == Y1)/numel(Y_result1);
disp(['The accuracy on the training set: ' num2str(accuracy1)]);


%% The Pattern Recognition Toolbox Engine
% In the Pattern Recogntion toolbox, all actions (classification,
% regression, etc...) are implemented as  <matlab:doc('prtAction')
% prtAction> objects. All prtAction objects share fundamental operations
% such as training, running and validating results share this common API.
% There are 5 methods, <matlab:doc('prtAction/train') train>,
% <matlab:doc('prtAction/run') run>,
% <matlab:doc('prtAction/runOnTrainingData') runOnTrainingData>,
% <matlab:doc('prtAction/crossValidate') crossValidate>, and
% <matlab:doc('prtAction/kfolds') kfolds>.
%
% Training is the first fundamental method in the Pattern Recognition
% Toolbox. Training occurs whenever a PRT object needs to learn some
% parameters from the data. All PRT objects require that training be done
% before the run function can be called. Training can be supervised or
% unsupervised, depending on the action. Supervised training makes use of
% labeled PRT data sets. A common example of supervised training is
% classification, where a classification objsct is trained using labeled
% datasets, and then performs classification on an unlabeled data set. For
% example:

ds = prtDataGenUnimodal;
classifier = prtClassGlrt;
classifier = classifier.train(ds);

%%
% Note that ds is a labeleled prtDataSetClass object. The object 'classsifier' is now a trained generalized likelihood ratoi
% test classifier. 

classifier.isTrained 

%%
% Unsupervised learing is when labels are not necessary for training. An
% example of this would be clustering. Suppose we remove the labels from
% ds, and train a K-means clustering algorithm:

ds = ds.setY([]); % setY is a shortcut for setTargets

% Create a K-means clustering object with 2 clusters.
cluster = prtClusterKmeans('nClusters', 2);  
cluster = cluster.train(ds);

%%
% The 'cluster' object is now a trained prtClusterKmeans object, and the
% run function can be invoked. Note, if you try to train a supervised
% object with unlabeled data, you will get an error. If you train an
% unsupervised object with labeled data, the labels are ignored.

%% Run
% The next fundamental method in the Pattern Recognition Toolbox is the run
% function. Invoking the run method calls whatever functionaly the
% prtAction object implements. For example, calling run on a prtClassGlrt
% object will perform the likelihood ratio test and output the likelihood
% ratio values. The result will be stored in a prtDataSet. 
%
% For example, create a new dataset, drawn from the same distribution
% as our training dataset ds:

dsTest = prtDataGenUnimodal;

%%
% Now, call the run function, and pass the test data set:

result = classifier.run(dsTest)

%%
% Have a look at the first few elements of the result dataset:

result.getX(1:5)    % getX() is a shortcut for getObservations()

%% 
% The values in results.observations correspond to the values of the
% likelihood ratio test for each observation in dsTest, as performed by the
% classifier that was trained with the data from the dataset ds. To make a
% decision based on these outputs, you will need to use a
% <matlab:doc('prtDecision') prtDecision> Object.
%
% The cluster object operates in exactly the same way:

result = cluster.run(dsTest)

%%
% However, the output is different for clustering. In this case the
% elements are assigned to a particular cluster:

result.getX(1:5,:)

%% 
% Indicating that the first 5 results correspond to either class 1 or class
% 2. Note in clustering there is some ambiguity because cluster labeling is
% arbitrary.

%% Cross Validation
%
% <matlab:doc('prtAction/crossValidate' Cross validation> allows you to
% perform training and running of an action in one command, by partitioning
% a labeled dataset into training and test data using keys. This also
% ensures that all data will be used for both training and testing. To
% illustrate, here is an example of how to use this functionality with a
% PRT clustering object:

keys = mod(1:ds.nObservations,3)'; % The keys will have values 1, 2 and 3
result = cluster.crossValidate(ds,keys);

%%
% This divides the dataset ds into 3 partitions, or folds. To test the
% first fold, the classifier will first be trained with the 2nd and 3rd
% folds. Then the classifier will be run using the data in the 1st fold.
% This will be repeated for all folds.
%
% The keys must be a single column vector, with the same number of
% observations in the data set.  In the example above, the first
% observation corresponds to key 1, the second to key 3, the third to key
% 3, and the 4th corresponds to key 1 again, and so forth. 
%
% When crossValidate is called, all the observations of ds corresponding to
% key 1 will be treated as test data, and the classifier will be trained
% using the data corresponding to keys 2 and 3. 

%% K-folds
% In the above example of cross validation, the user manually picked which
% data belonged to which fold. An alternative method is to use the
% <matlab:doc('prtAction/kfolds') kfolds> function. When calling kfolds,
% specify the number of folds you would like the data divided into. Kfolds
% will then randomly subdivide the data into the specified number of folds,
% and perform cross validation. For example:

nFolds = 3;
result = cluster.kfolds(ds,nFolds);

%%
% A final note about cross validation and kfolds, there are some actions
% that cross validation does not make sense, or is not possible. Outlier
% removal is an example of this. Kernel object are another. In this case, a flag is set, indicating
% that cross-validation is not a valid operation, and calling crossValidate
% or kfolds on such an object will error.

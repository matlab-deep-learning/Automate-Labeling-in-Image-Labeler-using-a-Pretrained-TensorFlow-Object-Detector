% Helper code to generate some label definitions for the test images.

function gTruth = generateGroundTruth

    % Label definitions
    ldc = labelDefinitionCreator;
    labels = {'person','vehicle','outdoor','animal','accessory','sports', ...
        'kitchen','food','furniture','appliance','indoor' };

    % Create randomized label colors for the categories
    for i=1:numel(labels)
        addLabel(ldc,labels{i},'Rectangle','LabelColor',rand([1,3]))
    end
    labelDefs = create(ldc);

    % DataSource for the images
    imageFilenames = {'stopSignTest.jpg','camp.jpg'};
    imageFilenames = fullfile(pwd,'Testimages',imageFilenames);
    dataSource = groundTruthDataSource(imageFilenames);

    % Empty Ground truth
    labelData =cell2table(cell(2,11), 'VariableNames', labels);

    %Ground Truth object
    gTruth = groundTruth(dataSource,labelDefs,labelData);

end

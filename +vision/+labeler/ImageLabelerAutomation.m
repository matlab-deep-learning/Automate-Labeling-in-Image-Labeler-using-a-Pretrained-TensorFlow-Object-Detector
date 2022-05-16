classdef ImageLabelerAutomation < vision.labeler.AutomationAlgorithm
    
    %   Copyright 2017-2022 The MathWorks, Inc.
    properties(Constant)
        
        % Name: Character vector specifying the name of the algoritm.
        Name = 'Object Detection Automation';
        
        % Description: One-line description of the algorithm.
        Description = ['This example uses pre-trained third party deep ' ...
            'learning library to perform object labelling.'];
        
        UserDirections = {...
            ['This AutomationAlgorithm automatically creates bounding box ', ...
           'labels for 11 object categories.'], ...
           ['Review and Modify: Review automated labels over the interval ', ...
           'using playback controls. Modify/delete/add ROIs that were not ' ...
           'satisfactorily automated at this stage. If the results are ' ...
           'satisfactory, click Accept to accept the automated labels.'], ...
           ['Accept/Cancel: If results of automation are satisfactory, ' ...
           'click Accept to accept all automated labels and return to ' ...
           'manual labeling. If results of automation are not ' ...
           'satisfactory, click Cancel to return to manual labeling ' ...
           'without saving automated labels.']};

    end
    
    properties
        
        TensorFlowModel

        % Threshold for the object detection score
        Threshold = 0.3
        
        % Label class names (super-classes)
        Labels = {'person','vehicle','outdoor','animal','accessory', ...
            'sports','kitchen','food','furniture','appliance','indoor'};

        % ids corresponding to the labels. Note that be bunch together
        % similar classes into superclasses
        LabelIDs = {1,(2:9),(10:15),(16:25),(26:33),(34:43),(44:51),(52:61), ...
            (62:71),(72:83),(84:91)};

        
    end
    
    
    methods
       
        function isValid = checkLabelDefinition(algObj, labelDef)
                     
            isValid = false;

            % We turn on only those labels whose name matches the list
            if any(strcmp(algObj.Labels,labelDef.Name))
                isValid = true;
            end
                        
        end
        
        function isReady = checkSetup(algObj)
 
            isReady = 0;
            if ~isempty(algObj.ValidLabelDefinitions)
                isReady = 1;
            end


        end
        
        
    end
    

    methods

        function initialize(algObj, ~)
            
            % Load the tensorflow function using Python utility module
            algObj.TensorFlowModel = py.pyUtil.createModel();            
            
        end
        

        function autoLabels = run(algObj, I)

            sz = size(I);
            I = imresize(I,[640,640]);
            I2(1,:,:,:) = I; 
            
            % Obtain network prediction using Python utility
            out = py.pyUtil.detect(algObj.TensorFlowModel,py.numpy.array(I2));
            
            % Convert Python dictionary into a MATLAB struct
            out = struct(out);
        
            % Extract boxes, classes and probabilities from the struct
            detectionClasses = single(out.detection_classes.numpy());
            detectionScores = single(out.detection_scores.numpy());
            detectionBoxes = single(out.detection_boxes.numpy());
        
            % Only keep predictions above originalBox certain threshold
            aboveThresh = find(detectionScores>algObj.Threshold);
            detectionClasses = detectionClasses(aboveThresh);

            % Extract label ids and bounding boxes from the prediction
            labels = arrayfun(@(y) find(cellfun(@(x) ismember(y,x),algObj.LabelIDs)) ,detectionClasses);          
            bboxes = detectionBoxes(1,aboveThresh, :);

            % Resize the bounding box for each prediction according to
            % original image
            bboxes = reshape(bboxes,[numel(detectionClasses),4]);
            labelNames = algObj.Labels(labels);
        
            % Resize the bounding boxes to original image dimensions and permute the dimensions
            % to make it consistent with MATLAB rectangle notation.
        
            bboxes = ceil(bboxresize(bboxes,[ sz(2) sz(1)]));    
            permutedBox = [bboxes(:,2),bboxes(:,1), ...
                    bboxes(:,4)-bboxes(:,2),(bboxes(:,3)-bboxes(:,1))];
            
        
            % If no labels are found, return an empty array
            if (numel(aboveThresh)==0)
                autoLabels = [];
            else
                autoLabels = struct('Name', cell(1, numel(aboveThresh) ), ...
                    'Type', cell(1, numel(aboveThresh) ),'Position',zeros([1 4]));
            end

            for i=1:numel(aboveThresh)               
                % Add the predicted label to outputs
                autoLabels(i).Name     = labelNames{i};
                autoLabels(i).Type     = labelType.Rectangle;
                autoLabels(i).Position = permutedBox(i,:);
        
            end
            
            
        end
        

    end
end

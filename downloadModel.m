function downloadModel()
    outputDir = fullfile(pwd,'efficientdet_d1_1');
    if ~exist(outputDir,'dir')
        websave("model.tar.gz","https://storage.googleapis.com/tfhub-modules/tensorflow/efficientdet/d1/1.tar.gz");
        untar('model.tar.gz','efficientdet_d1_1')
    end
end

function prep_celiuDataset
% preps celiu's cvpr2013 dataset into pascal voc friendly format (so as to
% run dpm detectors on it)

try
    
indir = '/projects/grail/santosh/Datasets/ObjectDiscoveryData_JoulinCVPR13/Data/';
outdir = '/projects/grail/santosh/Datasets/Pascal_VOC/VOC1002/';
objnames = {'aeroplane', 'car', 'horse'};

for f = 1:numel(objnames) 
    
    disp(['DOING OBJECT: ' objnames{f}]);
    
    disp('softlink images into JPEGImages');
    ids = mydir([indir '/' objnames{f} '/GroundTruth/*.png']);
    for j=1:numel(ids)
        myprintf(j,100);
        system(['ln -s ' [indir '/' objnames{f} '/' strtok(ids{j},'.') '.jpg'] ' ' [outdir '/JPEGImages/' objnames{f} '_' strtok(ids{j},'.') '.jpg']]);
    end
    myprintfn;

    disp('create .txt files in ImageSets');
    fid = fopen([outdir '/ImageSets/' objnames{f} '_test.txt'], 'w');
    for j=1:numel(ids)
        myprintf(j,100);
        fprintf(fid, '%s\n', [objnames{f} '_' strtok(ids{j},'.')]);
    end    
    fclose(fid);
    myprintfn;
      
end
   
catch
    disp(lasterr); keyboard;
end
        
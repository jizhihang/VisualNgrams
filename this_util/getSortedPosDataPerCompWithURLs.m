function [poscell, posdata] = getSortedPosDataPerCompWithURLs(pos, posscores_befjnt, lbbox_befjnt, model)

% be careful using the dataid field of "pos" (they have been modified in the parent
% function)

posdata = pos;
for ik = 1:numel(posdata)
    myprintf(ik, 100);  
    [~, fnameval] = system(['readlink -f ' posdata(ik).im]);
    fnameval = strtok(fnameval);        % get rid of carriage return
    [pathToURLfile, fnameval] = myStrtokEnd(fnameval, '/');
    imgID = myStrtokEnd(fnameval, '.');
    pathToURLfile = [pathToURLfile '/ignore/.images.tsv'];
    [~, imurl] = system(['grep ' '^' imgID ' ' pathToURLfile ' | cut -f 2']);
    imurl = strtok(imurl);              % get rid of carriage return
    posdata(ik).imgurl = imurl;
    
    posdata(ik).imgsize = size(imread(posdata(ik).im)); % size
    posdata(ik).score = posscores_befjnt(ik,:);           % finalbbox score
    posdata(ik).bbox = round(lbbox_befjnt(ik,:));              % finalbbox
end
myprintfn;
%posdata = rmfield(posdata,{'im', 'x1', 'y1', 'x2', 'y2', 'boxes', 'dataids', 'sizes'});


% save it as a cell so it is more user friendly + sorted by scores
poscell = cell(numel(model.phrasenames), 1);
for ik=1:numel(model.phrasenames)
    myprintf(ik, 10);
    thisCompInds = find([posdata(:).thisPosModelId] == ik);
    poscell{ik} = posdata(thisCompInds);
    [~, sinds] = sort([poscell{ik}(:).score], 'descend');
    poscell{ik} = poscell{ik}(sinds);
    poscell{ik} = rmfield(poscell{ik}, {'im', 'x1', 'y1', 'x2', 'y2', 'boxes', 'dataids', 'sizes'});
    poscell{ik} = rmfield(poscell{ik}, {'thisPosModelId', 'score'});
    poscell{ik} = orderfields(poscell{ik}, {'imgurl', 'imgsize', 'bbox', 'flip', 'trunc'});
end
myprintfn;

%{
    posdata = pos;
    parfor ik = 1:numel(posdata)
        myprintf(ik, 100);
        [~, fnameval] = system(['readlink -f ' posdata(ik).im]);
        fnameval = strtok(fnameval);        % get rid of carriage return
        [pathToURLfile, fnameval] = myStrtokEnd(fnameval, '/');
        imgID = myStrtokEnd(fnameval, '.');
        pathToURLfile = [pathToURLfile '/ignore/.images.tsv'];
        [~, imurl] = system(['grep ' '^' imgID ' ' pathToURLfile ' | cut -f 2']);
        imurl = strtok(imurl);              % get rid of carriage return
        posdata(ik).url = imurl;
        
        posdata(ik).imgsize = size(imread(posdata(ik).im)); % size
        posdata(ik).bbox = lbbox_befjnt(ik,:);              % finalbbox
        posdata(ik).score = posscores_befjnt(ik);           % finalbbox score
    end
    myprintfn;
    %posdata = rmfield(posdata,{'im', 'x1', 'y1', 'x2', 'y2', 'boxes', 'dataids', 'sizes'});
    
    % save it as a cell so it is more user friendly + sorted by scores
    poscell = cell(numel(model.phrasenames), 1);
    for ik=1:numel(model.phrasenames)
        myprintf(ik, 10);
        thisCompInds = find([posdata(:).thisPosModelId] == ik);
        poscell{ik} = posdata(thisCompInds);
        [~, sinds] = sort([poscell{ik}(:).score], 'descend');
        poscell{ik} = poscell{ik}(sinds);
        poscell{ik} = rmfield(poscell{ik},{'im', 'x1', 'y1', 'x2', 'y2', 'boxes', 'dataids', 'sizes'});
    end
    myprintfn;
%}

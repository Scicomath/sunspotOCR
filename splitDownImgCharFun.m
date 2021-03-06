function [ aimCharIndex,aimChar,RGB,mergedImg ] = splitDownImgCharFun( downImg,verbose )
%splitDownImgCharFun 此处显示有关此函数的摘要
%   此处显示详细说明

% 标记连通区域
CC = bwconncomp(downImg);
L = labelmatrix(CC);

% 分割粘连字符
for i = 1:CC.NumObjects
    if sum(any(L==i)) > 60 % 如果连通块的宽度大于60
        [img,rIndex,cIndex] = extractCompFun( L,i,0 );
        [ newImg,splitCharImg ] = splitConnectCharFun( img,0 );
        if ~isempty(splitCharImg)
            downImg(rIndex,cIndex) = newImg | (L(rIndex,cIndex) ~= i & L(rIndex,cIndex)~=0 );
        end
    end
end

% 标记连通区域
CC = bwconncomp(downImg);
L = labelmatrix(CC);

% 分割粘连字符
for i = 1:CC.NumObjects
    if sum(any(L==i)) > 60 % 如果连通块的宽度大于60
        [img,rIndex,cIndex] = extractCompFun( L,i,0 );
        [ newImg,splitCharImg ] = splitConnectCharFun( img,0 );
        if ~isempty(splitCharImg)
            downImg(rIndex,cIndex) = newImg | (L(rIndex,cIndex) ~= i & L(rIndex,cIndex)~=0 );
        end
    end
end

% 标记连通区域
CC = bwconncomp(downImg);
L = labelmatrix(CC);

% 提取单个字符矩阵
charImg = cell(1,CC.NumObjects);
for i = 1:CC.NumObjects
    charImg{i} = extractCompFun( L,i,1 );
end

% 提取区块属性
[Eccentricity,ConvexArea,Solidity,Centroid,Orientation,MajorAxisLength,Area,rMean,Height,Width] = findPropFun(downImg);

% 寻找等号
[equal] = findEqualFun(Eccentricity, Orientation,MajorAxisLength,Area,Solidity,rMean,Centroid);
% 寻找撇号
[ prime ] = findPrimeFun( Centroid,Eccentricity,rMean,MajorAxisLength,Orientation,Area );

[RGB] = imgHighlightComp( downImg,{equal,prime},{'red','blue'} );
if verbose
    figure,imshow(RGB)
end

% 筛掉面积小于250 主轴长大于150 的连通块
leftComp = setdiff(find(Area>250&MajorAxisLength>10&MajorAxisLength<150 &...
    abs(rMean - Centroid(:,2))' < 30 & Height >= 33),[equal,prime]);
leftN = length(leftComp);

aimCharIndex = leftComp;
aimN = length(aimCharIndex);


aimChar = cell(1,aimN);
for i = 1:aimN
    aimChar{i} = charImg{aimCharIndex(i)};
end

[ mergedImg ] = mergeImageFun( aimChar,0 );
if verbose
    figure
    imshow(mergedImg)
end
end


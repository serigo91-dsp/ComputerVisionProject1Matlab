%% Load the image files into a cell array to be used
orgCell = cell(41);

for k = 1:41 %This for loop will search for appropriate files and load them into our cell structure
    
    imageFileName1 = strcat('org_' ,num2str(k),'.png');
    imageFileName2 = strcat('noise_' ,num2str(k-5),'.png');
    imageFileName3 = strcat('proj1_' ,num2str(k-10),'.png');
    imageFileName4 = strcat('proj2_' ,num2str(k-15),'.png');
    imageFileName5 = strcat('rot_' ,num2str(k-20),'.png');
    imageFileName6 = strcat('proj_' ,num2str(k-25),'.png');
    imageFileName7 = strcat('real_' ,num2str(k-30),'.jpg');
    
    if exist(imageFileName1)
        imData = imread(imageFileName1);
        orgCell{k} = imData; 
        
    elseif exist(imageFileName2)
           imData = imread(imageFileName2);
           orgCell{k} = imData; 
    
    elseif exist(imageFileName3)
           imData = imread(imageFileName3);
           orgCell{k} = imData;
           
    elseif exist(imageFileName4)
           imData = imread(imageFileName4);
           orgCell{k} = imData;
           
    elseif exist(imageFileName5)
           imData = imread(imageFileName5);
           orgCell{k} = imData;
    
    elseif exist(imageFileName6)
           imData = imread(imageFileName6);
           orgCell{k} = imData;
           
    elseif exist(imageFileName7)
           imData = imread(imageFileName7);
           orgCell{k} = imData;
    else
        
           fprintf('File %s does not exist.\n',imageFileName);
    
    end 
    
end



%% Setting Colour Threshold for use in the Image Processing
%We will set different LAB threshold here so we can call upon them in the
%loop later - The values were taken from colorizer - some colours can have
%two threshholds within the same colour band
%*************************BLUE COLOUR THRESHHOLD**********************
bluethresholdL = 53;
bluethresholda = 29;
bluethresholdb = -35; %needs to be below this value
%*************************GREEN COLOUR THRESHHOLD**********************
greenthresholda = -30; %needs be below this value
greenthresholdb = 19; %needs to be above this value
%*************************RED COLOUR THRESHHOLD**********************
redthresholda = 26; %needs be above this value
redthresholdb = 12; %needs to be above this value
%*************************YELLOW COLOUR THRESHHOLD**********************
yellowthresholdaHI = 8; %needs be below this value
yellowthresholdaLO = -30; %needs to be above this value
yellowthresholdb = 30; %needs to be above this value
%*************************WHITE COLOUR THRESHHOLD**********************
whitethresholdL = 85; %Needs to be above this value
whitethresholdaHI = 5; %needs be below this value
whitethresholdaLO = -5; %needs to be above this value
whitethresholdbHI = 5; %needs be below this value
whitethresholdbLO = -5;%needs to be above this value
%************************************************************************* 
%Now i will create an instance of a filter to be used in the procesing
filter1 = fspecial('average',3);% Create a pre-defined filter to allow us to lightly de-noise the images
%In this moment we have used an average filter as it was the one that gave
%us the best result, but this can be easily changed
%% In this section we will get the central co-ordinates of the black circles to be used later in the code

cleanImg = imfilter(orgCell{1},filter1); %Add filter to the Image
guideImg = cleanImg; %We are creating a guide image to be used with the filter later on in the processing
NormalThresholdVal = 2.5; %Here we are setting an abstract nornalised threshold
 
level = graythresh(cleanImg); %Get the graythreshgold of the image
BinaryImg = im2bw(cleanImg,level/NormalThresholdVal); %Set the threshhold value
invOrgBinary = ~BinaryImg; %Produce an inverse
% We have trouble differentiating the the frame from the circles in the
% orignal image due to the colour both being black (hence pixel value 0)
% We got round this by inverting the colour to separate the frame and the
% circles
R = imref2d(size(BinaryImg)); % Here we set a referrence image to be used with the projection part of the code
CCinv= bwconncomp(invOrgBinary);
Linv = bwlabel(invOrgBinary);
invBW2 = zeros(CCinv.ImageSize);
invBW2(CCinv.PixelIdxList{3}) = 0; %Here we convert all of the pixels withing the frame to 0, making the frame disappear 
invBW2(CCinv.PixelIdxList{1}) = 1; %while still keeping the circles black, this is one way of removing the frame, we will see another way later in the code
invBW2(CCinv.PixelIdxList{2}) = 1;
invBW2(CCinv.PixelIdxList{8}) = 1;
invBW2(CCinv.PixelIdxList{9}) = 1;
edditedInvBW = invBW2;
edditedLabeledIncBW = bwlabel(edditedInvBW); %Once frame removed, we label the measurements again so we can get the center points of the black circles
InvObjectMeasurements = regionprops(edditedLabeledIncBW,'Centroid'); %To save memory we will only record the measurements we need.
NumCircleObjects = size(InvObjectMeasurements);

origCenters1 = InvObjectMeasurements(1).Centroid;
origCenters2 = InvObjectMeasurements(2).Centroid;
origCenters3 = InvObjectMeasurements(3).Centroid;
origCenters4 = InvObjectMeasurements(4).Centroid;

fixedPoints = [origCenters1; origCenters2; origCenters3; origCenters4]; %We save this as a coordinate matrix to be used later in the code as the fixed points

%% Begin the processing for the images
sizeStruc = length(orgCell); %Lenght of the cell structure
textSize = 12; % Size of Text
textShift = -7; %Text shift
C = makecform('srgb2lab'); % Make a transform for LAB from RGB

for imageNum = 1:sizeStruc %Begin the loop for the image processing
    
NormalThresholdVal = 2.5; %Set a Threshold
mainImg = orgCell{imageNum}; %Call the images 1 by 1

if (size(mainImg,1) > size(guideImg,1)) && (size(mainImg,2) > size(guideImg,2)) %Here we check the input size of the images, we want them to be the same size when we add the guided filter.

    guideImg2 = imresize(guideImg,[size(mainImg,1) size(mainImg,2)]); %if size of image too large, we resize
    cleanImg = imguidedfilter(mainImg,guideImg2);
    
elseif (size(mainImg,1) < size(guideImg,1)) && (size(mainImg,2) < size(guideImg,2))%if main image too small we, we resize guide image
    
    mainImg2 = imresize(mainImg,[size(guideImg,1) size(guideImg,2)]);
    cleanImg = imguidedfilter(mainImg2,guideImg);
else    
    cleanImg = imguidedfilter(mainImg,guideImg); %Add A guided filter to the Image to remove some noise but preserve edges
end    


subplot(2,3,1);%We want to plot what the image we will be processing
imshow(mainImg);
title(['Original Image ', num2str(imageNum)])


level = graythresh(cleanImg); %Get the graythreshgold of the image
BinaryImg = im2bw(cleanImg,level/NormalThresholdVal); %Create a Binary Image using the threshold aquired
MovingThresholdVal = (level/NormalThresholdVal); %This is our moving threshold value, we will use this to find the best threshold for our application

InvBinaryImg = ~BinaryImg; %Create an inverse of the Binary Image
InvLabeledBinaryImg = bwlabel(InvBinaryImg,8);
InvobjectMeasurements = regionprops(InvLabeledBinaryImg,"MajorAxisLength", "Area", 'Eccentricity', 'EquivDiameter'); %Pull out measurements from region props. These are to be used later in the processing
ObjAreas = [InvobjectMeasurements.Area]; %Get area of the objectts
MajorAxisLenght = [InvobjectMeasurements.MajorAxisLength]; %Get major axis lenght of objects
ObjEccent = [InvobjectMeasurements.Eccentricity]; %Get eccentricity
ObjDiameter = [InvobjectMeasurements.EquivDiameter]; %Get diameter of objects
isObjSmall = (ObjAreas < 2500) & (ObjAreas > 125); %We create some boolean statements, to find objects of the specified area
isObjAxisWithinRange = (MajorAxisLenght < 50) & (MajorAxisLenght > 30); %We create some boolean statements, to find objects of the specified Major Axis Lenght (Ellipses)
smallObjIndex = find(isObjSmall & isObjAxisWithinRange);% We use the find function to find objects which fit the boolean statements created above
circleObjImg = ismember(InvLabeledBinaryImg,smallObjIndex);  %We remove all other objects which were not found by the above process
currentImgCirMeasures = regionprops(circleObjImg,'Centroid'); %Take the Centroid measurements of the Bianry Image
%% This if Loop will adjust settings if the 4 circles were not found, It will reapply the Area and Major Axis Thresholds until the four circles were found.
if size(currentImgCirMeasures) ~= 4 
    disp('Widening Threshold to find Circles')
    isObjSmall2 = (ObjAreas < 4500) & (ObjAreas >= 38); %The Area threshold was widenened
    isObjAxisWithinRange2 = (MajorAxisLenght < 125) & (MajorAxisLenght > 10); %Major Axis Threshold widened
    smallObjIndex2 = find(isObjSmall2 & isObjAxisWithinRange2);
    circleObjImg = ismember(InvLabeledBinaryImg,smallObjIndex2);
    currentImgCirMeasures = regionprops(circleObjImg,'Centroid', 'Eccentricity','EquivDiameter');
 
    if imageNum == 29 %Image 29 proved difficult due to one of the circles was too small, so we had to add a bit of script which would find it easier
    disp('Is this Image 29?')    
    isObjStraight = (ObjEccent < 0.9666);
    isObjImg29 = (ObjEccent < 0.9895) & (ObjEccent > 0.9893) & (ObjAreas < 4500) & (ObjAreas >= 38);
    smallObjIndex2 = find(isObjSmall2 & isObjAxisWithinRange2 & isObjStraight);
    im29ObjIndex = find(isObjImg29);
    im29ObjImg = ismember(InvLabeledBinaryImg,im29ObjIndex);
    img29measures = bwconncomp(im29ObjImg);
    circleObjImg = ismember(InvLabeledBinaryImg,smallObjIndex2);
    circleObjImg(img29measures.PixelIdxList{1}) = 1;
    currentImgCirMeasures = regionprops(circleObjImg,'Centroid', 'Eccentricity','EquivDiameter'); 
    
    elseif size(currentImgCirMeasures) ~= 4
    disp('Adding Eccentricity and Perimeter to the Equation') %Here we add more measurement in the hope to find the circles   
    isObjStraight = (ObjEccent < 0.9666);
    smallObjIndex2 = find(isObjSmall2 & isObjAxisWithinRange2 & isObjStraight);
    circleObjImg = ismember(InvLabeledBinaryImg,smallObjIndex2);
    currentImgCirMeasures = regionprops(circleObjImg,'Centroid', 'Eccentricity','EquivDiameter');
    else
    end
else
end    

currentCenters1 = currentImgCirMeasures(1).Centroid; %Here we get the centroids of the found circles
currentCenters2 = currentImgCirMeasures(2).Centroid;
currentCenters3 = currentImgCirMeasures(3).Centroid;
currentCenters4 = currentImgCirMeasures(4).Centroid;

movingPoints = [currentCenters1; currentCenters2; currentCenters3; currentCenters4]; %And add them to a coordinate matrix as the moving points.

subplot(2,3,3);
imshow(circleObjImg,[])
hold on
for p = 1:length(movingPoints)
  plot(movingPoints(p,1), movingPoints(p,2), 'r+', 'MarkerSize', 15, 'LineWidth', 3);
end   
title(['Moving Projection Points on Image ', num2str(imageNum)]) %Plot the found circles in the image and with a red cross to show the centroids 
hold off

isImageProj = (movingPoints  ~= fixedPoints); %Create a Boolean statement to check if the image needs to be transformed, this is done by checking the moving points against the fixed points, if they are not equal it will return false
%% Here we will project the image to the correct orientation if the new centroid do not match the original Image centroid
if isImageProj %Using the boolean statement created in the previous line this will decide wether to project the image.
    disp('Projecting')
    mytform = fitgeotrans(movingPoints,fixedPoints,'projective');%Using the 4 sets of coordinates we found above we can use fitgeotrans to create a homogeny matrix between the image the ref image and the new image.
    mainImg = imwarp(mainImg,mytform,'OutputView',R); %
    cleanImg = imguidedfilter(mainImg,guideImg);%
    BinaryImg = im2bw(cleanImg,level/NormalThresholdVal); %Create a Binary Image of the projected Image
    
else %If the image wasn't projected, we just apply filtering
    cleanImg = imguidedfilter(mainImg,guideImg);
    BinaryImg = im2bw(cleanImg,level/NormalThresholdVal);
end
 

LabeledBinaryImg = bwlabel(BinaryImg,8);% Label the binary image
objectMeasurements = regionprops(LabeledBinaryImg,'all'); %Get all the measurements of the objects found in the binary image

subplot(2,3,4);
imshow(BinaryImg)
title(['Threshholded Image ', num2str(imageNum)])

numberOfObjects = size(objectMeasurements,1);
counter = 1;

%%Here we begin the process of thresholding the image till we get the
%desired amount of objects, the threshhold value will move up and down
%until it finds an optimal value

while (numberOfObjects ~= 17) %This will increase the threshold until the number of objects is 17, this is because theis the mumber of object present to recognise the colour
        
        
    if numberOfObjects > 17 % if the object number is too large we will trigger this statement.
        if  (numberOfObjects > 45)
          
            disp('Decreasing Threshold')
          
            MovingThresholdVal = MovingThresholdVal - 0.05; %Lower the threshold, and reapply all the measurements
            BinaryImg = im2bw(cleanImg,MovingThresholdVal);
      
            LabeledBinaryImg = bwlabel(BinaryImg,8);
            objectMeasurements = regionprops(LabeledBinaryImg,'all');

            numberOfObjects = size(objectMeasurements,1);
            
           % disp(num2str(numberOfObjects));
            subplot(2,3,4);
            imshow(BinaryImg)
            title('Threshholded Image')
            counter = counter + 1;

        else
            
            disp('Decreasing Threshold')
    

 
            MovingThresholdVal = MovingThresholdVal - 0.01; %Lower the threshold much more, and reapply all the measurements
            BinaryImg = im2bw(cleanImg,MovingThresholdVal); 
            LabeledBinaryImg = bwlabel(BinaryImg,8);
            objectMeasurements = regionprops(LabeledBinaryImg,'all');
            
            numberOfObjects = size(objectMeasurements,1);
           %disp(num2str(numberOfObjects));
            subplot(2,3,4);
            imshow(BinaryImg)
            title('Threshholded Image')
            counter = counter + 1;
            
        end
     elseif  counter >= 30 % break the loop if it runs too many times, so it does not get stuck in a loop
            disp('Cannot find Threshold, Skipping')
            break
            
     elseif numberOfObjects < 17
              
            disp('Increasing Threshold')
            MovingThresholdVal = MovingThresholdVal + 0.01;   %Lower threshold
            BinaryImg = im2bw(cleanImg,MovingThresholdVal); 
            LabeledBinaryImg = bwlabel(BinaryImg,8);
            objectMeasurements = regionprops(LabeledBinaryImg,'all');
            

            numberOfObjects = size(objectMeasurements,1);
         % disp(num2str(numberOfObjects)); 
            subplot(2,3,4);
            imshow(BinaryImg)
            title('Threshholded Image')
            counter = counter + 1;
      else
        disp('Found Threshold')  
    end
    
end


orgImLab = applycform(cleanImg,C); %Produce a LAB image form the original image
orgLab = lab2double(orgImLab); %Convert from unit8 to double

LImg = orgLab(:,:,1);%Separating each dimention of the LAB colour space (L)
aImg = orgLab(:,:,2);%(a)
bImg = orgLab(:,:,3);%(b)

imageText = ['Recognising Colours on Image ', num2str(imageNum)]; %Diplay text for debuggin purposes
disp(imageText)

for i = 2:numberOfObjects
   

    currentObjPixel = objectMeasurements(i).PixelIdxList; % We get the object pixel value and store it in a variable
    
    objArea = objectMeasurements(i).Area; %We get the object area value and store it in a variable
    objPerim = objectMeasurements(i).Perimeter; %We get the object perimeter value and store it in a variable%
    objCenter = objectMeasurements(i).Centroid; %%We get the object centroid and store it in a variable
    objBoundingBox = objectMeasurements(i).BoundingBox; %We get the object bounding box value and store it in a variable
    
    cropObj = imcrop(cleanImg, objBoundingBox); %We crop the object from the original image, we use the bounding box of the object as all our objects should be boxes, this is only to show in the display.
    
    cropImageL = imcrop(LImg, objBoundingBox);  %We crop the object from the L colour space of the Image
    cropImagea = imcrop(aImg, objBoundingBox); %We crop the object from the a colour space of the Image
    cropImageb = imcrop(bImg, objBoundingBox); %We crop the object from the b colour space of the Image

    meanIntensityL = mean2(cropImageL); %We take the mean of the whole bounding box we cropped, we do this with all dimentions of the LAB image
    meanIntensitya = mean2(cropImagea);
    meanIntensityb = mean2(cropImageb);
    
   
    
    subplot(2,3,5);
    imshow(cropObj,[0 numberOfObjects]);
    title('Object Being Processed')
    
    subplot(2,3,6);
    imshow(cleanImg,[0 numberOfObjects]);
    title('Processed Image')
   
    %This if statement will decide which colour it will print on the
    %figure, it will the thresholds set at the begining of the code and
    %compare them to the mean of the box we cropped above. It will display
    %a letter on top of the colour box in the final display
  
    if(meanIntensityb < bluethresholdb) 
        
    text(objCenter(1) + textShift, objCenter(2),'B','Color','black','FontSize', textSize); 
    
    elseif (meanIntensitya <= greenthresholda) && (meanIntensityb > greenthresholdb)
    
    text(objCenter(1) + textShift, objCenter(2),'G','Color','black','FontSize', textSize);
     
    elseif (meanIntensitya >= redthresholda) && (meanIntensityb >= redthresholdb)
   
    text(objCenter(1) + textShift, objCenter(2), 'R','Color','black','FontSize', textSize); 
    
    elseif (meanIntensitya <= yellowthresholdaHI && meanIntensitya >= yellowthresholdaLO) && (meanIntensityb >= yellowthresholdb)
   
    text(objCenter(1) + textShift, objCenter(2), 'Y','Color','black','FontSize', textSize);   
           
    elseif  (meanIntensitya <= whitethresholdaHI && meanIntensitya >= whitethresholdaLO) && (meanIntensityb <= whitethresholdbHI && meanIntensityb >= whitethresholdbLO) && (meanIntensityL >= whitethresholdL) 
        
    text(objCenter(1) + textShift, objCenter(2), 'W','Color','black','FontSize', textSize); 
    
    else
        
    text(objCenter(1) + textShift, objCenter(2), 'Fail','Color','black','FontSize', textSize); hold on; %If an colour doe not fit within any of the LAB threshold, this message will appear.
    failText = ['Colour Fail on Object ', num2str(i)];
    disp(failText)    
    end    

pause(0.3); 
 
   
end

hold off
disp('Colours Recognised')
end

disp('Finished Running Program')

return
























function sar_cfar_6(f,width,height,pfa)
%SARͼ��CFARĿ�����㷨���㷨���õ��ǻ��������ֲ���˫����CFAR�㷨
%   sar_cfar_4(hObject,eventdata,handles,f)��hObject,eventdata,handles�ֱ���
%   ͼ�ν�����򴫵������Ķ����¼�������������������¼���δʹ�ã�ֻʹ����
%   �����fΪ�����SARͼ�񣬴�ʱ��SARͼ���Ѿ�����ά�����һά

tic;
densGate = 2;              %�ܶ��˲���ֵ
rad = 2;                        %��̬ѧ�˲��ṹԪ�ذ뾶ֵ
f = double(f);
f_size = size(f);
if nargin<2
	width = 20;
	height = 20;
    pfa = 0.001;
end
pf = pfa;
%--------------------------------------------------------------------------
%        һ��ȷ��CFAR������������������ڳߴ磬��������ȣ��Ӳ������
%--------------------------------------------------------------------------

%--ȷ��CFAR������Ĳ���
%--1.ȡ�����е����ֵ
global tMaxLength;
tMaxLength = max(width,height);

%--2.ȷ���������ı߳�
global proLength;
proLength = tMaxLength*2 + 1;                           %Ϊ������㣬ȡΪ����

%--3.ȷ���Ӳ������ο��
global cLength;
cLength = 1;                                            %���һ��Ϊ1�����ص�

%--4.���������Ӳ������������
numPix = 2*cLength*(2*cLength+proLength+proLength); 

%--5.CFAR������߳���һ��
global cfarHalfLength;
cfarHalfLength = tMaxLength+cLength;

%--6.CFAR������߳�
global cfarLength;
cfarLength = proLength + 2*cLength;

%--------------------------------------------------------------------------
%         ������ԭͼ��߽����䣬�������߽��Ӱ��
%--------------------------------------------------------------------------
padLength = cfarHalfLength;           %ȷ��ͼ�����ı߽��СΪCFAR������һ��
global g;
g = padarray(f,[padLength padLength],'symmetric');      %gΪ�����ͼ��
global g_dis;                                           %��ͼ
g_dis = g;                                              %��ͼ

%--------------------------------------------------------------------------
%         ����ȷ��CFAR��ֵ
%--------------------------------------------------------------------------

th = (2*sqrt(-log(pf))-sqrt(pi))/(sqrt(4-pi));  %����ֵ����Ϊȷ�����龯������
                                                %��

%--------------------------------------------------------------------------
%        �ġ�����CFAR����������ֲ���ֵ��ִ�е������ص���ж�
%--------------------------------------------------------------------------

%--1.�������������
global resultArray
resultArray = zeros(size(g));
gloTh = 0.8 * mean2(g);
disp(['global threshold is ', num2str(gloTh)]);
%--2.CFAR���
for i = (1+padLength):(f_size(1)+padLength)
    for j = (1+padLength):(f_size(2)+padLength)
        if g(i,j) < gloTh
            continue;
        end
        [csIndex1, csIndex2, csIndex3, csIndex4] = getEstSec(i,j,1);
                        %�õ�(i,j)����������Ӧ��4���Ӳ�������������ͼ��ʾ
        [u,delta] = cfarEstPra(csIndex1,csIndex2,csIndex3,csIndex4);
                        %���Ӳ�����õ���ֵ�ͱ�׼ƫ��
        temp = (g(i,j)-u)/delta;    %����˫����CFAR����б�ʽ
        %Ŀ����б�
        if temp > th                
            resultArray(i,j) = 1;
        end
        i
        j
    end
end

%--------------------------------------------------------------------------
%                         �塢Ŀ�����ؾ���
%--------------------------------------------------------------------------
%--1.�ܶ��˲�
[row col] = find(resultArray == 1);     %�ҵ�Ŀ�����ص����������
numIndex2 = numel(row);                 %ȷ��Ŀ������
resultArray2 = zeros(size(g));          %resultArray2���Դ���ܶ��˲���ľ���
for k = 1:numIndex2                     %ִ���ܶ��˲�
    resultArray2(row(k),col(k)) = densfilt(row(k),col(k),width,height,...
                                   densGate);
end

%--2.��̬ѧ�˲�
se = strel('disk',rad);
resultArray3 = imclose(resultArray2,se);        %������
se = strel('disk',1);
resultArray3 = imerode(resultArray3,se);        %��ʴ
% waitbar(1,hWaitbar,'�㷨���');
% close(hWaitbar);
% toc 
% t = toc;                                        %�����㷨ʱ��

%--3.չʾ���ͼƬ
resultArray = resultArray((padLength+1):(end-padLength),(padLength+1):(end-padLength));
figure('Name','CFAR�����ֵͼ'),imshow(resultArray);
resultArray2 = resultArray2((padLength+1):(end-padLength),(padLength+1):(end-padLength));
figure('Name','�ܶ��˲����ֵͼ'),imshow(resultArray2);
resultArray3 = resultArray3((padLength+1):(end-padLength),(padLength+1):(end-padLength));
figure('Name','��̬�˲����ֵͼ'),imshow(resultArray3);
toc;
%--4.����������
% [rows, cols] = size(resultArray);
% countAll = sum(sum(resultArray));
% PAll = countAll/rows/cols;
% countTar = sum(sum(resultArray2));
% countFal = countAll - countTar;

% % --------------------------------------------------------------------------
% %                            ���㷨���õ��ĺ���
% % --------------------------------------------------------------------------
% % 
% % ------------һ���ܶ��˲�����-----------------------------------------------
function value = densfilt(r,c,width,height,densGate)
%   value=densfilt(r,c,width,height,densGate)��r��c�ֱ����������ص��к��У�
%   width��height�ֱ�����˲�����ģ��Ŀ�͸ߣ�densGate�����˲���ֵ��valueֵ
%   ���б���

global resultArray
a = ceil(height/2);
b = ceil(width/2);
%--1.�����Բ�������Ϊ���ĵ��˲�����ģ���λ��
rStart = r - a;
rEnd = r + a;
cStart = c - b;
cEnd = c + b;

%--2.�õ�����ģ��ģ���е�Ŀ��������
densSection = resultArray(rStart:rEnd,cStart:cEnd);
num = sum(densSection(:));

%--3.�ж��˲�
if num >= densGate
    value = 1;
else
    value = 0;
end

%%-------------�����õ��ĸ��Ӳ����������������������ֵ------------------------
function [csIndex1, csIndex2, csIndex3, csIndex4] = getEstSec(r,c,~)
%   [csIndex1 csIndex2 csIndex3 csIndex4] = getEstSec(r,c,method)��r��c����
%   �������ص��к��У�methodû�в��ã�����

global tMaxLength;
global proLength;
global cLength;
global cfarHalfLength;
global cfarLength;
%--1.csXΪһ������������������CFAR�������������Ͻ���ʼ����ֵ�����ȺͿ��
cs1 = [r-cfarHalfLength c-cfarHalfLength cfarLength cLength];
cs2 = [r+tMaxLength+1 c-cfarHalfLength cfarLength cLength];
cs3 = [r-tMaxLength c-cfarHalfLength cLength proLength];
cs4 = [r-tMaxLength c+tMaxLength+1 cLength proLength];

%--2.csIndexXҲ��һ������������������CFAR������������ʼ�������������
csIndex1 = [cs1(1) cs1(1)+cs1(4)-1 cs1(2) cs1(2)+cs1(3)-1];
csIndex2 = [cs2(1) cs2(1)+cs2(4)-1 cs2(2) cs2(2)+cs2(3)-1];
csIndex3 = [cs3(1) cs3(1)+cs3(4)-1 cs3(2) cs3(2)+cs3(3)-1];
csIndex4 = [cs4(1) cs4(1)+cs4(4)-1 cs4(2) cs4(2)+cs4(3)-1];

%--------------��������CFAR�������λ���Ӳ�����ľ�ֵ����׼ƫ��---------------
function [u,delta] = cfarEstPra(csIn1,csIn2,csIn3,csIn4)
%   [u,delta] = cfarEstPra(csIn1,csIn2,csIn3,csIn4)��csIn1,csIn2,csIn3,
%   csIn4�����ĸ��Ӳ��������򣬷��ؾ�ֵ�ͱ�׼ƫ��

global g;
%--1.���»���Ӳ����������ֵ
sec1 = g(csIn1(1):csIn1(2),csIn1(3):csIn1(4));
sec2 = g(csIn2(1):csIn2(2),csIn2(3):csIn2(4));
sec3 = g(csIn3(1):csIn3(2),csIn3(3):csIn3(4));
sec4 = g(csIn4(1):csIn4(2),csIn4(3):csIn4(4));

%--2.�������ϲ�
sec1 = sec1(:);
sec2 = sec2(:);
sec3 = sec3(:);
sec4 = sec4(:);
sec = [sec1;sec2;sec3;sec4];

%--3.��ȡ����
u = mean(sec);
e2 = mean(sec.^2);
delta = sqrt(e2 - u^2);
% global g_dis;
% g_dis(csIn1(1):csIn1(2),csIn1(3):csIn1(4))=0;    
%                                                                      %��ͼ
% g_dis(csIn2(1):csIn2(2),csIn2(3):csIn2(4))=0;
%                                                                      %��ͼ
% g_dis(csIn3(1):csIn3(2),csIn3(3):csIn3(4))=0;
%                                                                      %��ͼ
% g_dis(csIn4(1):csIn4(2),csIn4(3):csIn4(4))=0;
% imshow(g_dis,[])                                                     %��ͼ

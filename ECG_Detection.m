%% Loading Ecg Signal
ecg_signal=load('100m.mat', 'val');
new_signal=ecg_signal.val(1,:);

t=0:1:21599;
figure(1)
plot(t,new_signal,'k-')
xlabel ('Time')
ylabel ('Amplitude')
legend ('ECG Signal')
R_peak=0;

%% loading and plotting signal
signal=zeros(1,300);
 for i=1:1:300
   signal(1,i)=new_signal(1,i)./200;
 end
 
figure(2)
plot(signal,'k-')
xlabel ('Time')
ylabel ('Amplitude')
legend ('ECG Signal(300 samples)')
axis([0 300 -0.6 1])

%% Adding noise to the signal

sampling_frequency = 1000;
mains_coeff = 0.3;   
time_step = 1/sampling_frequency;
max_time = .300;   
t = time_step:time_step:max_time; 

mains_signal = cos(2*pi*60*t);

figure(3)
plot(mains_signal,'k-')
xlabel ('Time')
ylabel ('Amplitude')
legend ('Noise Signal')

noise_signal=mains_coeff*mains_signal;
dirty_signal=signal+noise_signal;

figure(4)
plot(dirty_signal,'k-')
xlabel ('Time')
ylabel ('Amplitude')
legend ('Noise Added Signal')

%% Analog to digital conversion

U=1; 
n=3;   
q=U/(2^n-1);
t=0:1:99;
y=abs(dirty_signal);
a=fix(y/q);
yq=a*q;

figure(5)
plot(yq, 'k-')
xlabel ('Time')
ylabel ('Amplitude')
legend ('Digital Signal')


%% implementation of filter banks

%low pass filters
B=[0.125 0.375 0.375 0.125];
A=1;

filtered_signal=filter(B,A,yq);

figure(6)
plot(filtered_signal, 'k-')
xlabel ('Time')
ylabel ('Amplitude')
legend ('Output of 1st filter')

filtered_signal1=filter(B,A,filtered_signal);

figure(7)
plot(filtered_signal1, 'k-')
xlabel ('Time')
ylabel ('Amplitude')
legend ('Output of 2nd filter')

filtered_signal2=filter(B,A,filtered_signal1);

figure(8)
plot(filtered_signal2, 'k-')
xlabel ('Time')
ylabel ('Amplitude')
legend ('Output of 3rd filter')

%high pass filter
B1=[-2 2];
A1=1;

filtered_signal3=filter(B1,A1,filtered_signal2);

figure(9)
plot(filtered_signal3, 'k-')
xlabel ('Time')
ylabel ('Amplitude')
legend ('Output of 4th filter')


%% Vth and Comparison 

vth=.85*max(filtered_signal3);

for j=1:1:100
    if filtered_signal3(1,j)>vth
        
        if R_peak>=filtered_signal(1,j)
            R_peak=R_peak;
            
        else
            R_peak=filtered_signal3(1,j);
        end
         
    end
end

Identified_R_peak=R_peak


%% RLE Coding:

x=find(filtered_signal3==R_peak)
Binary_Matrix=zeros(1,300);
Binary_Matrix(x)=1;

figure(10)
plot(Binary_Matrix,'k-')
xlabel ('Time')
ylabel ('Amplitude')
legend ('Binary Matrix For RLE')

a=Binary_Matrix;
g=size(a);
h=g(2);
k=0;
j=zeros(1,h);
for i=1:h
    
    if(a(i)==1 & i==1)
         if(a(i+1)==0)
             k=k+1;
                j(i)=k.*10+1;
                   
               
        else
            k=k+1;
               
         end
         
    elseif(a(i)==1 & i==g(2))
        if(a(i-1)==1)
            k=k+1;
            j(i)=k.*10+1;
        else
            k=0;
            k=k+1;
            j(i)=k.*10+1;
        end
            
    
        elseif(a(i)==1 & i~=g(2))
             if(a(i-1)==1)
                if(a(i+1)==0)
                    k=k+1;
                        j(i)=k.*10+1;
                        
                else
                    k=k+1;
                end
                
            else
                k=0;
                
                    if(a(i+1)==0)
                    k=k+1;
                        j(i)=k.*10+1;
                        
                    else
                        k=k+1;
                        
                    end
    
                end
                
    else
        if(a(i)==0 & i==1)
            if (a(i+1)==1)
                k=k+1;
                    j(i)=k.*10;
                    
            else
                k=k+1;
                    
            end
            
       elseif(a(i)==0 & i==g(2))
           if(a(i-1)==0)
              k=k+1;
              j(i)=k.*10;
          else
            k=0;
            k=k+1;
            j(i)=k.*10;
        end
            
        elseif(a(i)==0 & i~=g(2))
             if(a(i-1)==0)
                if(a(i+1)==1)
                    k=k+1;
                        j(i)=10.*k;
                        
                else
                    k=k+1;
                end
            else
                k=0;
                    if(a(i+1)==1)
                    k=k+1;
                        j(i)=k.*10;
                        
                    else
                        k=k+1;
                    end
            end
        end
    end
    
    
end

RLE=j;
z=1;
Result=zeros(1,2);
for i=1:300
    
    if RLE(i)~=0
        Result(z)=RLE(i);
        z=z+1;
    end
    
end

RLE_coded_data=Result
function [Spec,freq]=relativaTapSpec(data,Fs)

params.Fs=Fs;

[Spec,freq]=mtspectrumc(data,params);
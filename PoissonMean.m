function [W] = PoissonMean(Control,Stimulus)

W = (Control-Stimulus)/(sqrt(Control-Stimulus));


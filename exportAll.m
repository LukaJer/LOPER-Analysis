%% Exports Data from multiple Steady State Files to latex tables [Grouped by Measurement]

clear
selpath = uigetdir;
Files=dir(fullfile(selpath,'*.mat'));
ref=zeros(1,4);
for i=1:height(Files)
    full_path=selpath+"/"+string(Files(i).name);
    matObj = matfile(full_path);
    Temp_wall_mean=matObj.Temp_wall_mean;
    Temp_fluid_mean=matObj.Temp_fluid_mean;
    Temp_wall_outside_mean=matObj.Temp_wall_outside_mean;
    HTC_mean=matObj.HTC_mean;
    HTC_sim_mean=matObj.HTC_sim_mean;
    VapourFrac_mean=matObj.VapourFrac_mean;
    Heat_flux_mean=matObj.Heat_flux_mean;

    HTC_dev=(HTC_sim_mean-HTC_mean)./HTC_mean;
    summary=table(linspace(1,10,10)',round(Temp_wall_mean,3),round(Temp_wall_outside_mean,3), round(Temp_fluid_mean,3),...
        round(Heat_flux_mean/1000,3), round(VapourFrac_mean,3),round(HTC_mean/1000,3),round(HTC_sim_mean/1000,3),HTC_dev);
    summary.Properties.VariableNames={'pos','Temp_wall','Temp_wall_outside', 'Temp_fluid', 'Heat_flux','VapourFrac','HTC_meas','HTC_sim','HTC_dev'};
    tex_path= convertStringsToChars(full_path);
    table2latex(summary,tex_path(1:end-4));

    ref(i,1)=matObj.Massflow_mean;
    ref(i,2)=matObj.HeaterPower_mean;
    ref(i,3)=matObj.Pressure_mean;
    ref(i,4)=matObj.EnthalpyIn_mean;
end
names=struct2table(Files).name;
ref=table(names,ref(:,1),ref(:,2),ref(:,3),ref(:,4));
ref.Properties.VariableNames={'File','Massflow','Heater Power','Pressure','Enthalpy in'};

fig = uifigure('Position',[500 500 760 360]);
uit = uitable(fig);
uit.Position = [20 20 720 320];
uit.Data = ref;
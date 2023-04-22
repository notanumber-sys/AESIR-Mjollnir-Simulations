
% Calculate gravity as function of height above surface in meters
function g = gravity_model(h)
    h = max(1, h);
    lat = 60 .* ones(1, length(h));
    lon = 18 .* ones(1, length(h));
    
    g = gravitywgs84(h, lat, lon, 'Exact');
end
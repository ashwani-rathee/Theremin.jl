function zero_crossings(y)
    map(x-> (sign(y[x-1]) != sign(y[x])) ? true : false,2:length(y))
end


function mu_compress(y)
    sign.(y) .* log.(1 .+ mu .* abs.(y)) /  log(1 + mu)

end

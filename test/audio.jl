

@testset "Simple Load" begin
    aud = load_aud("./testaudios/test_440left_880right_0.5amp.flac")
    aud1 = load_aud("./testaudios/test_440left_880right_0.5amp.ogg")
    # aud2 = load_audio("test/testaudios/test_440left_880right_0.5amp.flac")
end


function predicted_output = predict_lstm(lstm_model, X_new)
    % predict_lstm: LSTMモデルを使って軌道を予測
    % 引数:
    %   lstm_model: 学習済みのLSTMモデル
    %   X_new: 新しい入力データ [x, y, z, vx, vy, vz] (予測対象データ)
    %
    % 出力:
    %   predicted_output: LSTMで予測された軌道データ
    
    % LSTMモデルを使って新しいデータに対して予測
    predicted_output = predict(lstm_model, X_new);
end
CREATE TABLE IF NOT EXISTS garage_vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner VARCHAR(50) NOT NULL,
    plate VARCHAR(10) NOT NULL,
    vehicle_model VARCHAR(50) NOT NULL,
    garage_name VARCHAR(50) NOT NULL,
    stored BOOLEAN DEFAULT TRUE
);

INSERT INTO garage_vehicles (owner, plate, vehicle_model, garage_name) VALUES
('player1', 'ABC123', 'adder', 'Garage1'),
('player2', 'DEF456', 'zentorno', 'Garage2');
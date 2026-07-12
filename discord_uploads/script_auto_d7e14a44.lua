
local AutoAttack = {
    -- Variável global para controlar o loop
    enabled = false,
}

function AutoAttack:start()
    if not self.enabled then
        print("Auto-attack started.")
        
        local smokePunchEvent = game:GetService("RemoteServer"):FindFirstChildOfType(self, "Smoke Punch")
        
        -- Se o evento não foi encontrado, parar a execução do script
        if not smokePunchEvent then
            print("Could not find 'Smoke Punch' event.")
            return
        end
        
        self.enabled = true
        
        -- Loop infinito para ativar o evento repetidamente
        repeat
            smokePunchEvent:Fire()
            task.wait(0.1) -- Wait for 0.1 seconds before executing again
        until false
    end
end

function AutoAttack:stop()
    if self.enabled then
        print("Auto-attack stopped.")
        
        smokePunchEvent = nil -- Remove o evento do jogo para evitar erros
        
        self.enabled = false
    end
end

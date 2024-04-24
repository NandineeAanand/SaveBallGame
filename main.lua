local love=require "love" --optional as love is already imported 
local enemy=require"Enemy"
local button=require"Button"

math.randomseed(os.time())
local game={
    diffuculty=1,
    state={
        menu=true,
        paused=false,
        running=false,
        ended=false
    },
    -- runbg=love.graphics.newArrayImage("icon/spacebg.jpg"),
    points=0,
    level={15, 30, 50, 75,100, 150,200},
    high_score=0
}

local fonts={
    small={
        font=love.graphics.newFont(10),
        size=10
    },
    medium={
        font=love.graphics.newFont(16),
        size=16
    },
    large={
        font=love.graphics.newFont(24),
        size=24
    },
    massive={
        font=love.graphics.newFont(80),
        size=80
    }
}

local player={
    -- img=love.graphics.newImage("icon/crsr.png"),
    img=love.graphics.newArrayImage("icon/alien.jpg"),
    rd=15,
    x1=30,
    x2=15,
    y1=30,
    y2=15
}

local buttons={
    menu_state={},
    running_state={},
    paused_state={},
    ended_state={}
}

local function chngGameState(state)
    game.state["menu"]=state=="menu"
    game.state["paused"]=state=="paused"
    game.state["running"]=state=="running"
    game.state["ended"]=state=="ended"
end

local enemies={}

local function startNewGame()
    chngGameState("running")
    game.points=0

    enemies={
        enemy(1)
    }
end

function love.mousepressed(x, y, button, istouch, presses)
    if not game.state["running"] then
        if button==1 then
            if game.state["menu"] then
                for index in pairs(buttons.menu_state) do
                    buttons.menu_state[index]:checkPressed(x, y, player.x2)
                end
            elseif game.state["paused"] then
                for index in pairs(buttons.paused_state) do
                    buttons.paused_state[index]:checkPressed(x, y, player.x2)
                end
            elseif game.state["ended"] then
                for index in pairs(buttons.ended_state) do
                    buttons.ended_state[index]:checkPressed(x, y, player.x2)
                end
            end
        end
    end
    if game.state["running"]  then
        if button==1 then
            buttons.running_state.pause:checkPressed(x, y, player.x2)
        end
    end
end

function love.load()
    love.window.setTitle("Save the Ball!")
    love.mouse.setVisible(false)
    buttons.menu_state.play_game=button("Play Game", startNewGame, nil, 110, 30)
    buttons.menu_state.settings=button("Settings", nil, nil, 110, 30)
    buttons.menu_state.exit_game=button("Exit Game", love.event.quit, nil, 110, 30)
    buttons.paused_state.resume=button("Resume", chngGameState, "running", 100, 40)
    buttons.running_state.pause=button("||", chngGameState,"paused", 25, 25)
    buttons.paused_state.menu=button("Menu", chngGameState,"menu", 100, 40)
    buttons.paused_state.exit_game=button("Quit", love.event.quit, nil, 100, 40)
    buttons.ended_state.replay_game=button("Replay", startNewGame, nil, 100, 40)
    buttons.ended_state.menu=button("Menu", chngGameState,"menu", 100, 40)
    buttons.ended_state.exit_game=button("Quit", love.event.quit, nil, 100, 40)
end

function love.update(dt)
    player.x1,player.y1=love.mouse.getPosition()
    -- player.x2,player.y2=player.x1+5,player.y1+5
    if game.state["running"] then
        for i=1,#enemies do
            if not enemies[i]:chckTouched(player.x1,player.y1,player.rd) then
                enemies[i]: move(player.x1, player.y1)
                for i=1,#game.level do
                    if math.floor(game.points)==game.level[i] then
                        table.insert(enemies,1, enemy(game.diffuculty*(i+1)))
                        game.points=game.points+1
                    end
                end
            else
                chngGameState("ended")
            end
        end
        love.graphics.setFont(fonts.small.font)
        game.points=game.points+dt
    end
    
    
end

function love.draw()
    love.graphics.setFont(fonts.small.font)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("FPS: "..love.timer.getFPS(),fonts.medium.font,10,love.graphics.getHeight()-20,love.graphics.getWidth() )
    -- love.graphics.scale(0.2)
    -- love.graphics.draw(player.img,player.x,player.y) 
    if game.state["running"] then
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(fonts.medium.font)
        buttons.running_state.pause:draw(love.graphics.getWidth()-30,love.graphics.getHeight()-30,0,0)
        love.graphics.printf("High Score:"..math.floor(game.high_score), fonts.medium.font,10,love.graphics.getHeight()-25, love.graphics.getWidth(),"center")
        love.graphics.printf(math.floor(game.points), fonts.large.font,0, 20, love.graphics.getWidth(),"center")
        for i=1,#enemies do
            enemies[i]:draw()
        end
        -- love.graphics.scale(3)
        -- love.graphics.draw(game.runbg,0,0)
        love.graphics.setColor(1,0,0.627)
        love.graphics.circle("fill",player.x1,player.y1,player.rd)
        -- love.graphics.scale(0.1)
        -- love.graphics.draw(player.img,player.x1,player.y1)
    elseif game.state["menu"] then
        love.graphics.setFont(fonts.medium.font)
        buttons.menu_state.play_game:draw(10, 20 ,10 ,10)
        buttons.menu_state.settings:draw(10, 70 ,10 ,10)
        buttons.menu_state.exit_game:draw(10, 120 ,10 ,10)
    elseif game.state["paused"] then
        love.graphics.setFont(fonts.medium.font)
        buttons.paused_state.resume:draw(love.graphics.getWidth()/2.25,love.graphics.getHeight()/2.0 ,10 ,10 )
        buttons.paused_state.menu:draw(love.graphics.getWidth()/2.25,love.graphics.getHeight()/1.7 ,10 ,10)
        buttons.paused_state.exit_game:draw(love.graphics.getWidth()/2.25,love.graphics.getHeight()/1.4 ,10 ,10)
    elseif game.state["ended"] then
        love.graphics.setFont(fonts.large.font)
        if game.high_score<game.points then
            love.graphics.printf("New High Score Achieved!!!", fonts.large.font,0, 30, love.graphics.getWidth(),"center")
            game.high_score=game.points
        end
        love.graphics.printf("Game Over :(", fonts.massive.font,0, 50, love.graphics.getWidth(),"center")
        love.graphics.printf("High Score:"..math.floor(game.high_score), fonts.large.font,10,love.graphics.getHeight()/2.1, love.graphics.getWidth(),"center")
        buttons.ended_state.replay_game:draw(love.graphics.getWidth()/2.25,love.graphics.getHeight()/1.8 ,10 ,10)
        buttons.ended_state.menu:draw(love.graphics.getWidth()/2.25,love.graphics.getHeight()/1.53 ,10 ,10)
        buttons.ended_state.exit_game:draw(love.graphics.getWidth()/2.25, love.graphics.getHeight()/1.33 ,10 ,10)
        love.graphics.printf(math.floor(game.points),fonts.massive.font,0,love.graphics.getHeight()/2-2*fonts.massive.size,love.graphics.getWidth(),"center")
    end
    if not game.state["running"] then
        love.graphics.setColor(23/255,252/255,3/255)
        -- love.graphics.circle("fill",player.x1,player.y1,player.rd/2)
        love.graphics.rectangle("fill",player.x1,player.y1,player.x2,player.y2)
        
    end

end

local love= require"love"
function Enemy(lvl)
    local dice=math.random(1,4)
    local  _x,_y
    local _rd=math.random(5,50)
    if dice==1 then
        _x=math.random(_rd,love.graphics.getWidth())
        _y=-_rd*4
    elseif dice==2 then
        _x=-_rd*4
        _y=math.random(_rd,love.graphics.getHeight())
    elseif dice==3 then 
        _x=math.random(_rd,love.graphics.getWidth())
        _y=love.graphics.getHeight()+_rd*4
    else
        _x=love.graphics.getWidth()+_rd*4
        _y=math.random(_rd,love.graphics.getHeight())
    end
    return{
        level=lvl or 1,
        radius=_rd,
        x=_x,
        y=_y,
        chckTouched=function(self,player_x,player_y,cursor_radius)
            return math.sqrt((self.x-player_x)^2+(self.y-player_y)^2)<=cursor_radius*2
        end,
        move=function (self, player_x, player_y)
            player_x=player_x or 0
            player_y=player_y or 0
            if player_x-self.x>0 then
                self.x=self.x+self.level
            elseif player_x-self.x<0 then
                self.x=self.x-self.level
            end
            if player_y-self.y>0 then
                self.y=self.y+self.level
            elseif player_y-self.y<0 then
                self.y=self.y-self.level
            end
        end,
        draw =function (self)
            love.graphics.setColor(0.7,1,1)
            love.graphics.circle("fill",self.x,self.y,self.radius)
            love.graphics.setColor(1,1,1)

        end
    }
end

return Enemy
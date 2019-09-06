require 'src/Dependencies'

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
   love.window.setTitle('midterm project')
   
   
   gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
    } love.graphics.setFont(gFonts['small'])
  
  gTextures = {
        ['background'] = love.graphics.newImage('graphics/space_ft.png')
    }
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, arenaWidth, arenaHeight, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })
  
  gSounds = {
        ['music'] = love.audio.newSource('sounds/tfit.wav'),
        ['hit'] = love.audio.newSource('sounds/wall_hit.wav')
    }


    shipRadius = 30

    bulletRadius = 5

    asteroidStages = {
        {
            speed = 120,
            radius = 15
        },
        {
            speed = 70,
            radius = 30
        },
        {
            speed = 50,
            radius = 50
        },
        {
            speed = 20,
            radius = 80
        }
    }
    
  function love.resize(w,h)
    push: resize(w,h)
    end

    function reset()
        shipX = arenaWidth / 2
        shipY = arenaHeight / 2
        shipAngle = 0
        shipSpeedX = 0
        shipSpeedY = 0

        bullets = {}
        bulletTimer = 0

        asteroids = {
            {
                x = 100,
                y = 100,
            },
            {
                x = arenaWidth - 100,
                y = 100,
            },
            {
                x = arenaWidth / 2,
                y = arenaHeight - 100,
            }
        }

        for asteroidIndex, asteroid in ipairs(asteroids) do
            asteroid.angle = love.math.random() * (2 * math.pi)
            asteroid.stage = #asteroidStages
        end
    end

    reset()
end

function love.keypressed(key)
  if key == 'escape' then 
    love.event.quit()
  end
  end

function love.update(dt)
  
   gSounds['music']:play()
    local turnSpeed = 10

    if love.keyboard.isDown('right') then
         shipAngle = (shipAngle + turnSpeed * dt) % (2 * math.pi)
    end

    if love.keyboard.isDown('left') then
        shipAngle = (shipAngle - turnSpeed * dt) % (2 * math.pi)
    end

    if love.keyboard.isDown('up') then
        local shipSpeed = 100
        shipSpeedX = shipSpeedX + math.cos(shipAngle) * shipSpeed * dt
        shipSpeedY = shipSpeedY + math.sin(shipAngle) * shipSpeed * dt
    end

    shipX = (shipX + shipSpeedX * dt) % arenaWidth
    shipY = (shipY + shipSpeedY * dt) % arenaHeight

    local function areCirclesIntersecting(aX, aY, aRadius, bX, bY, bRadius)
        return (aX - bX)^2 + (aY - bY)^2 <= (aRadius + bRadius)^2
    end

    for bulletIndex = #bullets, 1, -1 do
        local bullet = bullets[bulletIndex]

        bullet.timeLeft = bullet.timeLeft - dt
        if bullet.timeLeft <= 0 then
            table.remove(bullets, bulletIndex)
        else
            local bulletSpeed = 500
            bullet.x = (bullet.x + math.cos(bullet.angle) * bulletSpeed * dt) % arenaWidth
            bullet.y = (bullet.y + math.sin(bullet.angle) * bulletSpeed * dt) % arenaHeight
        end

        for asteroidIndex = #asteroids, 1, -1 do
            local asteroid = asteroids[asteroidIndex]

            if areCirclesIntersecting(bullet.x, bullet.y, bulletRadius, asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius) then
                table.remove(bullets, bulletIndex)

                if asteroid.stage > 1 then
                    local angle1 = love.math.random() * (2 * math.pi)
                    local angle2 = (angle1 - math.pi) % (2 * math.pi)

                    table.insert(asteroids, {
                        x = asteroid.x,
                        y = asteroid.y,
                        angle = angle1,
                        stage = asteroid.stage - 1,
                    })
                    table.insert(asteroids, {
                        x = asteroid.x,
                        y = asteroid.y,
                        angle = angle2,
                        stage = asteroid.stage - 1,
                    })
                end

                table.remove(asteroids, asteroidIndex)
                break
            end
        end
    end

    bulletTimer = bulletTimer + dt

    if love.keyboard.isDown('s') then
      gSounds['hit']:play()
        if bulletTimer >= 0.5 then
            bulletTimer = 0

            table.insert(bullets, {
                x = shipX + math.cos(shipAngle) * shipRadius,
                y = shipY + math.sin(shipAngle) * shipRadius,
                angle = shipAngle,
                timeLeft = 4,
            })
        end
    end

    for asteroidIndex, asteroid in ipairs(asteroids) do
        asteroid.x = (asteroid.x + math.cos(asteroid.angle) * asteroidStages[asteroid.stage].speed * dt) % arenaWidth
        asteroid.y = (asteroid.y + math.sin(asteroid.angle) * asteroidStages[asteroid.stage].speed * dt) % arenaHeight

        if areCirclesIntersecting(shipX, shipY, shipRadius, asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius) then
            reset()
            break
        end
    end

    if #asteroids == 0 then
        reset()
    end
end


function love.draw()
  push: start()
    for y = -1, 1 do
        for x = -1, 1 do
            love.graphics.origin()
            love.graphics.translate(x * arenaWidth, y * arenaHeight)
    
            love.graphics.setColor(0, 0, 255)
            love.graphics.circle('fill', shipX, shipY, shipRadius)

            love.graphics.setColor(0, 255, 255)
            local shipCircleDistance = 20
            love.graphics.circle(
                'fill',
                shipX + math.cos(shipAngle) * shipCircleDistance,
                shipY + math.sin(shipAngle) * shipCircleDistance,
                5
            )

            for bulletIndex, bullet in ipairs(bullets) do
                love.graphics.setColor(0, 255, 0)
                love.graphics.circle('fill', bullet.x, bullet.y, bulletRadius)
            end

            for asteroidIndex, asteroid in ipairs(asteroids) do
                love.graphics.setColor(255, 255, 0)
                love.graphics.circle('fill', asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius)
            end
        end
    end
    push:finish()
end
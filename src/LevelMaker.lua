--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)
    local lockset = math.random(4)

    -- flag for ensuring that only one locked brick is spawned
    local lockSpawned = false

    -- flag for ensuring that only one key is spawned
    local keySpawned = false

    -- stores a reference to our locked block that will be in scope for the key
    local lockedBlock = false

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a locked block, increasing as we progress through level gen
            if math.random(math.max(width - x - 9, 1)) == 1 and lockSpawned == false then

                -- set flag to true so that we only have one locked brick per level
                lockSpawned = true

                -- maintain reference to block so that we can nil it
                lockedBlock = GameObject {
                    texture = 'keys-locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,

                    frame = lockset + 4,
                    collidable = true,
                    hit = false,
                    solid = true,
                    consumable = false,

                    -- don't do anything special on a collision
                    onCollide = function(obj)
                        return
                    end,

                    -- the key makes the lock consumable, onConsume first remove it
                    onConsume = function(player, object)
                        lockedBlock = nil

                        -- calculate a suitable X coord for the flag
                        local flagX = width
                        local columnNotFree = true

                        while columnNotFree do
                            flagX = flagX - 1
                            -- if tiles at y = 6 & 7 are the same, it is either a chasm or pillar and not free
                            columnNotFree = tiles[7][flagX].id == tiles[6][flagX].id
                        end

                        -- create a flagpole
                        table.insert(objects,
                            GameObject {
                                texture = 'flags',
                                frame = math.random(6),
                                x = ((flagX - 1) * TILE_SIZE),
                                y = 3 * TILE_SIZE,
                                width = 16,
                                height = 48,
                                collidable = false,
                                consumable = false,
                                solid = false
                            }
                        )

                        -- create the flag
                        table.insert(objects,
                            GameObject {
                                texture = 'flags',
                                frame = 7 + (3 * math.random(0, 3)),
                                x = (flagX) * TILE_SIZE - 8,
                                y = 3 * TILE_SIZE + 6,
                                width = 16,
                                height = 16,
                                collidable = false,
                                consumable = true,
                                solid = false,

                                onConsume = function(obj)
                                    gStateMachine:change('play')
                                end
                            }
                        )
                    end
                }
                
                table.insert(objects, lockedBlock)

            -- chance to spawn a key, increasing as we progress through level gen
            elseif math.random(math.max(width - x - 9, 1)) == 1 and keySpawned == false and lockSpawned == true then

                -- set flag to true so that we only spawn one key per level
                keySpawned = true

                -- create the key object, insert it into the objects list
                table.insert(objects,
                    GameObject {
                        texture = 'keys-locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        frame = lockset,
                        collidable = true,
                        consumable = true,
                        solid = false,

                        onConsume = function(player, object)
                            lockedBlock['consumable'] = true
                            lockedBlock['solid'] = false
                        end
                    }
                )

            -- chance to spawn a block
            elseif math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end
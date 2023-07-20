class 'LevelsSystem'

function LevelsSystem:__init()
	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_levels (steamid VARCHAR UNIQUE, level INTEGER)" )

	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "SaveLevels", self, self.SaveLevels )
end

function LevelsSystem:PlayerJoin( args )
	local qry = SQL:Query( "select level from players_levels where steamid = (?)" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local result = qry:Execute()

	if #result > 0 then
		args.player:SetNetworkValue( "PlayerLevel", tonumber(result[1].level) )
	else
		args.player:SetNetworkValue( "PlayerLevel", 1 )
    end
end

function LevelsSystem:SaveLevels()
	for player in Server:GetPlayers() do
		if player:GetValue( "PlayerLevel" ) and player:GetValue( "PlayerLevel" ) ~= 1 then
			local cmd = SQL:Command( "insert or replace into players_levels (steamid, level) values (?, ?)" )
			cmd:Bind( 1, player:GetSteamId().id )
			cmd:Bind( 2, player:GetValue( "PlayerLevel" ) )
			cmd:Execute()
		end
	end
end

levelssystem = LevelsSystem()
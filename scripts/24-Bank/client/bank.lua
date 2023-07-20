class 'Bank'

function Bank:__init()
	self.actions = {
		[3] = true,
		[4] = true,
		[5] = true,
		[6] = true,
		[11] = true,
		[12] = true,
		[13] = true,
		[14] = true,
		[17] = true,
		[18] = true,
		[105] = true,
		[137] = true,
		[138] = true,
		[139] = true,
		[51] = true,
		[52] = true,
		[16] = true
	}

	self.MenuActive = false

	self.rows = {}
	self:CreateSendMoneyWindow()

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "ENG" then
		self:Lang()
	else
		self.money = "Баланс: $"
		self.nomoney_txt = "У вас нет столько денег!"
		self.playernotselected_txt = "Игрок не выбран!"
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "OpenSendMoneyMenu", self, self.OpenSendMoneyMenu )
	Events:Subscribe( "CloseSendMoney", self, self.CloseSendMoneyMenu )
	Events:Subscribe( "LocalPlayerMoneyChange", self, self.MoneyChange )

	self.timer = Timer()
	self.message_size = TextSize.VeryLarge
	self.submessage_size = 25
end

function Bank:Lang()
	if self.plist.window then
		self.plist.window:SetTitle( "▧ Send money" )
		self.plist.balance:SetText( "Money: " .. formatNumber( LocalPlayer:GetMoney() ) )
		self.plist.text:SetText( "Specify the amount to be sent:" )
		self.plist.okay:SetText( "Send" )
		self.plist.filter:SetToolTip( "Search" )
	end

	self.money = "Money: $"
	self.nomoney_txt = "You don't have that much money!"
	self.playernotselected_txt = "Player is not selected!"
end

function Bank:GetActive()
	return self.MenuActive
end

function Bank:SetActive( state )
	self.MenuActive = state
	self.plist.window:SetVisible( self.MenuActive )
	Mouse:SetVisible( self.MenuActive )

	if self.MenuActive then
		if not self.LocalPlayerInputEvent then
			self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
		end

		if not self.WindowRenderEvent then
			self.WindowRenderEvent = Events:Subscribe( "Render", self, self.WindowRender )
		end

		if LocalPlayer:GetValue( "SystemFonts" ) then
			if self.plist.balance then
				self.plist.balance:SetFont( AssetLocation.SystemFont, "Impact" )
			end
		end
	else
		if self.LocalPlayerInputEvent then
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
		end

		if self.WindowRenderEvent then
			Events:Unsubscribe( self.WindowRenderEvent )
			self.WindowRenderEvent = nil
		end
	end
end

function Bank:OpenSendMoneyMenu()
	self:SetActive( not self:GetActive() )
end

function Bank:CloseSendMoneyMenu()
	if self:GetActive() then
		self:SetActive( false )
	end
end

function Bank:CreateSendMoneyWindow()
	self.plist = {}

	self.plist.window = Window.Create()
    self.plist.window:SetSizeRel( Vector2( 0.25, 0.42 ) )
    self.plist.window:SetMinimumSize( Vector2( 370, 240 ) )
    self.plist.window:SetPositionRel( Vector2( 0.85, 0.5 ) - self.plist.window:GetSizeRel()/2 )
	self.plist.window:SetVisible( self.MenuActive )
	self.plist.window:SetTitle( "▧ Отправить деньги" )
	self.plist.window:Subscribe( "WindowClosed", self, self.WindowClosed )

	self.plist.balance = Label.Create( self.plist.window )
	self.plist.balance:SetDock( GwenPosition.Top )
	self.plist.balance:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
	self.plist.balance:SetTextSize( 20 )
	self.plist.balance:SetText( "Баланс: " .. formatNumber( LocalPlayer:GetMoney() ) )
	self.plist.balance:SetTextColor( Color( 251, 184, 41 ) )
	self.plist.balance:SizeToContents()

	self.plist.text = Label.Create( self.plist.window )
	self.plist.text:SetDock( GwenPosition.Top )
	self.plist.text:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
	self.plist.text:SetText( "Укажите отправляемую сумму:" )
	self.plist.text:SizeToContents()
	
	self.plist.moneytosend = TextBoxNumeric.Create( self.plist.window )
	self.plist.moneytosend:SetDock( GwenPosition.Top )
	self.plist.moneytosend:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
	self.plist.moneytosend:SetHeight( 20 )
	self.plist.moneytosend:Subscribe( "Focus", self, self.Focus )
	self.plist.moneytosend:Subscribe( "Blur", self, self.Blur )
	self.plist.moneytosend:Subscribe( "EscPressed", self, self.EscPressed )

	self.plist.playerList = SortedList.Create( self.plist.window )
	self.plist.playerList:SetMargin( Vector2.Zero, Vector2( 0, 4 ) )
	self.plist.playerList:SetBackgroundVisible( false )
	self.plist.playerList:AddColumn( "Игрок" )
	self.plist.playerList:SetButtonsVisible( true )
	self.plist.playerList:SetDock( GwenPosition.Fill )

	self.plist.okay = Button.Create( self.plist.window )
	self.plist.okay:SetDock( GwenPosition.Bottom )
	self.plist.okay:SetHeight( 35 )
	self.plist.okay:SetText( "Отправить" )
	self.plist.okay:Subscribe( "Press", self, self.SendToPlayer )

	self.plist.filter = TextBox.Create( self.plist.window )
	self.plist.filter:SetDock( GwenPosition.Bottom )
	self.plist.filter:SetMargin( Vector2( 0, 5 ), Vector2( 0, 5 ) )
	self.plist.filter:SetHeight( 25 )
	self.plist.filter:SetToolTip( "Поиск" )
	self.plist.filter:Subscribe( "TextChanged", self, self.TextChanged )
	self.plist.filter:Subscribe( "Focus", self, self.Focus )
	self.plist.filter:Subscribe( "Blur", self, self.Blur )
	self.plist.filter:Subscribe( "EscPressed", self, self.EscPressed )

	for player in Client:GetPlayers() do
		self:AddPlayer( player )
	end
	--self:AddPlayer(LocalPlayer)
end

function Bank:WindowClosed( args )
	self:SetActive( false )
end

function Bank:PlayerJoin( args )
	local player = args.player

	self:AddPlayer( player )
end

function Bank:PlayerQuit( args )
	local player = args.player
	local playerId = tostring(player:GetSteamId().id)

	if self.rows[playerId] == nil then return end

	self.plist.playerList:RemoveItem(self.rows[playerId])
	self.rows[playerId] = nil
end

function Bank:AddPlayer( player )
	local playerSteamId = tostring(player:GetSteamId().id)
	local playerName = player:GetName()
	local playerColor = player:GetColor()
	local playerId = tostring( player:GetId() )

	local item = self.plist.playerList:AddItem( playerSteamId )

	item:SetCellText( 0, playerName )
	item:SetTextColor( playerColor )
	item:SetName( playerId )

	self.rows[playerSteamId] = item
end

function Bank:SendToPlayer()
	if self.plist.playerList:GetSelectedRow() then
		Network:Send( "SendMoney", { selectedplayer = tonumber( self.plist.playerList:GetSelectedRow():GetName() ), money = self.plist.moneytosend:GetValue() } )
	else
		Events:Fire( "CastCenterText", { text = self.playernotselected_txt, time = 2, color = Color( 255, 0, 0 ) } )
	end
	self:SetActive( false )
end

function Bank:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
		self:SetActive( false )
	end

	if self.actions[args.input] then
		return false
	end
end

function Bank:WindowRender()
	local is_visible = Game:GetState() == GUIState.Game

	if self.plist.window:GetVisible() ~= is_visible then
		self.plist.window:SetVisible( is_visible )
	end

    Mouse:SetVisible( is_visible )
end

--  Player search
function Bank:TextChanged()
	local filter = self.plist.filter:GetText()

	if filter:len() > 0 then
		for k, v in pairs( self.rows ) do
			v:SetVisible( self:PlayerNameContains(v:GetCellText( 0 ), filter) )
		end
	else
		for k, v in pairs( self.rows ) do
			v:SetVisible( true )
		end
	end
end

function Bank:PlayerNameContains( name, filter )
	return string.match(name:lower(), filter:lower()) ~= nil
end

function Bank:Focus()
	Input:SetEnabled( false )
end

function Bank:Blur()
	Input:SetEnabled( true )
end

function Bank:EscPressed()
	self:Blur()
	self:SetActive( false )
end

function Bank:Render()
	if self.message_timer and self.message then
		local alpha = 4

		if self.message_timer:GetSeconds() > 4 and self.message_timer:GetSeconds() < 5 then
			alpha = 4 - (self.message_timer:GetSeconds() - 1)
		elseif self.message_timer:GetSeconds() >= 5 then
			self.message_timer = nil
			self.message = nil
			self.submessage = nil
			if self.RenderEvent then
				Events:Unsubscribe( self.RenderEvent )
				self.RenderEvent = nil
			end
			return
		end

		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end

		local pos_2d = Vector2( (Render.Size.x / 2) - (Render:GetTextSize( self.message .. " | " .. self.submessage, self.submessage_size ).x / 2), 100 )
		local col = Copy( self.colour )
		local colS = Copy( Color( 25, 25, 25, 150 ) )
		col.a = col.a * alpha
		colS.a = colS.a * alpha
	
		Render:DrawText( pos_2d + Vector2.One, self.message .. " | " .. self.submessage, colS, self.submessage_size )
		Render:DrawText( pos_2d, self.message .. " | " .. self.submessage, col, self.submessage_size )
	end
end

function Bank:MoneyChange( args )
	if args.new_money == nil then
        args.new_money = LocalPlayer:GetMoney()
    end

    if LocalPlayer:GetValue( "Lang" ) then
		if LocalPlayer:GetValue( "Lang" ) == "РУС" then
			self.plist.balance:SetText( "Баланс: $" .. formatNumber( args.new_money ) )
		else
			self.plist.balance:SetText( "Money: $" .. formatNumber( args.new_money ) )
		end
    end

	if Game:GetState() ~= GUIState.Game then return end
	if not self.RenderEvent then
		self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
	end
	local diff = args.new_money - args.old_money

	-- Very unlikely you'll be able to get any money in the first 2 seconds!
	if diff > 0 and self.timer:GetSeconds() > 2 then
		self.message_timer = Timer()
		self.message = "+ $" .. formatNumber( diff )
		self.submessage = self.money .. formatNumber( args.new_money )
		self.colour = Color( 251, 184, 41 )
	end

	local diff = args.old_money - args.new_money

	if diff > 0 and self.timer:GetSeconds() > 2 then
		self.message_timer = Timer()
		self.message = "- $" .. formatNumber( diff )
		self.submessage = self.money .. formatNumber( args.new_money )
		self.colour = Color.OrangeRed
	end
end

function formatNumber( amount )
	local formatted = tostring( amount );
	while true do  
		formatted, k = string.gsub( formatted, "^(-?%d+)(%d%d%d)", '%1.%2' );
		if (k==0) then
			break
		end
	end
	return formatted;
end

bank = Bank()
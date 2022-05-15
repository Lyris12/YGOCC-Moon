--[[
Each time a card destroys another card, the Kill Count of the card that executed the destruction is raised by the amount of destroyed cards
kf = Killer Filter (filter for the card that destroyed)
df = Destroyed Filter (filter for the card that got destroyed)
reset = You can set a reset for the Kill Count. By default, a card's Kill Count is resetted when it leaves its current location or becomes face-down while on the field
id = The id that will be used for the flag. By default, the original ID of the card is set as the id
]]
function aux.EnableKillCounter(c,kf,df,reset,id)
	if not reset then reset=0 end
	if not id then id=c:GetOriginalCode() end
	local g1=Effect.CreateEffect(c)
	g1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	g1:SetCode(EVENT_DESTROYED)
	g1:SetOperation(aux.KillCounterOperation(kf,df,reset,id))
	Duel.RegisterEffect(g1,0)
	return g1
end
function aux.KillCounterOperation(kf,df,reset,id)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local g=eg:Filter(df,nil,e,tp,eg,ep,ev,re,r,rp)
				for tc in aux.Next(g) do
					local rc=tc:GetReasonCard()
					if rc and (not kf or kf(rc,e,tp,eg,ep,ev,re,r,rp)) then
						rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+reset,0,1,nil)
					end
				end
			end
end
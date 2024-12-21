--[[
Special Rule
Scripted by: XGlitchy30
]]

TOKEN_GLITCHY_HELPER					= 1232
function Card.IsNonPlayableCard(c)
	return c:HasFlagEffect(TOKEN_GLITCHY_HELPER)
end

local _IsExistingMatchingCard, _IsExistingTarget, _GetMatchingGroup, _GetMatchingGroupCount, _SelectMatchingCard, _SelectTarget, _GetFieldGroup, _GetFieldGroupCount
=
Duel.IsExistingMatchingCard, Duel.IsExistingTarget, Duel.GetMatchingGroup, Duel.GetMatchingGroupCount, Duel.SelectMatchingCard, Duel.SelectTarget, Duel.GetFieldGroup, Duel.GetFieldGroupCount

Duel.IsExistingMatchingCard = function(f,pov,l1,l2,min,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _IsExistingMatchingCard(f,pov,l1,l2,min,g,...)
	else
		return _IsExistingMatchingCard(f,pov,l1,l2,min,exc,...)
	end
end
Duel.IsExistingTarget = function(f,pov,l1,l2,min,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _IsExistingTarget(f,pov,l1,l2,min,g,...)
	else
		return _IsExistingTarget(f,pov,l1,l2,min,exc,...)
	end
end
Duel.GetMatchingGroup = function(f,pov,l1,l2,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _GetMatchingGroup(f,pov,l1,l2,g,...)
	else
		return _GetMatchingGroup(f,pov,l1,l2,exc,...)
	end
end
Duel.GetMatchingGroupCount = function(f,pov,l1,l2,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _GetMatchingGroupCount(f,pov,l1,l2,g,...)
	else
		return _GetMatchingGroupCount(f,pov,l1,l2,exc,...)
	end
end
Duel.SelectMatchingCard = function(p,f,pov,l1,l2,min,max,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _SelectMatchingCard(p,f,pov,l1,l2,min,max,g,...)
	else
		return _SelectMatchingCard(p,f,pov,l1,l2,min,max,exc,...)
	end
end
Duel.SelectTarget = function(p,f,pov,l1,l2,min,max,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _SelectTarget(p,f,pov,l1,l2,min,max,g,...)
	else
		return _SelectTarget(p,f,pov,l1,l2,min,max,exc,...)
	end
end
Duel.GetFieldGroup = function(pov,l1,l2)
	local g0=_GetFieldGroup(pov,l1,l2)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		g0:Sub(g)
	end
	return g0
end
Duel.GetFieldGroupCount = function(pov,l1,l2)
	local ct0=_GetFieldGroupCount(pov,l1,l2)
	local ct=_GetMatchingGroupCount(Card.IsNonPlayableCard,pov,l1,l2,nil)
	return math.max(ct0-ct,0)
end

local s,id=GetID()
function s.initial_effect(c)
	if not s.global_check then
		s.global_check=true
		s.planeGroup=Group.CreateGroup()
		s.planeGroup:KeepAlive()
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCountLimit(1,id|EFFECT_COUNT_CODE_DUEL)
		e1:SetOperation(s.regop)
		Duel.RegisterEffect(e1,0)
	end
end

local flag=0
local planes={87430998,50913601,86318356,22702055,23424603,59197169}

local FLAG_CARD_FROM_OUTSIDE_DECKS = 0x1

local isCardFromOutsideDecks = flag&FLAG_CARD_FROM_OUTSIDE_DECKS>0

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Debug.Message("Enabling Special Rules...")
	if isCardFromOutsideDecks then
		Debug.Message('These starting hands will be reshuffled since a card must be added from outside the Decks.')
		Debug.Message('New hands will be generated so the added card has a chance to appear in them.')
		local hands=Duel.GetHand(0)+Duel.GetHand(1)
		Duel.SendtoDeck(hands,nil,SEQ_DECKSHUFFLE,REASON_RULE)
	end
	local compensate_draw = {0,0}
	Duel.DisableShuffleCheck(true)
	for p=0,1 do
		local g=Duel.Group(Card.IsOriginalCode,p,LOCATION_HAND|LOCATION_DECK,0,nil,id)
		if #g>0 then
			compensate_draw[p+1]=g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
			Duel.Exile(g,REASON_RULE)
		end
		if Duel.GetDeckCount(p)+Duel.GetHandCount(p)<40 then
			Debug.Message('Player '..p..' has less than 40 cards in their Main Deck. The Duel cannot proceed.')
			Duel.Win(1-p,WIN_REASON_EXODIA)
			return
		end
	end
	Duel.DisableShuffleCheck(false)
	
	--[[The effect of Convulsion of Nature and Ceremonial Bell remains active for the entire Duel]]
	-- Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	-- local e1=Effect.GlobalEffect()
	-- e1:SetType(EFFECT_TYPE_FIELD)
	-- e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	-- e1:SetCode(EFFECT_REVERSE_DECK)
	-- e1:SetTargetRange(1,1)
	-- Duel.RegisterEffect(e1,0)
	-- local e2=Effect.GlobalEffect()
	-- e2:SetType(EFFECT_TYPE_FIELD)
	-- e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- e2:SetCode(EFFECT_PUBLIC)
	-- e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	-- Duel.RegisterEffect(e2,0)
	
	--[[At the start of the Duel, spawn 1 copy "Gem-Knight Garnet" in each player's Deck.]]
	-- for p=0,1 do
		-- local garnet=Duel.CreateToken(p,91731841)
		-- Duel.SendtoDeck(garnet,nil,SEQ_DECKSHUFFLE,REASON_RULE)
		-- Duel.ConfirmCards(1-p,garnet)
	-- end
	
	for _,code in ipairs(planes) do
		local tk=Duel.CreateToken(0,code)
		s.planeGroup:AddCard(tk)
	end
	
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:OPT()
	e1:SetOperation(s.ddrawop)
	Duel.RegisterEffect(e1,0)
	if Duel.GetTurnCount()==1 then
		Duel.RaiseEvent(e:GetOwner(),EVENT_PREDRAW,e,0,0,0,0)
	end
	
	for p=0,1 do
		local ct=isCardFromOutsideDecks and 5 or compensate_draw[p+1]
		if ct>0 then
			Duel.Draw(p,ct,REASON_RULE)
		end
	end
end

function s.ddrawop(e,tp,eg,ep,ev,re,r,rp)
	local n=Duel.GetRandomNumber(#planes)
	local code=planes[n]
	Duel.Hint(HINT_CARD,0,code)
	local exg=s.planeGroup:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	if #exg>0 then
		Duel.Exile(exg,REASON_RULE)
	end
	local fg=s.planeGroup:Filter(Card.IsOriginalCode,nil,code)
	local fs=fg:GetFirst()
	Duel.Remove(fs,POS_FACEUP,REASON_RULE)
	if not fs:HasFlagEffect(TOKEN_GLITCHY_HELPER) then
		fs:RegisterFlagEffect(TOKEN_GLITCHY_HELPER,0,0,1)
	end
	local eset=fs:GetEffects()
	for _,ce in ipairs(eset) do
		if ce:GetType()==EFFECT_TYPE_FIELD then
			local ge=ce:Clone()
			ge:SetProperty(ce:GetProperty()|EFFECT_FLAG_IGNORE_IMMUNE)
			ge:SetRange(0)
			ge:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(ge,0)
		end
	end
	local e1=Effect.CreateEffect(fs)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:OPT()
	e1:SetOperation(aux.TRUE)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,0)
	local e2=e1:Clone()
	Duel.RegisterEffect(e2,1)
	
	local p=Duel.GetTurnPlayer()
	if not Duel.PlayerHasFlagEffect(p,id) and aux.IsPlayerCanNormalDraw(p) and Duel.GetLP(p)<=2000 and Duel.SelectYesNo(p,aux.Stringid(id,0)) then
		aux.GiveUpNormalDraw(e,p)
		local g=Duel.GetDeck(p):Select(p,1,1,nil)
		if #g>0 then
			Duel.Hint(HINT_CARD,0,856784)
			Duel.SendtoHand(g,nil,REASON_RULE)
			Duel.RegisterFlagEffect(p,id,0,0,1)
		end
	end
end